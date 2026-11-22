import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EventsGateway } from '../events/events.gateway';
import { UpdateAvailabilityDto } from './dto/update-availability.dto';
import { UpdateLocationDto } from './dto/update-location.dto';
import { UpdateMechanicProfileDto } from './dto/update-profile.dto';
import { NearbyMechanicsQueryDto } from './dto/nearby-mechanics-query.dto';
import {
  calculateHaversineDistance,
  fuzzCoordinates,
  estimateArrivalTimeMinutes,
} from '../../common/utils/haversine';
import {
  AvailabilityStatus,
  VerificationStatus,
  ServiceRequestStatus,
} from '@prisma/client';

@Injectable()
export class MechanicsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  /**
   * Retrieves full operational profile for authenticated mechanic
   */
  async getProfile(userId: string) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            avatarUrl: true,
          },
        },
        currentLocation: true,
        services: true,
      },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile was not found for this user account');
    }

    return profile;
  }

  /**
   * Updates mechanic profile parameters (workshop name, service radius, experience, certifications)
   * Enforces security rule: altering tradeLicenseNumber resets verificationStatus to PENDING and logs audit trail
   */
  async updateProfile(userId: string, dto: UpdateMechanicProfileDto) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile was not found');
    }

    let verificationStatus = profile.verificationStatus;
    let verificationNotes = profile.verificationNotes;

    // Security workflow: If trade license is updated, reset verification and audit log
    if (
      dto.tradeLicenseNumber !== undefined &&
      dto.tradeLicenseNumber.trim() !== (profile.tradeLicenseNumber || '')
    ) {
      verificationStatus = VerificationStatus.PENDING;
      verificationNotes = `Trade license modified to "${dto.tradeLicenseNumber.trim()}". Pending administrative credential audit.`;

      await this.prisma.auditLog.create({
        data: {
          userId,
          action: 'MECHANIC_LICENSE_UPDATED_PENDING_AUDIT',
          entityName: 'MechanicProfile',
          entityId: profile.id,
          details: {
            previousLicense: profile.tradeLicenseNumber,
            newLicense: dto.tradeLicenseNumber.trim(),
            previousStatus: profile.verificationStatus,
            newStatus: VerificationStatus.PENDING,
          },
        },
      });
    }

    if (dto.phone !== undefined) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { phone: dto.phone.trim() || null },
      });
    }

    return this.prisma.mechanicProfile.update({
      where: { id: profile.id },
      data: {
        workshopName: dto.workshopName?.trim() || profile.workshopName,
        workshopAddress: dto.workshopAddress !== undefined ? dto.workshopAddress?.trim() : profile.workshopAddress,
        operatingRadiusKm: dto.operatingRadiusKm ?? profile.operatingRadiusKm,
        experienceYears: dto.experienceYears ?? profile.experienceYears,
        tradeLicenseNumber: dto.tradeLicenseNumber !== undefined ? dto.tradeLicenseNumber.trim() : profile.tradeLicenseNumber,
        verificationStatus,
        verificationNotes,
        certifications: dto.certifications ?? profile.certifications,
        specializations: dto.specializations ?? profile.specializations,
        bio: dto.bio !== undefined ? dto.bio?.trim() : profile.bio,
      },
      include: {
        currentLocation: true,
        user: {
          select: {
            fullName: true,
            email: true,
            phone: true,
          },
        },
      },
    });
  }

  /**
   * Calculates career and recent earnings breakdown from completed jobs
   */
  async getEarnings(userId: string) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile was not found');
    }

    const completed = await this.prisma.serviceRequest.findMany({
      where: {
        mechanicId: profile.id,
        currentStatus: ServiceRequestStatus.COMPLETED,
      },
      include: {
        breakdownReport: {
          include: {
            vehicle: true,
          },
        },
        review: true,
      },
      orderBy: { completedAt: 'desc' },
    });

    let totalRevenue = 0;
    let totalLabor = 0;
    let totalParts = 0;
    let totalDiagnostic = 0;

    for (const req of completed) {
      const computedTotal = (req.laborCost ?? 0) + (req.partsCost ?? 0) + (req.diagnosticQuote ?? 0);
      const earned = req.agreedQuote ?? (computedTotal > 0 ? computedTotal : 0);
      totalRevenue += earned;
      totalLabor += req.laborCost ?? 0;
      totalParts += req.partsCost ?? 0;
      totalDiagnostic += req.diagnosticQuote ?? 0;
    }

    return {
      totalRevenue: Number(totalRevenue.toFixed(2)),
      totalLabor: Number(totalLabor.toFixed(2)),
      totalParts: Number(totalParts.toFixed(2)),
      totalDiagnostic: Number(totalDiagnostic.toFixed(2)),
      completedJobsCount: completed.length,
      averageJobValue: completed.length > 0 ? Number((totalRevenue / completed.length).toFixed(2)) : 0,
      recentPayoutRecords: completed.slice(0, 15).map((req) => {
        const computedTotal = (req.laborCost ?? 0) + (req.partsCost ?? 0) + (req.diagnosticQuote ?? 0);
        const earned = req.agreedQuote ?? (computedTotal > 0 ? computedTotal : 0);
        return {
          serviceRequestId: req.id,
          completedAt: req.completedAt,
          vehicle: req.breakdownReport?.vehicle
            ? `${req.breakdownReport.vehicle.year} ${req.breakdownReport.vehicle.make} ${req.breakdownReport.vehicle.model}`
            : 'Standard Vehicle',
          category: req.breakdownReport?.category,
          laborCost: req.laborCost ?? 0,
          partsCost: req.partsCost ?? 0,
          diagnosticQuote: req.diagnosticQuote ?? 0,
          totalEarned: earned,
          rating: req.review?.rating ?? null,
        };
      }),
    };
  }

  /**
   * Updates operational readiness state (AVAILABLE, OFFLINE, ON_JOB)
   */
  async updateAvailability(userId: string, dto: UpdateAvailabilityDto) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile was not found');
    }

    const updated = await this.prisma.mechanicProfile.update({
      where: { id: profile.id },
      data: { availabilityStatus: dto.status },
      include: { currentLocation: true },
    });

    // Broadcast status update in real time
    this.eventsGateway.broadcastMechanicStatus({
      mechanicId: profile.id,
      status: dto.status,
    });

    return updated;
  }

  /**
   * High-frequency GPS telemetry update
   */
  async updateLocation(userId: string, dto: UpdateLocationDto) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile was not found');
    }

    const location = await this.prisma.mechanicLocation.upsert({
      where: { mechanicId: profile.id },
      create: {
        mechanicId: profile.id,
        latitude: dto.latitude,
        longitude: dto.longitude,
        heading: dto.heading ?? null,
        speed: dto.speed ?? null,
        accuracy: dto.accuracy ?? null,
      },
      update: {
        latitude: dto.latitude,
        longitude: dto.longitude,
        heading: dto.heading ?? null,
        speed: dto.speed ?? null,
        accuracy: dto.accuracy ?? null,
      },
    });

    // Real-time broadcast
    this.eventsGateway.broadcastMechanicLocation({
      mechanicId: profile.id,
      latitude: dto.latitude,
      longitude: dto.longitude,
      heading: dto.heading,
      speed: dto.speed,
    });

    return location;
  }

  /**
   * Retrieves active inbound dispatches within the mechanic's operational boundary
   * MANDATORY: Offline mechanics must not receive new dispatches
   */
  async getDispatchesForMechanic(userId: string) {
    const profile = await this.prisma.mechanicProfile.findUnique({
      where: { userId },
      include: { currentLocation: true },
    });

    if (!profile) {
      throw new NotFoundException('Mechanic profile not found');
    }

    // Offline or On-Job technicians do NOT receive inbound dispatch offers
    if (profile.availabilityStatus !== AvailabilityStatus.AVAILABLE) {
      return [];
    }

    if (!profile.currentLocation) {
      return [];
    }

    // Query active unassigned breakdown requests
    const activeRequests = await this.prisma.serviceRequest.findMany({
      where: {
        currentStatus: {
          in: [ServiceRequestStatus.SUBMITTED, ServiceRequestStatus.SEARCHING],
        },
        mechanicId: null,
      },
      include: {
        breakdownReport: {
          include: {
            vehicle: true,
            customer: {
              select: {
                fullName: true,
                phone: true,
              },
            },
            images: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Filter by Haversine radial distance within operatingRadiusKm
    const eligibleDispatches = [];
    const mechLat = profile.currentLocation.latitude;
    const mechLon = profile.currentLocation.longitude;
    const maxRadius = profile.operatingRadiusKm;

    for (const req of activeRequests) {
      const rep = req.breakdownReport;
      const distance = calculateHaversineDistance(
        mechLat,
        mechLon,
        rep.latitude,
        rep.longitude,
      );

      // Boundary condition: distance must be within operating radius
      if (distance <= maxRadius) {
        eligibleDispatches.push({
          serviceRequestId: req.id,
          reportId: rep.id,
          distanceKm: Number(distance.toFixed(1)),
          estimatedArrivalMinutes: estimateArrivalTimeMinutes(distance),
          category: rep.category,
          severity: rep.severity,
          description: rep.description,
          latitude: rep.latitude,
          longitude: rep.longitude,
          addressText: rep.addressText,
          requiresTowing: rep.requiresTowing,
          ruleDiagnosis: rep.ruleDiagnosis,
          createdAt: rep.createdAt,
          vehicle: rep.vehicle,
          customerName: rep.customer.fullName,
          customerPhone: rep.customer.phone,
          images: rep.images,
        });
      }
    }

    // Sort ascending by proximity (nearest incident first)
    eligibleDispatches.sort((a, b) => a.distanceKm - b.distanceKm);

    return eligibleDispatches;
  }

  /**
   * Atomically accepts an incoming roadside dispatch
   * MANDATORY: Uses PostgreSQL atomic transaction to prevent duplicate claims
   */
  async acceptDispatch(mechanicUserId: string, serviceRequestId: string) {
    const result = await this.prisma.$transaction(async (tx) => {
      // 1. Fetch service request and verify claimability first
      const request = await tx.serviceRequest.findUnique({
        where: { id: serviceRequestId },
        include: {
          breakdownReport: {
            include: {
              vehicle: true,
              customer: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                },
              },
            },
          },
        },
      });

      if (!request) {
        throw new NotFoundException('Service request was not found');
      }

      // Check if already claimed by another technician
      if (
        (request.currentStatus !== ServiceRequestStatus.SUBMITTED &&
          request.currentStatus !== ServiceRequestStatus.SEARCHING) ||
        request.mechanicId !== null
      ) {
        throw new ConflictException(
          'This dispatch request has already been claimed by another field technician.',
        );
      }

      // 2. Fetch technician profile and verify eligibility
      const profile = await tx.mechanicProfile.findUnique({
        where: { userId: mechanicUserId },
        include: {
          user: { select: { fullName: true, phone: true } },
          currentLocation: true,
        },
      });

      if (!profile) {
        throw new NotFoundException('Mechanic profile not found');
      }

      if (profile.availabilityStatus !== AvailabilityStatus.AVAILABLE) {
        throw new BadRequestException(
          'Technician must be in AVAILABLE status to accept dispatches. Please activate your beacon.',
        );
      }

      if (profile.verificationStatus !== VerificationStatus.APPROVED) {
        throw new ForbiddenException(
          'Technician account must be verified and approved by administration before taking jobs.',
        );
      }

      // 3. Atomically update ServiceRequest
      const updatedRequest = await tx.serviceRequest.update({
        where: { id: serviceRequestId },
        data: {
          mechanicId: profile.id,
          currentStatus: ServiceRequestStatus.ACCEPTED,
          acceptedAt: new Date(),
        },
        include: {
          breakdownReport: {
            include: {
              vehicle: true,
              customer: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                },
              },
            },
          },
          mechanic: {
            include: {
              user: {
                select: {
                  fullName: true,
                  phone: true,
                },
              },
              currentLocation: true,
            },
          },
        },
      });

      // 4. Update technician status to ON_JOB
      await tx.mechanicProfile.update({
        where: { id: profile.id },
        data: { availabilityStatus: AvailabilityStatus.ON_JOB },
      });

      // 5. Append Status History record
      await tx.serviceStatusHistory.create({
        data: {
          serviceRequestId,
          fromStatus: request.currentStatus,
          toStatus: ServiceRequestStatus.ACCEPTED,
          changedById: mechanicUserId,
          notes: `Dispatch claimed by ${profile.workshopName || profile.user.fullName}`,
        },
      });

      // 6. Append Audit Log
      await tx.auditLog.create({
        data: {
          userId: mechanicUserId,
          action: 'DISPATCH_ACCEPTED',
          entityName: 'ServiceRequest',
          entityId: serviceRequestId,
          details: {
            mechanicId: profile.id,
            breakdownReportId: request.breakdownReportId,
          },
        },
      });

      return updatedRequest;
    });

    // 7. Broadcast real-time Socket.IO notification outside of transaction
    this.eventsGateway.broadcastDispatchAccepted({
      serviceRequestId: result.id,
      mechanicId: result.mechanicId!,
      mechanicName: result.mechanic?.workshopName || result.mechanic?.user?.fullName,
    });

    return result;
  }

  /**
   * Radial discovery query for customers to discover nearby certified mechanics
   * MANDATORY: Protects location privacy by fuzzing coordinates and validating boundary conditions
   */
  async findNearbyMechanics(query: NearbyMechanicsQueryDto) {
    const searchRadius = query.radius || 25.0;

    // Fetch verified and currently available mechanics with locations
    const availableMechanics = await this.prisma.mechanicProfile.findMany({
      where: {
        verificationStatus: VerificationStatus.APPROVED,
        availabilityStatus: AvailabilityStatus.AVAILABLE,
        currentLocation: { isNot: null },
      },
      include: {
        user: {
          select: {
            fullName: true,
            avatarUrl: true,
          },
        },
        currentLocation: true,
        services: true,
      },
    });

    const nearbyResults = [];

    for (const mech of availableMechanics) {
      if (!mech.currentLocation) continue;

      // Filter by category specialization if requested
      if (query.category) {
        const offersCategory = mech.services.some(
          (s) => s.category === query.category,
        );
        if (!offersCategory && mech.services.length > 0) {
          continue;
        }
      }

      // Calculate exact Haversine distance
      const distance = calculateHaversineDistance(
        query.latitude,
        query.longitude,
        mech.currentLocation.latitude,
        mech.currentLocation.longitude,
      );

      // Boundary condition: must satisfy BOTH customer search radius AND mechanic operating radius
      if (distance <= searchRadius && distance <= mech.operatingRadiusKm) {
        // LOCATION PRIVACY: Fuzz coordinates to ~1.1 km precision
        const fuzzed = fuzzCoordinates(
          mech.currentLocation.latitude,
          mech.currentLocation.longitude,
          2,
        );

        nearbyResults.push({
          mechanicId: mech.id,
          workshopName: mech.workshopName || mech.user.fullName,
          ratingAverage: mech.ratingAverage,
          totalReviews: mech.totalReviews,
          experienceYears: mech.experienceYears,
          operatingRadiusKm: mech.operatingRadiusKm,
          distanceKm: Number(distance.toFixed(1)),
          estimatedArrivalMinutes: estimateArrivalTimeMinutes(distance),
          approximateCoordinates: fuzzed, // Privacy-preserved
          services: mech.services.map((s) => ({
            category: s.category,
            priceEstimateMin: s.priceEstimateMin,
            priceEstimateMax: s.priceEstimateMax,
          })),
        });
      }
    }

    // Sort ascending by proximity (nearest first)
    nearbyResults.sort((a, b) => a.distanceKm - b.distanceKm);

    return nearbyResults;
  }
}

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EventsGateway } from '../events/events.gateway';
import { TransitionStatusDto } from './dto/transition-status.dto';
import { RecordQuoteDto } from './dto/record-quote.dto';
import { CancelServiceDto } from './dto/cancel-service.dto';
import { UpdateLocationConsentDto } from './dto/update-consent.dto';
import {
  Role,
  ServiceRequestStatus,
  AvailabilityStatus,
} from '@prisma/client';
import {
  calculateHaversineDistance,
  estimateArrivalTimeMinutes,
} from '../../common/utils/haversine';

const VALID_TRANSITIONS: Record<ServiceRequestStatus, ServiceRequestStatus[]> = {
  [ServiceRequestStatus.SUBMITTED]: [
    ServiceRequestStatus.SEARCHING,
    ServiceRequestStatus.ASSIGNED,
    ServiceRequestStatus.ACCEPTED,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.SEARCHING]: [
    ServiceRequestStatus.ASSIGNED,
    ServiceRequestStatus.ACCEPTED,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.ASSIGNED]: [
    ServiceRequestStatus.ACCEPTED,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.ACCEPTED]: [
    ServiceRequestStatus.EN_ROUTE,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.EN_ROUTE]: [
    ServiceRequestStatus.ARRIVED,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.ARRIVED]: [
    ServiceRequestStatus.IN_PROGRESS,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.IN_PROGRESS]: [
    ServiceRequestStatus.COMPLETED,
    ServiceRequestStatus.CANCELLED,
  ],
  [ServiceRequestStatus.COMPLETED]: [], // Terminal state
  [ServiceRequestStatus.CANCELLED]: [], // Terminal state
};

@Injectable()
export class ServiceRequestsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly eventsGateway: EventsGateway,
  ) {}

  /**
   * Helper to look up a ServiceRequest by its own ID or by its breakdownReportId
   */
  private async findRequestEntity(idOrReportId: string) {
    const request = await this.prisma.serviceRequest.findFirst({
      where: {
        OR: [{ id: idOrReportId }, { breakdownReportId: idOrReportId }],
      },
      include: {
        customer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            avatarUrl: true,
          },
        },
        breakdownReport: {
          include: {
            vehicle: true,
            images: true,
            customer: {
              select: {
                id: true,
                fullName: true,
                email: true,
                phone: true,
                avatarUrl: true,
              },
            },
          },
        },
        mechanic: {
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
        },
        statusHistory: {
          orderBy: { timestamp: 'asc' },
          include: {
            changedBy: {
              select: {
                fullName: true,
                role: true,
              },
            },
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundException(`Service request '${idOrReportId}' was not found`);
    }

    return request;
  }

  /**
   * Enforces strict state machine transitions with atomic verification and concurrency guards
   */
  async transitionStatus(
    idOrReportId: string,
    userId: string,
    role: Role,
    dto: TransitionStatusDto,
  ) {
    const initialRequest = await this.findRequestEntity(idOrReportId);
    const fromStatus = initialRequest.currentStatus;
    const toStatus = dto.status;

    // 1. Guard terminal states: cannot transition from COMPLETED or CANCELLED
    if (
      fromStatus === ServiceRequestStatus.COMPLETED ||
      fromStatus === ServiceRequestStatus.CANCELLED
    ) {
      throw new BadRequestException(
        `Cannot change status: Service request is already finalized in terminal state '${fromStatus}'.`,
      );
    }

    // 2. Prevent duplicate same-status transition
    if (fromStatus === toStatus) {
      throw new BadRequestException(
        `Service request is already in state '${toStatus}'.`,
      );
    }

    // 3. Validate allowable transition path (prevent state skipping)
    const allowedTargets = VALID_TRANSITIONS[fromStatus] || [];
    if (!allowedTargets.includes(toStatus)) {
      throw new BadRequestException(
        `Invalid lifecycle transition from '${fromStatus}' to '${toStatus}'. State progression must strictly follow: ACCEPTED -> EN_ROUTE -> ARRIVED -> IN_PROGRESS -> COMPLETED (or CANCELLED).`,
      );
    }

    // 4. Role-based authorization per transition
    const isOwnerCustomer = initialRequest.customerId === userId;
    const isAssignedMechanic = initialRequest.mechanic?.userId === userId;
    const isAdmin = role === Role.ADMIN;

    if (toStatus === ServiceRequestStatus.CANCELLED) {
      if (!isOwnerCustomer && !isAssignedMechanic && !isAdmin) {
        throw new ForbiddenException(
          'You do not have authorization to cancel this service request.',
        );
      }
    } else {
      // EN_ROUTE, ARRIVED, IN_PROGRESS, COMPLETED require assigned technician or admin
      if (!isAssignedMechanic && !isAdmin) {
        throw new ForbiddenException(
          'Only the assigned field technician or system administrator can advance this service milestone.',
        );
      }
    }

    // 5. Execute atomic state transition in transaction
    const updatedRequest = await this.prisma.$transaction(async (tx) => {
      // Re-verify current status to prevent race conditions
      const current = await tx.serviceRequest.findUnique({
        where: { id: initialRequest.id },
      });

      if (!current || current.currentStatus !== fromStatus) {
        throw new ConflictException(
          'Service request status was modified concurrently by another process.',
        );
      }

      const updateData: any = {
        currentStatus: toStatus,
      };

      const now = new Date();

      if (toStatus === ServiceRequestStatus.EN_ROUTE) {
        updateData.enRouteAt = now;
      } else if (toStatus === ServiceRequestStatus.ARRIVED) {
        updateData.arrivedAt = now;
      } else if (toStatus === ServiceRequestStatus.IN_PROGRESS) {
        updateData.inProgressAt = now;
      } else if (toStatus === ServiceRequestStatus.COMPLETED) {
        updateData.completedAt = now;
        if (dto.resolutionNotes) {
          updateData.resolutionNotes = dto.resolutionNotes;
        }

        // Release mechanic availability back to AVAILABLE and increment jobs counter
        if (initialRequest.mechanicId) {
          await tx.mechanicProfile.update({
            where: { id: initialRequest.mechanicId },
            data: {
              availabilityStatus: AvailabilityStatus.AVAILABLE,
              totalJobsCompleted: { increment: 1 },
            },
          });
        }
      } else if (toStatus === ServiceRequestStatus.CANCELLED) {
        updateData.cancelledAt = now;
        updateData.cancellationReason =
          dto.cancellationReason || dto.notes || 'Service cancelled';

        // Release mechanic availability back to AVAILABLE if assigned
        if (initialRequest.mechanicId) {
          await tx.mechanicProfile.update({
            where: { id: initialRequest.mechanicId },
            data: {
              availabilityStatus: AvailabilityStatus.AVAILABLE,
            },
          });
        }
      }

      // Update ServiceRequest record
      const reqUpdated = await tx.serviceRequest.update({
        where: { id: initialRequest.id },
        data: updateData,
        include: {
          breakdownReport: {
            include: {
              vehicle: true,
              customer: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                  email: true,
                },
              },
            },
          },
          mechanic: {
            include: {
              user: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                  email: true,
                },
              },
              currentLocation: true,
            },
          },
        },
      });

      // Append immutable Status History record
      await tx.serviceStatusHistory.create({
        data: {
          serviceRequestId: initialRequest.id,
          fromStatus,
          toStatus,
          changedById: userId,
          notes:
            dto.notes ||
            dto.cancellationReason ||
            dto.resolutionNotes ||
            `Status transitioned from ${fromStatus} to ${toStatus}`,
        },
      });

      // Audit Log
      await tx.auditLog.create({
        data: {
          userId,
          action: `SERVICE_STATUS_${toStatus}`,
          entityName: 'ServiceRequest',
          entityId: initialRequest.id,
          details: {
            fromStatus,
            toStatus,
            notes: dto.notes,
            cancellationReason: dto.cancellationReason,
          },
        },
      });

      return reqUpdated;
    });

    // 6. Broadcast real-time events over isolated WebSocket channel
    this.eventsGateway.broadcastStatusUpdate(updatedRequest.id, {
      serviceRequestId: updatedRequest.id,
      status: updatedRequest.currentStatus,
      fromStatus,
      timestamp: new Date(),
      notes: dto.notes,
      mechanicName:
        updatedRequest.mechanic?.workshopName ||
        updatedRequest.mechanic?.user?.fullName,
    });

    // Automatic arrival alert when arriving on site
    if (toStatus === ServiceRequestStatus.ARRIVED) {
      this.eventsGateway.broadcastArrivalAlert(updatedRequest.id, {
        serviceRequestId: updatedRequest.id,
        message: 'Technician has arrived on scene at breakdown coordinates.',
      });
    }

    return this.getTracking(updatedRequest.id, userId, role);
  }

  /**
   * Secure tracking data retrieval with authorization guards, location privacy, and staleness detection
   */
  async getTracking(idOrReportId: string, userId: string, role: Role) {
    const request = await this.findRequestEntity(idOrReportId);

    // Authorization verification: Motorist owner, assigned technician, or admin
    const isOwnerCustomer = request.customerId === userId;
    const isAssignedMechanic = request.mechanic?.userId === userId;
    const isAdmin = role === Role.ADMIN;

    if (!isOwnerCustomer && !isAssignedMechanic && !isAdmin) {
      throw new ForbiddenException(
        'You do not have authorization to track this service request.',
      );
    }

    // Accurate Haversine Distance & ETA calculation
    let liveTelemetry = null;
    const mechLocation = request.mechanic?.currentLocation;

    if (mechLocation) {
      const repLat = request.breakdownReport.latitude;
      const repLon = request.breakdownReport.longitude;

      const distanceKm = Number(
        calculateHaversineDistance(
          mechLocation.latitude,
          mechLocation.longitude,
          repLat,
          repLon,
        ).toFixed(2),
      );

      const estimatedArrivalMinutes =
        distanceKm <= 0.05 ? 0 : estimateArrivalTimeMinutes(distanceKm);

      // Stale GPS detection (older than 300 seconds / 5 minutes)
      const locAgeSeconds = Math.max(
        0,
        Math.round((Date.now() - new Date(mechLocation.updatedAt).getTime()) / 1000),
      );
      const isStale = locAgeSeconds > 300;

      // Location sharing consent guard
      const locationAllowed = request.locationConsent !== false;

      liveTelemetry = {
        distanceKm,
        estimatedArrivalMinutes,
        isArrived: distanceKm <= 0.05,
        locationSharingConsent: locationAllowed,
        isStale,
        ageSeconds: locAgeSeconds,
        coordinates: locationAllowed
          ? {
              latitude: mechLocation.latitude,
              longitude: mechLocation.longitude,
              heading: mechLocation.heading,
              speed: mechLocation.speed,
              accuracy: mechLocation.accuracy,
              updatedAt: mechLocation.updatedAt,
            }
          : null,
      };
    }

    return {
      serviceRequestId: request.id,
      breakdownReportId: request.breakdownReportId,
      currentStatus: request.currentStatus,
      locationConsent: request.locationConsent,
      timestamps: {
        createdAt: request.createdAt,
        assignedAt: request.assignedAt,
        acceptedAt: request.acceptedAt,
        enRouteAt: request.enRouteAt,
        arrivedAt: request.arrivedAt,
        inProgressAt: request.inProgressAt,
        completedAt: request.completedAt,
        cancelledAt: request.cancelledAt,
      },
      quote: {
        diagnosticQuote: request.diagnosticQuote,
        laborCost: request.laborCost,
        partsCost: request.partsCost,
        agreedQuote: request.agreedQuote,
        resolutionNotes: request.resolutionNotes,
        cancellationReason: request.cancellationReason,
      },
      customer: {
        id: request.customer.id,
        fullName: request.customer.fullName,
        phone: request.customer.phone,
        email: request.customer.email,
        avatarUrl: request.customer.avatarUrl,
      },
      mechanic: request.mechanic
        ? {
            id: request.mechanic.id,
            workshopName:
              request.mechanic.workshopName || request.mechanic.user.fullName,
            phone: request.mechanic.user.phone,
            ratingAverage: request.mechanic.ratingAverage,
            totalReviews: request.mechanic.totalReviews,
            totalJobsCompleted: request.mechanic.totalJobsCompleted,
            experienceYears: request.mechanic.experienceYears,
          }
        : null,
      breakdownReport: {
        id: request.breakdownReport.id,
        category: request.breakdownReport.category,
        severity: request.breakdownReport.severity,
        description: request.breakdownReport.description,
        latitude: request.breakdownReport.latitude,
        longitude: request.breakdownReport.longitude,
        addressText: request.breakdownReport.addressText,
        ruleDiagnosis: request.breakdownReport.ruleDiagnosis,
        requiresTowing: request.breakdownReport.requiresTowing,
        vehicle: request.breakdownReport.vehicle,
        images: request.breakdownReport.images,
      },
      liveTelemetry,
      statusHistory: request.statusHistory.map((h) => ({
        id: h.id,
        fromStatus: h.fromStatus,
        toStatus: h.toStatus,
        timestamp: h.timestamp,
        notes: h.notes,
        changedBy: h.changedBy
          ? {
              fullName: h.changedBy.fullName,
              role: h.changedBy.role,
            }
          : null,
      })),
    };
  }

  /**
   * Record diagnostic quotation, labor and parts costs
   */
  async recordQuote(
    idOrReportId: string,
    userId: string,
    role: Role,
    dto: RecordQuoteDto,
  ) {
    const request = await this.findRequestEntity(idOrReportId);

    // Authorization: assigned mechanic or admin
    const isAssignedMechanic = request.mechanic?.userId === userId;
    const isAdmin = role === Role.ADMIN;

    if (!isAssignedMechanic && !isAdmin) {
      throw new ForbiddenException(
        'Only the assigned field technician can record diagnostic quotations and parts costs.',
      );
    }

    if (
      request.currentStatus === ServiceRequestStatus.COMPLETED ||
      request.currentStatus === ServiceRequestStatus.CANCELLED
    ) {
      throw new BadRequestException(
        `Cannot submit quotation: Service request is already in terminal state '${request.currentStatus}'.`,
      );
    }

    // Compute agreed total quote if not explicitly supplied
    const calculatedTotal =
      (dto.diagnosticQuote ?? request.diagnosticQuote ?? 0) +
      (dto.laborCost ?? request.laborCost ?? 0) +
      (dto.partsCost ?? request.partsCost ?? 0);

    const agreedQuote = dto.agreedQuote ?? (calculatedTotal > 0 ? calculatedTotal : null);

    const updated = await this.prisma.serviceRequest.update({
      where: { id: request.id },
      data: {
        diagnosticQuote: dto.diagnosticQuote ?? request.diagnosticQuote,
        laborCost: dto.laborCost ?? request.laborCost,
        partsCost: dto.partsCost ?? request.partsCost,
        agreedQuote: agreedQuote,
        resolutionNotes: dto.notes ? dto.notes : request.resolutionNotes,
      },
    });

    // Append to status history
    await this.prisma.serviceStatusHistory.create({
      data: {
        serviceRequestId: request.id,
        fromStatus: request.currentStatus,
        toStatus: request.currentStatus,
        changedById: userId,
        notes: `Quotation updated: Diagnostic=$${updated.diagnosticQuote || 0}, Labor=$${updated.laborCost || 0}, Parts=$${updated.partsCost || 0}. Total=$${updated.agreedQuote || 0}.`,
      },
    });

    // Broadcast quote event to isolated request room
    this.eventsGateway.broadcastQuoteUpdate(request.id, {
      serviceRequestId: request.id,
      diagnosticQuote: updated.diagnosticQuote,
      laborCost: updated.laborCost,
      partsCost: updated.partsCost,
      agreedQuote: updated.agreedQuote,
      notes: dto.notes,
    });

    return this.getTracking(request.id, userId, role);
  }

  /**
   * Cancel service request with mandatory reason
   */
  async cancel(
    idOrReportId: string,
    userId: string,
    role: Role,
    dto: CancelServiceDto,
  ) {
    return this.transitionStatus(idOrReportId, userId, role, {
      status: ServiceRequestStatus.CANCELLED,
      cancellationReason: dto.reason,
      notes: `Cancellation reason: ${dto.reason}`,
    });
  }

  /**
   * Update location-sharing consent
   */
  async updateLocationConsent(
    idOrReportId: string,
    userId: string,
    role: Role,
    dto: UpdateLocationConsentDto,
  ) {
    const request = await this.findRequestEntity(idOrReportId);

    const isOwnerCustomer = request.customerId === userId;
    const isAssignedMechanic = request.mechanic?.userId === userId;
    const isAdmin = role === Role.ADMIN;

    if (!isOwnerCustomer && !isAssignedMechanic && !isAdmin) {
      throw new ForbiddenException(
        'You do not have authorization to modify location consent for this request.',
      );
    }

    await this.prisma.serviceRequest.update({
      where: { id: request.id },
      data: { locationConsent: dto.locationConsent },
    });

    return this.getTracking(request.id, userId, role);
  }

  /**
   * Returns current active mission assignment for authenticated mechanic or active incident for customer
   */
  async getActive(userId: string, role: Role) {
    if (role === Role.MECHANIC) {
      const profile = await this.prisma.mechanicProfile.findUnique({
        where: { userId },
      });

      if (!profile) return null;

      const active = await this.prisma.serviceRequest.findFirst({
        where: {
          mechanicId: profile.id,
          currentStatus: {
            in: [
              ServiceRequestStatus.ACCEPTED,
              ServiceRequestStatus.EN_ROUTE,
              ServiceRequestStatus.ARRIVED,
              ServiceRequestStatus.IN_PROGRESS,
            ],
          },
        },
        orderBy: { updatedAt: 'desc' },
      });

      if (!active) return null;
      return this.getTracking(active.id, userId, role);
    } else {
      const active = await this.prisma.serviceRequest.findFirst({
        where: {
          customerId: userId,
          currentStatus: {
            notIn: [
              ServiceRequestStatus.COMPLETED,
              ServiceRequestStatus.CANCELLED,
            ],
          },
        },
        orderBy: { createdAt: 'desc' },
      });

      if (!active) return null;
      return this.getTracking(active.id, userId, role);
    }
  }

  /**
   * Retrieves historical completed and cancelled service requests with cost itemization and reviews
   */
  async getHistory(userId: string, role: Role) {
    if (role === Role.MECHANIC) {
      const profile = await this.prisma.mechanicProfile.findUnique({
        where: { userId },
      });

      if (!profile) return [];

      return this.prisma.serviceRequest.findMany({
        where: {
          mechanicId: profile.id,
          currentStatus: {
            in: [ServiceRequestStatus.COMPLETED, ServiceRequestStatus.CANCELLED],
          },
        },
        include: {
          breakdownReport: {
            include: {
              vehicle: true,
              images: true,
              customer: {
                select: {
                  id: true,
                  fullName: true,
                  phone: true,
                  avatarUrl: true,
                },
              },
            },
          },
          review: true,
        },
        orderBy: { updatedAt: 'desc' },
      });
    } else {
      return this.prisma.serviceRequest.findMany({
        where: {
          customerId: userId,
          currentStatus: {
            in: [ServiceRequestStatus.COMPLETED, ServiceRequestStatus.CANCELLED],
          },
        },
        include: {
          breakdownReport: {
            include: {
              vehicle: true,
              images: true,
            },
          },
          mechanic: {
            include: {
              user: {
                select: {
                  fullName: true,
                  phone: true,
                  avatarUrl: true,
                },
              },
            },
          },
          review: true,
        },
        orderBy: { updatedAt: 'desc' },
      });
    }
  }
}

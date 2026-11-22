import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { VerifyMechanicDto } from './dto/verify-mechanic.dto';
import { CreateComplaintDto } from './dto/create-complaint.dto';
import { UpdateComplaintStatusDto } from './dto/update-complaint-status.dto';
import { AuditLogQueryDto } from './dto/audit-log-query.dto';
import {
  Role,
  VerificationStatus,
  ComplaintStatus,
  ServiceRequestStatus,
} from '@prisma/client';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * List technician profiles with optional verification status filtering
   */
  async getMechanics(status?: VerificationStatus) {
    const where: any = {};
    if (status) {
      where.verificationStatus = status;
    }

    return this.prisma.mechanicProfile.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            createdAt: true,
          },
        },
        services: true,
        currentLocation: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Admin approves or rejects a technician verification application
   */
  async verifyMechanic(
    mechanicProfileId: string,
    adminUserId: string,
    dto: VerifyMechanicDto,
  ) {
    const profile = await this.prisma.mechanicProfile.findFirst({
      where: {
        OR: [{ id: mechanicProfileId }, { userId: mechanicProfileId }],
      },
      include: { user: true },
    });

    if (!profile) {
      throw new NotFoundException(`Mechanic profile '${mechanicProfileId}' was not found`);
    }

    const updated = await this.prisma.mechanicProfile.update({
      where: { id: profile.id },
      data: {
        verificationStatus: dto.status,
        verificationNotes: dto.notes || profile.verificationNotes,
      },
      include: { user: true },
    });

    // Immutable Audit Log
    await this.prisma.auditLog.create({
      data: {
        userId: adminUserId,
        action: `MECHANIC_VERIFICATION_${dto.status}`,
        entityName: 'MechanicProfile',
        entityId: profile.id,
        details: {
          previousStatus: profile.verificationStatus,
          newStatus: dto.status,
          notes: dto.notes,
          technicianEmail: profile.user.email,
        },
      },
    });

    return updated;
  }

  /**
   * File a formal municipal dispute / grievance for a service request
   */
  async createComplaint(filedById: string, dto: CreateComplaintDto) {
    const request = await this.prisma.serviceRequest.findUnique({
      where: { id: dto.serviceRequestId },
      include: { mechanic: true },
    });

    if (!request) {
      throw new NotFoundException(
        `Associated service request '${dto.serviceRequestId}' was not found`,
      );
    }

    const isCustomerOwner = request.customerId === filedById;
    const isAssignedMechanic = request.mechanic?.userId === filedById;

    if (!isCustomerOwner && !isAssignedMechanic) {
      throw new ForbiddenException(
        'Only the motorist or assigned technician associated with this service request may file a dispute.',
      );
    }

    // Determine target user if not explicitly supplied
    let targetUserId = dto.targetUserId;
    if (!targetUserId) {
      targetUserId = isCustomerOwner
        ? request.mechanic?.userId || null
        : request.customerId;
    }

    const complaint = await this.prisma.complaint.create({
      data: {
        serviceRequestId: dto.serviceRequestId,
        filedById,
        targetUserId,
        subject: dto.subject.trim(),
        description: dto.description.trim(),
        status: ComplaintStatus.PENDING,
      },
      include: {
        filedBy: { select: { fullName: true, email: true, role: true } },
        targetUser: { select: { fullName: true, email: true, role: true } },
      },
    });

    // Audit Log
    await this.prisma.auditLog.create({
      data: {
        userId: filedById,
        action: 'COMPLAINT_FILED',
        entityName: 'Complaint',
        entityId: complaint.id,
        details: {
          serviceRequestId: dto.serviceRequestId,
          subject: dto.subject,
        },
      },
    });

    return complaint;
  }

  /**
   * List disputes with tenant filtering (Admin sees all; Customer/Mechanic sees their own)
   */
  async getComplaints(userId: string, role: Role, status?: ComplaintStatus) {
    const where: any = {};
    if (status) {
      where.status = status;
    }

    if (role !== Role.ADMIN) {
      where.OR = [{ filedById: userId }, { targetUserId: userId }];
    }

    return this.prisma.complaint.findMany({
      where,
      include: {
        filedBy: { select: { id: true, fullName: true, email: true, role: true } },
        targetUser: { select: { id: true, fullName: true, email: true, role: true } },
        serviceRequest: {
          include: {
            breakdownReport: {
              select: {
                id: true,
                category: true,
                severity: true,
                addressText: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Administrative status advancement and resolution notes on a dispute
   */
  async updateComplaintStatus(
    complaintId: string,
    adminUserId: string,
    dto: UpdateComplaintStatusDto,
  ) {
    const complaint = await this.prisma.complaint.findUnique({
      where: { id: complaintId },
    });

    if (!complaint) {
      throw new NotFoundException(`Complaint '${complaintId}' was not found`);
    }

    const isFinalized =
      dto.status === ComplaintStatus.RESOLVED ||
      dto.status === ComplaintStatus.DISMISSED;

    const updated = await this.prisma.complaint.update({
      where: { id: complaintId },
      data: {
        status: dto.status,
        resolutionNotes: dto.resolutionNotes || complaint.resolutionNotes,
        resolvedAt: isFinalized ? new Date() : complaint.resolvedAt,
      },
      include: {
        filedBy: { select: { fullName: true, email: true } },
        targetUser: { select: { fullName: true, email: true } },
      },
    });

    // Audit Log
    await this.prisma.auditLog.create({
      data: {
        userId: adminUserId,
        action: `COMPLAINT_STATUS_${dto.status}`,
        entityName: 'Complaint',
        entityId: complaint.id,
        details: {
          fromStatus: complaint.status,
          toStatus: dto.status,
          resolutionNotes: dto.resolutionNotes,
        },
      },
    });

    return updated;
  }

  /**
   * Real PostgreSQL SQL Analytics Engine (Zero Mock Statistics)
   */
  async getAnalyticsOverview() {
    // 1. High-level counts
    const [
      totalIncidents,
      activeDispatches,
      completedJobs,
      cancelledJobs,
      towingRequiredCount,
      totalVehicles,
      totalDrivers,
      totalMechanics,
      approvedMechanics,
      pendingMechanics,
    ] = await Promise.all([
      this.prisma.breakdownReport.count(),
      this.prisma.serviceRequest.count({
        where: {
          currentStatus: {
            in: [
              ServiceRequestStatus.SUBMITTED,
              ServiceRequestStatus.SEARCHING,
              ServiceRequestStatus.ASSIGNED,
              ServiceRequestStatus.ACCEPTED,
              ServiceRequestStatus.EN_ROUTE,
              ServiceRequestStatus.ARRIVED,
              ServiceRequestStatus.IN_PROGRESS,
            ],
          },
        },
      }),
      this.prisma.serviceRequest.count({
        where: { currentStatus: ServiceRequestStatus.COMPLETED },
      }),
      this.prisma.serviceRequest.count({
        where: { currentStatus: ServiceRequestStatus.CANCELLED },
      }),
      this.prisma.breakdownReport.count({
        where: { requiresTowing: true },
      }),
      this.prisma.vehicle.count(),
      this.prisma.user.count({ where: { role: Role.CUSTOMER } }),
      this.prisma.mechanicProfile.count(),
      this.prisma.mechanicProfile.count({
        where: { verificationStatus: VerificationStatus.APPROVED },
      }),
      this.prisma.mechanicProfile.count({
        where: { verificationStatus: VerificationStatus.PENDING },
      }),
    ]);

    // 2. Breakdown Category Distribution (SQL GroupBy)
    const categoryGroups = await this.prisma.breakdownReport.groupBy({
      by: ['category'],
      _count: { category: true },
      orderBy: { _count: { category: 'desc' } },
    });

    // 3. Severity Distribution (SQL GroupBy)
    const severityGroups = await this.prisma.breakdownReport.groupBy({
      by: ['severity'],
      _count: { severity: true },
    });

    // 4. Top Performing Field Technicians
    const topMechanics = await this.prisma.mechanicProfile.findMany({
      where: { verificationStatus: VerificationStatus.APPROVED },
      take: 5,
      orderBy: [
        { totalJobsCompleted: 'desc' },
        { ratingAverage: 'desc' },
      ],
      include: {
        user: { select: { fullName: true, email: true } },
      },
    });

    // 5. Response Time & Resolution Metrics (From actual timestamp fields)
    const completedRequests = await this.prisma.serviceRequest.findMany({
      where: {
        currentStatus: ServiceRequestStatus.COMPLETED,
        acceptedAt: { not: null },
        completedAt: { not: null },
      },
      select: {
        createdAt: true,
        acceptedAt: true,
        completedAt: true,
      },
      take: 100,
    });

    let totalDispatchLatencyMinutes = 0;
    let totalServiceDurationMinutes = 0;

    for (const req of completedRequests) {
      if (req.acceptedAt) {
        const dispatchLatency =
          (new Date(req.acceptedAt).getTime() - new Date(req.createdAt).getTime()) /
          (1000 * 60);
        totalDispatchLatencyMinutes += Math.max(0, dispatchLatency);
      }
      if (req.acceptedAt && req.completedAt) {
        const duration =
          (new Date(req.completedAt).getTime() - new Date(req.acceptedAt).getTime()) /
          (1000 * 60);
        totalServiceDurationMinutes += Math.max(0, duration);
      }
    }

    const countCompleted = completedRequests.length;
    const avgDispatchLatencyMinutes = countCompleted > 0
      ? Number((totalDispatchLatencyMinutes / countCompleted).toFixed(1))
      : 0;
    const avgServiceDurationMinutes = countCompleted > 0
      ? Number((totalServiceDurationMinutes / countCompleted).toFixed(1))
      : 0;

    // 6. Towing percentage
    const towingPercentage =
      totalIncidents > 0
        ? Number(((towingRequiredCount / totalIncidents) * 100).toFixed(1))
        : 0;

    return {
      fleetMetrics: {
        totalIncidents,
        activeDispatches,
        completedJobs,
        cancelledJobs,
        totalVehicles,
        totalDrivers,
        totalMechanics,
        approvedMechanics,
        pendingMechanics,
        towingRequiredCount,
        towingPercentage,
      },
      responseTiming: {
        avgDispatchLatencyMinutes,
        avgServiceDurationMinutes,
      },
      categoryDistribution: categoryGroups.map((g) => ({
        category: g.category,
        count: g._count.category,
      })),
      severityDistribution: severityGroups.map((g) => ({
        severity: g.severity,
        count: g._count.severity,
      })),
      topMechanics: topMechanics.map((m) => ({
        id: m.id,
        name: m.workshopName || m.user.fullName,
        email: m.user.email,
        ratingAverage: m.ratingAverage,
        totalReviews: m.totalReviews,
        totalJobsCompleted: m.totalJobsCompleted,
        operatingRadiusKm: m.operatingRadiusKm,
      })),
    };
  }

  /**
   * Security Audit Log Explorer querying real PostgreSQL AuditLog records
   */
  async getAuditLogs(query: AuditLogQueryDto) {
    const where: any = {};
    if (query.action) {
      where.action = { contains: query.action };
    }
    if (query.entityName) {
      where.entityName = query.entityName;
    }

    const limit = query.limit || 50;
    const offset = query.offset || 0;

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        take: limit,
        skip: offset,
        orderBy: { timestamp: 'desc' },
        include: {
          user: {
            select: {
              fullName: true,
              email: true,
              role: true,
            },
          },
        },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      logs,
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + limit < total,
      },
    };
  }
}

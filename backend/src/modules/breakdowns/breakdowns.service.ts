import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBreakdownDto } from './dto/create-breakdown.dto';
import { BreakdownTriageService } from './breakdown-triage.service';
import { ServiceRequestStatus, SeverityLevel } from '@prisma/client';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class BreakdownsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly triageService: BreakdownTriageService,
  ) {}

  /**
   * Create an emergency breakdown report with optional photographs and rule-based diagnosis
   */
  async create(
    customerId: string,
    dto: CreateBreakdownDto,
    files: Express.Multer.File[] = [],
  ) {
    // 1. Verify associated vehicle belongs to customer if vehicleId supplied
    let vehicle = null;
    if (dto.vehicleId) {
      vehicle = await this.prisma.vehicle.findUnique({
        where: { id: dto.vehicleId },
      });

      if (!vehicle) {
        throw new NotFoundException('Specified vehicle was not found');
      }

      if (vehicle.userId !== customerId) {
        throw new ForbiddenException('You do not have permission to attach this vehicle');
      }
    }

    // 2. Run deterministic rule-based triage classification
    const severity = dto.severity || SeverityLevel.MEDIUM;
    const triage = this.triageService.classify(
      dto.category,
      severity,
      dto.description,
      vehicle?.powertrain,
    );

    // 3. Atomically persist BreakdownReport, ReportImages, ServiceRequest, and initial Status History
    const result = await this.prisma.$transaction(async (tx) => {
      // Create Breakdown Report
      const report = await tx.breakdownReport.create({
        data: {
          customerId,
          vehicleId: dto.vehicleId || null,
          category: dto.category,
          severity,
          description: dto.description.trim(),
          latitude: dto.latitude,
          longitude: dto.longitude,
          addressText: dto.addressText?.trim() || null,
          ruleDiagnosis: triage.ruleDiagnosis,
          requiresTowing: triage.requiresTowing,
        },
      });

      // Persist uploaded image metadata
      if (files && files.length > 0) {
        for (const file of files) {
          await tx.reportImage.create({
            data: {
              reportId: report.id,
              filePath: file.path.replace(/\\/g, '/'),
              fileName: file.filename,
              fileSize: file.size,
              mimeType: file.mimetype,
            },
          });
        }
      }

      // Initialize Service Request in SUBMITTED state
      const serviceRequest = await tx.serviceRequest.create({
        data: {
          breakdownReportId: report.id,
          customerId,
          currentStatus: ServiceRequestStatus.SUBMITTED,
        },
      });

      // Record initial Status History
      await tx.serviceStatusHistory.create({
        data: {
          serviceRequestId: serviceRequest.id,
          fromStatus: null,
          toStatus: ServiceRequestStatus.SUBMITTED,
          changedById: customerId,
          notes: `Breakdown reported: ${dto.category}. Towing required: ${triage.requiresTowing}.`,
        },
      });

      // Audit Log
      await tx.auditLog.create({
        data: {
          userId: customerId,
          action: 'BREAKDOWN_REPORT_CREATED',
          entityName: 'BreakdownReport',
          entityId: report.id,
          details: {
            category: dto.category,
            severity,
            requiresTowing: triage.requiresTowing,
            imageCount: files.length,
          },
        },
      });

      return report;
    });

    return this.findOne(result.id, customerId, false);
  }

  /**
   * List all breakdown reports filed by a specific customer
   */
  async findAllForCustomer(customerId: string) {
    return this.prisma.breakdownReport.findMany({
      where: { customerId },
      include: {
        vehicle: true,
        images: true,
        serviceRequest: {
          include: {
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
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Get single breakdown report by ID with tenant isolation verification
   */
  async findOne(id: string, customerId?: string, isAdmin = false) {
    const report = await this.prisma.breakdownReport.findUnique({
      where: { id },
      include: {
        vehicle: true,
        images: true,
        customer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
          },
        },
        serviceRequest: {
          include: {
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
            statusHistory: {
              orderBy: { timestamp: 'asc' },
            },
          },
        },
      },
    });

    if (!report) {
      throw new NotFoundException(`Breakdown report ${id} was not found`);
    }

    if (!isAdmin && customerId && report.customerId !== customerId) {
      throw new ForbiddenException('You do not have permission to view this breakdown report');
    }

    return report;
  }

  /**
   * Securely retrieve an uploaded image file
   */
  getImageFilePath(filename: string): string {
    const safeFilename = path.basename(filename);
    const fullPath = path.resolve(process.cwd(), 'uploads', 'breakdowns', safeFilename);

    if (!fs.existsSync(fullPath)) {
      throw new NotFoundException('Requested incident image was not found');
    }

    return fullPath;
  }

  /**
   * Cancel/delete a breakdown report (only if still in SUBMITTED state)
   */
  async delete(id: string, customerId: string, isAdmin = false) {
    const report = await this.findOne(id, customerId, isAdmin);

    if (report.serviceRequest && report.serviceRequest.currentStatus !== ServiceRequestStatus.SUBMITTED) {
      throw new BadRequestException(
        `Cannot cancel breakdown report after service status has progressed to ${report.serviceRequest.currentStatus}`,
      );
    }

    // Clean up local image files from disk
    for (const img of report.images) {
      try {
        if (fs.existsSync(img.filePath)) {
          fs.unlinkSync(img.filePath);
        }
      } catch (err) {
        console.warn(`Failed to unlink image ${img.filePath}:`, err);
      }
    }

    await this.prisma.breakdownReport.delete({
      where: { id },
    });

    return { message: 'Breakdown report cancelled successfully' };
  }
}

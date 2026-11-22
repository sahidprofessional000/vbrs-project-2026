import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';

@Injectable()
export class VehiclesService {
  private readonly logger = new Logger(VehiclesService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get all vehicles belonging to the customer
   */
  async getGarage(userId: string) {
    return this.prisma.vehicle.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  /**
   * Get single vehicle by ID ensuring user ownership or admin privilege
   */
  async getVehicleById(userId: string, vehicleId: string, isAdmin = false) {
    const vehicle = await this.prisma.vehicle.findUnique({
      where: { id: vehicleId },
    });

    if (!vehicle) {
      throw new NotFoundException(`Vehicle with ID ${vehicleId} not found`);
    }

    if (vehicle.userId !== userId && !isAdmin) {
      throw new ForbiddenException('You do not have permission to access this vehicle');
    }

    return vehicle;
  }

  /**
   * Register a new vehicle to customer garage
   */
  async createVehicle(userId: string, dto: CreateVehicleDto) {
    const normalizedPlate = dto.licensePlate.toUpperCase().trim();

    // Check if user already registered this plate
    const existing = await this.prisma.vehicle.findFirst({
      where: {
        userId,
        licensePlate: normalizedPlate,
      },
    });

    if (existing) {
      throw new ConflictException(
        `A vehicle with license plate ${normalizedPlate} is already in your garage`,
      );
    }

    // Count existing vehicles: if this is first vehicle, make it default automatically
    const vehicleCount = await this.prisma.vehicle.count({ where: { userId } });
    const shouldBeDefault = dto.isDefault || vehicleCount === 0;

    return this.prisma.$transaction(async (tx) => {
      // If setting as default, clear default flag from other user vehicles
      if (shouldBeDefault) {
        await tx.vehicle.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }

      const vehicle = await tx.vehicle.create({
        data: {
          userId,
          make: dto.make.trim(),
          model: dto.model.trim(),
          year: dto.year,
          licensePlate: normalizedPlate,
          vin: dto.vin?.toUpperCase().trim(),
          color: dto.color?.trim(),
          powertrain: dto.powertrain,
          isDefault: shouldBeDefault,
        },
      });

      await tx.auditLog.create({
        data: {
          userId,
          action: 'VEHICLE_ADDED',
          entityName: 'Vehicle',
          entityId: vehicle.id,
          details: { make: vehicle.make, model: vehicle.model, plate: vehicle.licensePlate },
        },
      });

      return vehicle;
    });
  }

  /**
   * Update an existing vehicle
   */
  async updateVehicle(userId: string, vehicleId: string, dto: UpdateVehicleDto, isAdmin = false) {
    const existing = await this.getVehicleById(userId, vehicleId, isAdmin);

    const normalizedPlate = dto.licensePlate
      ? dto.licensePlate.toUpperCase().trim()
      : undefined;

    if (normalizedPlate && normalizedPlate !== existing.licensePlate) {
      const duplicatePlate = await this.prisma.vehicle.findFirst({
        where: {
          userId,
          licensePlate: normalizedPlate,
          id: { not: vehicleId },
        },
      });

      if (duplicatePlate) {
        throw new ConflictException(
          `Another vehicle in your garage already has license plate ${normalizedPlate}`,
        );
      }
    }

    return this.prisma.$transaction(async (tx) => {
      if (dto.isDefault) {
        await tx.vehicle.updateMany({
          where: { userId, isDefault: true, id: { not: vehicleId } },
          data: { isDefault: false },
        });
      }

      const updated = await tx.vehicle.update({
        where: { id: vehicleId },
        data: {
          make: dto.make?.trim(),
          model: dto.model?.trim(),
          year: dto.year,
          licensePlate: normalizedPlate,
          vin: dto.vin?.toUpperCase().trim(),
          color: dto.color?.trim(),
          powertrain: dto.powertrain,
          isDefault: dto.isDefault,
        },
      });

      await tx.auditLog.create({
        data: {
          userId,
          action: 'VEHICLE_UPDATED',
          entityName: 'Vehicle',
          entityId: vehicleId,
        },
      });

      return updated;
    });
  }

  /**
   * Set vehicle as primary default
   */
  async setDefaultVehicle(userId: string, vehicleId: string) {
    await this.getVehicleById(userId, vehicleId);

    return this.prisma.$transaction(async (tx) => {
      await tx.vehicle.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });

      return tx.vehicle.update({
        where: { id: vehicleId },
        data: { isDefault: true },
      });
    });
  }

  /**
   * Delete vehicle from garage
   */
  async deleteVehicle(userId: string, vehicleId: string, isAdmin = false) {
    const existing = await this.getVehicleById(userId, vehicleId, isAdmin);

    await this.prisma.$transaction(async (tx) => {
      await tx.vehicle.delete({
        where: { id: vehicleId },
      });

      // If this was default vehicle, promote another vehicle if exists
      if (existing.isDefault) {
        const remaining = await tx.vehicle.findFirst({
          where: { userId },
          orderBy: { createdAt: 'desc' },
        });

        if (remaining) {
          await tx.vehicle.update({
            where: { id: remaining.id },
            data: { isDefault: true },
          });
        }
      }

      await tx.auditLog.create({
        data: {
          userId,
          action: 'VEHICLE_DELETED',
          entityName: 'Vehicle',
          entityId: vehicleId,
          details: { plate: existing.licensePlate },
        },
      });
    });

    return { message: 'Vehicle deleted successfully', id: vehicleId };
  }
}

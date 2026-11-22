import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSavedAddressDto } from './dto/create-saved-address.dto';

@Injectable()
export class CustomerService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Retrieves all saved addresses for the customer
   */
  async getSavedAddresses(userId: string) {
    return this.prisma.savedAddress.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  /**
   * Creates a new saved address for the customer
   */
  async createSavedAddress(userId: string, dto: CreateSavedAddressDto) {
    // If setting as default, unset existing default addresses
    if (dto.isDefault) {
      await this.prisma.savedAddress.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
    }

    return this.prisma.savedAddress.create({
      data: {
        userId,
        label: dto.label.trim(),
        address: dto.address.trim(),
        latitude: dto.latitude ?? null,
        longitude: dto.longitude ?? null,
        isDefault: dto.isDefault ?? false,
      },
    });
  }

  /**
   * Deletes a saved address with ownership validation
   */
  async deleteSavedAddress(userId: string, addressId: string) {
    const address = await this.prisma.savedAddress.findUnique({
      where: { id: addressId },
    });

    if (!address) {
      throw new NotFoundException('Saved address not found');
    }

    if (address.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this address');
    }

    await this.prisma.savedAddress.delete({
      where: { id: addressId },
    });

    return { message: 'Address removed successfully' };
  }

  /**
   * Comprehensive customer home overview aggregation
   */
  async getCustomerOverview(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        phone: true,
        avatarUrl: true,
        role: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('Customer profile not found');
    }

    const [vehicles, savedAddresses, reports, completedRequests] = await Promise.all([
      this.prisma.vehicle.findMany({
        where: { userId },
        orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
      }),
      this.prisma.savedAddress.findMany({
        where: { userId },
        orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
      }),
      this.prisma.breakdownReport.findMany({
        where: { customerId: userId },
        include: {
          vehicle: true,
          images: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
      this.prisma.serviceRequest.count({
        where: {
          customerId: userId,
          currentStatus: 'COMPLETED',
        },
      }),
    ]);

    return {
      profile: user,
      vehicles,
      savedAddresses,
      recentBreakdowns: reports,
      stats: {
        totalVehicles: vehicles.length,
        totalBreakdownsReported: reports.length,
        completedServicesCount: completedRequests,
        savedLocationsCount: savedAddresses.length,
      },
    };
  }
}

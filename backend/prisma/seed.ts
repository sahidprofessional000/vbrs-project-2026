import { PrismaClient, Role, PowertrainType, BreakdownCategory, VerificationStatus, AvailabilityStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding for VBRS...');

  // Clean existing tables (in reverse foreign key dependency order)
  await prisma.auditLog.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.complaint.deleteMany();
  await prisma.review.deleteMany();
  await prisma.serviceStatusHistory.deleteMany();
  await prisma.serviceRequest.deleteMany();
  await prisma.reportImage.deleteMany();
  await prisma.breakdownReport.deleteMany();
  await prisma.mechanicLocation.deleteMany();
  await prisma.mechanicService.deleteMany();
  await prisma.mechanicProfile.deleteMany();
  await prisma.vehicle.deleteMany();
  await prisma.refreshToken.deleteMany();
  await prisma.user.deleteMany();

  const saltRounds = 12;
  const commonPassword = await bcrypt.hash('Password@123', saltRounds);

  // 1. Seed System Administrator
  const admin = await prisma.user.create({
    data: {
      email: 'admin@vbrs.local',
      passwordHash: commonPassword,
      fullName: 'System Administrator',
      phone: '+1-555-0100',
      role: Role.ADMIN,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
  });
  console.log(`👤 Admin created: ${admin.email}`);

  // 2. Seed Verified Active Mechanics
  const mechanicUser1 = await prisma.user.create({
    data: {
      email: 'mechanic.alex@vbrs.local',
      passwordHash: commonPassword,
      fullName: 'Alex Vance (Apex Automotive)',
      phone: '+1-555-0201',
      role: Role.MECHANIC,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
  });

  const mechanicProfile1 = await prisma.mechanicProfile.create({
    data: {
      userId: mechanicUser1.id,
      workshopName: 'Apex Mobile Roadside Services',
      tradeLicenseNumber: 'ASE-MASTER-99482',
      experienceYears: 12,
      verificationStatus: VerificationStatus.APPROVED,
      verificationNotes: 'Certified ASE Master Automotive Technician. Fully verified.',
      availabilityStatus: AvailabilityStatus.AVAILABLE,
      operatingRadiusKm: 35.0,
      ratingAverage: 4.9,
      totalReviews: 24,
      totalJobsCompleted: 58,
      documentUrl: '/uploads/cert_alex.pdf',
    },
  });

  // Services offered by Mechanic 1
  await prisma.mechanicService.createMany({
    data: [
      { mechanicId: mechanicProfile1.id, category: BreakdownCategory.ENGINE_FAILURE, priceEstimateMin: 80, priceEstimateMax: 250, description: 'Engine diagnostics, belt replacement, sensor swaps' },
      { mechanicId: mechanicProfile1.id, category: BreakdownCategory.BATTERY_DEAD_ELECTRICAL, priceEstimateMin: 45, priceEstimateMax: 120, description: 'Jump start, alternator testing, battery replacement' },
      { mechanicId: mechanicProfile1.id, category: BreakdownCategory.FLAT_TIRE_WHEEL, priceEstimateMin: 35, priceEstimateMax: 80, description: 'Tire repair, spare tire installation' },
      { mechanicId: mechanicProfile1.id, category: BreakdownCategory.BRAKE_SYSTEM_FAILURE, priceEstimateMin: 70, priceEstimateMax: 200, description: 'Brake pad swap, fluid line bleed' },
    ],
  });

  // Location for Mechanic 1 (Downtown zone)
  await prisma.mechanicLocation.create({
    data: {
      mechanicId: mechanicProfile1.id,
      latitude: 40.7128,
      longitude: -74.0060,
      heading: 90.0,
      speed: 0.0,
      accuracy: 5.0,
    },
  });
  console.log(`🔧 Mechanic 1 created: ${mechanicUser1.email} (Online & Verified)`);

  const mechanicUser2 = await prisma.user.create({
    data: {
      email: 'mechanic.marcus@vbrs.local',
      passwordHash: commonPassword,
      fullName: 'Marcus Sterling (Sterling Tow & Repair)',
      phone: '+1-555-0202',
      role: Role.MECHANIC,
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
  });

  const mechanicProfile2 = await prisma.mechanicProfile.create({
    data: {
      userId: mechanicUser2.id,
      workshopName: 'Sterling Heavy Towing & Roadside',
      tradeLicenseNumber: 'TOW-NJ-48821',
      experienceYears: 8,
      verificationStatus: VerificationStatus.APPROVED,
      verificationNotes: 'Flatbed tow truck operator certified.',
      availabilityStatus: AvailabilityStatus.AVAILABLE,
      operatingRadiusKm: 50.0,
      ratingAverage: 4.7,
      totalReviews: 18,
      totalJobsCompleted: 42,
      documentUrl: '/uploads/cert_marcus.pdf',
    },
  });

  await prisma.mechanicService.createMany({
    data: [
      { mechanicId: mechanicProfile2.id, category: BreakdownCategory.COLLISION_ACCIDENT, priceEstimateMin: 120, priceEstimateMax: 400, description: 'Flatbed emergency towing and winching' },
      { mechanicId: mechanicProfile2.id, category: BreakdownCategory.TRANSMISSION_ISSUE, priceEstimateMin: 100, priceEstimateMax: 300, description: 'Roadside transmission lockout and tow' },
      { mechanicId: mechanicProfile2.id, category: BreakdownCategory.FUEL_EMPTY_OR_CONTAMINATED, priceEstimateMin: 40, priceEstimateMax: 90, description: 'Emergency 5-gallon fuel delivery' },
    ],
  });

  await prisma.mechanicLocation.create({
    data: {
      mechanicId: mechanicProfile2.id,
      latitude: 40.7306,
      longitude: -73.9352,
      heading: 180.0,
      speed: 15.0,
      accuracy: 8.0,
    },
  });
  console.log(`🔧 Mechanic 2 created: ${mechanicUser2.email} (Online & Verified)`);

  // 3. Seed Customers with Registered Vehicles
  const customer1 = await prisma.user.create({
    data: {
      email: 'customer.john@vbrs.local',
      passwordHash: commonPassword,
      fullName: 'Johnathan Doe',
      phone: '+1-555-0301',
      role: Role.CUSTOMER,
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
    },
  });

  await prisma.vehicle.createMany({
    data: [
      {
        userId: customer1.id,
        make: 'Toyota',
        model: 'Camry XSE',
        year: 2022,
        licensePlate: 'NYC-7842',
        vin: '4T1B11HK5NU123456',
        color: 'Midnight Black',
        powertrain: PowertrainType.PETROL,
        isDefault: true,
      },
      {
        userId: customer1.id,
        make: 'Tesla',
        model: 'Model 3 Long Range',
        year: 2023,
        licensePlate: 'EV-88219',
        vin: '5YJ3E1EB9PF654321',
        color: 'Pearl White',
        powertrain: PowertrainType.ELECTRIC,
        isDefault: false,
      },
    ],
  });
  console.log(`🚗 Customer 1 created: ${customer1.email} (with 2 vehicles)`);

  const customer2 = await prisma.user.create({
    data: {
      email: 'customer.sarah@vbrs.local',
      passwordHash: commonPassword,
      fullName: 'Sarah Connor',
      phone: '+1-555-0302',
      role: Role.CUSTOMER,
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    },
  });

  await prisma.vehicle.create({
    data: {
      userId: customer2.id,
      make: 'Ford',
      model: 'F-150 Lariat',
      year: 2021,
      licensePlate: 'TRK-9014',
      vin: '1FTFW1ED6MFC99887',
      color: 'Agate Black',
      powertrain: PowertrainType.PETROL,
      isDefault: true,
    },
  });
  console.log(`🚗 Customer 2 created: ${customer2.email} (with 1 vehicle)`);

  console.log('✅ Seeding completed successfully!');
  console.log('All seeded user credentials: Password@123');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { Role, VerificationStatus, ServiceRequestStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

describe('Experience Upgrade & Profile Enhancement E2E Suite', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customerToken: string;
  let customerUser: any;
  let otherCustomerToken: string;
  let otherCustomerUser: any;

  let mechanicToken: string;
  let mechanicUser: any;
  let mechanicProfile: any;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: false,
      }),
    );
    await app.init();
    prisma = app.get<PrismaService>(PrismaService);

    const passwordHash = await bcrypt.hash('Password@123', 10);
    const ts = Date.now();

    // 1. Create primary Customer
    customerUser = await prisma.user.create({
      data: {
        email: `cust_upgrade_${ts}@vbrs.local`,
        passwordHash,
        fullName: 'Eleanor Vance',
        phone: '+1-555-4001',
        role: Role.CUSTOMER,
      },
    });

    // 2. Create second Customer for tenant isolation checks
    otherCustomerUser = await prisma.user.create({
      data: {
        email: `cust_other_${ts}@vbrs.local`,
        passwordHash,
        fullName: 'Lucas Scott',
        phone: '+1-555-4002',
        role: Role.CUSTOMER,
      },
    });

    // 3. Create Mechanic with profile
    mechanicUser = await prisma.user.create({
      data: {
        email: `mech_upgrade_${ts}@vbrs.local`,
        passwordHash,
        fullName: 'Viktor Koenig',
        phone: '+1-555-5001',
        role: Role.MECHANIC,
      },
    });

    mechanicProfile = await prisma.mechanicProfile.create({
      data: {
        userId: mechanicUser.id,
        workshopName: 'Koenig Precision Garage',
        tradeLicenseNumber: 'ASE-KOENIG-01',
        verificationStatus: VerificationStatus.APPROVED,
        operatingRadiusKm: 30,
        experienceYears: 15,
        ratingAverage: 4.8,
      },
    });

    // Log in all actors to get signed JWT tokens
    const custLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: customerUser.email, password: 'Password@123' });
    customerToken = custLogin.body.tokens.accessToken;

    const otherCustLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: otherCustomerUser.email, password: 'Password@123' });
    otherCustomerToken = otherCustLogin.body.tokens.accessToken;

    const mechLogin = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: mechanicUser.email, password: 'Password@123' });
    mechanicToken = mechLogin.body.tokens.accessToken;
  });

  afterAll(async () => {
    // Clean up created entities
    if (customerUser) {
      await prisma.savedAddress.deleteMany({ where: { userId: customerUser.id } }).catch(() => {});
      await prisma.user.delete({ where: { id: customerUser.id } }).catch(() => {});
    }
    if (otherCustomerUser) {
      await prisma.user.delete({ where: { id: otherCustomerUser.id } }).catch(() => {});
    }
    if (mechanicUser) {
      await prisma.user.delete({ where: { id: mechanicUser.id } }).catch(() => {});
    }
    await app.close();
  });

  describe('Customer Saved Addresses & Overview APIs', () => {
    let createdAddressId: string;

    it('GET /api/customer/overview — returns complete customer summary', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/customer/overview')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(200);

      expect(res.body).toHaveProperty('profile');
      expect(res.body.profile.email).toBe(customerUser.email);
      expect(res.body).toHaveProperty('vehicles');
      expect(res.body).toHaveProperty('savedAddresses');
      expect(res.body).toHaveProperty('stats');
      expect(res.body.stats.savedLocationsCount).toBe(0);
    });

    it('POST /api/customer/saved-addresses — creates a new saved address bookmark', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/customer/saved-addresses')
        .set('Authorization', `Bearer ${customerToken}`)
        .send({
          label: 'Primary Residence',
          address: '420 Park Ave South, New York, NY 10016',
          latitude: 40.7431,
          longitude: -73.9845,
          isDefault: true,
        })
        .expect(201);

      expect(res.body).toHaveProperty('id');
      expect(res.body.label).toBe('Primary Residence');
      expect(res.body.address).toBe('420 Park Ave South, New York, NY 10016');
      expect(res.body.isDefault).toBe(true);
      createdAddressId = res.body.id;
    });

    it('GET /api/customer/saved-addresses — lists saved addresses for the customer', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/customer/saved-addresses')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(1);
      expect(res.body[0].id).toBe(createdAddressId);
    });

    it('DELETE /api/customer/saved-addresses/:id — enforces tenant isolation against other users', async () => {
      // User B cannot delete User A's address
      await request(app.getHttpServer())
        .delete(`/api/customer/saved-addresses/${createdAddressId}`)
        .set('Authorization', `Bearer ${otherCustomerToken}`)
        .expect(403);

      // Verify address still exists
      const check = await prisma.savedAddress.findUnique({ where: { id: createdAddressId } });
      expect(check).not.toBeNull();
    });

    it('DELETE /api/customer/saved-addresses/:id — permits owner to delete address', async () => {
      await request(app.getHttpServer())
        .delete(`/api/customer/saved-addresses/${createdAddressId}`)
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(200);

      const check = await prisma.savedAddress.findUnique({ where: { id: createdAddressId } });
      expect(check).toBeNull();
    });

    it('POST /api/customer/saved-addresses — rejects call from MECHANIC role (RBAC guard)', async () => {
      await request(app.getHttpServer())
        .post('/api/customer/saved-addresses')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .send({
          label: 'Workshop Yard',
          address: 'Industrial Zone 3',
        })
        .expect(403);
    });
  });

  describe('Mechanic Profile & Professional Credential Governance', () => {
    it('PUT /api/mechanic/profile — updates workshop address, specializations, bio, and radius', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/mechanic/profile')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .send({
          workshopName: 'Koenig Advanced Automotive',
          workshopAddress: '88 Industrial Parkway, Bay 4, Queens, NY',
          operatingRadiusKm: 45,
          experienceYears: 16,
          specializations: ['ECU Tuning', 'High-Voltage Hybrid', 'Suspension Overhaul'],
          certifications: ['ASE Master Tech', 'Bosch Diagnostic Specialist'],
          bio: 'Specialized in precision drivetrain and electrical triage.',
        })
        .expect(200);

      expect(res.body.workshopName).toBe('Koenig Advanced Automotive');
      expect(res.body.workshopAddress).toBe('88 Industrial Parkway, Bay 4, Queens, NY');
      expect(res.body.operatingRadiusKm).toBe(45);
      expect(res.body.experienceYears).toBe(16);
      expect(res.body.specializations).toEqual(['ECU Tuning', 'High-Voltage Hybrid', 'Suspension Overhaul']);
      expect(res.body.certifications).toEqual(['ASE Master Tech', 'Bosch Diagnostic Specialist']);
      expect(res.body.bio).toBe('Specialized in precision drivetrain and electrical triage.');
      expect(res.body.verificationStatus).toBe(VerificationStatus.APPROVED);
    });

    it('PUT /api/mechanic/profile — resetting tradeLicenseNumber resets verificationStatus to PENDING and logs audit trail', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/mechanic/profile')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .send({
          tradeLicenseNumber: 'ASE-NEW-LICENSE-999',
        })
        .expect(200);

      expect(res.body.tradeLicenseNumber).toBe('ASE-NEW-LICENSE-999');
      expect(res.body.verificationStatus).toBe(VerificationStatus.PENDING);
      expect(res.body.verificationNotes).toContain('Pending administrative credential audit');

      // Verify audit log entry was created
      const audit = await prisma.auditLog.findFirst({
        where: {
          action: 'MECHANIC_LICENSE_UPDATED_PENDING_AUDIT',
          entityId: mechanicProfile.id,
        },
      });
      expect(audit).not.toBeNull();
      expect((audit?.details as any)?.newLicense).toBe('ASE-NEW-LICENSE-999');
    });

    it('GET /api/mechanic/earnings — calculates earnings and completed jobs for technician', async () => {
      // Create a test breakdown and completed service request for this mechanic
      const breakdown = await prisma.breakdownReport.create({
        data: {
          customerId: customerUser.id,
          category: 'ENGINE_FAILURE',
          description: 'E2E Earnings Test',
          latitude: 40.7128,
          longitude: -74.006,
        },
      });

      const sr = await prisma.serviceRequest.create({
        data: {
          breakdownReportId: breakdown.id,
          customerId: customerUser.id,
          mechanicId: mechanicProfile.id,
          currentStatus: ServiceRequestStatus.COMPLETED,
          agreedQuote: 250,
          laborCost: 150,
          partsCost: 75,
          diagnosticQuote: 25,
          completedAt: new Date(),
        },
      });

      const res = await request(app.getHttpServer())
        .get('/api/mechanic/earnings')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .expect(200);

      expect(res.body).toHaveProperty('totalRevenue');
      expect(res.body.totalRevenue).toBeGreaterThanOrEqual(250);
      expect(res.body.totalLabor).toBeGreaterThanOrEqual(150);
      expect(res.body.totalParts).toBeGreaterThanOrEqual(75);
      expect(res.body.completedJobsCount).toBeGreaterThanOrEqual(1);
      expect(Array.isArray(res.body.recentPayoutRecords)).toBe(true);

      // Clean up test request
      await prisma.serviceRequest.delete({ where: { id: sr.id } });
      await prisma.breakdownReport.delete({ where: { id: breakdown.id } });
    });

    it('GET /api/mechanic/earnings — rejects CUSTOMER role (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/mechanic/earnings')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(403);
    });
  });

  describe('Service Requests History API', () => {
    it('GET /api/service-requests/history — returns completed requests for Customer', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/service-requests/history')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
    });

    it('GET /api/service-requests/history — returns completed requests for Mechanic', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/service-requests/history')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
    });
  });
});

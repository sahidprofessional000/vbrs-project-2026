import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import {
  AvailabilityStatus,
  VerificationStatus,
  ServiceRequestStatus,
  BreakdownCategory,
  SeverityLevel,
} from '@prisma/client';

describe('Milestone 4: Mechanic Portal, Availability & Haversine Proximity Suite (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customerToken: string;
  let customerId: string;

  let mechanic1Token: string;
  let mechanic1Id: string;
  let mechanic1ProfileId: string;

  let mechanic2Token: string;
  let mechanic2Id: string;
  let mechanic2ProfileId: string;

  let testReportId: string;
  let testServiceRequestId: string;

  const timestamp = Date.now();
  const customerEmail = `m4.customer.${timestamp}@vbrs.local`;
  const mechanic1Email = `m4.mech1.${timestamp}@vbrs.local`;
  const mechanic2Email = `m4.mech2.${timestamp}@vbrs.local`;
  const password = 'SecurePassword@2026';

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
        forbidNonWhitelisted: true,
      }),
    );
    app.use(cookieParser());
    await app.init();

    prisma = app.get<PrismaService>(PrismaService);

    // 1. Register Customer
    const regCust = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: customerEmail,
        password,
        fullName: 'Stranded Motorist M4',
        phone: '+1-555-5001',
      })
      .expect(201);
    customerToken = regCust.body.tokens.accessToken;
    customerId = regCust.body.user.id;

    // 2. Register Mechanic 1 (Downtown - close to customer)
    const regM1 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: mechanic1Email,
        password,
        fullName: 'Downtown Tech Master',
        phone: '+1-555-5002',
        role: 'MECHANIC',
        workshopName: 'Downtown Rapid Roadside',
        experienceYears: 10,
      })
      .expect(201);
    mechanic1Token = regM1.body.tokens.accessToken;
    mechanic1Id = regM1.body.user.id;

    // Set Mechanic 1 to APPROVED and AVAILABLE with coords: 40.7130, -74.0050 (~0.1 km from customer)
    const m1Profile = await prisma.mechanicProfile.findUnique({
      where: { userId: mechanic1Id },
    });
    mechanic1ProfileId = m1Profile!.id;

    await prisma.mechanicProfile.update({
      where: { id: mechanic1ProfileId },
      data: {
        verificationStatus: VerificationStatus.APPROVED,
        availabilityStatus: AvailabilityStatus.AVAILABLE,
        operatingRadiusKm: 25.0,
      },
    });

    await prisma.mechanicLocation.upsert({
      where: { mechanicId: mechanic1ProfileId },
      create: {
        mechanicId: mechanic1ProfileId,
        latitude: 40.7130,
        longitude: -74.0050,
      },
      update: {
        latitude: 40.7130,
        longitude: -74.0050,
      },
    });

    // 3. Register Mechanic 2 (Suburban - 35 km away)
    const regM2 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: mechanic2Email,
        password,
        fullName: 'Far Hills Auto Rescue',
        phone: '+1-555-5003',
        role: 'MECHANIC',
        workshopName: 'Far Hills Rescue Inc',
        experienceYears: 8,
      })
      .expect(201);
    mechanic2Token = regM2.body.tokens.accessToken;
    mechanic2Id = regM2.body.user.id;

    const m2Profile = await prisma.mechanicProfile.findUnique({
      where: { userId: mechanic2Id },
    });
    mechanic2ProfileId = m2Profile!.id;

    await prisma.mechanicProfile.update({
      where: { id: mechanic2ProfileId },
      data: {
        verificationStatus: VerificationStatus.APPROVED,
        availabilityStatus: AvailabilityStatus.AVAILABLE,
        operatingRadiusKm: 20.0, // Only 20km radius
      },
    });

    // Mechanic 2 is at 41.0000, -74.0000 (~32 km away from customer)
    await prisma.mechanicLocation.upsert({
      where: { mechanicId: mechanic2ProfileId },
      create: {
        mechanicId: mechanic2ProfileId,
        latitude: 41.0000,
        longitude: -74.0000,
      },
      update: {
        latitude: 41.0000,
        longitude: -74.0000,
      },
    });

    // 4. File a Breakdown Report by Customer at (40.7128, -74.0060)
    const repRes = await request(app.getHttpServer())
      .post('/api/breakdowns')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({
        category: BreakdownCategory.FLAT_TIRE_WHEEL,
        severity: SeverityLevel.MEDIUM,
        description: 'Tire blowout on highway shoulder near exit 14',
        latitude: 40.7128,
        longitude: -74.0060,
      })
      .expect(201);

    testReportId = repRes.body.id;
    testServiceRequestId = repRes.body.serviceRequest.id;
  }, 30000);

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  // =========================================================================
  // 1. MECHANIC PROFILE & AVAILABILITY TOGGLING
  // =========================================================================
  describe('Mechanic Profile & Availability Management', () => {
    it('GET /api/mechanic/profile returns full operational telemetry (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/mechanic/profile')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(200);

      expect(res.body.id).toBe(mechanic1ProfileId);
      expect(res.body.verificationStatus).toBe('APPROVED');
      expect(res.body.availabilityStatus).toBe('AVAILABLE');
      expect(res.body.operatingRadiusKm).toBe(25);
      expect(res.body.currentLocation).toBeDefined();
      expect(res.body.currentLocation.latitude).toBe(40.7130);
    });

    it('PUT /api/mechanic/profile updates operational radius and workshop name (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/mechanic/profile')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          workshopName: 'Downtown Elite Precision',
          operatingRadiusKm: 30.0,
          experienceYears: 12,
        })
        .expect(200);

      expect(res.body.workshopName).toBe('Downtown Elite Precision');
      expect(res.body.operatingRadiusKm).toBe(30);
      expect(res.body.experienceYears).toBe(12);
    });

    it('PUT /api/mechanic/profile rejects radius > 100km with 400 Bad Request', async () => {
      await request(app.getHttpServer())
        .put('/api/mechanic/profile')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          operatingRadiusKm: 150.0,
        })
        .expect(400);
    });

    it('PATCH /api/mechanic/availability toggles status between AVAILABLE and OFFLINE', async () => {
      // Toggle to OFFLINE
      const offRes = await request(app.getHttpServer())
        .patch('/api/mechanic/availability')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: 'OFFLINE' })
        .expect(200);

      expect(offRes.body.availabilityStatus).toBe('OFFLINE');

      // Toggle back to AVAILABLE
      const onRes = await request(app.getHttpServer())
        .patch('/api/mechanic/availability')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: 'AVAILABLE' })
        .expect(200);

      expect(onRes.body.availabilityStatus).toBe('AVAILABLE');
    });
  });

  // =========================================================================
  // 2. LOCATION TELEMETRY TRANSMISSION & VALIDATION
  // =========================================================================
  describe('Location Telemetry Transmission & Validation', () => {
    it('POST /api/mechanic/location updates GPS telemetry (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/mechanic/location')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          latitude: 40.7135,
          longitude: -74.0055,
          heading: 180.0,
          speed: 25.0,
          accuracy: 3.5,
        })
        .expect(200);

      expect(res.body.latitude).toBe(40.7135);
      expect(res.body.longitude).toBe(-74.0055);
      expect(res.body.speed).toBe(25);
    });

    it('POST /api/mechanic/location rejects invalid coordinates (latitude > 90) (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/mechanic/location')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          latitude: 95.0,
          longitude: -74.0055,
        })
        .expect(400);
    });
  });

  // =========================================================================
  // 3. OFFLINE MECHANICS MUST NOT RECEIVE DISPATCHES
  // =========================================================================
  describe('Offline Mechanic Isolation', () => {
    it('returns empty dispatch list when technician is OFFLINE', async () => {
      // Switch Mechanic 1 to OFFLINE
      await request(app.getHttpServer())
        .patch('/api/mechanic/availability')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: 'OFFLINE' })
        .expect(200);

      // Verify dispatches array is strictly empty
      const res = await request(app.getHttpServer())
        .get('/api/mechanic/dispatches')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(200);

      expect(res.body).toEqual([]);
    });

    it('forbids OFFLINE technician from accepting a dispatch (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/mechanic/dispatches/${testServiceRequestId}/accept`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(400);

      expect(res.body.message).toMatch(/must be in AVAILABLE status/i);
    });
  });

  // =========================================================================
  // 4. HAVERSINE PROXIMITY & BOUNDARY CONDITIONS
  // =========================================================================
  describe('Haversine Proximity Boundary Conditions', () => {
    beforeAll(async () => {
      // Set Mechanic 1 back to AVAILABLE
      await request(app.getHttpServer())
        .patch('/api/mechanic/availability')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: 'AVAILABLE' });
    });

    it('Mechanic 1 (~0.1 km away) receives the dispatch in their queue', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/mechanic/dispatches')
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(200);

      expect(res.body.length).toBeGreaterThanOrEqual(1);
      const match = res.body.find((d: any) => d.serviceRequestId === testServiceRequestId);
      expect(match).toBeDefined();
      expect(match.distanceKm).toBeLessThan(1.0); // Very close
      expect(match.estimatedArrivalMinutes).toBeDefined();
    });

    it('Mechanic 2 (~32 km away with 20km radius) does NOT receive the dispatch (Boundary Enforced)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/mechanic/dispatches')
        .set('Authorization', `Bearer ${mechanic2Token}`)
        .expect(200);

      const match = res.body.find((d: any) => d.serviceRequestId === testServiceRequestId);
      expect(match).toBeUndefined(); // Strictly excluded outside 20km radius
    });

    it('GET /api/mechanics/nearby returns Mechanic 1 and excludes distant Mechanic 2 for 10km radius', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/mechanics/nearby')
        .set('Authorization', `Bearer ${customerToken}`)
        .query({
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 10.0, // 10 km search
        })
        .expect(200);

      expect(res.body.length).toBeGreaterThanOrEqual(1);
      const m1 = res.body.find((m: any) => m.mechanicId === mechanic1ProfileId);
      const m2 = res.body.find((m: any) => m.mechanicId === mechanic2ProfileId);

      expect(m1).toBeDefined();
      expect(m2).toBeUndefined(); // Excluded because distance (~32km) > 10km radius
    });
  });

  // =========================================================================
  // 5. MECHANIC LOCATION PRIVACY PROTECTION
  // =========================================================================
  describe('Location Privacy Protection', () => {
    it('GET /api/mechanics/nearby returns fuzzed coordinates (~1.1 km resolution), protecting exact home address', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/mechanics/nearby')
        .set('Authorization', `Bearer ${customerToken}`)
        .query({
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 15.0,
        })
        .expect(200);

      const m1 = res.body.find((m: any) => m.mechanicId === mechanic1ProfileId);
      expect(m1).toBeDefined();
      expect(m1.approximateCoordinates).toBeDefined();

      // Coordinates should be rounded to 2 decimal places (e.g. 40.71, -74.01)
      const latStr = m1.approximateCoordinates.latitude.toString();
      const lonStr = m1.approximateCoordinates.longitude.toString();
      const latDecimals = latStr.includes('.') ? latStr.split('.')[1].length : 0;
      const lonDecimals = lonStr.includes('.') ? lonStr.split('.')[1].length : 0;

      expect(latDecimals).toBeLessThanOrEqual(2);
      expect(lonDecimals).toBeLessThanOrEqual(2);
    });
  });

  // =========================================================================
  // 6. ATOMIC TRANSACTION: PREVENT DUPLICATE JOB ACCEPTANCE
  // =========================================================================
  describe('Atomic Transaction & Duplicate Acceptance Prevention', () => {
    it('Mechanic 1 successfully accepts the dispatch (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/mechanic/dispatches/${testServiceRequestId}/accept`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(200);

      expect(res.body.id).toBe(testServiceRequestId);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.ACCEPTED);
      expect(res.body.mechanicId).toBe(mechanic1ProfileId);
      expect(res.body.acceptedAt).toBeDefined();

      // Verify Mechanic 1 status transitioned to ON_JOB in database
      const profile = await prisma.mechanicProfile.findUnique({
        where: { id: mechanic1ProfileId },
      });
      expect(profile?.availabilityStatus).toBe(AvailabilityStatus.ON_JOB);
    });

    it('Mechanic 2 attempting to claim the SAME dispatch is rejected with 409 Conflict', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/mechanic/dispatches/${testServiceRequestId}/accept`)
        .set('Authorization', `Bearer ${mechanic2Token}`)
        .expect(409);

      expect(res.body.message).toMatch(/already been claimed|assigned to another/i);
    });

    it('Mechanic 1 re-attempting to accept the already accepted dispatch also receives 409 Conflict', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/mechanic/dispatches/${testServiceRequestId}/accept`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .expect(409);

      expect(res.body.message).toMatch(/already been claimed|assigned to another/i);
    });
  });

  // =========================================================================
  // 7. ROLE-BASED ACCESS CONTROL
  // =========================================================================
  describe('Role-Based Access Control on Mechanic Endpoints', () => {
    it('forbids CUSTOMER role from accessing mechanic dispatches (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/mechanic/dispatches')
        .set('Authorization', `Bearer ${customerToken}`)
        .expect(403);
    });

    it('forbids unauthenticated request to /api/mechanic/profile (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/mechanic/profile')
        .expect(401);
    });
  });
});

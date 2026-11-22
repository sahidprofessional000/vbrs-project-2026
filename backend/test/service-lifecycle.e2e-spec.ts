import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import {
  Role,
  VerificationStatus,
  AvailabilityStatus,
  ServiceRequestStatus,
  BreakdownCategory,
  SeverityLevel,
} from '@prisma/client';

describe('Milestone 5: Service Lifecycle State Machine & Tracking E2E Suite', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customer1Token: string;
  let customer1Id: string;

  let customer2Token: string;
  let customer2Id: string;

  let mechanic1Token: string;
  let mechanic1Id: string;
  let mechanic1ProfileId: string;

  let mechanic2Token: string;
  let mechanic2Id: string;

  let adminToken: string;

  let serviceRequestId: string;
  let breakdownReportId: string;

  const timestamp = Date.now();
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

    // 1. Register Customer 1
    const regC1 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m5.cust1.${timestamp}@vbrs.local`,
        password,
        fullName: 'Marcus Vance (Customer 1)',
        phone: '+1-555-0191',
        role: Role.CUSTOMER,
      });
    customer1Token = regC1.body.tokens.accessToken;
    customer1Id = regC1.body.user.id;

    // 2. Register Customer 2 (Unrelated party)
    const regC2 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m5.cust2.${timestamp}@vbrs.local`,
        password,
        fullName: 'Diana Prince (Customer 2)',
        phone: '+1-555-0192',
        role: Role.CUSTOMER,
      });
    customer2Token = regC2.body.tokens.accessToken;
    customer2Id = regC2.body.user.id;

    // 3. Register Mechanic 1
    const regM1 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m5.mech1.${timestamp}@vbrs.local`,
        password,
        fullName: 'Ethan Hunt (Lead Tech)',
        phone: '+1-555-0193',
        role: Role.MECHANIC,
        workshopName: 'Hunt High-Performance Roadside',
      });
    mechanic1Token = regM1.body.tokens.accessToken;
    mechanic1Id = regM1.body.user.id;

    // Approve Mechanic 1 & initialize location
    const profM1 = await prisma.mechanicProfile.findUnique({
      where: { userId: mechanic1Id },
    });
    mechanic1ProfileId = profM1.id;
    await prisma.mechanicProfile.update({
      where: { id: profM1.id },
      data: {
        verificationStatus: VerificationStatus.APPROVED,
        availabilityStatus: AvailabilityStatus.AVAILABLE,
        operatingRadiusKm: 30.0,
      },
    });
    await prisma.mechanicLocation.upsert({
      where: { mechanicId: profM1.id },
      create: {
        mechanicId: profM1.id,
        latitude: 37.7749,
        longitude: -122.4194,
        heading: 90.0,
        speed: 35.0,
        accuracy: 5.0,
      },
      update: {
        latitude: 37.7749,
        longitude: -122.4194,
        heading: 90.0,
        speed: 35.0,
        accuracy: 5.0,
      },
    });

    // 4. Register Mechanic 2 (Unrelated technician)
    const regM2 = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m5.mech2.${timestamp}@vbrs.local`,
        password,
        fullName: 'Lucas Grey (Tech 2)',
        phone: '+1-555-0194',
        role: Role.MECHANIC,
        workshopName: 'Grey Roadside Ops',
      });
    mechanic2Token = regM2.body.tokens.accessToken;
    mechanic2Id = regM2.body.user.id;

    // 5. Register Admin
    const regAdm = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m5.admin.${timestamp}@vbrs.local`,
        password,
        fullName: 'Command Admin',
        phone: '+1-555-0195',
        role: Role.ADMIN,
      });
    adminToken = regAdm.body.tokens.accessToken;

    // 6. Create Breakdown Report as Customer 1
    const reportRes = await request(app.getHttpServer())
      .post('/api/breakdowns')
      .set('Authorization', `Bearer ${customer1Token}`)
      .field('category', BreakdownCategory.ENGINE_FAILURE)
      .field('severity', SeverityLevel.CRITICAL)
      .field('description', 'Engine shut down completely on highway shoulder with oil warning.')
      .field('latitude', '37.7755')
      .field('longitude', '-122.4180')
      .field('addressText', 'Highway 101 Northbound Mile 4');

    expect(reportRes.status).toBe(201);
    breakdownReportId = reportRes.body.id;
    serviceRequestId = reportRes.body.serviceRequest.id;

    // 7. Mechanic 1 claims the dispatch
    const acceptRes = await request(app.getHttpServer())
      .post(`/api/mechanic/dispatches/${serviceRequestId}/accept`)
      .set('Authorization', `Bearer ${mechanic1Token}`);

    expect(acceptRes.status).toBe(200);
    expect(acceptRes.body.currentStatus).toBe(ServiceRequestStatus.ACCEPTED);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  describe('Requirement 2: Authorization & Unauthorized Access Guards', () => {
    it('rejects unauthenticated requests to tracking endpoint (401 Unauthorized)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`);
      expect(res.status).toBe(401);
    });

    it('forbids unrelated customer from tracking another customer request (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${customer2Token}`);
      expect(res.status).toBe(403);
      expect(res.body.message).toContain('authorization');
    });

    it('forbids unrelated mechanic from tracking non-assigned request (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${mechanic2Token}`);
      expect(res.status).toBe(403);
    });

    it('returns 404 for non-existent service request ID', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/service-requests/non-existent-uuid-1234/tracking')
        .set('Authorization', `Bearer ${customer1Token}`);
      expect(res.status).toBe(404);
    });

    it('allows owner customer and assigned mechanic to access tracking data (200 OK)', async () => {
      const custRes = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${customer1Token}`);
      expect(custRes.status).toBe(200);
      expect(custRes.body.serviceRequestId).toBe(serviceRequestId);
      expect(custRes.body.currentStatus).toBe(ServiceRequestStatus.ACCEPTED);

      const mechRes = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${mechanic1Token}`);
      expect(mechRes.status).toBe(200);
      expect(mechRes.body.mechanic.workshopName).toBe('Hunt High-Performance Roadside');
    });
  });

  describe('Requirement 1 & 7: Service Lifecycle FSM & Illegal Transition Prevention', () => {
    it('rejects illegal state skip from ACCEPTED directly to COMPLETED (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: ServiceRequestStatus.COMPLETED });

      expect(res.status).toBe(400);
      expect(res.body.message).toContain('Invalid lifecycle transition');
    });

    it('rejects illegal state skip from ACCEPTED directly to ARRIVED (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: ServiceRequestStatus.ARRIVED });

      expect(res.status).toBe(400);
    });

    it('forbids customer from advancing milestone status to EN_ROUTE (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ status: ServiceRequestStatus.EN_ROUTE });

      expect(res.status).toBe(403);
    });

    it('allows assigned mechanic to transition to EN_ROUTE and sets enRouteAt timestamp (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          status: ServiceRequestStatus.EN_ROUTE,
          notes: 'Technician departed garage; en route via arterial highway.',
        });

      expect(res.status).toBe(200);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.EN_ROUTE);
      expect(res.body.timestamps.enRouteAt).not.toBeNull();
    });

    it('allows assigned mechanic to transition from EN_ROUTE to ARRIVED (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          status: ServiceRequestStatus.ARRIVED,
          notes: 'Arrived at incident site; positioning emergency safety cones.',
        });

      expect(res.status).toBe(200);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.ARRIVED);
      expect(res.body.timestamps.arrivedAt).not.toBeNull();
    });
  });

  describe('Requirement 8: Diagnostic Quotations, Labour and Parts Costs', () => {
    it('records diagnostic quote, parts, and labor costs from assigned mechanic (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/service-requests/${serviceRequestId}/quote`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          diagnosticQuote: 65.0,
          laborCost: 120.0,
          partsCost: 85.0,
          notes: 'OBD-II showed P0300 multi-cylinder misfire. Ignition coil replacement.',
        });

      expect(res.status).toBe(200);
      expect(res.body.quote.diagnosticQuote).toBe(65.0);
      expect(res.body.quote.laborCost).toBe(120.0);
      expect(res.body.quote.partsCost).toBe(85.0);
      expect(res.body.quote.agreedQuote).toBe(270.0); // 65 + 120 + 85
    });

    it('forbids unauthorized customer from modifying service quotation (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/service-requests/${serviceRequestId}/quote`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ diagnosticQuote: 10.0 });

      expect(res.status).toBe(403);
    });
  });

  describe('Requirement 5 & 6: GPS Freshness, Accurate Telemetry & Location Sharing Consent', () => {
    it('calculates accurate Haversine distance and non-fabricated ETA', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${customer1Token}`);

      expect(res.status).toBe(200);
      expect(res.body.liveTelemetry).not.toBeNull();
      expect(res.body.liveTelemetry.distanceKm).toBeGreaterThan(0);
      expect(res.body.liveTelemetry.estimatedArrivalMinutes).toBeGreaterThanOrEqual(0);
      expect(res.body.liveTelemetry.isStale).toBe(false);
      expect(res.body.liveTelemetry.locationSharingConsent).toBe(true);
    });

    it('suppresses precise coordinates when customer revokes location consent', async () => {
      // Customer toggles consent to false
      const consentRes = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/location-consent`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ locationConsent: false });

      expect(consentRes.status).toBe(200);
      expect(consentRes.body.locationConsent).toBe(false);
      expect(consentRes.body.liveTelemetry.coordinates).toBeNull();

      // Customer restores consent
      const restoreRes = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/location-consent`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ locationConsent: true });

      expect(restoreRes.status).toBe(200);
      expect(restoreRes.body.liveTelemetry.coordinates).not.toBeNull();
      expect(restoreRes.body.liveTelemetry.coordinates.latitude).toBe(37.7749);
    });
  });

  describe('Requirement 1 & 9: Completion Workflow, History Timestamps & Terminal Protection', () => {
    it('advances status from ARRIVED to IN_PROGRESS (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          status: ServiceRequestStatus.IN_PROGRESS,
          notes: 'Disassembled ignition harness; installing new OEM coils.',
        });

      expect(res.status).toBe(200);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.IN_PROGRESS);
      expect(res.body.timestamps.inProgressAt).not.toBeNull();
    });

    it('completes service with resolution notes and resets mechanic to AVAILABLE (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({
          status: ServiceRequestStatus.COMPLETED,
          resolutionNotes: 'Replaced ignition coil pack #3, cleared DTC trouble codes, engine running smoothly at idle.',
        });

      expect(res.status).toBe(200);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.COMPLETED);
      expect(res.body.timestamps.completedAt).not.toBeNull();
      expect(res.body.quote.resolutionNotes).toContain('Replaced ignition coil pack');

      // Verify mechanic availability is restored to AVAILABLE in database
      const mechProf = await prisma.mechanicProfile.findUnique({
        where: { id: mechanic1ProfileId },
      });
      expect(mechProf.availabilityStatus).toBe(AvailabilityStatus.AVAILABLE);
      expect(mechProf.totalJobsCompleted).toBeGreaterThanOrEqual(1);
    });

    it('rejects duplicate completion or status change on completed request (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${serviceRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: ServiceRequestStatus.COMPLETED });

      expect(res.status).toBe(400);
      expect(res.body.message).toContain('terminal state');
    });

    it('forbids cancellation after service has already completed (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/service-requests/${serviceRequestId}/cancel`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ reason: 'Attempting to cancel already completed job' });

      expect(res.status).toBe(400);
    });

    it('verifies complete chronological status history timeline', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/service-requests/${serviceRequestId}/tracking`)
        .set('Authorization', `Bearer ${customer1Token}`);

      expect(res.status).toBe(200);
      const history = res.body.statusHistory;
      expect(history.length).toBeGreaterThanOrEqual(5);

      const statuses = history.map((h: any) => h.toStatus);
      expect(statuses).toContain(ServiceRequestStatus.SUBMITTED);
      expect(statuses).toContain(ServiceRequestStatus.ACCEPTED);
      expect(statuses).toContain(ServiceRequestStatus.EN_ROUTE);
      expect(statuses).toContain(ServiceRequestStatus.ARRIVED);
      expect(statuses).toContain(ServiceRequestStatus.IN_PROGRESS);
      expect(statuses).toContain(ServiceRequestStatus.COMPLETED);
    });
  });

  describe('Cancellation Workflow & Technician Release', () => {
    let cancelRequestId: string;

    beforeAll(async () => {
      // Create second breakdown to test cancellation
      const reportRes = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customer1Token}`)
        .field('category', BreakdownCategory.FLAT_TIRE_WHEEL)
        .field('severity', SeverityLevel.MEDIUM)
        .field('description', 'Flat passenger tire in driveway.')
        .field('latitude', '37.7750')
        .field('longitude', '-122.4190');

      cancelRequestId = reportRes.body.serviceRequest.id;

      // Mechanic 1 accepts dispatch (moves to ON_JOB)
      await request(app.getHttpServer())
        .post(`/api/mechanic/dispatches/${cancelRequestId}/accept`)
        .set('Authorization', `Bearer ${mechanic1Token}`);
    });

    it('cancels active service request with reason and releases technician (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/service-requests/${cancelRequestId}/cancel`)
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ reason: 'Spare tire located; vehicle changed independently.' });

      expect(res.status).toBe(200);
      expect(res.body.currentStatus).toBe(ServiceRequestStatus.CANCELLED);
      expect(res.body.timestamps.cancelledAt).not.toBeNull();
      expect(res.body.quote.cancellationReason).toContain('Spare tire located');

      // Verify technician released back to AVAILABLE
      const mechProf = await prisma.mechanicProfile.findUnique({
        where: { id: mechanic1ProfileId },
      });
      expect(mechProf.availabilityStatus).toBe(AvailabilityStatus.AVAILABLE);
    });

    it('rejects status progression on a cancelled service request (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/service-requests/${cancelRequestId}/status`)
        .set('Authorization', `Bearer ${mechanic1Token}`)
        .send({ status: ServiceRequestStatus.EN_ROUTE });

      expect(res.status).toBe(400);
      expect(res.body.message).toContain('terminal state');
    });
  });
});

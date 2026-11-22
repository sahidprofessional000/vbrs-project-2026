import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { AuthService } from '../src/modules/auth/auth.service';
import {
  Role,
  BreakdownCategory,
  SeverityLevel,
  PowertrainType,
  ServiceRequestStatus,
  VerificationStatus,
} from '@prisma/client';

describe('Milestone 7: Rule-Based Expert Diagnostics & Customer Reputation Scoring (E2E)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let authService: AuthService;

  let customer1Token: string;
  let customer1Id: string;
  let customer2Token: string;
  let customer2Id: string;

  let mechanicUserId: string;
  let mechanicProfileId: string;

  let completedRequestId1: string;
  let completedRequestId2: string;
  let inProgressRequestId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
      }),
    );
    app.setGlobalPrefix('api');
    await app.init();

    prisma = app.get<PrismaService>(PrismaService);
    authService = app.get<AuthService>(AuthService);

    // 1. Setup Customer 1
    const uniqueSuffix = Date.now();
    const cust1 = await authService.register({
      email: `m7.customer1.${uniqueSuffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Marcus Vance',
      role: Role.CUSTOMER,
      phone: '+1-555-0101',
    });
    customer1Token = cust1.tokens.accessToken;
    customer1Id = cust1.user.id;

    // 2. Setup Customer 2
    const cust2 = await authService.register({
      email: `m7.customer2.${uniqueSuffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Elena Rostova',
      role: Role.CUSTOMER,
      phone: '+1-555-0102',
    });
    customer2Token = cust2.tokens.accessToken;
    customer2Id = cust2.user.id;

    // 3. Setup Field Mechanic
    const mechUser = await authService.register({
      email: `m7.mechanic.${uniqueSuffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'David Sterling',
      role: Role.MECHANIC,
      phone: '+1-555-0199',
    });
    mechanicUserId = mechUser.user.id;

    const profile = await prisma.mechanicProfile.update({
      where: { userId: mechanicUserId },
      data: {
        workshopName: 'Sterling Diagnostic Lab',
        tradeLicenseNumber: `ASE-M7-${uniqueSuffix}`,
        verificationStatus: VerificationStatus.APPROVED,
        operatingRadiusKm: 40.0,
        ratingAverage: 0.0,
        totalReviews: 0,
        totalJobsCompleted: 5,
      },
    });
    mechanicProfileId = profile.id;

    // 4. Setup Completed Service Request 1 (Belongs to Customer 1)
    const breakdown1 = await prisma.breakdownReport.create({
      data: {
        customerId: customer1Id,
        category: BreakdownCategory.ENGINE_FAILURE,
        severity: SeverityLevel.CRITICAL,
        description: 'Engine stalled with metallic knock on I-95.',
        latitude: 40.7128,
        longitude: -74.006,
        requiresTowing: true,
      },
    });

    const sReq1 = await prisma.serviceRequest.create({
      data: {
        breakdownReportId: breakdown1.id,
        customerId: customer1Id,
        mechanicId: mechanicProfileId,
        currentStatus: ServiceRequestStatus.COMPLETED,
        agreedQuote: 350.0,
        completedAt: new Date(),
      },
    });
    completedRequestId1 = sReq1.id;

    // 5. Setup Completed Service Request 2 (Belongs to Customer 2)
    const breakdown2 = await prisma.breakdownReport.create({
      data: {
        customerId: customer2Id,
        category: BreakdownCategory.FLAT_TIRE_WHEEL,
        severity: SeverityLevel.MEDIUM,
        description: 'Sidewall puncture on Turnpike.',
        latitude: 40.73,
        longitude: -74.02,
        requiresTowing: false,
      },
    });

    const sReq2 = await prisma.serviceRequest.create({
      data: {
        breakdownReportId: breakdown2.id,
        customerId: customer2Id,
        mechanicId: mechanicProfileId,
        currentStatus: ServiceRequestStatus.COMPLETED,
        agreedQuote: 120.0,
        completedAt: new Date(),
      },
    });
    completedRequestId2 = sReq2.id;

    // 6. Setup In-Progress Service Request (Uncompleted, belongs to Customer 1)
    const breakdown3 = await prisma.breakdownReport.create({
      data: {
        customerId: customer1Id,
        category: BreakdownCategory.BATTERY_DEAD_ELECTRICAL,
        severity: SeverityLevel.MEDIUM,
        description: 'Battery dead in garage.',
        latitude: 40.72,
        longitude: -74.01,
      },
    });

    const sReq3 = await prisma.serviceRequest.create({
      data: {
        breakdownReportId: breakdown3.id,
        customerId: customer1Id,
        mechanicId: mechanicProfileId,
        currentStatus: ServiceRequestStatus.IN_PROGRESS,
      },
    });
    inProgressRequestId = sReq3.id;
  });

  afterAll(async () => {
    await app.close();
  });

  // ===========================================================================
  // SECTION 1: RULE-BASED EXPERT DIAGNOSTIC DECISION ENGINE
  // ===========================================================================
  describe('1. Rule-Based Expert Diagnostic Decision Engine', () => {
    it('evaluates ICE coolant overheating with scalding safety warnings and towing verdict', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/diagnostics/evaluate')
        .send({
          category: BreakdownCategory.OVERHEATING_COOLANT,
          severity: SeverityLevel.CRITICAL,
          powertrain: PowertrainType.PETROL,
          description: 'White steam pouring from engine bay, temp gauge pinned in red.',
          symptoms: ['white_smoke', 'fluid_leak'],
          warningLights: ['coolant_temp'],
          roadsideContext: 'HIGHWAY_SHOULDER',
        })
        .expect(200);

      expect(res.body.isPreliminary).toBe(true);
      expect(res.body.requiresTowing).toBe(true);
      expect(res.body.towingVerdict).toBe('MANDATORY FLATBED RECOVERY');
      expect(res.body.disclaimer).toContain('PRELIMINARY ADVISORY ONLY');

      // Verify scalding safety warning
      const scaldingWarning = res.body.criticalSafetyWarnings.find((w: string) =>
        w.includes('SCALDING HAZARD') || w.includes('radiator cap'),
      );
      expect(scaldingWarning).toBeDefined();

      // Verify highway barrier advisory
      const highwayAdvisory = res.body.criticalSafetyWarnings.find((w: string) =>
        w.includes('guardrail') || w.includes('barrier'),
      );
      expect(highwayAdvisory).toBeDefined();

      // Verify hypothesis
      expect(res.body.hypotheses.length).toBeGreaterThan(0);
      expect(res.body.hypotheses[0].subsystem).toBeDefined();
      expect(res.body.hypotheses[0].estimatedLaborHours).toBeDefined();
    });

    it('evaluates Electric Vehicle (EV) battery fault with 800V safety warnings and no-flat-tow mandate', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/diagnostics/evaluate')
        .send({
          category: BreakdownCategory.BATTERY_DEAD_ELECTRICAL,
          severity: SeverityLevel.CRITICAL,
          powertrain: PowertrainType.ELECTRIC,
          description: 'EV powertrain alert on central display, car bricked on ramp.',
          warningLights: ['battery_charge'],
        })
        .expect(200);

      expect(res.body.isPreliminary).toBe(true);
      expect(res.body.powertrain).toBe('ELECTRIC');
      expect(res.body.towingVerdict).toBe('SPECIALIZED EV FLATBED CARRIER');

      // Verify high-voltage safety warning
      const hvWarning = res.body.criticalSafetyWarnings.find((w: string) =>
        w.includes('400V–800V') || w.includes('orange insulated'),
      );
      expect(hvWarning).toBeDefined();

      // Verify back-EMF / flatbed recovery mandate
      const flatbedMandate = res.body.criticalSafetyWarnings.find((w: string) =>
        w.includes('FLATBED RECOVERY MANDATORY FOR EV/HYBRID') || w.includes('back-EMF'),
      );
      expect(flatbedMandate).toBeDefined();
    });

    it('evaluates Brake Failure with catastrophic braking loss warnings and immediate halt directive', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/diagnostics/evaluate')
        .send({
          category: BreakdownCategory.BRAKE_SYSTEM_FAILURE,
          severity: SeverityLevel.CRITICAL,
          description: 'Brake pedal went straight to the floorboard.',
          symptoms: ['spongy_pedal'],
          warningLights: ['brake_warning'],
        })
        .expect(200);

      expect(res.body.requiresTowing).toBe(true);
      const brakeWarning = res.body.criticalSafetyWarnings.find((w: string) =>
        w.includes('DO NOT DRIVE UNDER ANY CIRCUMSTANCES'),
      );
      expect(brakeWarning).toBeDefined();
      expect(res.body.immediateActionChecklist).toContain('Firmly engage mechanical emergency handbrake or electronic parking brake.');
    });

    it('evaluates Flat Tire puncture as eligible for mobile roadside repair', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/diagnostics/evaluate')
        .send({
          category: BreakdownCategory.FLAT_TIRE_WHEEL,
          severity: SeverityLevel.LOW,
          description: 'Nail caught in right rear tire tread.',
        })
        .expect(200);

      expect(res.body.requiresTowing).toBe(false);
      expect(res.body.towingVerdict).toBe('MOBILE ROADSIDE FIELD SERVICE ELIGIBLE');
      expect(res.body.recommendedEquipment).toContain('3-Ton Heavy-Duty Pneumatic Jack');
    });

    it('returns official legal disclaimer on GET /api/diagnostics/disclaimer', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/diagnostics/disclaimer')
        .expect(200);

      expect(res.body.disclaimer).toContain('PRELIMINARY ADVISORY ONLY');
      expect(res.body.isPreliminary).toBe(true);
    });
  });

  // ===========================================================================
  // SECTION 2: CUSTOMER RATING & REVIEW VALIDATION & LIFECYCLE GUARDS
  // ===========================================================================
  describe('2. Customer Rating & Review Validation & Lifecycle Guards', () => {
    it('rejects review submission for uncompleted (IN_PROGRESS) service requests (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({
          serviceRequestId: inProgressRequestId,
          rating: 5,
          comment: 'Premature review attempt',
        })
        .expect(400);

      expect(res.body.message).toContain('Reviews can only be submitted for COMPLETED service requests');
    });

    it('forbids unrelated customer from submitting review for another user service request (403 Forbidden)', async () => {
      // Customer 2 attempts to review Customer 1's request
      const res = await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer2Token}`)
        .send({
          serviceRequestId: completedRequestId1,
          rating: 4,
          comment: 'Fraudulent cross-tenant review',
        })
        .expect(403);

      expect(res.body.message).toContain('Only the motorist who requested this roadside assistance');
    });

    it('rejects invalid rating scores outside [1, 5] range (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({
          serviceRequestId: completedRequestId1,
          rating: 6, // Exceeds max 5
        })
        .expect(400);

      await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({
          serviceRequestId: completedRequestId1,
          rating: 0, // Below min 1
        })
        .expect(400);
    });

    it('allows verified customer to submit 5-star review on completed request (201 Created)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({
          serviceRequestId: completedRequestId1,
          rating: 5,
          comment: 'Alex arrived in 8 minutes and diagnosed the engine stall accurately. Professional work.',
          timelinessRating: 5,
          costFairnessRating: 5,
          professionalismRating: 5,
        })
        .expect(201);

      expect(res.body.review.id).toBeDefined();
      expect(res.body.review.rating).toBe(5);
      expect(res.body.updatedReputation.ratingAverage).toBe(5.0);
      expect(res.body.updatedReputation.totalReviews).toBe(1);
    });

    it('forbids duplicate review submission for the same completed service request (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({
          serviceRequestId: completedRequestId1,
          rating: 4,
          comment: 'Duplicate review attempt.',
        })
        .expect(400);

      expect(res.body.message).toContain('A formal review has already been submitted');
    });
  });

  // ===========================================================================
  // SECTION 3: TECHNICIAN REPUTATION SCORING ENGINE & POSTGRESQL PERSISTENCE
  // ===========================================================================
  describe('3. Technician Reputation Scoring Engine & Mathematics', () => {
    it('mathematically updates mechanic rating average on second review submission', async () => {
      // Customer 2 submits a 3-star review on their completed request
      const res = await request(app.getHttpServer())
        .post('/api/reviews')
        .set('Authorization', `Bearer ${customer2Token}`)
        .send({
          serviceRequestId: completedRequestId2,
          rating: 3,
          comment: 'Service completed, but dispatch took longer than estimated.',
          timelinessRating: 2,
          costFairnessRating: 4,
          professionalismRating: 4,
        })
        .expect(201);

      // (5 + 3) / 2 = 4.00
      expect(res.body.updatedReputation.ratingAverage).toBe(4.0);
      expect(res.body.updatedReputation.totalReviews).toBe(2);

      // Verify database record directly in PostgreSQL
      const dbProfile = await prisma.mechanicProfile.findUnique({
        where: { id: mechanicProfileId },
      });
      expect(dbProfile?.ratingAverage).toBe(4.0);
      expect(dbProfile?.totalReviews).toBe(2);
    });

    it('retrieves public review ledger for mechanic (GET /api/reviews/mechanic/:id)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/reviews/mechanic/${mechanicProfileId}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBe(2);
      expect(res.body[0].customer.fullName).toBeDefined();
    });

    it('computes transparent mathematical reputation and Bayesian score (GET /api/reviews/mechanic/:id/reputation)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/reviews/mechanic/${mechanicProfileId}/reputation`)
        .expect(200);

      expect(res.body.totalReviews).toBe(2);
      expect(res.body.arithmeticAverage).toBe(4.0);

      // Bayesian calculation verification:
      // W = (2 / (2 + 2)) * 4.0 + (2 / (2 + 2)) * 4.5 = 0.5 * 4.0 + 0.5 * 4.5 = 4.25
      expect(res.body.bayesianReputationScore).toBe(4.25);

      // Verify star distribution counts
      expect(res.body.ratingDistribution.fiveStar).toBe(1);
      expect(res.body.ratingDistribution.threeStar).toBe(1);
      expect(res.body.ratingDistribution.fourStar).toBe(0);

      // Verify sub-scores
      // Timeliness: (5 + 2) / 2 = 3.5
      expect(res.body.subScores.averageTimeliness).toBe(3.5);
      // Cost fairness: (5 + 4) / 2 = 4.5
      expect(res.body.subScores.averageCostFairness).toBe(4.5);
    });

    it('verifies tamper-evident audit log entries created for review submissions', async () => {
      const auditEntries = await prisma.auditLog.findMany({
        where: {
          action: 'CUSTOMER_REVIEW_SUBMITTED',
          entityName: 'Review',
        },
      });

      expect(auditEntries.length).toBeGreaterThanOrEqual(2);
      expect(auditEntries[0].userId).toBeDefined();
      expect(auditEntries[0].details).toBeDefined();
    });
  });
});

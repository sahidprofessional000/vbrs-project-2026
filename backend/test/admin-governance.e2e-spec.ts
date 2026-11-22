import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import {
  Role,
  VerificationStatus,
  ComplaintStatus,
  BreakdownCategory,
  SeverityLevel,
} from '@prisma/client';

describe('Milestone 6: Admin Governance, Dispute Manager & SQL Analytics E2E Suite', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let adminToken: string;
  let adminUserId: string;

  let customerToken: string;
  let customerUserId: string;

  let pendingMechanicToken: string;
  let pendingMechanicUserId: string;
  let pendingMechanicProfileId: string;

  let serviceRequestId: string;
  let filedComplaintId: string;

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

    // 1. Register Admin
    const regAdm = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m6.admin.${timestamp}@vbrs.local`,
        password,
        fullName: 'Chief Inspector Kane',
        phone: '+1-555-0800',
        role: Role.ADMIN,
      });
    adminToken = regAdm.body.tokens.accessToken;
    adminUserId = regAdm.body.user.id;

    // 2. Register Customer
    const regCust = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m6.customer.${timestamp}@vbrs.local`,
        password,
        fullName: 'Eleanor Sterling',
        phone: '+1-555-0801',
        role: Role.CUSTOMER,
      });
    customerToken = regCust.body.tokens.accessToken;
    customerUserId = regCust.body.user.id;

    // 3. Register Pending Field Mechanic
    const regMech = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: `m6.pending.mech.${timestamp}@vbrs.local`,
        password,
        fullName: 'Derrick Moss',
        phone: '+1-555-0802',
        role: Role.MECHANIC,
        workshopName: 'Moss Specialized Mobile Workshop',
        tradeLicenseNumber: 'ASE-MASTER-88391',
        experienceYears: 7,
      });
    pendingMechanicToken = regMech.body.tokens.accessToken;
    pendingMechanicUserId = regMech.body.user.id;

    const profile = await prisma.mechanicProfile.findUnique({
      where: { userId: pendingMechanicUserId },
    });
    pendingMechanicProfileId = profile.id;

    // 4. File a breakdown incident to associate complaints
    const reportRes = await request(app.getHttpServer())
      .post('/api/breakdowns')
      .set('Authorization', `Bearer ${customerToken}`)
      .field('category', BreakdownCategory.BRAKE_SYSTEM_FAILURE)
      .field('severity', SeverityLevel.CRITICAL)
      .field('description', 'Brake pedal collapsed to floorboards on exit ramp.')
      .field('latitude', '40.7128')
      .field('longitude', '-74.0060')
      .field('addressText', 'Exit 14C Hudson Toll Plaza');

    serviceRequestId = reportRes.body.serviceRequest.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  describe('1. Role-Based Access Control on Administrative Gate', () => {
    it('forbids unauthenticated access to admin endpoints (401 Unauthorized)', async () => {
      const res = await request(app.getHttpServer()).get('/api/admin/mechanics');
      expect(res.status).toBe(401);
    });

    it('forbids customer role from accessing admin verification desk (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/mechanics')
        .set('Authorization', `Bearer ${customerToken}`);
      expect(res.status).toBe(403);
    });

    it('forbids mechanic role from accessing admin analytics (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/analytics/overview')
        .set('Authorization', `Bearer ${pendingMechanicToken}`);
      expect(res.status).toBe(403);
    });
  });

  describe('2. Field Technician Verification Desk', () => {
    it('allows admin to list pending mechanic applications (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/mechanics?status=PENDING')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      const found = res.body.find((m: any) => m.id === pendingMechanicProfileId);
      expect(found).toBeDefined();
      expect(found.verificationStatus).toBe(VerificationStatus.PENDING);
      expect(found.workshopName).toBe('Moss Specialized Mobile Workshop');
    });

    it('allows admin to approve technician credentials and records audit log (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/admin/mechanics/${pendingMechanicProfileId}/verify`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          status: VerificationStatus.APPROVED,
          notes: 'ASE Master Certificate #88391 confirmed valid with State Board.',
        });

      expect(res.status).toBe(200);
      expect(res.body.verificationStatus).toBe(VerificationStatus.APPROVED);
      expect(res.body.verificationNotes).toContain('ASE Master Certificate');

      // Verify database persistence
      const dbProfile = await prisma.mechanicProfile.findUnique({
        where: { id: pendingMechanicProfileId },
      });
      expect(dbProfile.verificationStatus).toBe(VerificationStatus.APPROVED);

      // Verify audit log
      const audit = await prisma.auditLog.findFirst({
        where: {
          entityId: pendingMechanicProfileId,
          action: 'MECHANIC_VERIFICATION_APPROVED',
        },
      });
      expect(audit).toBeDefined();
      expect(audit.userId).toBe(adminUserId);
    });
  });

  describe('3. Municipal Dispute & Complaint Manager', () => {
    it('allows motorist to file a grievance against a service request (201 Created)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/complaints')
        .set('Authorization', `Bearer ${customerToken}`)
        .send({
          serviceRequestId,
          subject: 'Late Arrival & Tow Rig Discrepancy',
          description: 'Flatbed recovery arrived 45 minutes beyond scheduled ETA window.',
        });

      expect(res.status).toBe(201);
      expect(res.body.id).toBeDefined();
      expect(res.body.status).toBe(ComplaintStatus.PENDING);
      expect(res.body.subject).toBe('Late Arrival & Tow Rig Discrepancy');
      filedComplaintId = res.body.id;
    });

    it('forbids unrelated user from filing complaint on third-party service request (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/complaints')
        .set('Authorization', `Bearer ${pendingMechanicToken}`)
        .send({
          serviceRequestId,
          subject: 'Unauthorized Intrusion Attempt',
          description: 'Testing non-authorized tenant filing.',
        });

      expect(res.status).toBe(403);
    });

    it('allows customer to view only their own filed complaints (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/complaints')
        .set('Authorization', `Bearer ${customerToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThanOrEqual(1);
      expect(res.body[0].id).toBe(filedComplaintId);
    });

    it('allows admin to list all municipal disputes across the platform (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/complaints')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      const found = res.body.find((c: any) => c.id === filedComplaintId);
      expect(found).toBeDefined();
    });

    it('allows admin to advance dispute status to INVESTIGATING and RESOLVED (200 OK)', async () => {
      // Step 1: INVESTIGATING
      const invRes = await request(app.getHttpServer())
        .patch(`/api/admin/complaints/${filedComplaintId}/status`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          status: ComplaintStatus.INVESTIGATING,
          resolutionNotes: 'Contacted fleet dispatch log to verify arterial traffic delay.',
        });

      expect(invRes.status).toBe(200);
      expect(invRes.body.status).toBe(ComplaintStatus.INVESTIGATING);

      // Step 2: RESOLVED
      const resRes = await request(app.getHttpServer())
        .patch(`/api/admin/complaints/${filedComplaintId}/status`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          status: ComplaintStatus.RESOLVED,
          resolutionNotes: 'Traffic bottleneck verified on camera feed. Courtesy credit applied.',
        });

      expect(resRes.status).toBe(200);
      expect(resRes.body.status).toBe(ComplaintStatus.RESOLVED);
      expect(resRes.body.resolvedAt).not.toBeNull();
    });
  });

  describe('4. PostgreSQL Real-Time Operational Analytics (Zero Mock Statistics)', () => {
    it('returns real database aggregation KPIs and SQL groupings (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/analytics/overview')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      const { fleetMetrics, responseTiming, categoryDistribution, topMechanics } = res.body;

      // Real DB counts
      expect(fleetMetrics.totalIncidents).toBeGreaterThan(0);
      expect(fleetMetrics.totalDrivers).toBeGreaterThan(0);
      expect(fleetMetrics.totalMechanics).toBeGreaterThan(0);
      expect(fleetMetrics.approvedMechanics).toBeGreaterThan(0);
      expect(typeof fleetMetrics.towingPercentage).toBe('number');

      // Response timings
      expect(responseTiming.avgDispatchLatencyMinutes).toBeGreaterThanOrEqual(0);

      // Breakdown distribution
      expect(Array.isArray(categoryDistribution)).toBe(true);

      // Top Mechanics
      expect(Array.isArray(topMechanics)).toBe(true);
    });
  });

  describe('5. Security Audit Log Explorer', () => {
    it('returns real security audit logs with pagination and user attribution (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/audit-logs?limit=10')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.logs)).toBe(true);
      expect(res.body.logs.length).toBeGreaterThan(0);
      expect(res.body.pagination.total).toBeGreaterThan(0);
      expect(res.body.pagination.limit).toBe(10);

      // Verify audit log structure
      const sample = res.body.logs[0];
      expect(sample.id).toBeDefined();
      expect(sample.action).toBeDefined();
      expect(sample.entityName).toBeDefined();
      expect(sample.timestamp).toBeDefined();
    });

    it('filters audit logs by action query parameter (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/admin/audit-logs?action=MECHANIC_VERIFICATION')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(res.body.logs.every((l: any) => l.action.includes('MECHANIC_VERIFICATION'))).toBe(true);
    });
  });
});

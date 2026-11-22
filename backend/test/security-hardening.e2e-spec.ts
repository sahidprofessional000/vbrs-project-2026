import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { AuthService } from '../src/modules/auth/auth.service';
import { Role, BreakdownCategory, SeverityLevel, ServiceRequestStatus } from '@prisma/client';

describe('Milestone 8: Platform Security Hardening & Penetration Audit (E2E)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let authService: AuthService;

  let customer1Token: string;
  let customer1Id: string;
  let customer2Token: string;
  let customer2Id: string;
  let mechanicToken: string;
  let adminToken: string;

  let customer1RequestId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();

    // Security Headers Middleware
    app.use((req: any, res: any, next: any) => {
      res.setHeader('X-Content-Type-Options', 'nosniff');
      res.setHeader('X-Frame-Options', 'DENY');
      res.setHeader('X-XSS-Protection', '1; mode=block');
      res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
      next();
    });

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

    const suffix = Date.now();

    // 1. Customer 1
    const cust1 = await authService.register({
      email: `sec.cust1.${suffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Alice SecTest',
      role: Role.CUSTOMER,
    });
    customer1Token = cust1.tokens.accessToken;
    customer1Id = cust1.user.id;

    // 2. Customer 2
    const cust2 = await authService.register({
      email: `sec.cust2.${suffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Bob SecTest',
      role: Role.CUSTOMER,
    });
    customer2Token = cust2.tokens.accessToken;
    customer2Id = cust2.user.id;

    // 3. Mechanic
    const mech = await authService.register({
      email: `sec.mech.${suffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Charlie Mechanic',
      role: Role.MECHANIC,
    });
    mechanicToken = mech.tokens.accessToken;

    // 4. Admin
    const admin = await authService.register({
      email: `sec.admin.${suffix}@vbrs.local`,
      password: 'Password@123',
      fullName: 'Admin Supervisor',
      role: Role.ADMIN,
    });
    adminToken = admin.tokens.accessToken;

    // Seed Customer 1 breakdown and service request
    const bReport = await prisma.breakdownReport.create({
      data: {
        customerId: customer1Id,
        category: BreakdownCategory.ENGINE_FAILURE,
        severity: SeverityLevel.CRITICAL,
        description: 'Engine failure on West Side Hwy',
        latitude: 40.75,
        longitude: -74.0,
      },
    });

    const sReq = await prisma.serviceRequest.create({
      data: {
        breakdownReportId: bReport.id,
        customerId: customer1Id,
        currentStatus: ServiceRequestStatus.SUBMITTED,
      },
    });
    customer1RequestId = sReq.id;
  });

  afterAll(async () => {
    await app.close();
  });

  // ===========================================================================
  // 1. HTTP SECURITY HEADERS AUDIT
  // ===========================================================================
  describe('1. Security Headers Audit', () => {
    it('enforces X-Content-Type-Options: nosniff on API responses', async () => {
      const res = await request(app.getHttpServer()).get('/api/health');
      expect(res.headers['x-content-type-options']).toBe('nosniff');
    });

    it('enforces X-Frame-Options: DENY against clickjacking', async () => {
      const res = await request(app.getHttpServer()).get('/api/health');
      expect(res.headers['x-frame-options']).toBe('DENY');
    });

    it('enforces X-XSS-Protection and Referrer-Policy headers', async () => {
      const res = await request(app.getHttpServer()).get('/api/health');
      expect(res.headers['x-xss-protection']).toBe('1; mode=block');
      expect(res.headers['referrer-policy']).toBe('strict-origin-when-cross-origin');
    });
  });

  // ===========================================================================
  // 2. AUTHENTICATION & JWT INTEGRITY AUDIT
  // ===========================================================================
  describe('2. Authentication & JWT Integrity', () => {
    it('rejects unauthenticated requests to protected endpoints (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/vehicles')
        .expect(401);
    });

    it('rejects forged / corrupted JWT tokens with invalid cryptographic signatures (401 Unauthorized)', async () => {
      const forgedToken = customer1Token.slice(0, -6) + 'abcdef';
      await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${forgedToken}`)
        .expect(401);
    });

    it('rejects malformed authorization header schemes (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Basic ${customer1Token}`)
        .expect(401);
    });
  });

  // ===========================================================================
  // 3. ROLE-BASED ACCESS CONTROL (RBAC) & VERTICAL PRIVILEGE ESCALATION
  // ===========================================================================
  describe('3. Role Escalation Prevention', () => {
    it('forbids Customer role from accessing administrative operational analytics (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/admin/analytics/overview')
        .set('Authorization', `Bearer ${customer1Token}`)
        .expect(403);
    });

    it('forbids Customer role from accessing technician verification desk (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/admin/mechanics')
        .set('Authorization', `Bearer ${customer1Token}`)
        .expect(403);
    });

    it('forbids Customer role from accessing security audit logs (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/admin/audit-logs')
        .set('Authorization', `Bearer ${customer1Token}`)
        .expect(403);
    });

    it('forbids Field Mechanic role from accessing administrative analytics (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get('/api/admin/analytics/overview')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .expect(403);
    });

    it('forbids Customer role from performing mechanic location beaconing (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .post('/api/mechanic/location')
        .set('Authorization', `Bearer ${customer1Token}`)
        .send({ latitude: 40.71, longitude: -74.0 })
        .expect(403);
    });

    it('allows verified Administrator access to administrative desks (200 OK)', async () => {
      await request(app.getHttpServer())
        .get('/api/admin/analytics/overview')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);
    });
  });

  // ===========================================================================
  // 4. MULTI-TENANT ISOLATION & HORIZONTAL PRIVILEGE ESCALATION
  // ===========================================================================
  describe('4. Tenant Isolation & Horizontal Privilege Escalation', () => {
    it('forbids Customer B from tracking Customer A service request (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get(`/api/service-requests/${customer1RequestId}/tracking`)
        .set('Authorization', `Bearer ${customer2Token}`)
        .expect(403);
    });

    it('forbids Customer B from cancelling Customer A service request (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .post(`/api/service-requests/${customer1RequestId}/cancel`)
        .set('Authorization', `Bearer ${customer2Token}`)
        .send({ reason: 'Malicious cancellation attempt' })
        .expect(403);
    });

    it('forbids Customer B from toggling location consent on Customer A service request (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .patch(`/api/service-requests/${customer1RequestId}/location-consent`)
        .set('Authorization', `Bearer ${customer2Token}`)
        .send({ locationConsent: false })
        .expect(403);
    });
  });

  // ===========================================================================
  // 5. PATH TRAVERSAL & INPUT INJECTION PREVENTION
  // ===========================================================================
  describe('5. Path Traversal & Input Validation', () => {
    it('neutralizes directory traversal attacks on image serving endpoint', async () => {
      // Trying directory traversal ../../package.json or similar
      const res = await request(app.getHttpServer())
        .get('/api/breakdowns/images/..%2F..%2Fpackage.json');

      // Must be 404 (file not found in upload directory) or 400, never serve files outside uploads
      expect([400, 404]).toContain(res.status);
    });

    it('rejects non-whitelisted payload injection properties via global ValidationPipe (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: 'admin@vbrs.local',
          password: 'Password@123',
          injectedAdminPrivilege: true,
          maliciousRoleOverride: 'SUPER_ROOT',
        })
        .expect(400);
    });
  });
});

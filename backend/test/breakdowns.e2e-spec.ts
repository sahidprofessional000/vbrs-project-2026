import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import * as path from 'path';
import * as fs from 'fs';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Breakdown Reporting & Location Capture E2E Suite', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customerAccessToken: string;
  let customerUserId: string;

  let userBToken: string;

  let createdReportId: string;
  let uploadedImageFileName: string;

  const timestamp = Date.now();
  const customerEmail = `m3.customer.${timestamp}@vbrs.local`;
  const userBEmail = `m3.userb.${timestamp}@vbrs.local`;
  const password = 'SecurePassword@2026';

  // Create temporary test image buffers
  const dummyJpgPath = path.resolve(__dirname, 'test-dummy.jpg');
  const dummyTxtPath = path.resolve(__dirname, 'test-dummy.txt');

  beforeAll(async () => {
    // Create valid 1x1 JPEG byte sequence
    const jpegBuffer = Buffer.from([
      0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43,
      0x00, 0xff, 0xd9,
    ]);
    fs.writeFileSync(dummyJpgPath, jpegBuffer);
    fs.writeFileSync(dummyTxtPath, 'Disallowed plain text file content');

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

    // Register Customer A
    const regA = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: customerEmail,
        password,
        fullName: 'Roadside Driver A',
        phone: '+1-555-3001',
      })
      .expect(201);

    customerAccessToken = regA.body.tokens.accessToken;
    customerUserId = regA.body.user.id;

    // Register Customer B
    const regB = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: userBEmail,
        password,
        fullName: 'Roadside Driver B',
        phone: '+1-555-3002',
      })
      .expect(201);

    userBToken = regB.body.tokens.accessToken;
  }, 30000);

  afterAll(async () => {
    // Clean up temporary dummy test files
    if (fs.existsSync(dummyJpgPath)) fs.unlinkSync(dummyJpgPath);
    if (fs.existsSync(dummyTxtPath)) fs.unlinkSync(dummyTxtPath);

    if (app) {
      await app.close();
    }
  });

  // =========================================================================
  // 1. BREAKDOWN REPORT CREATION & MULTIPART UPLOAD
  // =========================================================================
  describe('POST /api/breakdowns', () => {
    it('creates breakdown report with coordinates, rule diagnosis and image attachment', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .field('category', 'ENGINE_FAILURE')
        .field('severity', 'CRITICAL')
        .field('description', 'Engine smoking aggressively on highway shoulder with oil pressure light on.')
        .field('latitude', '40.712800')
        .field('longitude', '-74.006000')
        .field('addressText', 'Interstate 95 North near Milepost 42')
        .attach('images', dummyJpgPath)
        .expect(201);

      expect(res.body.id).toBeDefined();
      expect(res.body.customerId).toBe(customerUserId);
      expect(res.body.category).toBe('ENGINE_FAILURE');
      expect(res.body.severity).toBe('CRITICAL');
      expect(res.body.latitude).toBe(40.7128);
      expect(res.body.longitude).toBe(-74.006);
      expect(res.body.requiresTowing).toBe(true); // Due to CRITICAL + "smoke"
      expect(res.body.ruleDiagnosis).toContain('[DIAGNOSIS PROTOCOL]');
      expect(res.body.ruleDiagnosis).toContain('MANDATORY FLATBED RECOVERY');

      expect(res.body.images).toHaveLength(1);
      expect(res.body.images[0].fileName).toBeDefined();
      expect(res.body.images[0].mimeType).toBe('image/jpeg');

      expect(res.body.serviceRequest).toBeDefined();
      expect(res.body.serviceRequest.currentStatus).toBe('SUBMITTED');

      createdReportId = res.body.id;
      uploadedImageFileName = res.body.images[0].fileName;
    });

    it('creates roadside-repair eligible report without towing when severity is LOW and simple puncture', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .field('category', 'FLAT_TIRE_WHEEL')
        .field('severity', 'LOW')
        .field('description', 'Slow puncture in right rear tire. Vehicle safely parked on curb with spare ready.')
        .field('latitude', '40.730610')
        .field('longitude', '-73.935242')
        .field('addressText', 'Brooklyn Greenpoint Ave')
        .expect(201);

      expect(res.body.requiresTowing).toBe(false);
      expect(res.body.ruleDiagnosis).toContain('ROADSIDE MOBILE REPAIR ELIGIBLE');
    });

    it('rejects upload of disallowed file types (e.g. text/plain) with 400 Bad Request', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .field('category', 'BATTERY_DEAD_ELECTRICAL')
        .field('severity', 'MEDIUM')
        .field('description', 'Car will not crank, clicking starter relay.')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060')
        .attach('images', dummyTxtPath)
        .expect(400);

      expect(res.body.message).toMatch(/only jpeg, png, and webp/i);
    });

    it('rejects report with invalid coordinates out of range (-95 latitude) (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          category: 'BATTERY_DEAD_ELECTRICAL',
          severity: 'MEDIUM',
          description: 'Car will not crank, clicking starter relay.',
          latitude: -95.0,
          longitude: -74.006,
        })
        .expect(400);
    });
  });

  // =========================================================================
  // 2. RETRIEVAL & DETAIL ENDPOINTS
  // =========================================================================
  describe('GET /api/breakdowns', () => {
    it('returns breakdown reports list for customer with images and service status', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThanOrEqual(2);
      expect(res.body.some((r: any) => r.id === createdReportId)).toBe(true);
    });
  });

  describe('GET /api/breakdowns/:id', () => {
    it('returns report details for report owner (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/breakdowns/${createdReportId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.id).toBe(createdReportId);
      expect(res.body.customer.id).toBe(customerUserId);
      expect(res.body.images).toHaveLength(1);
    });

    it('denies access to report for another customer (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get(`/api/breakdowns/${createdReportId}`)
        .set('Authorization', `Bearer ${userBToken}`)
        .expect(403);
    });
  });

  // =========================================================================
  // 3. SECURE LOCAL IMAGE SERVING
  // =========================================================================
  describe('GET /api/breakdowns/images/:filename', () => {
    it('serves the uploaded breakdown image binary stream (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/breakdowns/images/${uploadedImageFileName}`)
        .expect(200);

      expect(res.headers['content-type']).toMatch(/image\/(jpeg|jpg)/);
      expect(res.headers['cache-control']).toBeDefined();
    });

    it('rejects path traversal attempts (404 Not Found)', async () => {
      await request(app.getHttpServer())
        .get('/api/breakdowns/images/../../package.json')
        .expect(404);
    });
  });

  // =========================================================================
  // 4. POSTGRESQL PERSISTENCE & LIFECYCLE
  // =========================================================================
  describe('Database Lifecycle Verification', () => {
    it('verifies report, image, and status history persisted in PostgreSQL', async () => {
      const dbReport = await prisma.breakdownReport.findUnique({
        where: { id: createdReportId },
        include: {
          images: true,
          serviceRequest: {
            include: { statusHistory: true },
          },
        },
      });

      expect(dbReport).toBeDefined();
      expect(dbReport?.requiresTowing).toBe(true);
      expect(dbReport?.images).toHaveLength(1);
      expect(dbReport?.serviceRequest?.currentStatus).toBe('SUBMITTED');
      expect(dbReport?.serviceRequest?.statusHistory[0].toStatus).toBe('SUBMITTED');
    });

    it('deletes/cancels report while in SUBMITTED state (200 OK)', async () => {
      await request(app.getHttpServer())
        .delete(`/api/breakdowns/${createdReportId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      // Verify 404
      await request(app.getHttpServer())
        .get(`/api/breakdowns/${createdReportId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(404);
    });
  });
});

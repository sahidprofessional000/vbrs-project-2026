import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import * as path from 'path';
import * as fs from 'fs';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { PowertrainType, Role } from '@prisma/client';

describe('Milestone 3 Comprehensive Edge-Case Verification Suite', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customerAToken: string;
  let customerAId: string;
  let customerBToken: string;
  let customerBId: string;
  let mechanicToken: string;
  let mechanicId: string;

  let vehicleAId: string;
  let vehicleBId: string;

  const timestamp = Date.now();
  const customerAEmail = `m3.edge.custA.${timestamp}@vbrs.local`;
  const customerBEmail = `m3.edge.custB.${timestamp}@vbrs.local`;
  const mechanicEmail = `m3.edge.mech.${timestamp}@vbrs.local`;
  const password = 'SecurePassword@2026';

  // Temporary files for tests
  const validJpgPath = path.resolve(__dirname, `test-valid-${timestamp}.jpg`);
  const oversizeJpgPath = path.resolve(__dirname, `test-oversize-${timestamp}.jpg`);
  const unsupportedTxtPath = path.resolve(__dirname, `test-unsupported-${timestamp}.txt`);
  const unsupportedGifPath = path.resolve(__dirname, `test-unsupported-${timestamp}.gif`);

  beforeAll(async () => {
    // 1. Create a minimal valid 1x1 JPEG
    const validJpeg = Buffer.from([
      0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43,
      0x00, 0xff, 0xd9,
    ]);
    fs.writeFileSync(validJpgPath, validJpeg);

    // 2. Create an oversized image > 5 MB (5.5 MB)
    const oversizeBuffer = Buffer.alloc(Math.ceil(5.5 * 1024 * 1024));
    // Set JPEG header so mime detection doesn't fail before size check
    validJpeg.copy(oversizeBuffer, 0, 0, validJpeg.length);
    fs.writeFileSync(oversizeJpgPath, oversizeBuffer);

    // 3. Create unsupported file formats (.txt and .gif)
    fs.writeFileSync(unsupportedTxtPath, 'Plain text document not allowed.');
    fs.writeFileSync(unsupportedGifPath, 'GIF89a minimal dummy gif content');

    // Initialize Nest application
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
    const resA = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: customerAEmail,
        password,
        fullName: 'Edge Customer Alpha',
        phone: '+1-555-4001',
      })
      .expect(201);
    customerAToken = resA.body.tokens.accessToken;
    customerAId = resA.body.user.id;

    // Register Customer B
    const resB = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: customerBEmail,
        password,
        fullName: 'Edge Customer Beta',
        phone: '+1-555-4002',
      })
      .expect(201);
    customerBToken = resB.body.tokens.accessToken;
    customerBId = resB.body.user.id;

    // Register Mechanic
    const resMech = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        email: mechanicEmail,
        password,
        fullName: 'Edge Tech Master',
        phone: '+1-555-4003',
        role: 'MECHANIC',
        workshopName: 'Edge Precision Garage',
        experienceYears: 7,
      })
      .expect(201);
    mechanicToken = resMech.body.tokens.accessToken;
    mechanicId = resMech.body.user.id;

    // Add Vehicle for Customer A
    const vehA = await request(app.getHttpServer())
      .post('/api/vehicles')
      .set('Authorization', `Bearer ${customerAToken}`)
      .send({
        make: 'Porsche',
        model: '911 GT3',
        year: 2023,
        licensePlate: `EDGE-A-${Date.now().toString().slice(-4)}`,
        powertrain: PowertrainType.PETROL,
      })
      .expect(201);
    vehicleAId = vehA.body.id;

    // Add Vehicle for Customer B
    const vehB = await request(app.getHttpServer())
      .post('/api/vehicles')
      .set('Authorization', `Bearer ${customerBToken}`)
      .send({
        make: 'Tesla',
        model: 'Model S Plaid',
        year: 2024,
        licensePlate: `EDGE-B-${Date.now().toString().slice(-4)}`,
        powertrain: PowertrainType.ELECTRIC,
      })
      .expect(201);
    vehicleBId = vehB.body.id;
  }, 30000);

  afterAll(async () => {
    // Clean up temporary files
    if (fs.existsSync(validJpgPath)) fs.unlinkSync(validJpgPath);
    if (fs.existsSync(oversizeJpgPath)) fs.unlinkSync(oversizeJpgPath);
    if (fs.existsSync(unsupportedTxtPath)) fs.unlinkSync(unsupportedTxtPath);
    if (fs.existsSync(unsupportedGifPath)) fs.unlinkSync(unsupportedGifPath);

    if (app) {
      await app.close();
    }
  });

  // =========================================================================
  // EDGE CASE 1: 5 MB IMAGE SIZE LIMIT VALIDATION
  // =========================================================================
  describe('Edge Case 1: 5 MB Image Limit Validation', () => {
    it('rejects image exceeding 5 MB ceiling with 400 or 413 (Payload Too Large)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'ENGINE_FAILURE')
        .field('severity', 'HIGH' as any)
        .field('description', 'Attempting upload of oversized 5.5MB file')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060')
        .attach('images', oversizeJpgPath);

      // Multer limits throw PayloadTooLargeException (413) or MulterError handled as 400
      expect([400, 413]).toContain(res.status);
    });
  });

  // =========================================================================
  // EDGE CASE 2: MAXIMUM 5 IMAGES LIMIT VALIDATION
  // =========================================================================
  describe('Edge Case 2: Maximum 5 Images Limit Validation', () => {
    it('rejects attempt to upload 6 images (exceeding max 5 files limit)', async () => {
      const req = request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'ENGINE_FAILURE')
        .field('severity', 'MEDIUM')
        .field('description', 'Attempting to attach 6 images')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060');

      // Attach 6 files
      for (let i = 0; i < 6; i++) {
        req.attach('images', validJpgPath);
      }

      const res = await req;
      // Multer limits throw 400 Bad Request on LIMIT_UNEXPECTED_FILE
      expect(res.status).toBe(400);
    });

    it('accepts valid submission with exactly 5 images (at the limit)', async () => {
      const req = request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'COLLISION_ACCIDENT')
        .field('severity', 'CRITICAL')
        .field('description', 'Multiple collision impact angles documented with 5 photographs')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060');

      // Attach exactly 5 files
      for (let i = 0; i < 5; i++) {
        req.attach('images', validJpgPath);
      }

      const res = await req.expect(201);
      expect(res.body.images).toHaveLength(5);
    });
  });

  // =========================================================================
  // EDGE CASE 3: UNSUPPORTED IMAGE FORMATS REJECTION
  // =========================================================================
  describe('Edge Case 3: Unsupported Image Formats Rejection', () => {
    it('rejects text/plain format with 400 Bad Request', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'FLAT_TIRE_WHEEL')
        .field('severity', 'LOW')
        .field('description', 'Testing text file rejection')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060')
        .attach('images', unsupportedTxtPath)
        .expect(400);

      expect(res.body.message).toMatch(/only jpeg, png, and webp/i);
    });

    it('rejects image/gif format with 400 Bad Request', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'FLAT_TIRE_WHEEL')
        .field('severity', 'LOW')
        .field('description', 'Testing gif file rejection')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060')
        .attach('images', unsupportedGifPath)
        .expect(400);

      expect(res.body.message).toMatch(/only jpeg, png, and webp/i);
    });
  });

  // =========================================================================
  // EDGE CASE 6: UNAUTHORIZED API REQUESTS
  // =========================================================================
  describe('Edge Case 6: Unauthorized API Requests', () => {
    it('rejects POST /api/breakdowns without JWT token (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .post('/api/breakdowns')
        .send({
          category: 'ENGINE_FAILURE',
          severity: 'MEDIUM',
          description: 'Unauthenticated report',
          latitude: 40.7128,
          longitude: -74.006,
        })
        .expect(401);
    });

    it('rejects GET /api/breakdowns without JWT token (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/breakdowns')
        .expect(401);
    });

    it('forbids MECHANIC role from creating breakdown reports (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${mechanicToken}`)
        .send({
          category: 'ENGINE_FAILURE',
          severity: 'MEDIUM',
          description: 'Mechanic attempting to file customer report',
          latitude: 40.7128,
          longitude: -74.006,
        })
        .expect(403);

      expect(res.body.message).toMatch(/access denied|forbidden/i);
    });

    it('forbids Customer A from attaching Customer B vehicle (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'ENGINE_FAILURE',
          severity: 'MEDIUM',
          description: 'Cross-tenant vehicle attachment attempt',
          latitude: 40.7128,
          longitude: -74.006,
          vehicleId: vehicleBId, // Owned by Customer B
        })
        .expect(403);

      expect(res.body.message).toMatch(/permission to attach this vehicle/i);
    });

    it('forbids Customer B from retrieving Customer A breakdown report (403 Forbidden)', async () => {
      // First create report for Customer A
      const created = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'BRAKE_SYSTEM_FAILURE',
          severity: 'CRITICAL',
          description: 'Brakes completely lost hydraulic pressure on off-ramp',
          latitude: 40.7128,
          longitude: -74.006,
          vehicleId: vehicleAId,
        })
        .expect(201);

      // Customer B attempts to read Customer A's report
      await request(app.getHttpServer())
        .get(`/api/breakdowns/${created.body.id}`)
        .set('Authorization', `Bearer ${customerBToken}`)
        .expect(403);
    });
  });

  // =========================================================================
  // EDGE CASE 5: POSTGRESQL RELATIONAL PERSISTENCE VERIFICATION
  // =========================================================================
  describe('Edge Case 5: Direct PostgreSQL Persistence Verification', () => {
    it('verifies breakdown report, images, service request and status history exist in PostgreSQL', async () => {
      const reportRes = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'BATTERY_DEAD_ELECTRICAL')
        .field('severity', 'MEDIUM')
        .field('description', 'Auxiliary battery failure requiring jump start on highway')
        .field('latitude', '40.748817')
        .field('longitude', '-73.985428')
        .field('addressText', 'Near Empire State Building')
        .field('vehicleId', vehicleAId)
        .attach('images', validJpgPath)
        .expect(201);

      const reportId = reportRes.body.id;

      // 1. Direct Prisma query on BreakdownReport
      const dbReport = await prisma.breakdownReport.findUnique({
        where: { id: reportId },
        include: {
          images: true,
          vehicle: true,
          serviceRequest: {
            include: {
              statusHistory: true,
            },
          },
        },
      });

      expect(dbReport).toBeDefined();
      expect(dbReport?.customerId).toBe(customerAId);
      expect(dbReport?.vehicleId).toBe(vehicleAId);
      expect(dbReport?.latitude).toBe(40.748817);
      expect(dbReport?.longitude).toBe(-73.985428);
      expect(dbReport?.addressText).toBe('Near Empire State Building');
      expect(dbReport?.requiresTowing).toBe(false);

      // 2. Direct query on ReportImage
      expect(dbReport?.images).toHaveLength(1);
      expect(dbReport?.images[0].mimeType).toBe('image/jpeg');
      expect(dbReport?.images[0].reportId).toBe(reportId);

      // 3. Direct query on ServiceRequest
      expect(dbReport?.serviceRequest).toBeDefined();
      expect(dbReport?.serviceRequest?.currentStatus).toBe('SUBMITTED');
      expect(dbReport?.serviceRequest?.customerId).toBe(customerAId);

      // 4. Direct query on ServiceStatusHistory
      expect(dbReport?.serviceRequest?.statusHistory).toBeDefined();
      expect(dbReport?.serviceRequest?.statusHistory.length).toBeGreaterThanOrEqual(1);
      expect(dbReport?.serviceRequest?.statusHistory[0].toStatus).toBe('SUBMITTED');
      expect(dbReport?.serviceRequest?.statusHistory[0].changedById).toBe(customerAId);

      // 5. Direct query on AuditLog
      const auditLogs = await prisma.auditLog.findMany({
        where: {
          entityId: reportId,
          action: 'BREAKDOWN_REPORT_CREATED',
        },
      });
      expect(auditLogs.length).toBeGreaterThanOrEqual(1);
      expect(auditLogs[0].userId).toBe(customerAId);
    });
  });

  // =========================================================================
  // EDGE CASE 7: MULTIPLE INDEPENDENT BREAKDOWN SUBMISSIONS
  // =========================================================================
  describe('Edge Case 7: Multiple Independent Breakdown Submissions', () => {
    it('processes multiple sequential reports maintaining distinct UUIDs and correct chronological order', async () => {
      // Submission 1: Transmission issue
      const rep1 = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'TRANSMISSION_ISSUE',
          severity: 'CRITICAL',
          description: 'Independent submission 1: Gearbox stuck in 3rd',
          latitude: 40.7100,
          longitude: -74.0000,
        })
        .expect(201);

      // Small delay to ensure timestamp separation
      await new Promise((r) => setTimeout(r, 20));

      // Submission 2: Fuel issue
      const rep2 = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'FUEL_EMPTY_OR_CONTAMINATED',
          severity: 'LOW',
          description: 'Independent submission 2: Ran dry on frontage road',
          latitude: 40.7200,
          longitude: -74.0100,
        })
        .expect(201);

      // Submission 3: Overheating
      const rep3 = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'OVERHEATING_COOLANT',
          severity: 'MEDIUM',
          description: 'Independent submission 3: Steam escaping radiator',
          latitude: 40.7300,
          longitude: -74.0200,
        })
        .expect(201);

      // Verify UUID uniqueness
      expect(rep1.body.id).not.toBe(rep2.body.id);
      expect(rep2.body.id).not.toBe(rep3.body.id);
      expect(rep1.body.serviceRequest.id).not.toBe(rep2.body.serviceRequest.id);

      // Retrieve list of customer reports
      const listRes = await request(app.getHttpServer())
        .get('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .expect(200);

      // Reports must be in reverse chronological order (rep3 first, then rep2, then rep1)
      const ids = listRes.body.map((r: any) => r.id);
      const idx1 = ids.indexOf(rep1.body.id);
      const idx2 = ids.indexOf(rep2.body.id);
      const idx3 = ids.indexOf(rep3.body.id);

      expect(idx3).toBeLessThan(idx2);
      expect(idx2).toBeLessThan(idx1);
    });
  });

  // =========================================================================
  // EDGE CASE 8: ERROR HANDLING & DATABASE CONSISTENCY (ROLLBACK & CASCADE)
  // =========================================================================
  describe('Edge Case 8: Error Handling & Database Consistency', () => {
    it('aborts and rolls back completely when non-existent vehicleId is supplied', async () => {
      const initialCount = await prisma.breakdownReport.count();
      const initialSRCount = await prisma.serviceRequest.count();

      const fakeVehicleId = 'e0000000-0000-4000-8000-000000000000'; // Valid UUID v4 but non-existent in DB

      const res = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .send({
          category: 'ENGINE_FAILURE',
          severity: 'MEDIUM',
          description: 'Testing rollback consistency with bad vehicle UUID',
          latitude: 40.7128,
          longitude: -74.0060,
          vehicleId: fakeVehicleId,
        })
        .expect(404);

      expect(res.body.message).toMatch(/specified vehicle was not found/i);

      // Verify no orphan records created in PostgreSQL
      const postCount = await prisma.breakdownReport.count();
      const postSRCount = await prisma.serviceRequest.count();

      expect(postCount).toBe(initialCount);
      expect(postSRCount).toBe(initialSRCount);
    });

    it('cascades clean deletion of breakdown report, removing child serviceRequest and images', async () => {
      // 1. Create a temporary report with an image
      const created = await request(app.getHttpServer())
        .post('/api/breakdowns')
        .set('Authorization', `Bearer ${customerAToken}`)
        .field('category', 'LOCKOUT_KEY_LOST')
        .field('severity', 'LOW')
        .field('description', 'Keys locked in boot during stop')
        .field('latitude', '40.7128')
        .field('longitude', '-74.0060')
        .attach('images', validJpgPath)
        .expect(201);

      const rId = created.body.id;
      const srId = created.body.serviceRequest.id;

      // Verify existence
      expect(await prisma.breakdownReport.findUnique({ where: { id: rId } })).toBeDefined();
      expect(await prisma.serviceRequest.findUnique({ where: { id: srId } })).toBeDefined();

      // 2. Delete report via DELETE /api/breakdowns/:id
      await request(app.getHttpServer())
        .delete(`/api/breakdowns/${rId}`)
        .set('Authorization', `Bearer ${customerAToken}`)
        .expect(200);

      // 3. Confirm cascaded removal in DB (zero orphan records)
      expect(await prisma.breakdownReport.findUnique({ where: { id: rId } })).toBeNull();
      expect(await prisma.serviceRequest.findUnique({ where: { id: srId } })).toBeNull();
      const remainingImages = await prisma.reportImage.findMany({ where: { reportId: rId } });
      expect(remainingImages).toHaveLength(0);
    });
  });
});

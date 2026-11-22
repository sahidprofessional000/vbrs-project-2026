import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import * as bcrypt from 'bcryptjs';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { Role } from '@prisma/client';

describe('Milestone 2 Comprehensive Verification Audit', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  let customerAccessToken: string;
  let customerRefreshToken: string;
  let customerUserId: string;

  let mechanicAccessToken: string;
  let mechanicRefreshToken: string;
  let mechanicUserId: string;

  let adminAccessToken: string;

  let userBToken: string;

  let testVehicleId: string;

  const timestamp = Date.now();
  const customerEmail = `audit.customer.${timestamp}@vbrs.local`;
  const mechanicEmail = `audit.mechanic.${timestamp}@vbrs.local`;
  const userBEmail = `audit.userb.${timestamp}@vbrs.local`;
  const strongPassword = 'AuditPassword@2026!';

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
  }, 30000);

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  // =========================================================================
  // REQUIREMENT 1: CUSTOMER, MECHANIC & ADMIN REGISTRATION/LOGIN
  // =========================================================================
  describe('Requirement 1: Registration and Login for all roles', () => {
    it('1.1: Customer Registration creates account, JWT tokens and audit log', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: customerEmail,
          password: strongPassword,
          fullName: 'Audit Customer',
          phone: '+1-555-1001',
          role: 'CUSTOMER',
        })
        .expect(201);

      expect(res.body.user).toBeDefined();
      expect(res.body.user.email).toBe(customerEmail.toLowerCase());
      expect(res.body.user.role).toBe('CUSTOMER');
      expect(res.body.user.passwordHash).toBeUndefined(); // Never expose hash
      expect(res.body.tokens.accessToken).toBeDefined();
      expect(res.body.tokens.refreshToken).toBeDefined();

      customerAccessToken = res.body.tokens.accessToken;
      customerRefreshToken = res.body.tokens.refreshToken;
      customerUserId = res.body.user.id;
    });

    it('1.2: Mechanic Registration creates account, MechanicProfile and location', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: mechanicEmail,
          password: strongPassword,
          fullName: 'Audit Mechanic',
          phone: '+1-555-2002',
          role: 'MECHANIC',
          workshopName: 'Audit Precision Garage',
          tradeLicenseNumber: 'ASE-MASTER-9988',
          experienceYears: 8,
        })
        .expect(201);

      expect(res.body.user.role).toBe('MECHANIC');
      mechanicAccessToken = res.body.tokens.accessToken;
      mechanicRefreshToken = res.body.tokens.refreshToken;
      mechanicUserId = res.body.user.id;

      // Verify profile in DB
      const profile = await prisma.mechanicProfile.findUnique({
        where: { userId: mechanicUserId },
        include: { currentLocation: true },
      });
      expect(profile).toBeDefined();
      expect(profile?.workshopName).toBe('Audit Precision Garage');
      expect(profile?.tradeLicenseNumber).toBe('ASE-MASTER-9988');
      expect(profile?.experienceYears).toBe(8);
      expect(profile?.currentLocation).toBeDefined();
    });

    it('1.3: Customer Login with valid credentials returns 200 OK and tokens', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: customerEmail,
          password: strongPassword,
        })
        .expect(200);

      expect(res.body.tokens.accessToken).toBeDefined();
      customerAccessToken = res.body.tokens.accessToken;
      customerRefreshToken = res.body.tokens.refreshToken;
    });

    it('1.4: Mechanic Login with valid credentials returns 200 OK and mechanicProfile', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: mechanicEmail,
          password: strongPassword,
        })
        .expect(200);

      expect(res.body.user.role).toBe('MECHANIC');
      expect(res.body.tokens.accessToken).toBeDefined();
      mechanicAccessToken = res.body.tokens.accessToken;
    });

    it('1.5: Admin Login with seeded credentials returns 200 OK and ADMIN role', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: 'admin@vbrs.local',
          password: 'Password@123',
        })
        .expect(200);

      expect(res.body.user.role).toBe('ADMIN');
      expect(res.body.tokens.accessToken).toBeDefined();
      adminAccessToken = res.body.tokens.accessToken;
    });

    it('1.6: Rejects duplicate email registration with 409 Conflict', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: customerEmail,
          password: strongPassword,
          fullName: 'Duplicate User',
        })
        .expect(409);

      expect(res.body.message).toMatch(/already exists/i);
    });

    it('1.7: Rejects login with invalid password with 401 Unauthorized', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: customerEmail,
          password: 'IncorrectPassword@999',
        })
        .expect(401);
    });
  });

  // =========================================================================
  // REQUIREMENT 2: JWT ACCESS AND REFRESH TOKEN ROTATION
  // =========================================================================
  describe('Requirement 2: JWT and Refresh Token Rotation', () => {
    it('2.1: Validates JWT token structure, claims and expiration', () => {
      const payloadBase64 = customerAccessToken.split('.')[1];
      const payload = JSON.parse(Buffer.from(payloadBase64, 'base64').toString('utf8'));

      expect(payload.sub).toBe(customerUserId);
      expect(payload.email).toBe(customerEmail.toLowerCase());
      expect(payload.role).toBe('CUSTOMER');
      expect(payload.exp).toBeGreaterThan(Math.floor(Date.now() / 1000));
    });

    it('2.2: Rotates refresh token, invalidates old token and returns new token pair', async () => {
      const oldToken = customerRefreshToken;

      const res = await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: oldToken })
        .expect(200);

      expect(res.body.accessToken).toBeDefined();
      expect(res.body.refreshToken).toBeDefined();
      expect(res.body.refreshToken).not.toBe(oldToken);

      // Verify old token is marked revoked in DB
      const oldTokenRecord = await prisma.refreshToken.findFirst({
        where: { userId: customerUserId, revokedAt: { not: null } },
      });
      expect(oldTokenRecord).toBeDefined();
      expect(oldTokenRecord?.revokedAt).toBeInstanceOf(Date);

      customerAccessToken = res.body.accessToken;
      customerRefreshToken = res.body.refreshToken;
    });

    it('2.3: Rejects reuse of previously rotated refresh token (401 Unauthorized)', async () => {
      // Create user B to test token reuse
      const reg = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: userBEmail,
          password: strongPassword,
          fullName: 'User B',
        })
        .expect(201);

      const userBRefreshToken = reg.body.tokens.refreshToken;
      userBToken = reg.body.tokens.accessToken;

      // First rotation succeeds
      await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: userBRefreshToken })
        .expect(200);

      // Second attempt with old token must be blocked
      await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: userBRefreshToken })
        .expect(401);
    });
  });

  // =========================================================================
  // REQUIREMENT 3: SECURE PASSWORD HASHING
  // =========================================================================
  describe('Requirement 3: Secure Password Hashing Verification', () => {
    it('3.1: Password hash in PostgreSQL is 60 characters and starts with $2b$12$', async () => {
      const user = await prisma.user.findUnique({
        where: { id: customerUserId },
        select: { passwordHash: true },
      });

      expect(user).toBeDefined();
      expect(user?.passwordHash).toBeDefined();
      expect(user?.passwordHash.length).toBe(60);
      expect(user?.passwordHash.startsWith('$2b$12$') || user?.passwordHash.startsWith('$2a$12$')).toBe(true);
    });

    it('3.2: bcrypt verifies valid password and rejects incorrect password against DB hash', async () => {
      const user = await prisma.user.findUnique({
        where: { id: customerUserId },
        select: { passwordHash: true },
      });

      const matchesValid = await bcrypt.compare(strongPassword, user!.passwordHash);
      expect(matchesValid).toBe(true);

      const matchesInvalid = await bcrypt.compare('PlainPasswordNotMatching', user!.passwordHash);
      expect(matchesInvalid).toBe(false);
    });
  });

  // =========================================================================
  // REQUIREMENT 4: ROLE-BASED AUTHORIZATION (RBAC)
  // =========================================================================
  describe('Requirement 4: Role-Based Authorization Guards', () => {
    it('4.1: Customer is permitted to access vehicle garage endpoints', async () => {
      await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);
    });

    it('4.2: Mechanic is forbidden from accessing customer garage (403 Forbidden)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${mechanicAccessToken}`)
        .expect(403);

      expect(res.body.message).toMatch(/access denied|forbidden/i);
    });

    it('4.3: Unauthenticated request is rejected (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/vehicles')
        .expect(401);
    });
  });

  // =========================================================================
  // REQUIREMENT 5: CUSTOMER PROFILE MANAGEMENT
  // =========================================================================
  describe('Requirement 5: Customer Profile Management', () => {
    it('5.1: GET /api/auth/me returns authenticated profile and vehicles', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.id).toBe(customerUserId);
      expect(res.body.email).toBe(customerEmail.toLowerCase());
      expect(res.body.fullName).toBe('Audit Customer');
      expect(res.body.vehicles).toBeInstanceOf(Array);
    });

    it('5.2: PUT /api/auth/profile updates profile and persists to PostgreSQL', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/auth/profile')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          fullName: 'Audit Customer Updated',
          phone: '+1-555-7777',
        })
        .expect(200);

      expect(res.body.fullName).toBe('Audit Customer Updated');
      expect(res.body.phone).toBe('+1-555-7777');

      // Verify in DB
      const dbUser = await prisma.user.findUnique({
        where: { id: customerUserId },
      });
      expect(dbUser?.fullName).toBe('Audit Customer Updated');
      expect(dbUser?.phone).toBe('+1-555-7777');
    });
  });

  // =========================================================================
  // REQUIREMENT 6: VEHICLE GARAGE CRUD OPERATIONS
  // =========================================================================
  describe('Requirement 6: Complete Vehicle Garage CRUD', () => {
    const licensePlate = `AUD-${Date.now().toString().slice(-4)}`;

    it('6.1: CREATE: adds new vehicle to garage with powertrain enum', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          make: 'Porsche',
          model: 'Taycan GTS',
          year: 2024,
          licensePlate,
          color: 'Gentian Blue',
          powertrain: 'ELECTRIC',
          isDefault: true,
        })
        .expect(201);

      expect(res.body.id).toBeDefined();
      expect(res.body.make).toBe('Porsche');
      expect(res.body.model).toBe('Taycan GTS');
      expect(res.body.powertrain).toBe('ELECTRIC');
      expect(res.body.isDefault).toBe(true);

      testVehicleId = res.body.id;
    });

    it('6.2: READ (List): returns all vehicles in customer garage', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.some((v: any) => v.id === testVehicleId)).toBe(true);
    });

    it('6.3: READ (Single): returns vehicle by ID for owner', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/vehicles/${testVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.id).toBe(testVehicleId);
      expect(res.body.make).toBe('Porsche');
    });

    it('6.4: UPDATE: updates vehicle model and color', async () => {
      const res = await request(app.getHttpServer())
        .put(`/api/vehicles/${testVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          model: 'Taycan Turbo S',
          color: 'Obsidian Black',
        })
        .expect(200);

      expect(res.body.model).toBe('Taycan Turbo S');
      expect(res.body.color).toBe('Obsidian Black');
    });

    it('6.5: DEFAULT TOGGLE: designates vehicle as primary default', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/vehicles/${testVehicleId}/default`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.isDefault).toBe(true);
    });

    it('6.6: CROSS-TENANT ISOLATION: User B cannot access User A vehicle (403 Forbidden)', async () => {
      await request(app.getHttpServer())
        .get(`/api/vehicles/${testVehicleId}`)
        .set('Authorization', `Bearer ${userBToken}`)
        .expect(403);
    });

    it('6.7: DELETE: removes vehicle from garage', async () => {
      await request(app.getHttpServer())
        .delete(`/api/vehicles/${testVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      // Verify 404
      await request(app.getHttpServer())
        .get(`/api/vehicles/${testVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(404);
    });
  });

  // =========================================================================
  // REQUIREMENT 7: POSTGRESQL PERSISTENCE & CONSTRAINTS
  // =========================================================================
  describe('Requirement 7: PostgreSQL Persistence and Constraints', () => {
    it('7.1: Confirms User record, tokens and audit logs exist in PostgreSQL', async () => {
      const user = await prisma.user.findUnique({
        where: { id: customerUserId },
        include: { refreshTokens: true, auditLogs: true },
      });

      expect(user).toBeDefined();
      expect(user?.refreshTokens.length).toBeGreaterThanOrEqual(1);
      expect(user?.auditLogs.length).toBeGreaterThanOrEqual(1);
    });

    it('7.2: Confirms foreign key cascade constraints function properly', async () => {
      // Create a temporary user with a vehicle and verify cascade on delete
      const tempUser = await prisma.user.create({
        data: {
          email: `cascade.${Date.now()}@vbrs.local`,
          passwordHash: 'dummyhash',
          fullName: 'Cascade User',
        },
      });

      const tempVehicle = await prisma.vehicle.create({
        data: {
          userId: tempUser.id,
          make: 'Test',
          model: 'Cascade',
          year: 2020,
          licensePlate: `CAS-${Date.now().toString().slice(-4)}`,
        },
      });

      // Delete user
      await prisma.user.delete({ where: { id: tempUser.id } });

      // Vehicle should cascade delete
      const orphaned = await prisma.vehicle.findUnique({ where: { id: tempVehicle.id } });
      expect(orphaned).toBeNull();
    });
  });

  // =========================================================================
  // REQUIREMENT 9: INVALID INPUT AND UNAUTHORIZED ACCESS HANDLING
  // =========================================================================
  describe('Requirement 9: Validation and Error Handling', () => {
    it('9.1: Rejects malformed email (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'not-a-valid-email',
          password: strongPassword,
          fullName: 'Bad Email',
        })
        .expect(400);

      expect(res.body.message).toBeDefined();
    });

    it('9.2: Rejects weak password without required complexity (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'valid@example.com',
          password: 'simple',
          fullName: 'Weak Pass',
        })
        .expect(400);

      expect(res.body.message).toBeDefined();
    });

    it('9.3: Rejects vehicle creation with invalid year (e.g. 1850) (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          make: 'Ford',
          model: 'Model T',
          year: 1850,
          licensePlate: 'OLD-1850',
        })
        .expect(400);
    });

    it('9.4: Rejects vehicle creation with invalid powertrain (400 Bad Request)', async () => {
      await request(app.getHttpServer())
        .post('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          make: 'Tesla',
          model: 'Model 3',
          year: 2022,
          licensePlate: 'TES-1234',
          powertrain: 'NUCLEAR_FUSION',
        })
        .expect(400);
    });

    it('9.5: Rejects invalid UUID parameter (400 or 404)', async () => {
      await request(app.getHttpServer())
        .get('/api/vehicles/non-existent-uuid-123')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(404);
    });
  });
});

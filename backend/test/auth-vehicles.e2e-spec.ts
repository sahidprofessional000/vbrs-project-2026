import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import * as cookieParser from 'cookie-parser';
import { AppModule } from '../src/app.module';

describe('Authentication & Vehicle Garage End-to-End Suite', () => {
  let app: INestApplication;
  let customerAccessToken: string;
  let customerRefreshToken: string;
  let createdVehicleId: string;

  const testCustomer = {
    email: `m2.customer.${Date.now()}@vbrs.local`,
    password: 'SecurePassword@2026',
    fullName: 'David Hasselhoff',
    phone: '+1-555-8888',
    role: 'CUSTOMER',
  };

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
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  // ==========================================
  // AUTHENTICATION MODULE TESTS
  // ==========================================

  describe('POST /api/auth/register', () => {
    it('registers a new customer and returns JWT tokens', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send(testCustomer)
        .expect(201);

      expect(res.body).toHaveProperty('user');
      expect(res.body.user.email).toBe(testCustomer.email.toLowerCase());
      expect(res.body.user.role).toBe('CUSTOMER');
      expect(res.body.user).not.toHaveProperty('passwordHash');

      expect(res.body).toHaveProperty('tokens');
      expect(res.body.tokens).toHaveProperty('accessToken');
      expect(res.body.tokens).toHaveProperty('refreshToken');

      customerAccessToken = res.body.tokens.accessToken;
      customerRefreshToken = res.body.tokens.refreshToken;
    });

    it('rejects registration with duplicate email address (409 Conflict)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send(testCustomer)
        .expect(409);

      expect(res.body.message).toMatch(/already exists/i);
    });

    it('rejects registration with weak password (400 Bad Request)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'weakpass@vbrs.local',
          password: 'weak',
          fullName: 'Weak Password User',
        })
        .expect(400);

      expect(res.body.message).toBeDefined();
    });
  });

  describe('POST /api/auth/login', () => {
    it('authenticates with correct credentials and returns JWT (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: testCustomer.email,
          password: testCustomer.password,
        })
        .expect(200);

      expect(res.body).toHaveProperty('tokens');
      expect(res.body.tokens).toHaveProperty('accessToken');
      customerAccessToken = res.body.tokens.accessToken;
      customerRefreshToken = res.body.tokens.refreshToken;
    });

    it('rejects login with incorrect password (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({
          email: testCustomer.email,
          password: 'WrongPassword@123',
        })
        .expect(401);
    });
  });

  describe('GET /api/auth/me', () => {
    it('returns authenticated user profile when Bearer token is provided', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.email).toBe(testCustomer.email.toLowerCase());
      expect(res.body.fullName).toBe(testCustomer.fullName);
      expect(res.body).toHaveProperty('vehicles');
    });

    it('denies access when Authorization header is missing (401 Unauthorized)', async () => {
      await request(app.getHttpServer())
        .get('/api/auth/me')
        .expect(401);
    });
  });

  describe('POST /api/auth/refresh', () => {
    it('rotates refresh token and issues new access token (200 OK)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: customerRefreshToken })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      expect(res.body.refreshToken).not.toBe(customerRefreshToken); // Proves rotation

      customerAccessToken = res.body.accessToken;
      customerRefreshToken = res.body.refreshToken;
    });
  });

  describe('PUT /api/auth/profile', () => {
    it('updates user profile information successfully', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/auth/profile')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          fullName: 'David Michael Hasselhoff',
          phone: '+1-555-9999',
        })
        .expect(200);

      expect(res.body.fullName).toBe('David Michael Hasselhoff');
      expect(res.body.phone).toBe('+1-555-9999');
    });
  });

  // ==========================================
  // VEHICLE GARAGE MODULE TESTS
  // ==========================================

  describe('POST /api/vehicles', () => {
    it('adds a new vehicle to customer garage', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          make: 'Ford',
          model: 'Mustang Mach-E',
          year: 2023,
          licensePlate: `M2-${Date.now().toString().slice(-4)}`,
          color: 'Rapid Red',
          powertrain: 'ELECTRIC',
          isDefault: true,
        })
        .expect(201);

      expect(res.body).toHaveProperty('id');
      expect(res.body.make).toBe('Ford');
      expect(res.body.model).toBe('Mustang Mach-E');
      expect(res.body.powertrain).toBe('ELECTRIC');
      expect(res.body.isDefault).toBe(true);

      createdVehicleId = res.body.id;
    });

    it('rejects adding duplicate license plate for the same user (409 Conflict)', async () => {
      // First get the created plate
      const garage = await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      const existingPlate = garage.body[0].licensePlate;

      const res = await request(app.getHttpServer())
        .post('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          make: 'Chevrolet',
          model: 'Corvette',
          year: 2021,
          licensePlate: existingPlate,
          powertrain: 'PETROL',
        })
        .expect(409);

      expect(res.body.message).toMatch(/already in your garage/i);
    });
  });

  describe('GET /api/vehicles', () => {
    it('returns the list of vehicles in the customer garage', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/vehicles')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThanOrEqual(1);
      expect(res.body.some((v: any) => v.id === createdVehicleId)).toBe(true);
    });
  });

  describe('GET /api/vehicles/:id', () => {
    it('returns specific vehicle details for the owner', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/vehicles/${createdVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.id).toBe(createdVehicleId);
      expect(res.body.make).toBe('Ford');
    });
  });

  describe('PUT /api/vehicles/:id', () => {
    it('updates vehicle details successfully', async () => {
      const res = await request(app.getHttpServer())
        .put(`/api/vehicles/${createdVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({
          color: 'Carbonized Gray Metallic',
          model: 'Mustang Mach-E GT',
        })
        .expect(200);

      expect(res.body.color).toBe('Carbonized Gray Metallic');
      expect(res.body.model).toBe('Mustang Mach-E GT');
    });
  });

  describe('PATCH /api/vehicles/:id/default', () => {
    it('updates default status for vehicle', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/vehicles/${createdVehicleId}/default`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.isDefault).toBe(true);
    });
  });

  describe('DELETE /api/vehicles/:id', () => {
    it('deletes vehicle from customer garage', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/vehicles/${createdVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(200);

      expect(res.body.message).toMatch(/deleted successfully/i);

      // Verify it no longer exists
      await request(app.getHttpServer())
        .get(`/api/vehicles/${createdVehicleId}`)
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .expect(404);
    });
  });

  describe('POST /api/auth/logout', () => {
    it('revokes session upon sign out', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${customerAccessToken}`)
        .send({ refreshToken: customerRefreshToken })
        .expect(200);

      expect(res.body.message).toMatch(/logged out successfully/i);

      // Old refresh token must now be rejected
      await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: customerRefreshToken })
        .expect(401);
    });
  });
});

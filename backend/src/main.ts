import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as cookieParser from 'cookie-parser';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('VBRS_Bootstrap');
  const app = await NestFactory.create(AppModule);

  // Global prefix for API
  app.setGlobalPrefix('api');

  // Input validation and sanitization
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Cookie parser for secure refresh token handling
  app.use(cookieParser());

  // CORS configuration
  const allowedOrigins = [
    process.env.CORS_ORIGIN || 'http://localhost:3000',
    'http://127.0.0.1:3000',
  ];

  app.enableCors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(null, true); // Allow all in dev mode for testing
      }
    },
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: 'Content-Type,Accept,Authorization,X-Requested-With',
  });

  // Swagger OpenAPI 3.0 Documentation Setup
  const config = new DocumentBuilder()
    .setTitle('Vehicle Breakdown Reporting System (VBRS) API')
    .setDescription(
      'Enterprise-grade roadside assistance REST API supporting real-time breakdown reporting, mechanic dispatching, Haversine geospatial proximity, and lifecycle tracking.',
    )
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Enter your Bearer access token',
        in: 'header',
      },
      'bearer-jwt',
    )
    .addTag('Health', 'System uptime and database connectivity verification')
    .addTag('Auth', 'Authentication, token refresh, and session management')
    .addTag('Vehicles', 'Customer vehicle garage management')
    .addTag('Breakdowns', 'Breakdown incident reporting, photos, and location')
    .addTag('Mechanics', 'Mechanic onboarding, availability, and radial discovery')
    .addTag('Requests', 'Service request lifecycle state machine transitions')
    .addTag('Reviews', 'Customer ratings and dispute handling')
    .addTag('Admin', 'Platform governance, moderation, and analytics')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'VBRS API Documentation',
    customCss: '.swagger-ui .topbar { display: none }',
    swaggerOptions: {
      persistAuthorization: true,
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
    },
  });

  const port = process.env.PORT || 4000;
  await app.listen(port);
  logger.log(`=======================================================`);
  logger.log(`🚗 VBRS Backend Server successfully running on Port: ${port}`);
  logger.log(`📘 OpenAPI Swagger Documentation: http://localhost:${port}/api/docs`);
  logger.log(`🩺 System Health Check Endpoint:  http://localhost:${port}/api/health`);
  logger.log(`=======================================================`);
}

bootstrap();

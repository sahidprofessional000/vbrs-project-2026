import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './modules/prisma/prisma.module';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { VehiclesModule } from './modules/vehicles/vehicles.module';
import { BreakdownsModule } from './modules/breakdowns/breakdowns.module';
import { MechanicsModule } from './modules/mechanics/mechanics.module';
import { EventsModule } from './modules/events/events.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '../.env'],
    }),
    PrismaModule,
    EventsModule,
    HealthModule,
    AuthModule,
    VehiclesModule,
    BreakdownsModule,
    MechanicsModule,
  ],
})
export class AppModule {}

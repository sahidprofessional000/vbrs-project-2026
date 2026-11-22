import { Module } from '@nestjs/common';
import { ServiceRequestsController } from './service-requests.controller';
import { ServiceRequestsService } from './service-requests.service';
import { PrismaModule } from '../prisma/prisma.module';
import { EventsModule } from '../events/events.module';

@Module({
  imports: [PrismaModule, EventsModule],
  controllers: [ServiceRequestsController],
  providers: [ServiceRequestsService],
  exports: [ServiceRequestsService],
})
export class ServiceRequestsModule {}

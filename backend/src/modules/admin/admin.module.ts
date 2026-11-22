import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { ComplaintsController } from './complaints.controller';
import { AdminService } from './admin.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AdminController, ComplaintsController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}

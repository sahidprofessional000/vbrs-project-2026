import { Module } from '@nestjs/common';
import { BreakdownsController } from './breakdowns.controller';
import { BreakdownsService } from './breakdowns.service';
import { BreakdownTriageService } from './breakdown-triage.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [BreakdownsController],
  providers: [BreakdownsService, BreakdownTriageService],
  exports: [BreakdownsService, BreakdownTriageService],
})
export class BreakdownsModule {}

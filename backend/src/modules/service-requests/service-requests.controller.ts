import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { ServiceRequestsService } from './service-requests.service';
import { TransitionStatusDto } from './dto/transition-status.dto';
import { RecordQuoteDto } from './dto/record-quote.dto';
import { CancelServiceDto } from './dto/cancel-service.dto';
import { UpdateLocationConsentDto } from './dto/update-consent.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Service Requests & Lifecycle')
@Controller('service-requests')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('bearer-jwt')
export class ServiceRequestsController {
  constructor(
    private readonly serviceRequestsService: ServiceRequestsService,
  ) {}

  @Get('active')
  @ApiOperation({
    summary: 'Retrieve current active mission assignment (mechanic) or active incident (customer)',
  })
  @ApiResponse({ status: 200, description: 'Active service request or null if none' })
  async getActive(
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
  ) {
    return this.serviceRequestsService.getActive(userId, role);
  }

  @Get(':id/tracking')
  @ApiOperation({
    summary: 'Get live tracking data, telemetry, and milestone timeline for an authorized service request',
  })
  @ApiResponse({ status: 200, description: 'Tracking telemetry and state timeline' })
  @ApiResponse({ status: 403, description: 'Forbidden: unauthorized user' })
  @ApiResponse({ status: 404, description: 'Service request not found' })
  async getTracking(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
  ) {
    return this.serviceRequestsService.getTracking(id, userId, role);
  }

  @Patch(':id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Advance lifecycle state machine status (EN_ROUTE, ARRIVED, IN_PROGRESS, COMPLETED, CANCELLED)',
  })
  @ApiResponse({ status: 200, description: 'Status updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid state machine transition or illegal skip' })
  @ApiResponse({ status: 403, description: 'Forbidden: insufficient role or non-assigned technician' })
  @ApiResponse({ status: 409, description: 'Conflict: concurrent state modification' })
  async transitionStatus(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Body() dto: TransitionStatusDto,
  ) {
    return this.serviceRequestsService.transitionStatus(id, userId, role, dto);
  }

  @Post(':id/quote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Record or update diagnostic quotation, parts, and labor breakdown',
  })
  @ApiResponse({ status: 200, description: 'Quotation recorded and broadcast' })
  @ApiResponse({ status: 403, description: 'Forbidden: only assigned technician can quote' })
  async recordQuote(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Body() dto: RecordQuoteDto,
  ) {
    return this.serviceRequestsService.recordQuote(id, userId, role, dto);
  }

  @Post(':id/cancel')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Cancel service request with explicit reason',
  })
  @ApiResponse({ status: 200, description: 'Service request cancelled successfully' })
  @ApiResponse({ status: 400, description: 'Cannot cancel finalized or completed service' })
  async cancel(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Body() dto: CancelServiceDto,
  ) {
    return this.serviceRequestsService.cancel(id, userId, role, dto);
  }

  @Patch(':id/location-consent')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update GPS location-sharing consent flag',
  })
  @ApiResponse({ status: 200, description: 'Consent setting updated' })
  async updateLocationConsent(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Body() dto: UpdateLocationConsentDto,
  ) {
    return this.serviceRequestsService.updateLocationConsent(id, userId, role, dto);
  }
}

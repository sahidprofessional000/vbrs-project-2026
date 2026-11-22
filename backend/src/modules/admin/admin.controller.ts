import {
  Controller,
  Get,
  Patch,
  Query,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { VerifyMechanicDto } from './dto/verify-mechanic.dto';
import { UpdateComplaintStatusDto } from './dto/update-complaint-status.dto';
import { AuditLogQueryDto } from './dto/audit-log-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role, VerificationStatus } from '@prisma/client';

@ApiTags('Admin Command Center & Governance')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@ApiBearerAuth('bearer-jwt')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('mechanics')
  @ApiOperation({ summary: 'List field technician profiles with optional verification filter' })
  @ApiQuery({ name: 'status', enum: VerificationStatus, required: false })
  @ApiResponse({ status: 200, description: 'List of technician profiles' })
  async getMechanics(@Query('status') status?: VerificationStatus) {
    return this.adminService.getMechanics(status);
  }

  @Patch('mechanics/:id/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve or reject a field technician verification application' })
  @ApiResponse({ status: 200, description: 'Technician verification status updated' })
  @ApiResponse({ status: 404, description: 'Mechanic profile not found' })
  async verifyMechanic(
    @Param('id') id: string,
    @CurrentUser('id') adminUserId: string,
    @Body() dto: VerifyMechanicDto,
  ) {
    return this.adminService.verifyMechanic(id, adminUserId, dto);
  }

  @Patch('complaints/:id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update dispute investigation status and record administrative notes' })
  @ApiResponse({ status: 200, description: 'Dispute status updated' })
  @ApiResponse({ status: 404, description: 'Complaint not found' })
  async updateComplaintStatus(
    @Param('id') id: string,
    @CurrentUser('id') adminUserId: string,
    @Body() dto: UpdateComplaintStatusDto,
  ) {
    return this.adminService.updateComplaintStatus(id, adminUserId, dto);
  }

  @Get('analytics/overview')
  @ApiOperation({ summary: 'Real-time PostgreSQL SQL operational analytics and fleet KPIs' })
  @ApiResponse({ status: 200, description: 'Real SQL aggregated metrics and top performers' })
  async getAnalyticsOverview() {
    return this.adminService.getAnalyticsOverview();
  }

  @Get('audit-logs')
  @ApiOperation({ summary: 'Search and inspect security audit log records' })
  @ApiResponse({ status: 200, description: 'Paginated security audit logs' })
  async getAuditLogs(@Query() query: AuditLogQueryDto) {
    return this.adminService.getAuditLogs(query);
  }
}

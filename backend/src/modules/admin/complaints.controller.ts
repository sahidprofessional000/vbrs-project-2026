import {
  Controller,
  Get,
  Post,
  Query,
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
import { CreateComplaintDto } from './dto/create-complaint.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role, ComplaintStatus } from '@prisma/client';

@ApiTags('Disputes & Complaints')
@Controller('complaints')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('bearer-jwt')
export class ComplaintsController {
  constructor(private readonly adminService: AdminService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'File a dispute or grievance regarding a specific service request' })
  @ApiResponse({ status: 201, description: 'Dispute filed successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden: caller not part of this request' })
  async createComplaint(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateComplaintDto,
  ) {
    return this.adminService.createComplaint(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List disputes (Admins see all; Customers/Mechanics see their own)' })
  @ApiQuery({ name: 'status', enum: ComplaintStatus, required: false })
  @ApiResponse({ status: 200, description: 'List of complaints' })
  async getComplaints(
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
    @Query('status') status?: ComplaintStatus,
  ) {
    return this.adminService.getComplaints(userId, role, status);
  }
}

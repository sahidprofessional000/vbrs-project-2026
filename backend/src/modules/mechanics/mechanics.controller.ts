import {
  Controller,
  Get,
  Put,
  Patch,
  Post,
  Body,
  Param,
  Query,
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
import { MechanicsService } from './mechanics.service';
import { UpdateAvailabilityDto } from './dto/update-availability.dto';
import { UpdateLocationDto } from './dto/update-location.dto';
import { UpdateMechanicProfileDto } from './dto/update-profile.dto';
import { NearbyMechanicsQueryDto } from './dto/nearby-mechanics-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Mechanics')
@Controller()
export class MechanicsController {
  constructor(private readonly mechanicsService: MechanicsService) {}

  @Get('mechanic/profile')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC, Role.ADMIN)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Retrieve full operational profile for authenticated technician' })
  @ApiResponse({ status: 200, description: 'Technician profile with location and verification status' })
  async getProfile(@CurrentUser('id') userId: string) {
    return this.mechanicsService.getProfile(userId);
  }

  @Put('mechanic/profile')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Update operational profile parameters (service radius, workshop name)' })
  @ApiResponse({ status: 200, description: 'Updated mechanic profile' })
  async updateProfile(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateMechanicProfileDto,
  ) {
    return this.mechanicsService.updateProfile(userId, dto);
  }

  @Get('mechanic/earnings')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Calculate career and recent earnings breakdown from completed jobs' })
  @ApiResponse({ status: 200, description: 'Earnings and revenue summary' })
  async getEarnings(@CurrentUser('id') userId: string) {
    return this.mechanicsService.getEarnings(userId);
  }

  @Patch('mechanic/availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Toggle operational readiness state (AVAILABLE, OFFLINE, ON_JOB)' })
  @ApiResponse({ status: 200, description: 'Updated availability state' })
  async updateAvailability(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateAvailabilityDto,
  ) {
    return this.mechanicsService.updateAvailability(userId, dto);
  }

  @Post('mechanic/location')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Transmit high-frequency GPS coordinate telemetry' })
  @ApiResponse({ status: 200, description: 'Updated mechanic location' })
  async updateLocation(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateLocationDto,
  ) {
    return this.mechanicsService.updateLocation(userId, dto);
  }

  @Get('mechanic/dispatches')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Retrieve active inbound roadside dispatches within operational boundary' })
  @ApiResponse({ status: 200, description: 'List of matching dispatches ordered by proximity' })
  async getDispatches(@CurrentUser('id') userId: string) {
    return this.mechanicsService.getDispatchesForMechanic(userId);
  }

  @Post('mechanic/dispatches/:id/accept')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MECHANIC)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Atomically accept an incoming roadside dispatch' })
  @ApiResponse({ status: 200, description: 'Dispatch claimed and assigned successfully' })
  @ApiResponse({ status: 409, description: 'Conflict: Dispatch already claimed by another technician' })
  @ApiResponse({ status: 400, description: 'Technician is offline or ineligible' })
  async acceptDispatch(
    @CurrentUser('id') userId: string,
    @Param('id') serviceRequestId: string,
  ) {
    return this.mechanicsService.acceptDispatch(userId, serviceRequestId);
  }

  @Get('mechanics/nearby')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Radial proximity search to discover certified available technicians' })
  @ApiResponse({ status: 200, description: 'List of nearby technicians with privacy-preserved coordinates' })
  async findNearbyMechanics(@Query() query: NearbyMechanicsQueryDto) {
    return this.mechanicsService.findNearbyMechanics(query);
  }
}

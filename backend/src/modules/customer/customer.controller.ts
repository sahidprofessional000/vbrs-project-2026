import {
  Controller,
  Get,
  Post,
  Delete,
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
import { CustomerService } from './customer.service';
import { CreateSavedAddressDto } from './dto/create-saved-address.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Customer Portal & Saved Locations')
@Controller('customer')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('bearer-jwt')
export class CustomerController {
  constructor(private readonly customerService: CustomerService) {}

  @Get('overview')
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @ApiOperation({ summary: 'Retrieve comprehensive customer homepage overview metrics' })
  @ApiResponse({ status: 200, description: 'Customer overview dataset' })
  async getOverview(@CurrentUser('id') userId: string) {
    return this.customerService.getCustomerOverview(userId);
  }

  @Get('saved-addresses')
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @ApiOperation({ summary: 'List saved locations (home, work, garage) for customer' })
  @ApiResponse({ status: 200, description: 'List of saved addresses' })
  async getSavedAddresses(@CurrentUser('id') userId: string) {
    return this.customerService.getSavedAddresses(userId);
  }

  @Post('saved-addresses')
  @Roles(Role.CUSTOMER)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new saved address bookmark' })
  @ApiResponse({ status: 201, description: 'Address saved successfully' })
  async createSavedAddress(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateSavedAddressDto,
  ) {
    return this.customerService.createSavedAddress(userId, dto);
  }

  @Delete('saved-addresses/:id')
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a saved address bookmark' })
  @ApiResponse({ status: 200, description: 'Address removed successfully' })
  async deleteSavedAddress(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.customerService.deleteSavedAddress(userId, id);
  }
}

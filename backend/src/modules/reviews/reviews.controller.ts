import {
  Controller,
  Get,
  Post,
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
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

@ApiTags('Customer Reviews & Technician Reputation')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER)
  @ApiBearerAuth('bearer-jwt')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Submit customer review and rating for completed service request',
    description:
      'Only the motorist who requested the service can review. Service request must be COMPLETED. Duplicate reviews are forbidden.',
  })
  @ApiResponse({ status: 201, description: 'Review persisted and mechanic reputation recalculated' })
  @ApiResponse({ status: 400, description: 'Invalid rating, uncompleted request, or duplicate review' })
  @ApiResponse({ status: 403, description: 'Forbidden: caller did not request this service' })
  async createReview(
    @CurrentUser('id') customerId: string,
    @Body() dto: CreateReviewDto,
  ) {
    return this.reviewsService.createReview(customerId, dto);
  }

  @Get('mechanic/:mechanicId')
  @ApiOperation({ summary: 'List verified customer reviews for a given technician' })
  @ApiResponse({ status: 200, description: 'List of reviews' })
  async getMechanicReviews(@Param('mechanicId') mechanicId: string) {
    return this.reviewsService.getMechanicReviews(mechanicId);
  }

  @Get('request/:serviceRequestId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Check if a service request has an existing review' })
  @ApiResponse({ status: 200, description: 'Review object if exists, null otherwise' })
  async getRequestReview(@Param('serviceRequestId') serviceRequestId: string) {
    return this.reviewsService.getRequestReview(serviceRequestId);
  }

  @Get('mechanic/:mechanicId/reputation')
  @ApiOperation({
    summary: 'Get mathematical reputation metrics, star distribution, and Bayesian weighted score',
  })
  @ApiResponse({ status: 200, description: 'Mathematical reputation breakdown' })
  async getMechanicReputation(@Param('mechanicId') mechanicId: string) {
    return this.reviewsService.getMechanicReputation(mechanicId);
  }
}

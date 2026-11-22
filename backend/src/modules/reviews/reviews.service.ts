import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { ServiceRequestStatus } from '@prisma/client';

export interface ReputationSummary {
  mechanicId: string;
  totalReviews: number;
  arithmeticAverage: number;
  bayesianReputationScore: number;
  ratingDistribution: {
    fiveStar: number;
    fourStar: number;
    threeStar: number;
    twoStar: number;
    oneStar: number;
  };
  subScores: {
    averageTimeliness: number | null;
    averageCostFairness: number | null;
    averageProfessionalism: number | null;
  };
}

@Injectable()
export class ReviewsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Submit a customer review and service evaluation for a completed service request.
   * Atomically recalculates the mechanic's rating in PostgreSQL.
   */
  async createReview(customerId: string, dto: CreateReviewDto) {
    // 1. Fetch service request
    const request = await this.prisma.serviceRequest.findUnique({
      where: { id: dto.serviceRequestId },
      include: {
        mechanic: { include: { user: true } },
      },
    });

    if (!request) {
      throw new NotFoundException(`Service request '${dto.serviceRequestId}' was not found`);
    }

    // 2. Strict authorization: Only the customer who owned this request can review
    if (request.customerId !== customerId) {
      throw new ForbiddenException(
        'Unauthorized: Only the motorist who requested this roadside assistance can submit a review.',
      );
    }

    // 3. Strict lifecycle verification: Must be COMPLETED
    if (request.currentStatus !== ServiceRequestStatus.COMPLETED) {
      throw new BadRequestException(
        `Reviews can only be submitted for COMPLETED service requests. Current request status is '${request.currentStatus}'.`,
      );
    }

    // 4. Must have an assigned mechanic
    if (!request.mechanicId) {
      throw new BadRequestException(
        'Cannot review a service request that does not have an assigned technician.',
      );
    }

    // 5. Duplicate review prevention
    const existingReview = await this.prisma.review.findUnique({
      where: { serviceRequestId: dto.serviceRequestId },
    });

    if (existingReview) {
      throw new BadRequestException(
        'A formal review has already been submitted and finalized for this service request. Duplicate reviews are forbidden.',
      );
    }

    const mechanicId = request.mechanicId;

    // 6. Execute Atomic Transaction: Persist Review + Recalculate Rating + Log Audit
    const result = await this.prisma.$transaction(async (tx) => {
      // Create Review
      const review = await tx.review.create({
        data: {
          serviceRequestId: dto.serviceRequestId,
          customerId,
          mechanicId,
          rating: dto.rating,
          comment: dto.comment?.trim() || null,
          timelinessRating: dto.timelinessRating || null,
          costFairnessRating: dto.costFairnessRating || null,
          professionalismRating: dto.professionalismRating || null,
        },
        include: {
          customer: {
            select: { id: true, fullName: true, email: true },
          },
          mechanic: {
            include: { user: { select: { fullName: true, email: true } } },
          },
        },
      });

      // Recalculate mechanic rating across all real reviews in PostgreSQL
      const allMechanicReviews = await tx.review.findMany({
        where: { mechanicId },
        select: { rating: true },
      });

      const totalReviews = allMechanicReviews.length;
      const sumRatings = allMechanicReviews.reduce((acc, r) => acc + r.rating, 0);
      const ratingAverage = Number((sumRatings / totalReviews).toFixed(2));

      // Update MechanicProfile
      await tx.mechanicProfile.update({
        where: { id: mechanicId },
        data: {
          ratingAverage,
          totalReviews,
        },
      });

      // Immutable Audit Log
      await tx.auditLog.create({
        data: {
          userId: customerId,
          action: 'CUSTOMER_REVIEW_SUBMITTED',
          entityName: 'Review',
          entityId: review.id,
          details: {
            serviceRequestId: dto.serviceRequestId,
            mechanicId,
            rating: dto.rating,
            ratingAverage,
            totalReviews,
          },
        },
      });

      return {
        review,
        updatedReputation: {
          ratingAverage,
          totalReviews,
        },
      };
    });

    return result;
  }

  /**
   * Retrieve all public customer reviews for a given technician
   */
  async getMechanicReviews(mechanicId: string) {
    const profile = await this.prisma.mechanicProfile.findFirst({
      where: {
        OR: [{ id: mechanicId }, { userId: mechanicId }],
      },
    });

    if (!profile) {
      throw new NotFoundException(`Mechanic profile '${mechanicId}' was not found`);
    }

    return this.prisma.review.findMany({
      where: { mechanicId: profile.id },
      include: {
        customer: {
          select: {
            fullName: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Check if a specific service request has an existing review
   */
  async getRequestReview(serviceRequestId: string) {
    const review = await this.prisma.review.findUnique({
      where: { serviceRequestId },
      include: {
        customer: {
          select: {
            fullName: true,
          },
        },
      },
    });

    return review;
  }

  /**
   * Mathematically compute transparent reputation score and breakdown for a technician.
   * Incorporates arithmetic mean and Bayesian prior weighting.
   */
  async getMechanicReputation(mechanicId: string): Promise<ReputationSummary> {
    const profile = await this.prisma.mechanicProfile.findFirst({
      where: {
        OR: [{ id: mechanicId }, { userId: mechanicId }],
      },
    });

    if (!profile) {
      throw new NotFoundException(`Mechanic profile '${mechanicId}' was not found`);
    }

    const reviews = await this.prisma.review.findMany({
      where: { mechanicId: profile.id },
      select: {
        rating: true,
        timelinessRating: true,
        costFairnessRating: true,
        professionalismRating: true,
      },
    });

    const totalReviews = reviews.length;

    if (totalReviews === 0) {
      return {
        mechanicId: profile.id,
        totalReviews: 0,
        arithmeticAverage: 0.0,
        bayesianReputationScore: 0.0,
        ratingDistribution: {
          fiveStar: 0,
          fourStar: 0,
          threeStar: 0,
          twoStar: 0,
          oneStar: 0,
        },
        subScores: {
          averageTimeliness: null,
          averageCostFairness: null,
          averageProfessionalism: null,
        },
      };
    }

    // 1. Star Distribution
    const distribution = {
      fiveStar: reviews.filter((r) => r.rating === 5).length,
      fourStar: reviews.filter((r) => r.rating === 4).length,
      threeStar: reviews.filter((r) => r.rating === 3).length,
      twoStar: reviews.filter((r) => r.rating === 2).length,
      oneStar: reviews.filter((r) => r.rating === 1).length,
    };

    // 2. Arithmetic Average
    const sumRatings = reviews.reduce((sum, r) => sum + r.rating, 0);
    const arithmeticAverage = Number((sumRatings / totalReviews).toFixed(2));

    // 3. Bayesian Weighted Reputation Calculation
    // W = (v / (v + m)) * R + (m / (v + m)) * C
    // v = review count, m = minimum confidence threshold (2), C = municipal prior baseline (4.5)
    const m = 2.0;
    const C = 4.5;
    const bayesianReputationScore = Number(
      ((totalReviews / (totalReviews + m)) * arithmeticAverage +
        (m / (totalReviews + m)) * C).toFixed(2),
    );

    // 4. Sub-Scores (Average where supplied)
    const timelinessReviews = reviews.filter((r) => r.timelinessRating != null);
    const costReviews = reviews.filter((r) => r.costFairnessRating != null);
    const profReviews = reviews.filter((r) => r.professionalismRating != null);

    const averageTimeliness =
      timelinessReviews.length > 0
        ? Number(
            (
              timelinessReviews.reduce((sum, r) => sum + r.timelinessRating!, 0) /
              timelinessReviews.length
            ).toFixed(1),
          )
        : null;

    const averageCostFairness =
      costReviews.length > 0
        ? Number(
            (
              costReviews.reduce((sum, r) => sum + r.costFairnessRating!, 0) /
              costReviews.length
            ).toFixed(1),
          )
        : null;

    const averageProfessionalism =
      profReviews.length > 0
        ? Number(
            (
              profReviews.reduce((sum, r) => sum + r.professionalismRating!, 0) /
              profReviews.length
            ).toFixed(1),
          )
        : null;

    return {
      mechanicId: profile.id,
      totalReviews,
      arithmeticAverage,
      bayesianReputationScore,
      ratingDistribution: distribution,
      subScores: {
        averageTimeliness,
        averageCostFairness,
        averageProfessionalism,
      },
    };
  }
}

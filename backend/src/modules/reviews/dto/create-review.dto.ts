import { IsUUID, IsInt, Min, Max, IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReviewDto {
  @ApiProperty({ description: 'ID of the completed service request', example: 'uuid-v4' })
  @IsUUID('4', { message: 'serviceRequestId must be a valid UUID' })
  serviceRequestId: string;

  @ApiProperty({ description: 'Overall rating score from 1 to 5', minimum: 1, maximum: 5, example: 5 })
  @IsInt({ message: 'Rating must be an integer between 1 and 5' })
  @Min(1, { message: 'Rating minimum is 1' })
  @Max(5, { message: 'Rating maximum is 5' })
  rating: number;

  @ApiPropertyOptional({ description: 'Qualitative customer feedback review comment', maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000, { message: 'Comment cannot exceed 1000 characters' })
  comment?: string;

  @ApiPropertyOptional({ description: 'Timeliness sub-score (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  timelinessRating?: number;

  @ApiPropertyOptional({ description: 'Pricing transparency and fairness sub-score (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  costFairnessRating?: number;

  @ApiPropertyOptional({ description: 'Technician professionalism sub-score (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  professionalismRating?: number;
}

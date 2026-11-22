import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNumber, IsOptional, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { BreakdownCategory } from '@prisma/client';

export class NearbyMechanicsQueryDto {
  @ApiProperty({ example: 40.7128, description: 'Customer incident latitude (-90 to 90)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Latitude must be a valid number' })
  @Min(-90, { message: 'Latitude cannot be less than -90' })
  @Max(90, { message: 'Latitude cannot be greater than 90' })
  latitude: number;

  @ApiProperty({ example: -74.0060, description: 'Customer incident longitude (-180 to 180)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Longitude must be a valid number' })
  @Min(-180, { message: 'Longitude cannot be less than -180' })
  @Max(180, { message: 'Longitude cannot be greater than 180' })
  longitude: number;

  @ApiPropertyOptional({ example: 25.0, default: 25.0, description: 'Radial search boundary in km (1 to 100)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Search radius must be a number' })
  @Min(1, { message: 'Search radius must be at least 1 km' })
  @Max(100, { message: 'Search radius cannot exceed 100 km' })
  radius?: number = 25.0;

  @ApiPropertyOptional({ enum: BreakdownCategory, description: 'Filter by supported diagnostic specialization' })
  @IsOptional()
  @IsEnum(BreakdownCategory, { message: 'Invalid breakdown category' })
  category?: BreakdownCategory;
}

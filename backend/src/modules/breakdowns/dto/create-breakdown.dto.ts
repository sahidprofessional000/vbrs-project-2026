import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';
import { BreakdownCategory, SeverityLevel } from '@prisma/client';

export class CreateBreakdownDto {
  @ApiPropertyOptional({ example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', description: 'Associated customer vehicle UUID' })
  @IsOptional()
  @IsUUID('4', { message: 'Vehicle ID must be a valid UUID v4' })
  vehicleId?: string;

  @ApiProperty({ enum: BreakdownCategory, example: BreakdownCategory.ENGINE_FAILURE, description: 'Failure category' })
  @IsEnum(BreakdownCategory, { message: 'Invalid breakdown category' })
  @IsNotEmpty({ message: 'Category is required' })
  category: BreakdownCategory;

  @ApiPropertyOptional({ enum: SeverityLevel, default: SeverityLevel.MEDIUM, description: 'Roadside hazard severity' })
  @IsOptional()
  @IsEnum(SeverityLevel, { message: 'Severity must be LOW, MEDIUM, or CRITICAL' })
  severity?: SeverityLevel = SeverityLevel.MEDIUM;

  @ApiProperty({ example: 'Engine started smoking on highway shoulder, loss of power.', description: 'Detailed failure symptoms' })
  @IsString()
  @IsNotEmpty({ message: 'Fault description cannot be empty' })
  @MinLength(5, { message: 'Description must be at least 5 characters' })
  description: string;

  @ApiProperty({ example: 40.7128, description: 'Latitude coordinate (-90 to 90)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Latitude must be a valid number' })
  @Min(-90, { message: 'Latitude must be between -90 and 90' })
  @Max(90, { message: 'Latitude must be between -90 and 90' })
  latitude: number;

  @ApiProperty({ example: -74.0060, description: 'Longitude coordinate (-180 to 180)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Longitude must be a valid number' })
  @Min(-180, { message: 'Longitude must be between -180 and 180' })
  @Max(180, { message: 'Longitude must be between -180 and 180' })
  longitude: number;

  @ApiPropertyOptional({ example: 'I-95 North, Mile Marker 42, Shoulder', description: 'Human-readable address or landmark' })
  @IsOptional()
  @IsString()
  addressText?: string;
}

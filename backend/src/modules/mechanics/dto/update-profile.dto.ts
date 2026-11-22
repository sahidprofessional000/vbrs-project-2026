import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateMechanicProfileDto {
  @ApiPropertyOptional({ example: 'Precision Roadside Mechanics', description: 'Workshop or brand name' })
  @IsOptional()
  @IsString()
  workshopName?: string;

  @ApiPropertyOptional({ example: '742 Evergreen Terrace, Sector 4, Metro Area', description: 'Physical workshop address' })
  @IsOptional()
  @IsString()
  workshopAddress?: string;

  @ApiPropertyOptional({ example: 25.0, description: 'Service operational boundary radius in km (1 to 100)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Operating radius must be a number' })
  @Min(1, { message: 'Service radius must be at least 1 km' })
  @Max(100, { message: 'Service radius cannot exceed 100 km' })
  operatingRadiusKm?: number;

  @ApiPropertyOptional({ example: 10, description: 'Years of automotive repair experience' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Experience years must be a number' })
  @Min(0, { message: 'Experience cannot be negative' })
  @Max(60, { message: 'Experience exceeds valid range' })
  experienceYears?: number;

  @ApiPropertyOptional({ example: 'ASE-MASTER-99482', description: 'Trade certification or license number (triggers re-verification)' })
  @IsOptional()
  @IsString()
  tradeLicenseNumber?: string;

  @ApiPropertyOptional({ example: ['ASE Certified Master Technician', 'EV Powertrain Level 2'], description: 'Certifications held' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  certifications?: string[];

  @ApiPropertyOptional({ example: ['Engine Diagnostics', 'High-Voltage Battery', 'Hydraulic Brakes'], description: 'Technical specializations' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  specializations?: string[];

  @ApiPropertyOptional({ example: 'Certified mobile diagnostics specialist with 12+ years experience in heavy mechanical and electrical triage.', description: 'Professional bio' })
  @IsOptional()
  @IsString()
  bio?: string;
}

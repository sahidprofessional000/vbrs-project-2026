import { IsEnum, IsOptional, IsString, IsArray, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { BreakdownCategory, SeverityLevel, PowertrainType } from '@prisma/client';

export class EvaluateDiagnosisDto {
  @ApiProperty({ enum: BreakdownCategory, description: 'Primary symptom category' })
  @IsEnum(BreakdownCategory)
  category: BreakdownCategory;

  @ApiPropertyOptional({ enum: SeverityLevel, default: SeverityLevel.MEDIUM })
  @IsOptional()
  @IsEnum(SeverityLevel)
  severity?: SeverityLevel;

  @ApiPropertyOptional({ enum: PowertrainType, default: PowertrainType.PETROL })
  @IsOptional()
  @IsEnum(PowertrainType)
  powertrain?: PowertrainType;

  @ApiPropertyOptional({ description: 'Detailed motorist description of symptoms' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiPropertyOptional({
    description: 'Active warning indicator lights on the vehicle dashboard',
    example: ['check_engine', 'oil_pressure', 'coolant_temp'],
  })
  @IsOptional()
  @IsArray()
  warningLights?: string[];

  @ApiPropertyOptional({
    description: 'Specific auditory, sensory or physical symptoms observed',
    example: ['knocking_noise', 'white_smoke', 'fluid_leak'],
  })
  @IsOptional()
  @IsArray()
  symptoms?: string[];

  @ApiPropertyOptional({
    description: 'Roadside physical context',
    example: 'HIGHWAY_SHOULDER',
  })
  @IsOptional()
  @IsString()
  roadsideContext?: string;
}

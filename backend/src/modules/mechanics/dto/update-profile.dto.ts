import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateMechanicProfileDto {
  @ApiPropertyOptional({ example: 'Precision Roadside Mechanics', description: 'Workshop or brand name' })
  @IsOptional()
  @IsString()
  workshopName?: string;

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
}

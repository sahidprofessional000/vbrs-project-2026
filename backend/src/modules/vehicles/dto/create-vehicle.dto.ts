import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { PowertrainType } from '@prisma/client';

export class CreateVehicleDto {
  @ApiProperty({ example: 'Toyota', description: 'Vehicle manufacturer make' })
  @IsString()
  @IsNotEmpty({ message: 'Vehicle make is required' })
  make: string;

  @ApiProperty({ example: 'RAV4 Hybrid', description: 'Vehicle model' })
  @IsString()
  @IsNotEmpty({ message: 'Vehicle model is required' })
  model: string;

  @ApiProperty({ example: 2023, description: 'Manufacture model year' })
  @IsInt({ message: 'Year must be an integer' })
  @Min(1970, { message: 'Vehicle year must be 1970 or newer' })
  @Max(new Date().getFullYear() + 1, { message: 'Vehicle year cannot be in the far future' })
  year: number;

  @ApiProperty({ example: '7XYZ890', description: 'Registration license plate number' })
  @IsString()
  @IsNotEmpty({ message: 'License plate is required' })
  @Transform(({ value }) => (typeof value === 'string' ? value.toUpperCase().trim() : value))
  licensePlate: string;

  @ApiPropertyOptional({ example: '4T3B11HK5NU987654', description: '17-character VIN (optional)' })
  @IsOptional()
  @IsString()
  @Transform(({ value }) => (typeof value === 'string' ? value.toUpperCase().trim() : value))
  vin?: string;

  @ApiPropertyOptional({ example: 'Magnetic Gray', description: 'Vehicle body color' })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({
    enum: PowertrainType,
    default: PowertrainType.PETROL,
    description: 'Powertrain propulsion type',
  })
  @IsOptional()
  @IsEnum(PowertrainType, { message: 'Invalid powertrain type' })
  powertrain?: PowertrainType = PowertrainType.PETROL;

  @ApiPropertyOptional({ example: false, description: 'Designate as default vehicle for emergency filings' })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean = false;
}

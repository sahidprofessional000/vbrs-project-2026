import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateSavedAddressDto {
  @ApiProperty({ example: 'Primary Residence', description: 'Label or nickname for the location' })
  @IsString()
  @IsNotEmpty({ message: 'Address label is required' })
  label: string;

  @ApiProperty({ example: '124 Conway St, Brooklyn, NY 11207', description: 'Street address' })
  @IsString()
  @IsNotEmpty({ message: 'Address text is required' })
  address: string;

  @ApiPropertyOptional({ example: 40.7128, description: 'GPS Latitude' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Latitude must be a valid number' })
  @Min(-90)
  @Max(90)
  latitude?: number;

  @ApiPropertyOptional({ example: -74.006, description: 'GPS Longitude' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Longitude must be a valid number' })
  @Min(-180)
  @Max(180)
  longitude?: number;

  @ApiPropertyOptional({ example: true, description: 'Designate as default primary location' })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}

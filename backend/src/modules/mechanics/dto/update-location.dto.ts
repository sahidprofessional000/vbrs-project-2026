import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateLocationDto {
  @ApiProperty({ example: 40.7128, description: 'Technician GPS latitude (-90 to 90)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Latitude must be a valid number' })
  @Min(-90, { message: 'Latitude cannot be less than -90' })
  @Max(90, { message: 'Latitude cannot be greater than 90' })
  latitude: number;

  @ApiProperty({ example: -74.0060, description: 'Technician GPS longitude (-180 to 180)' })
  @Type(() => Number)
  @IsNumber({}, { message: 'Longitude must be a valid number' })
  @Min(-180, { message: 'Longitude cannot be less than -180' })
  @Max(180, { message: 'Longitude cannot be greater than 180' })
  longitude: number;

  @ApiPropertyOptional({ example: 180.0, description: 'Compass heading in degrees (0 to 360)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Heading must be a number' })
  @Min(0, { message: 'Heading cannot be negative' })
  @Max(360, { message: 'Heading cannot exceed 360 degrees' })
  heading?: number;

  @ApiPropertyOptional({ example: 45.5, description: 'Transit velocity in km/h' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Speed must be a number' })
  @Min(0, { message: 'Speed cannot be negative' })
  speed?: number;

  @ApiPropertyOptional({ example: 4.8, description: 'Horizontal GPS accuracy radius in meters' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Accuracy must be a number' })
  @Min(0, { message: 'Accuracy cannot be negative' })
  accuracy?: number;
}

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { ServiceRequestStatus } from '@prisma/client';

export class TransitionStatusDto {
  @ApiProperty({
    enum: ServiceRequestStatus,
    description: 'Target lifecycle status for the service request',
    example: ServiceRequestStatus.EN_ROUTE,
  })
  @IsEnum(ServiceRequestStatus)
  @IsNotEmpty()
  status: ServiceRequestStatus;

  @ApiPropertyOptional({
    description: 'Optional operational or diagnostic notes for this lifecycle transition',
    example: 'Technician dispatched with mobile diagnostic scanner.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @ApiPropertyOptional({
    description: 'Mandatory if transitioning to CANCELLED state',
    example: 'Motorist managed to restart vehicle independently.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  cancellationReason?: string;

  @ApiPropertyOptional({
    description: 'Resolution notes recorded upon service completion',
    example: 'Battery terminal corrosion cleaned; alternator output verified at 14.2V.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  resolutionNotes?: string;
}

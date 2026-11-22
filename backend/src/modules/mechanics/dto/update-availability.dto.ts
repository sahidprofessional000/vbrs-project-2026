import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty } from 'class-validator';
import { AvailabilityStatus } from '@prisma/client';

export class UpdateAvailabilityDto {
  @ApiProperty({
    enum: AvailabilityStatus,
    example: AvailabilityStatus.AVAILABLE,
    description: 'Operational readiness state of technician',
  })
  @IsEnum(AvailabilityStatus, {
    message: 'Status must be OFFLINE, AVAILABLE, or ON_JOB',
  })
  @IsNotEmpty()
  status: AvailabilityStatus;
}

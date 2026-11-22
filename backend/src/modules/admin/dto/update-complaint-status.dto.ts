import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { ComplaintStatus } from '@prisma/client';

export class UpdateComplaintStatusDto {
  @ApiProperty({
    enum: ComplaintStatus,
    description: 'New complaint lifecycle status (INVESTIGATING, RESOLVED, DISMISSED)',
    example: ComplaintStatus.RESOLVED,
  })
  @IsEnum(ComplaintStatus)
  @IsNotEmpty()
  status: ComplaintStatus;

  @ApiPropertyOptional({
    description: 'Official administrative resolution notes and mediation verdict',
    example: 'Dispute reviewed with GPS breadcrumbs. Partial refund issued; technician reprimanded.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  resolutionNotes?: string;
}

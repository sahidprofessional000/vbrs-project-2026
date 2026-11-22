import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CreateComplaintDto {
  @ApiProperty({
    description: 'Service Request ID associated with this dispute / complaint',
    example: '5667e3e6-1685-49a1-ae1b-73e2d7019d11',
  })
  @IsUUID()
  @IsNotEmpty()
  serviceRequestId: string;

  @ApiProperty({
    description: 'Dispute subject title',
    example: 'Unauthorized parts replacement quote discrepancy',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  subject: string;

  @ApiProperty({
    description: 'Full dispute description and grievance statement',
    example: 'Technician arrived 40 minutes after ETA without advance communication.',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  description: string;

  @ApiPropertyOptional({
    description: 'Target user ID against whom complaint is filed (optional)',
  })
  @IsOptional()
  @IsUUID()
  targetUserId?: string;
}

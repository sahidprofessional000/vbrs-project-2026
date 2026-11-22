import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { VerificationStatus } from '@prisma/client';

export class VerifyMechanicDto {
  @ApiProperty({
    enum: VerificationStatus,
    description: 'Target verification status (APPROVED, REJECTED, PENDING)',
    example: VerificationStatus.APPROVED,
  })
  @IsEnum(VerificationStatus)
  @IsNotEmpty()
  status: VerificationStatus;

  @ApiPropertyOptional({
    description: 'Administrative notes or feedback regarding trade certification audit',
    example: 'ASE Master certificate credentials verified against National Registry database.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}

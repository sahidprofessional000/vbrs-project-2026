import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class RecordQuoteDto {
  @ApiPropertyOptional({
    description: 'Preliminary diagnostic inspection fee ($)',
    example: 65.0,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(10000)
  diagnosticQuote?: number;

  @ApiPropertyOptional({
    description: 'Estimated or final technician labor cost ($)',
    example: 120.0,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(50000)
  laborCost?: number;

  @ApiPropertyOptional({
    description: 'Replacement parts and materials cost ($)',
    example: 85.5,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(50000)
  partsCost?: number;

  @ApiPropertyOptional({
    description: 'Agreed total quote ($). If omitted, automatically computed as sum of parts + labor + diagnostic.',
    example: 270.5,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(100000)
  agreedQuote?: number;

  @ApiPropertyOptional({
    description: 'Detailed work order description or parts itemization',
    example: 'Replaced dead 12V AGM battery and terminal clamps.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}

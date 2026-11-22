import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CancelServiceDto {
  @ApiProperty({
    description: 'Explicit reason for cancelling the breakdown service request',
    example: 'Customer arranged alternate towing service.',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason: string;
}

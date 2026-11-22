import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty } from 'class-validator';

export class UpdateLocationConsentDto {
  @ApiProperty({
    description: 'Whether high-precision GPS telemetry may be shared with the other party',
    example: true,
  })
  @IsNotEmpty()
  @IsBoolean()
  locationConsent: boolean;
}

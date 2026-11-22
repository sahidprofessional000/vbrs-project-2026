import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class RefreshTokenDto {
  @ApiPropertyOptional({ description: 'JWT refresh token (if not provided via httpOnly cookie)' })
  @IsOptional()
  @IsString()
  refreshToken?: string;
}

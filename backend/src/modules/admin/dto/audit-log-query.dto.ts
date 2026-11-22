import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class AuditLogQueryDto {
  @ApiPropertyOptional({
    description: 'Filter audit logs by action string prefix or name',
    example: 'SERVICE_STATUS',
  })
  @IsOptional()
  @IsString()
  action?: string;

  @ApiPropertyOptional({
    description: 'Filter audit logs by entity name',
    example: 'ServiceRequest',
  })
  @IsOptional()
  @IsString()
  entityName?: string;

  @ApiPropertyOptional({
    description: 'Pagination limit (default: 50, max: 100)',
    example: 50,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;

  @ApiPropertyOptional({
    description: 'Pagination offset (default: 0)',
    example: 0,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  offset?: number = 0;
}

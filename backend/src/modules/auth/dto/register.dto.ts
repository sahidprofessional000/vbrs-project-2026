import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
  Matches,
  IsInt,
  Min,
  Max,
} from 'class-validator';
import { Role } from '@prisma/client';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com', description: 'Unique user email address' })
  @IsEmail({}, { message: 'Please provide a valid email address' })
  @IsNotEmpty({ message: 'Email address cannot be empty' })
  email: string;

  @ApiProperty({
    example: 'SecurePass@123',
    description: 'Password with minimum 8 chars, 1 uppercase, 1 lowercase, 1 number or symbol',
  })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Password must contain uppercase, lowercase, and a number or special symbol',
  })
  password: string;

  @ApiProperty({ example: 'Marcus Vance', description: 'Full legal name' })
  @IsString()
  @IsNotEmpty({ message: 'Full name is required' })
  fullName: string;

  @ApiPropertyOptional({ example: '+1-555-0199', description: 'Phone contact number' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ enum: Role, default: Role.CUSTOMER, description: 'Role to register as' })
  @IsOptional()
  @IsEnum(Role, { message: 'Role must be either CUSTOMER or MECHANIC' })
  role?: Role = Role.CUSTOMER;

  // Mechanic-specific optional fields during registration
  @ApiPropertyOptional({ example: 'Apex Roadside Express', description: 'Business or workshop name' })
  @IsOptional()
  @IsString()
  workshopName?: string;

  @ApiPropertyOptional({ example: 'ASE-CERT-12345', description: 'Trade certification or license number' })
  @IsOptional()
  @IsString()
  tradeLicenseNumber?: string;

  @ApiPropertyOptional({ example: 5, description: 'Years of automotive trade experience' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(60)
  experienceYears?: number;
}

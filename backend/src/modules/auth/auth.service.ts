import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { Response } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { Role, VerificationStatus, AvailabilityStatus } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Register a new Customer or Mechanic
   */
  async register(dto: RegisterDto, res?: Response) {
    const normalizedEmail = dto.email.toLowerCase().trim();

    // Check email uniqueness
    const existingUser = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (existingUser) {
      throw new ConflictException('An account with this email address already exists');
    }

    // Hash password with bcrypt (12 rounds)
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    const userRole = dto.role || Role.CUSTOMER;

    // Use transaction to ensure user and mechanic profile are created atomically
    const user = await this.prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          email: normalizedEmail,
          passwordHash,
          fullName: dto.fullName.trim(),
          phone: dto.phone?.trim(),
          role: userRole,
        },
      });

      // If registered as mechanic, create MechanicProfile and default Location
      if (userRole === Role.MECHANIC) {
        const profile = await tx.mechanicProfile.create({
          data: {
            userId: newUser.id,
            workshopName: dto.workshopName?.trim() || `${dto.fullName}'s Roadside Service`,
            tradeLicenseNumber: dto.tradeLicenseNumber?.trim(),
            experienceYears: dto.experienceYears || 1,
            verificationStatus: VerificationStatus.PENDING,
            availabilityStatus: AvailabilityStatus.OFFLINE,
            operatingRadiusKm: 25.0,
          },
        });

        // Initialize zero coordinates for location
        await tx.mechanicLocation.create({
          data: {
            mechanicId: profile.id,
            latitude: 0.0,
            longitude: 0.0,
          },
        });
      }

      // Record audit log
      await tx.auditLog.create({
        data: {
          userId: newUser.id,
          action: 'USER_REGISTERED',
          entityName: 'User',
          entityId: newUser.id,
          details: { role: userRole, email: normalizedEmail },
        },
      });

      return newUser;
    });

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email, user.role);

    if (res) {
      this.setRefreshTokenCookie(res, tokens.refreshToken);
    }

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        role: user.role,
        avatarUrl: user.avatarUrl,
      },
      tokens,
    };
  }

  /**
   * Authenticate user with email and password
   */
  async login(dto: LoginDto, res?: Response) {
    const normalizedEmail = dto.email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({
      where: { email: normalizedEmail },
      include: {
        mechanicProfile: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account has been suspended. Please contact platform administration.');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Generate access & refresh tokens
    const tokens = await this.generateTokens(user.id, user.email, user.role);

    // Record audit log
    await this.prisma.auditLog.create({
      data: {
        userId: user.id,
        action: 'USER_LOGGED_IN',
        entityName: 'User',
        entityId: user.id,
      },
    });

    if (res) {
      this.setRefreshTokenCookie(res, tokens.refreshToken);
    }

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone,
        role: user.role,
        avatarUrl: user.avatarUrl,
        mechanicProfile: user.mechanicProfile,
      },
      tokens,
    };
  }

  /**
   * Rotate Refresh Token and return new token pair
   */
  async refreshTokens(rawRefreshToken: string, res?: Response) {
    if (!rawRefreshToken) {
      throw new UnauthorizedException('Refresh token is required');
    }

    const tokenHash = this.hashToken(rawRefreshToken);

    const tokenRecord = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!tokenRecord) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (tokenRecord.revokedAt) {
      // Possible token reuse attempt! Invalidate all tokens for this user for security
      await this.prisma.refreshToken.updateMany({
        where: { userId: tokenRecord.userId },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException('Revoked refresh token presented. All sessions terminated for security.');
    }

    if (new Date() > tokenRecord.expiresAt) {
      throw new UnauthorizedException('Refresh token has expired. Please sign in again.');
    }

    // Revoke old token
    await this.prisma.refreshToken.update({
      where: { id: tokenRecord.id },
      data: { revokedAt: new Date() },
    });

    // Generate fresh token pair
    const tokens = await this.generateTokens(
      tokenRecord.user.id,
      tokenRecord.user.email,
      tokenRecord.user.role,
    );

    if (res) {
      this.setRefreshTokenCookie(res, tokens.refreshToken);
    }

    return tokens;
  }

  /**
   * Invalidate Refresh Token upon logout
   */
  async logout(userId: string, rawRefreshToken?: string, res?: Response) {
    if (rawRefreshToken) {
      const tokenHash = this.hashToken(rawRefreshToken);
      await this.prisma.refreshToken.updateMany({
        where: { tokenHash, userId },
        data: { revokedAt: new Date() },
      });
    } else {
      // Revoke all active tokens for this user
      await this.prisma.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }

    if (res) {
      res.clearCookie('refresh_token', {
        httpOnly: true,
        sameSite: 'lax',
      });
    }

    await this.prisma.auditLog.create({
      data: {
        userId,
        action: 'USER_LOGGED_OUT',
        entityName: 'User',
        entityId: userId,
      },
    });

    return { message: 'Logged out successfully' };
  }

  /**
   * Get current authenticated user profile
   */
  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        mechanicProfile: {
          include: {
            services: true,
            currentLocation: true,
          },
        },
        vehicles: {
          orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User profile not found');
    }

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  /**
   * Update basic profile info
   */
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: {
        fullName: dto.fullName?.trim(),
        phone: dto.phone?.trim(),
        avatarUrl: dto.avatarUrl?.trim(),
      },
    });

    const { passwordHash, ...safeUser } = updated;
    return safeUser;
  }

  /**
   * Helper: Generate access & refresh tokens
   */
  private async generateTokens(userId: string, email: string, role: string) {
    const accessSecret =
      this.configService.get<string>('JWT_ACCESS_SECRET') ||
      'vbrs_jwt_access_super_secret_key_dev_2026_xyz';
    const accessExpiration =
      this.configService.get<string>('JWT_ACCESS_EXPIRATION') || '15m';

    const accessToken = this.jwtService.sign(
      { sub: userId, email, role },
      { secret: accessSecret, expiresIn: accessExpiration },
    );

    // Cryptographically secure random 64-char refresh token
    const rawRefreshToken = crypto.randomBytes(40).toString('hex');
    const tokenHash = this.hashToken(rawRefreshToken);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiration

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt,
      },
    });

    return {
      accessToken,
      refreshToken: rawRefreshToken,
      expiresInSeconds: 900, // 15 minutes
    };
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private setRefreshTokenCookie(res: Response, token: string) {
    res.cookie('refresh_token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      path: '/api/auth',
    });
  }
}

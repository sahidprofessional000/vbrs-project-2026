import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  Res,
  BadRequestException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { Response } from 'express';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';
import { BreakdownsService } from './breakdowns.service';
import { CreateBreakdownDto } from './dto/create-breakdown.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

// Ensure upload destination directory exists
const uploadDir = path.resolve(process.cwd(), 'uploads', 'breakdowns');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer storage and validation configuration
export const breakdownMulterOptions = {
  storage: diskStorage({
    destination: (req, file, cb) => {
      cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname).toLowerCase();
      const uniqueName = `${crypto.randomUUID()}${ext}`;
      cb(null, uniqueName);
    },
  }),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB per file
    files: 5, // Maximum 5 files
  },
  fileFilter: (req: any, file: Express.Multer.File, cb: any) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimes.includes(file.mimetype.toLowerCase())) {
      cb(null, true);
    } else {
      cb(
        new BadRequestException(
          `Invalid file format (${file.mimetype}). Only JPEG, PNG, and WebP images are permitted.`,
        ),
        false,
      );
    }
  },
};

@ApiTags('Breakdowns')
@Controller('breakdowns')
export class BreakdownsController {
  constructor(private readonly breakdownsService: BreakdownsService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Submit an emergency breakdown report with optional photographs' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'Breakdown report data and up to 5 optional damage images (max 5MB each)',
    type: CreateBreakdownDto,
  })
  @ApiResponse({ status: 201, description: 'Breakdown report created with initial diagnosis' })
  @ApiResponse({ status: 400, description: 'Validation error or invalid image file' })
  @UseInterceptors(FilesInterceptor('images', 5, breakdownMulterOptions))
  async create(
    @CurrentUser('id') customerId: string,
    @Body() dto: CreateBreakdownDto,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    return this.breakdownsService.create(customerId, dto, files || []);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'List customer breakdown reporting history' })
  @ApiResponse({ status: 200, description: 'List of reports with vehicle and images' })
  async findAll(@CurrentUser('id') customerId: string) {
    return this.breakdownsService.findAllForCustomer(customerId);
  }

  @Get('images/:filename')
  @ApiOperation({ summary: 'Serve incident damage photograph' })
  @ApiResponse({ status: 200, description: 'Image binary data' })
  @ApiResponse({ status: 404, description: 'Image not found' })
  async getImage(@Param('filename') filename: string, @Res() res: Response) {
    const filePath = this.breakdownsService.getImageFilePath(filename);
    res.setHeader('Cache-Control', 'public, max-age=86400');
    return res.sendFile(filePath);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.MECHANIC, Role.ADMIN)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Get details of a specific breakdown report' })
  @ApiResponse({ status: 200, description: 'Full breakdown report details' })
  @ApiResponse({ status: 404, description: 'Report not found' })
  async findOne(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
  ) {
    return this.breakdownsService.findOne(id, userId, role === Role.ADMIN);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @ApiBearerAuth('bearer-jwt')
  @ApiOperation({ summary: 'Cancel/delete a pending breakdown report' })
  @ApiResponse({ status: 200, description: 'Report deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete report after dispatch' })
  async delete(
    @Param('id') id: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') role: Role,
  ) {
    return this.breakdownsService.delete(id, userId, role === Role.ADMIN);
  }
}

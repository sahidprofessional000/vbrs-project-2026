import { Controller, Post, Get, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DiagnosticsService, ExpertDiagnosisResult } from './diagnostics.service';
import { EvaluateDiagnosisDto } from './dto/evaluate-diagnosis.dto';

@ApiTags('Rule-Based Expert Diagnostic Engine')
@Controller('diagnostics')
export class DiagnosticsController {
  constructor(private readonly diagnosticsService: DiagnosticsService) {}

  @Post('evaluate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Evaluate vehicle symptoms via deterministic expert diagnostic rule matrix',
    description:
      'Returns preliminary diagnostic suggestions, critical driver safety warnings, mandatory towing verdicts, and legal disclaimers. Never a guaranteed mechanical diagnosis.',
  })
  @ApiResponse({
    status: 200,
    description: 'Preliminary expert diagnostic evaluation and safety protocols',
  })
  evaluate(@Body() dto: EvaluateDiagnosisDto): ExpertDiagnosisResult {
    return this.diagnosticsService.evaluate(dto);
  }

  @Get('disclaimer')
  @ApiOperation({ summary: 'Retrieve official legal and technical diagnostic disclaimer' })
  getDisclaimer() {
    return {
      disclaimer: DiagnosticsService.LEGAL_DISCLAIMER,
      isPreliminary: true,
      standard: 'ISO 20488:2018 / SAE J1979 Diagnostic Protocols',
    };
  }
}

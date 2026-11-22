import { Injectable } from '@nestjs/common';
import { BreakdownCategory, SeverityLevel, PowertrainType } from '@prisma/client';

export interface TriageResult {
  requiresTowing: boolean;
  ruleDiagnosis: string;
  recommendedEquipment: string[];
  safetyAdvisories: string[];
}

@Injectable()
export class BreakdownTriageService {
  /**
   * Evaluates breakdown telemetry, category, severity, and powertrain
   * to produce deterministic triage diagnosis and towing requirements.
   */
  classify(
    category: BreakdownCategory,
    severity: SeverityLevel,
    description: string,
    powertrain?: PowertrainType,
  ): TriageResult {
    const descLower = description.toLowerCase();

    // 1. Determine Towing Requirement
    let requiresTowing = false;
    const safetyAdvisories: string[] = [];
    const recommendedEquipment: string[] = [];

    // Category-specific towing triggers
    if (
      category === BreakdownCategory.COLLISION_ACCIDENT ||
      category === BreakdownCategory.TRANSMISSION_ISSUE ||
      category === BreakdownCategory.BRAKE_SYSTEM_FAILURE
    ) {
      requiresTowing = true;
    }

    // Severity trigger
    if (severity === SeverityLevel.CRITICAL) {
      requiresTowing = true;
    }

    // Keyword heuristic triggers
    const criticalKeywords = [
      'smoke',
      'fire',
      'overturn',
      'seized',
      'axle',
      'blown',
      'undriveable',
      'locked up',
      'fluid leak',
      'airbag',
      'oil light',
    ];

    if (criticalKeywords.some((kw) => descLower.includes(kw))) {
      requiresTowing = true;
    }

    // 2. Powertrain-specific safety protocols
    if (powertrain === PowertrainType.ELECTRIC || powertrain === PowertrainType.HYBRID) {
      safetyAdvisories.push(
        'HIGH-VOLTAGE HAZARD (400V-800V): Do not attempt to disconnect or touch orange insulated cables.',
      );
      safetyAdvisories.push(
        'FLATBED RECOVERY MANDATORY: Do not push-tow or flat-tow EV to prevent magnetic motor regeneration damage.',
      );
      recommendedEquipment.push('Insulated 1000V Field Tooling', 'EV Flatbed Skates');
      if (category === BreakdownCategory.BATTERY_DEAD_ELECTRICAL) {
        safetyAdvisories.push(
          '12V auxiliary system jump-pack diagnostic required to close main traction battery contactors.',
        );
      }
    } else {
      // ICE (Petrol / Diesel)
      if (category === BreakdownCategory.OVERHEATING_COOLANT) {
        safetyAdvisories.push(
          'SCALDING HAZARD: Engine coolant under extreme pressure. DO NOT open radiator or expansion tank cap.',
        );
        safetyAdvisories.push('Turn engine off immediately to prevent cylinder head warpage.');
        recommendedEquipment.push('Coolant Refill Reservoir', 'Infrared Thermometer');
      }
    }

    // 3. Category-specific advisories and equipment
    switch (category) {
      case BreakdownCategory.FLAT_TIRE_WHEEL:
        if (!requiresTowing) {
          safetyAdvisories.push('Position vehicle entirely onto emergency shoulder before inspecting tire.');
          recommendedEquipment.push('3-Ton Pneumatic Low-Profile Jack', 'Impact Wrench', 'Tire Sealant Kit');
        } else {
          safetyAdvisories.push('Multiple tire or rim damage detected: Flatbed extraction assigned.');
          recommendedEquipment.push('Flatbed Carrier', 'Wheel Dollies');
        }
        break;

      case BreakdownCategory.BRAKE_SYSTEM_FAILURE:
        safetyAdvisories.push('CRITICAL SAFETY RISK: Do not attempt to operate vehicle under any circumstances.');
        safetyAdvisories.push('Hydraulic brake pressure loss requires immediate workshop bleed and master cylinder triage.');
        recommendedEquipment.push('Flatbed Winch Carrier', 'Wheel Chocks');
        break;

      case BreakdownCategory.BATTERY_DEAD_ELECTRICAL:
        if (!requiresTowing) {
          safetyAdvisories.push('Neutral gear lockout override may be required if electronic shifter is unpowered.');
          recommendedEquipment.push('Commercial 12V/24V Jump-Pack', 'Digital Multimeter / Alternator Tester');
        }
        break;

      case BreakdownCategory.COLLISION_ACCIDENT:
        safetyAdvisories.push('Emergency scene protocol: Remain behind highway barrier until first responders arrive.');
        safetyAdvisories.push('Inspect roadway for combustible fluid spillage.');
        recommendedEquipment.push('Heavy Flatbed Recovery Unit', 'Fluid Absorption Spills Kit');
        break;

      case BreakdownCategory.LOCKOUT_KEY_LOST:
        safetyAdvisories.push('Verify vehicle ownership documentation with technician prior to entry.');
        recommendedEquipment.push('Precision Lockout Wedge Kit', 'Long-Reach Lock Tooling');
        break;

      default:
        recommendedEquipment.push('OBD-II CAN-Bus Diagnostic Scanner', 'Standard Roadside Field Toolkit');
        break;
    }

    // General roadside safety guideline
    safetyAdvisories.push('Ensure emergency hazard flashers are active.');

    // 4. Construct Formatted Rule Diagnosis Text
    const primaryDiagnosis = this.getPrimaryDiagnosisLabel(category, requiresTowing, powertrain);
    const dispatchClass = requiresTowing ? 'FLATBED WINCH EXTRACTION' : 'MOBILE ROADSIDE FIELD DISPATCH';

    const ruleDiagnosis = [
      `[DIAGNOSIS PROTOCOL]: ${primaryDiagnosis}`,
      `[DISPATCH TIER]: ${dispatchClass}`,
      `[TOWING VERDICT]: ${requiresTowing ? 'MANDATORY FLATBED RECOVERY' : 'ROADSIDE MOBILE REPAIR ELIGIBLE'}`,
      `[SAFETY ADVISORIES]: ${safetyAdvisories.join(' | ')}`,
      `[RECOMMENDED GEAR]: ${recommendedEquipment.join(', ')}`,
    ].join('\n');

    return {
      requiresTowing,
      ruleDiagnosis,
      recommendedEquipment,
      safetyAdvisories,
    };
  }

  private getPrimaryDiagnosisLabel(
    category: BreakdownCategory,
    requiresTowing: boolean,
    powertrain?: PowertrainType,
  ): string {
    const isEV = powertrain === PowertrainType.ELECTRIC || powertrain === PowertrainType.HYBRID;

    switch (category) {
      case BreakdownCategory.ENGINE_FAILURE:
        return isEV ? 'Traction Inverter / Electric Motor Fault' : 'Internal Combustion Powertrain Seizure / Stalling';
      case BreakdownCategory.TRANSMISSION_ISSUE:
        return 'Transmission Gearbox / Direct-Drive Lockup';
      case BreakdownCategory.FLAT_TIRE_WHEEL:
        return requiresTowing ? 'Severe Rim Deformity / Multiple Blowouts' : 'Pneumatic Tire Puncture / Sidewall Breach';
      case BreakdownCategory.BATTERY_DEAD_ELECTRICAL:
        return isEV ? '12V Auxiliary Rail Depletion (Traction Isolation)' : '12V Cranking Battery Drain / Alternator Failure';
      case BreakdownCategory.BRAKE_SYSTEM_FAILURE:
        return 'Hydraulic Brake Line Breach / ABS Caliper Lock';
      case BreakdownCategory.OVERHEATING_COOLANT:
        return 'Coolant System Rupture / Radiator Overpressure';
      case BreakdownCategory.FUEL_EMPTY_OR_CONTAMINATED:
        return 'Fuel Starvation / System Contamination';
      case BreakdownCategory.LOCKOUT_KEY_LOST:
        return 'Electronic Key Fob Isolation / Passive Entry Lockout';
      case BreakdownCategory.COLLISION_ACCIDENT:
        return 'Chassis Structural Impact / Collision Damage';
      default:
        return 'Unspecified Powertrain / Roadside Incident';
    }
  }
}

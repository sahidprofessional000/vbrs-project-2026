import { Injectable } from '@nestjs/common';
import { BreakdownCategory, SeverityLevel, PowertrainType } from '@prisma/client';
import { EvaluateDiagnosisDto } from './dto/evaluate-diagnosis.dto';

export interface DiagnosticHypothesis {
  subsystem: string;
  faultPattern: string;
  technicalExplanation: string;
  likelihood: 'HIGH' | 'MODERATE' | 'POSSIBLE';
  urgency: 'IMMEDIATE_HALT' | 'INSPECT_BEFORE_DRIVING' | 'PROCEED_WITH_CAUTION';
  estimatedLaborHours: string;
}

export interface ExpertDiagnosisResult {
  isPreliminary: boolean;
  confidenceScore: number;
  confidenceTier: 'HIGH' | 'MODERATE' | 'INDICATIVE';
  category: BreakdownCategory;
  powertrain: PowertrainType;
  primaryHypothesis: string;
  hypotheses: DiagnosticHypothesis[];
  criticalSafetyWarnings: string[];
  immediateActionChecklist: string[];
  requiresTowing: boolean;
  towingVerdict: 'MANDATORY FLATBED RECOVERY' | 'MOBILE ROADSIDE FIELD SERVICE ELIGIBLE' | 'SPECIALIZED EV FLATBED CARRIER';
  recommendedEquipment: string[];
  disclaimer: string;
}

@Injectable()
export class DiagnosticsService {
  public static readonly LEGAL_DISCLAIMER =
    'PRELIMINARY ADVISORY ONLY: This algorithmic expert assessment is based strictly on driver-reported symptoms and is NOT a certified mechanical diagnosis. Vehicle systems must be inspected on-site with certified diagnostic equipment by an authorized automotive technician before driving or repair.';

  /**
   * Evaluates symptoms, warning indicators, and powertrain specifications
   * through a multi-factor deterministic expert rule matrix.
   */
  evaluate(dto: EvaluateDiagnosisDto): ExpertDiagnosisResult {
    const category = dto.category;
    const severity = dto.severity || SeverityLevel.MEDIUM;
    const powertrain = dto.powertrain || PowertrainType.PETROL;
    const desc = (dto.description || '').toLowerCase();
    const warningLights = (dto.warningLights || []).map((w) => w.toLowerCase());
    const symptoms = (dto.symptoms || []).map((s) => s.toLowerCase());
    const roadsideContext = (dto.roadsideContext || '').toUpperCase();

    const isEV = powertrain === PowertrainType.ELECTRIC;
    const isHybrid = powertrain === PowertrainType.HYBRID;
    const isHighVoltage = isEV || isHybrid;

    const criticalSafetyWarnings: string[] = [];
    const immediateActionChecklist: string[] = [];
    const hypotheses: DiagnosticHypothesis[] = [];
    const recommendedEquipment: string[] = [];
    let requiresTowing = false;
    let confidenceScore = 75;

    // -------------------------------------------------------------------------
    // RULE 1: UNIVERSAL ROADSIDE LIFE SAFETY CHECKLIST
    // -------------------------------------------------------------------------
    immediateActionChecklist.push('Activate hazard flasher lights immediately.');

    if (roadsideContext === 'HIGHWAY_SHOULDER' || roadsideContext === 'TRAFFIC_LANE') {
      criticalSafetyWarnings.push(
        'HIGH-SPEED ROADSIDE HAZARD: Remain behind the highway steel guardrail or concrete barrier. Never stand directly behind or in front of the disabled vehicle.',
      );
      immediateActionChecklist.push('Exit vehicle via passenger door facing away from moving traffic.');
      immediateActionChecklist.push('Position warning reflector triangle 50 meters behind vehicle if safe.');
    }

    if (roadsideContext === 'TRAFFIC_LANE' || severity === SeverityLevel.CRITICAL) {
      requiresTowing = true;
    }

    // -------------------------------------------------------------------------
    // RULE 2: POWERTRAIN-SPECIFIC HIGH-VOLTAGE & COMBUSTION SAFETY CHECKS
    // -------------------------------------------------------------------------
    if (isHighVoltage) {
      criticalSafetyWarnings.push(
        'HIGH-VOLTAGE HAZARD (400V–800V DC): High-voltage components and orange insulated wiring harnesses carry lethal electrical charge. Never attempt to touch, sever, or inspect orange high-voltage cabling.',
      );
      criticalSafetyWarnings.push(
        'FLATBED RECOVERY MANDATORY FOR EV/HYBRID: Vehicle must NOT be flat-towed or push-towed with drive wheels on the ground. Permanent magnet motors generate uncontrolled back-EMF voltage when rotated, risking inverter fires.',
      );
      recommendedEquipment.push('Insulated 1000V Field Tooling (ASTM F1505)', 'EV Wheel Skates / Dollies');
    }

    // -------------------------------------------------------------------------
    // RULE 3: CATEGORY & SYMPTOM SPECIFIC EXPERT DIAGNOSTIC MATRIX
    // -------------------------------------------------------------------------
    switch (category) {
      // -----------------------------------------------------------------------
      // CASE A: OVERHEATING COOLANT
      // -----------------------------------------------------------------------
      case BreakdownCategory.OVERHEATING_COOLANT:
        requiresTowing = true;
        confidenceScore += 10;
        criticalSafetyWarnings.push(
          'EXTREME SCALDING HAZARD: Engine cooling system operates under 15–20 PSI hydraulic pressure at temperatures above 110°C (230°F). NEVER loosen or remove the radiator cap or expansion tank cap while the engine is hot.',
        );
        criticalSafetyWarnings.push(
          'THERMAL SEIZURE RISK: Continued operation will warp aluminum cylinder heads, blow head gaskets, and cause irreversible engine block crack.',
        );
        immediateActionChecklist.push('Shut down engine immediately. Do not attempt to idle.');
        immediateActionChecklist.push('Pop hood latch from inside cabin; DO NOT place bare hands on the hot hood latch.');
        recommendedEquipment.push(
          'Infrared Thermal Imager',
          'Cooling System Pressure Tester Kit',
          'Vacuum Coolant Bleeder Unit',
          'Heavy Tow Carrier',
        );

        if (desc.includes('white smoke') || desc.includes('sweet smell') || symptoms.includes('white_smoke')) {
          hypotheses.push({
            subsystem: 'Cylinder Head Gasket & Combustion Seal',
            faultPattern: 'Cylinder Head Gasket Breach (Coolant Intrusion into Combustion Chamber)',
            technicalExplanation:
              'Symptoms of white vapor smoke and pressurized cooling system suggest combustion gasses are venting into water jackets, causing extreme overheating and exhaust vapor emissions.',
            likelihood: 'HIGH',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '8.0 - 14.0 hrs',
          });
        } else {
          hypotheses.push({
            subsystem: 'Cooling Circulation System',
            faultPattern: 'Radiator Hose Rupture / Mechanical Water Pump Impeller Shear',
            technicalExplanation:
              'Sudden coolant loss under load is typically triggered by aged EPDM hose splits, thermostat sticking closed, or centrifugal water pump shaft failure.',
            likelihood: 'HIGH',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '2.0 - 4.0 hrs',
          });
        }
        break;

      // -----------------------------------------------------------------------
      // CASE B: BRAKE SYSTEM FAILURE
      // -----------------------------------------------------------------------
      case BreakdownCategory.BRAKE_SYSTEM_FAILURE:
        requiresTowing = true;
        confidenceScore += 15;
        criticalSafetyWarnings.push(
          'CATASTROPHIC BRAKING RISK: Hydraulic fluid pressure loss or master cylinder piston bypass prevents vehicle deceleration. DO NOT DRIVE UNDER ANY CIRCUMSTANCES.',
        );
        immediateActionChecklist.push('Firmly engage mechanical emergency handbrake or electronic parking brake.');
        immediateActionChecklist.push('Ensure transmission is placed in PARK (P) or reverse gear for manual transmission.');
        immediateActionChecklist.push('Turn steering wheel toward roadside shoulder curb as a runaway safeguard.');
        recommendedEquipment.push(
          'DOT 4 Hydraulic Pressure Test Gauges',
          'DOT 4 Brake Bleed Kit',
          'Wheel Chocks',
          'Flatbed Winch Carrier',
        );

        if (desc.includes('spongy') || desc.includes('floor') || symptoms.includes('spongy_pedal')) {
          hypotheses.push({
            subsystem: 'Hydraulic Actuation Circuit',
            faultPattern: 'Hydraulic Brake Line Rupture or Master Cylinder Internal Cup Failure',
            technicalExplanation:
              'Brake pedal sinking directly to the floor indicates hydraulic fluid breach or secondary seal collapse inside the tandem master cylinder.',
            likelihood: 'HIGH',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '2.5 - 5.0 hrs',
          });
        } else {
          hypotheses.push({
            subsystem: 'Friction & Caliper Mechanism',
            faultPattern: 'Seized Caliper Piston / Rotor Thermal Warpage',
            technicalExplanation:
              'Brake dragging with severe pull or burning friction smell indicates caliper slide pin seizure or ABS valve blockage.',
            likelihood: 'MODERATE',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '2.0 - 3.5 hrs',
          });
        }
        break;

      // -----------------------------------------------------------------------
      // CASE C: BATTERY & ELECTRICAL
      // -----------------------------------------------------------------------
      case BreakdownCategory.BATTERY_DEAD_ELECTRICAL:
        recommendedEquipment.push('12V/24V Industrial Jump-Pack (3000A Peak)', 'Digital Alternator & Ripple Multimeter');

        if (isHighVoltage) {
          requiresTowing = true;
          criticalSafetyWarnings.push(
            'EV DC-DC CONVERTER & CONTACTOR INTERLOCK: If 12V auxiliary battery is depleted, the high-voltage contactor relays cannot close, preventing high-voltage drivetrain boot.',
          );
          hypotheses.push({
            subsystem: '12V Auxiliary Power Distribution Rail',
            faultPattern: '12V AGM/Lithium Auxiliary Battery Depletion (Contactor Lockout)',
            technicalExplanation:
              'Electric vehicle requires sustained 12V auxiliary rail voltage to energize battery management relays and telematics modules. 12V boost required before main pack engagement.',
            likelihood: 'HIGH',
            urgency: 'INSPECT_BEFORE_DRIVING',
            estimatedLaborHours: '1.0 - 2.0 hrs',
          });
        } else {
          if (warningLights.includes('battery_charge') || desc.includes('died while driving')) {
            requiresTowing = true;
            hypotheses.push({
              subsystem: 'Charging System & Alternator',
              faultPattern: 'Alternator Diode Trio Failure or Internal Voltage Regulator Fault',
              technicalExplanation:
                'Vehicle stalling while in motion with battery indicator suggests alternator stator/regulator collapse, resulting in engine running solely on battery reserve until total electrical starvation.',
              likelihood: 'HIGH',
              urgency: 'IMMEDIATE_HALT',
              estimatedLaborHours: '2.0 - 3.5 hrs',
            });
          } else {
            requiresTowing = false;
            hypotheses.push({
              subsystem: 'Cranking Battery',
              faultPattern: '12V Lead-Acid / AGM Battery Sulfation or Deep Parasitic Drain',
              technicalExplanation:
                'Starter motor rapid clicking with uncranked flywheel is classic symptom of low open-circuit resting battery voltage (<11.8V). Highly responsive to roadside jump-start.',
              likelihood: 'HIGH',
              urgency: 'PROCEED_WITH_CAUTION',
              estimatedLaborHours: '0.5 - 1.0 hrs',
            });
          }
        }
        break;

      // -----------------------------------------------------------------------
      // CASE D: TRANSMISSION & GEARBOX
      // -----------------------------------------------------------------------
      case BreakdownCategory.TRANSMISSION_ISSUE:
        requiresTowing = true;
        confidenceScore += 10;
        criticalSafetyWarnings.push(
          'DRIVELINE LOCKUP RISK: Transmission slippage or hydraulic pressure drop can cause uncommanded clutch pack lockup or catastrophic mechanical planetary gear failure.',
        );
        immediateActionChecklist.push('Do not attempt multiple aggressive throttle blips or gear shifting.');
        immediateActionChecklist.push('Shift into Neutral (N) if vehicle is being pushed onto shoulder.');
        recommendedEquipment.push(
          'OBD-II TCM Diagnostic Scanner',
          'Transmission Fluid Dipstick & Gauge',
          'Flatbed Winch Towing Rig',
        );

        hypotheses.push({
          subsystem: 'Hydraulic Valve Body / Mechatronic Unit',
          faultPattern: 'Transmission Solenoid Circuit Malfunction / Clutch Pressure Bleed',
          technicalExplanation:
            'Loss of forward propulsion accompanied by high engine RPM indicates automatic transmission torque converter slip, valve body solenoid contamination, or clutch pack friction wear.',
          likelihood: 'HIGH',
          urgency: 'IMMEDIATE_HALT',
          estimatedLaborHours: '4.0 - 8.0 hrs',
        });
        break;

      // -----------------------------------------------------------------------
      // CASE E: FLAT TIRE & WHEEL
      // -----------------------------------------------------------------------
      case BreakdownCategory.FLAT_TIRE_WHEEL:
        if (desc.includes('blowout') || desc.includes('rim') || symptoms.includes('rim_damage')) {
          requiresTowing = true;
          criticalSafetyWarnings.push(
            'STRUCTURAL WHEEL DAMAGE: Driving on bare metal rim will destroy suspension steering knuckle, lower control arm, and brake caliper.',
          );
          recommendedEquipment.push('Low-Profile Floor Jack', 'Wheel Dollies', 'Flatbed Carrier');
          hypotheses.push({
            subsystem: 'Wheel & Hub Assembly',
            faultPattern: 'Severe Sidewall Rim Deformity / High-Speed Pneumatic Rupture',
            technicalExplanation:
              'Wheel rim has sustained curb impact or run-flat delamination requiring shop rim replacement and multi-link alignment.',
            likelihood: 'HIGH',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '1.0 - 2.0 hrs',
          });
        } else {
          requiresTowing = false;
          criticalSafetyWarnings.push(
            'Ensure vehicle is on level, solid ground before placing mechanical jack. Never place body parts beneath a vehicle supported only by a jack.',
          );
          recommendedEquipment.push(
            '3-Ton Heavy-Duty Pneumatic Jack',
            'Torque Wrench & Metric Impact Sockets',
            'Tire Plug Kit & 12V Air Compressor',
          );
          hypotheses.push({
            subsystem: 'Pneumatic Tire Tread',
            faultPattern: 'Tread Puncture (Screw/Nail) / Valve Stem Degradation',
            technicalExplanation:
              'Pneumatic tire pressure loss localized to tread area. Suitable for mobile vulcanized plug repair or spare tire mount on site.',
            likelihood: 'HIGH',
            urgency: 'PROCEED_WITH_CAUTION',
            estimatedLaborHours: '0.5 - 1.0 hrs',
          });
        }
        break;

      // -----------------------------------------------------------------------
      // CASE F: ENGINE FAILURE
      // -----------------------------------------------------------------------
      case BreakdownCategory.ENGINE_FAILURE:
      default:
        requiresTowing = true;
        recommendedEquipment.push('OBD-II CAN-Bus Live Scanner', 'Compression Tester', 'Flatbed Winch Truck');

        if (desc.includes('knocking') || symptoms.includes('knocking_sound')) {
          criticalSafetyWarnings.push(
            'MECHANICAL INTERNAL DAMAGE: Metallic engine knocking indicates connecting rod bearing clearance failure or piston wrist pin damage. Engine operation must cease immediately.',
          );
          hypotheses.push({
            subsystem: 'Engine Rotating Assembly',
            faultPattern: 'Connecting Rod Bearing Spin / Crankshaft Journal Scoring',
            technicalExplanation:
              'Rhythmic metallic knocking varying with RPM suggests oil starvation has destroyed crankshaft rod bearings. Continued running risks throwing a rod through the engine block.',
            likelihood: 'HIGH',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '15.0 - 30.0 hrs',
          });
        } else {
          hypotheses.push({
            subsystem: 'Engine Management & Ignition',
            faultPattern: 'Crankshaft Position Sensor Loss / Ignition Coil Rail Failure',
            technicalExplanation:
              'Engine cranking without firing indicates missing primary spark trigger or fuel injector pulse caused by CKP sensor hall-effect degradation.',
            likelihood: 'MODERATE',
            urgency: 'IMMEDIATE_HALT',
            estimatedLaborHours: '1.5 - 3.5 hrs',
          });
        }
        break;
    }

    // Towing Verdict Construction
    let towingVerdict: 'MANDATORY FLATBED RECOVERY' | 'MOBILE ROADSIDE FIELD SERVICE ELIGIBLE' | 'SPECIALIZED EV FLATBED CARRIER' =
      'MOBILE ROADSIDE FIELD SERVICE ELIGIBLE';

    if (requiresTowing) {
      towingVerdict = isHighVoltage ? 'SPECIALIZED EV FLATBED CARRIER' : 'MANDATORY FLATBED RECOVERY';
    }

    const primaryHypothesis = hypotheses[0]?.faultPattern || 'Preliminary Roadside Incident';

    const confidenceTier: 'HIGH' | 'MODERATE' | 'INDICATIVE' =
      confidenceScore >= 80 ? 'HIGH' : confidenceScore >= 60 ? 'MODERATE' : 'INDICATIVE';

    return {
      isPreliminary: true,
      confidenceScore: Math.min(confidenceScore, 95),
      confidenceTier,
      category,
      powertrain,
      primaryHypothesis,
      hypotheses,
      criticalSafetyWarnings,
      immediateActionChecklist,
      requiresTowing,
      towingVerdict,
      recommendedEquipment,
      disclaimer: DiagnosticsService.LEGAL_DISCLAIMER,
    };
  }
}

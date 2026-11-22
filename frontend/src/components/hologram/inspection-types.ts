export type SubsystemId =
  | 'engine'
  | 'battery'
  | 'transmission'
  | 'brakes'
  | 'wheels'
  | 'suspension'
  | 'cooling'
  | 'electrical';

export type DisplayMode = 'standard' | 'xray' | 'exploded' | 'isolated';

export interface DiagnosticFaultCode {
  code: string;
  description: string;
  severity: 'CRITICAL' | 'WARNING' | 'ADVISORY';
  triggerCondition: string;
}

export interface RepairService {
  name: string;
  laborHours: number;
  estimatedLaborCost: number;
  estimatedPartsCost: number;
  priority: 'IMMEDIATE' | 'HIGH' | 'SCHEDULED';
}

export interface SubsystemDefinition {
  id: SubsystemId;
  name: string;
  category: string;
  locationDescription: string;
  centerPosition: [number, number, number];
  explodedOffset: [number, number, number];
  cameraTarget: [number, number, number];
  cameraPosition: [number, number, number];
  technicalOverview: string;
  specifications: Record<string, string>;
  commonSymptoms: string[];
  diagnosticFaultCodes: DiagnosticFaultCode[];
  diagnosticProcedure: string[];
  relatedRepairServices: RepairService[];
}

export const SUBSYSTEM_DEFINITIONS: Record<SubsystemId, SubsystemDefinition> = {
  engine: {
    id: 'engine',
    name: 'Internal Combustion Engine Assembly',
    category: 'Powertrain & Mechanical Core',
    locationDescription: 'Mid-rear longitudinal bay behind passenger bulkhead',
    centerPosition: [0, 0.48, -0.65],
    explodedOffset: [0, 0.75, 0],
    cameraTarget: [0, 0.5, -0.65],
    cameraPosition: [1.8, 1.4, -0.2],
    technicalOverview:
      'High-revving 4.5L 90° V8 naturally aspirated engine assembly featuring flat-plane crankshaft, dry-sump lubrication, direct gasoline injection (200 bar), and dual variable valve timing.',
    specifications: {
      Displacement: '4,497 cc (4.5 L)',
      Configuration: '90° V8 Flat-Plane Crank',
      Aspiration: 'Naturally Aspirated',
      MaxPower: '562 hp @ 9,000 RPM',
      MaxTorque: '540 Nm @ 6,000 RPM',
      CompressionRatio: '12.5 : 1',
    },
    commonSymptoms: [
      'Rough idle, rotational vibration, or intermittent cylinder misfires',
      'Engine oil pressure drop warning indicator on instrument cluster',
      'Excessive exhaust smoke (blue indicating ring wear, white indicating head gasket compromise)',
      'Unusual ticking or metallic knocking from valve train or bottom-end bearings',
    ],
    diagnosticFaultCodes: [
      {
        code: 'P0300',
        description: 'Random / Multiple Cylinder Misfire Detected',
        severity: 'CRITICAL',
        triggerCondition: 'Crankshaft acceleration delta exceeds permitted threshold across firing cycle',
      },
      {
        code: 'P0011',
        description: 'Camshaft Position - Timing Over-Advanced (Bank 1)',
        severity: 'WARNING',
        triggerCondition: 'VVT solenoid hydraulic phase deviation > 5° from commanded ECU map',
      },
      {
        code: 'P0521',
        description: 'Engine Oil Pressure Sensor / Switch Range Malfunction',
        severity: 'CRITICAL',
        triggerCondition: 'Oil pressure < 1.2 bar at operational engine speed',
      },
    ],
    diagnosticProcedure: [
      'Connect OBD-II CAN bus scanner; query live ignition timing and fuel trim data (STFT/LTFT).',
      'Execute dynamic compression test across all 8 cylinders (specification: 180-205 PSI, <10% delta).',
      'Inspect spark plug electrodes for carbon fouling, fuel wetting, or thermal detonation pitting.',
      'Perform cylinder bore scope inspection to evaluate cross-hatching and piston crown wash.',
    ],
    relatedRepairServices: [
      {
        name: 'Ignition Coil & Spark Plug Replacement (Bank 1 & 2)',
        laborHours: 2.5,
        estimatedLaborCost: 225,
        estimatedPartsCost: 280,
        priority: 'IMMEDIATE',
      },
      {
        name: 'VVT Solenoid Replacement & Oil Flush',
        laborHours: 3.0,
        estimatedLaborCost: 270,
        estimatedPartsCost: 195,
        priority: 'HIGH',
      },
      {
        name: 'Valve Cover & Camshaft Gasket Reseal',
        laborHours: 4.5,
        estimatedLaborCost: 405,
        estimatedPartsCost: 140,
        priority: 'SCHEDULED',
      },
    ],
  },

  battery: {
    id: 'battery',
    name: 'High-Output Auxiliary & 12V AGM Module',
    category: 'Electrical Energy Storage',
    locationDescription: 'Front bulkhead passenger footwell housing / low center chassis',
    centerPosition: [0, 0.24, 0.4],
    explodedOffset: [0, -0.55, 0],
    cameraTarget: [0, 0.25, 0.4],
    cameraPosition: [1.2, 0.9, 0.9],
    technicalOverview:
      'High-capacity 12V 80Ah AGM (Absorbent Glass Mat) dual-post power storage unit with intelligent battery monitoring shunt sensor, integrated thermal protection, and high-conductivity copper busbars.',
    specifications: {
      Chemistry: 'Absorbent Glass Mat (AGM) Sealed Lead-Acid',
      VoltageNominal: '12.8 V DC',
      Capacity: '80 Ah (C20)',
      ColdCrankingAmps: '850 CCA (SAE)',
      InternalResistance: '≤ 3.2 mΩ',
      Monitoring: 'LIN-bus Intelligent Battery Sensor (IBS)',
    },
    commonSymptoms: [
      'Slow engine cranking or intermittent starter solenoid click',
      'Flickering instrument cluster backlighting and spurious ECU communication errors',
      'Parasitic overnight voltage decay below 11.8V threshold',
      'Sulfation buildup or localized casing bulge from excessive thermal charging',
    ],
    diagnosticFaultCodes: [
      {
        code: 'P0562',
        description: 'System Voltage Low (< 10.5 V)',
        severity: 'CRITICAL',
        triggerCondition: 'Terminal voltage drops below minimum operating logic threshold for > 2.0s',
      },
      {
        code: 'B1318',
        description: 'Battery Voltage Below Critical Startup Level',
        severity: 'WARNING',
        triggerCondition: 'Resting open-circuit voltage < 11.7V prior to starter engagement',
      },
    ],
    diagnosticProcedure: [
      'Perform digital carbon-pile conductance load test at 50% CCA rating for 15 seconds.',
      'Measure resting Open Circuit Voltage (OCV) with high-impedance digital multimeter.',
      'Check parasitic dark-current draw using in-line shunt ammeter (specification: < 35 mA after bus sleep).',
      'Verify charging alternator ripple voltage using digital oscilloscope (< 50 mV AC peak-to-peak).',
    ],
    relatedRepairServices: [
      {
        name: 'Heavy-Duty AGM Power Unit Replacement & Coding',
        laborHours: 1.0,
        estimatedLaborCost: 95,
        estimatedPartsCost: 260,
        priority: 'IMMEDIATE',
      },
      {
        name: 'Parasitic Drain Triage & IBS Sensor Calibration',
        laborHours: 2.0,
        estimatedLaborCost: 180,
        estimatedPartsCost: 85,
        priority: 'HIGH',
      },
    ],
  },

  transmission: {
    id: 'transmission',
    name: '7-Speed Dual-Clutch Transaxle (DCT)',
    category: 'Drivetrain & Power Transfer',
    locationDescription: 'Rear transaxle assembly integrated with electronic differential (E-Diff)',
    centerPosition: [0, 0.35, -1.35],
    explodedOffset: [0, 0, -0.75],
    cameraTarget: [0, 0.35, -1.35],
    cameraPosition: [1.6, 0.8, -2.1],
    technicalOverview:
      '7-speed dual-clutch transmission with electro-hydraulic sequential actuation, integrated electronic limited-slip differential (E-Diff3), and high-strength helical gear sets with dry-sump casing lubrication.',
    specifications: {
      Architecture: '7-Speed Dual-Clutch (DCT) Transaxle',
      ClutchType: 'Twin Wet Multi-Plate Hydraulic',
      Differential: 'Electronically Controlled Limited Slip (E-Diff3)',
      ShiftTime: '60 ms (Race Mode)',
      FluidCapacity: '6.8 L Synthetic DCTF',
    },
    commonSymptoms: [
      'Harsh engagement, clunking sensation, or hesitation on initial drive selection',
      'Transmission temperature warning illuminate under stop-and-go load',
      'Gearbox limp-home protocol locking transmission into 2nd or 4th gear',
      'Fluid weeping from differential output shaft seals or hydraulic actuator body',
    ],
    diagnosticFaultCodes: [
      {
        code: 'P0700',
        description: 'Transmission Control System Malfunction (MIL Request)',
        severity: 'CRITICAL',
        triggerCondition: 'TCM broadcast error flag to main Powertrain Control Module',
      },
      {
        code: 'P0841',
        description: 'Transmission Fluid Pressure Sensor A Circuit Range / Performance',
        severity: 'CRITICAL',
        triggerCondition: 'Hydraulic clutch line pressure outside 18-25 bar operational band',
      },
      {
        code: 'P0810',
        description: 'Clutch Position Control Error',
        severity: 'WARNING',
        triggerCondition: 'Dual-clutch actuator stroke discrepancy exceeds 1.5mm',
      },
    ],
    diagnosticProcedure: [
      'Query Transmission Control Module (TCM) for sub-codes, clutch wear index, and oil temperature logs.',
      'Check hydraulic line operating pressure via live telemetry (specification: 20-24 bar).',
      'Inspect DCT fluid level, color, and odor; check magnetic drain plug for metallic debris.',
      'Execute TCM clutch bite point adaptation and solenoid relearn routine.',
    ],
    relatedRepairServices: [
      {
        name: 'DCT Hydraulic Fluid & Dual Filter Replacement',
        laborHours: 2.5,
        estimatedLaborCost: 240,
        estimatedPartsCost: 210,
        priority: 'HIGH',
      },
      {
        name: 'Electro-Hydraulic Actuator Solenoid Overhaul',
        laborHours: 5.5,
        estimatedLaborCost: 520,
        estimatedPartsCost: 680,
        priority: 'IMMEDIATE',
      },
    ],
  },

  brakes: {
    id: 'brakes',
    name: 'Carbon-Ceramic Braking Subsystem',
    category: 'Deceleration & Active Safety',
    locationDescription: 'All 4 wheel hubs: 6-piston front / 4-piston rear monobloc calipers',
    centerPosition: [0, 0.35, 0],
    explodedOffset: [0, 0, 0],
    cameraTarget: [0.88, 0.35, 1.45],
    cameraPosition: [1.8, 0.6, 1.9],
    technicalOverview:
      'High-performance carbon-ceramic matrix (CCM) braking system with cross-drilled ventilated discs (398mm front, 360mm rear), monobloc aluminum calipers, and high-temperature DOT 4 synthetic brake fluid.',
    specifications: {
      FrontRotor: '398 mm x 36 mm Carbon-Ceramic Matrix (CCM)',
      RearRotor: '360 mm x 32 mm Carbon-Ceramic Matrix (CCM)',
      Calipers: 'Front: 6-Piston Aluminum Monobloc; Rear: 4-Piston',
      BrakeFluid: 'DOT 4 High-Boiling (Dry BP > 300°C)',
      ABSLogic: 'Bosch High-Performance ABS / EBD',
    },
    commonSymptoms: [
      'High-pitch squeal under low-speed progressive braking',
      'Spongy brake pedal with extended travel or floor fade',
      'Brake pad wear sensor warning illuminated on dashboard',
      'Steering oscillation or pedal pulsation under heavy thermal deceleration',
    ],
    diagnosticFaultCodes: [
      {
        code: 'C0035',
        description: 'Left Front Wheel Speed Sensor Circuit Fault',
        severity: 'CRITICAL',
        triggerCondition: 'Magnetic wheel speed pulse signal missing while vehicle in motion',
      },
      {
        code: 'C0040',
        description: 'Brake Pedal Switch A Circuit Malfunction',
        severity: 'WARNING',
        triggerCondition: 'Dual-circuit pressure switch signal divergence > 100ms',
      },
    ],
    diagnosticProcedure: [
      'Measure brake rotor thickness with micrometers and inspect CCM disc surface for chipping or delamination.',
      'Check brake pad remaining friction lining depth (minimum specification: 3.5mm).',
      'Test brake fluid boiling point and moisture content using digital refractometer (< 2.0% water).',
      'Bleed hydraulic brake lines with automated pressure bleeder and verify pedal pressure firmness.',
    ],
    relatedRepairServices: [
      {
        name: 'High-Performance Front Carbon-Ceramic Brake Pad Set',
        laborHours: 2.0,
        estimatedLaborCost: 190,
        estimatedPartsCost: 450,
        priority: 'IMMEDIATE',
      },
      {
        name: 'Hydraulic System Bleed & DOT 4 Racing Fluid Flush',
        laborHours: 1.5,
        estimatedLaborCost: 145,
        estimatedPartsCost: 65,
        priority: 'HIGH',
      },
    ],
  },

  wheels: {
    id: 'wheels',
    name: 'Forged Alloy Wheels & Performance Tyres',
    category: 'Running Gear & Contact Patch',
    locationDescription: '4 corners: 20-inch staggered forged alloy rims with performance rubber',
    centerPosition: [0, 0.35, 0],
    explodedOffset: [0.65, 0, 0],
    cameraTarget: [0.92, 0.35, -1.45],
    cameraPosition: [1.9, 0.7, -1.2],
    technicalOverview:
      'Staggered 20-inch forged aluminum wheels with Michelin Pilot Sport Cup 2 ultra-high performance tyres (235/35 ZR20 front, 295/35 ZR20 rear), equipped with real-time direct TPMS radio sensors.',
    specifications: {
      FrontFitment: '20" x 8.5J ET 46.5 forged aluminum',
      RearFitment: '20" x 10.5J ET 58.5 forged aluminum',
      FrontTyres: '235/35 ZR20 (92Y) XL',
      RearTyres: '295/35 ZR20 (105Y) XL',
      PressureCold: 'Front: 2.1 bar (30 PSI); Rear: 2.0 bar (29 PSI)',
      LugTorque: '100 Nm (central lock / 5-bolt)',
    },
    commonSymptoms: [
      'High-speed vibration through steering column or chassis floor between 90-120 km/h',
      'Uneven shoulder tyre wear (indicating camber or toe alignment discrepancy)',
      'Gradual pressure loss from rim bead seat or valve stem seal',
      'Radial tyre bulge or tread separation from pothole impact',
    ],
    diagnosticFaultCodes: [
      {
        code: 'C0750',
        description: 'Left Front Tire Pressure Sensor Low Battery / Signal Loss',
        severity: 'ADVISORY',
        triggerCondition: 'TPMS RF transmission not received for > 15 minutes',
      },
      {
        code: 'C0755',
        description: 'Tire Pressure Deviation > 25% From Placed Calibration',
        severity: 'WARNING',
        triggerCondition: 'Live pressure drop below calibrated threshold',
      },
    ],
    diagnosticProcedure: [
      'Inspect tyre tread depth across all grooves (minimum legal: 1.6mm; recommended: 3.0mm).',
      'Execute high-speed dynamic road-force wheel balancing on digital balancer.',
      'Perform 4-wheel computerized optical suspension laser alignment.',
      'Check TPMS radio transmitter battery life and sensor ID broadcast.',
    ],
    relatedRepairServices: [
      {
        name: 'Road-Force High-Speed Wheel Balancing & Rotation',
        laborHours: 1.5,
        estimatedLaborCost: 140,
        estimatedPartsCost: 40,
        priority: 'HIGH',
      },
      {
        name: '4-Wheel Precision Laser Alignment Calibration',
        laborHours: 2.0,
        estimatedLaborCost: 195,
        estimatedPartsCost: 0,
        priority: 'SCHEDULED',
      },
    ],
  },

  suspension: {
    id: 'suspension',
    name: 'Magnetorheological Damper & Suspension Coilovers',
    category: 'Chassis Dynamics & Ride Control',
    locationDescription: 'Independent double-wishbone front / multi-link rear suspension',
    centerPosition: [0, 0.42, 0],
    explodedOffset: [0, 0.5, 0],
    cameraTarget: [0.72, 0.45, 1.45],
    cameraPosition: [1.5, 0.9, 1.8],
    technicalOverview:
      'SCM3 Magnetorheological fluid adaptive damping system combined with aluminum forged double wishbones, titanium helical springs, and hollow anti-roll stabilizer torsion bars.',
    specifications: {
      FrontArchitecture: 'Independent Double Wishbone with Forged Aluminum Arms',
      RearArchitecture: 'Multi-Link Independent with Cast Hub Carriers',
      Dampers: 'BWI Magnetorheological Fluid Adaptive (SCM3)',
      ResponseTime: '< 1 ms continuous viscosity adjustment',
      AntiRoll: 'Tubular Steel Torsion Bars with Ball-Joint Drop Links',
    },
    commonSymptoms: [
      'Clunking or rattling over road irregularities or expansion joints',
      'Excessive body roll on turn-in or rebound floating on crests',
      'Magnetorheological damper fluid leakage down shock absorber body',
      'Suspension fault indicator warning illuminated on TFT cluster',
    ],
    diagnosticFaultCodes: [
      {
        code: 'C1030',
        description: 'Left Front Damper Actuator Solenoid Circuit Open',
        severity: 'CRITICAL',
        triggerCondition: 'Damper magnetic coil current circuit resistance > 4.5 Ω',
      },
      {
        code: 'C1045',
        description: 'Ride Height Sensor Calibration Out of Bounds',
        severity: 'WARNING',
        triggerCondition: 'Potentiometer stroke value disagrees with chassis level',
      },
    ],
    diagnosticProcedure: [
      'Inspect damper bodies for magnetic fluid weeping or seal failure.',
      'Check ball joints, tie rod ends, and rubber-metal suspension bushings for play.',
      'Check stabilizer bar drop link ball joints with lever pry test.',
      'Scan SCM suspension ECU; execute damper coil current sweep test (0-4A).',
    ],
    relatedRepairServices: [
      {
        name: 'Magnetorheological Front Damper Assembly Replacement',
        laborHours: 3.5,
        estimatedLaborCost: 340,
        estimatedPartsCost: 890,
        priority: 'IMMEDIATE',
      },
      {
        name: 'Stabilizer Sway Bar Bushing & Drop Link Overhaul',
        laborHours: 2.0,
        estimatedLaborCost: 190,
        estimatedPartsCost: 120,
        priority: 'HIGH',
      },
    ],
  },

  cooling: {
    id: 'cooling',
    name: 'Aluminum Crossflow Radiator & Thermal Cooling',
    category: 'Thermal Management & Heat Rejection',
    locationDescription: 'Front bumper nose ducts feeding side-mounted aluminum radiator cores',
    centerPosition: [0, 0.38, 1.75],
    explodedOffset: [0, 0, 0.85],
    cameraTarget: [0, 0.38, 1.75],
    cameraPosition: [0.9, 0.8, 2.7],
    technicalOverview:
      'High-efficiency aluminum dual-crossflow radiator system with micro-louvered cooling fins, dual electric brushless suction fans with aerodynamic shroud, coolant expansion reservoir, and mechanical water pump.',
    specifications: {
      CoreType: 'Dual-Pass Aluminum Crossflow with High-Density Fins',
      OperatingTemp: '88°C - 102°C nominal',
      CapPressure: '1.4 bar (20 PSI) relief valve',
      FanSystem: 'Dual 300W Brushless High-Static Suction Fans',
      CoolantCapacity: '18.5 L OAT Long-Life Ethylene Glycol (50/50 mix)',
    },
    commonSymptoms: [
      'Rapid coolant temperature gauge elevation beyond 105°C marker',
      'Pungent sweet odor of vaporized ethylene glycol from front grilles',
      'Puddle of pink/blue coolant fluid beneath front nose fascia',
      'Electric radiator cooling fans continuously screaming at maximum RPM',
    ],
    diagnosticFaultCodes: [
      {
        code: 'P0117',
        description: 'Engine Coolant Temperature Circuit Low Input (< 0.2V)',
        severity: 'CRITICAL',
        triggerCondition: 'Sensor reported temperature > 130°C or short circuit to ground',
      },
      {
        code: 'P0128',
        description: 'Coolant Thermostat (Coolant Temp Below Regulating Temp)',
        severity: 'WARNING',
        triggerCondition: 'Engine fails to reach 82°C within calibrated drive duration',
      },
      {
        code: 'P0480',
        description: 'Fan 1 Control Circuit Malfunction',
        severity: 'CRITICAL',
        triggerCondition: 'ECU cooling fan PWM drive command unfulfilled',
      },
    ],
    diagnosticProcedure: [
      'Perform cooling system pressure decay test at 1.5 bar for 15 minutes to isolate leaks.',
      'Inspect radiator core face for road debris blockages, bent fins, or stone puncture.',
      'Check thermostat opening temperature using infrared thermal pyrometer.',
      'Test coolant freeze point and pH buffer reserve with optical refractometer.',
    ],
    relatedRepairServices: [
      {
        name: 'Radiator Pressure Test & Thermostat Replacement',
        laborHours: 3.0,
        estimatedLaborCost: 285,
        estimatedPartsCost: 145,
        priority: 'IMMEDIATE',
      },
      {
        name: 'Cooling System Power Flush & Long-Life Coolant Exchange',
        laborHours: 2.0,
        estimatedLaborCost: 190,
        estimatedPartsCost: 95,
        priority: 'HIGH',
      },
    ],
  },

  electrical: {
    id: 'electrical',
    name: 'ECU Wiring Harness & Power Distribution Bus',
    category: 'Electronics & CAN-Bus Architecture',
    locationDescription: 'Main passenger firewall bulkhead and central tunnel wiring spine',
    centerPosition: [0.45, 0.6, 0.7],
    explodedOffset: [0.4, 0.4, 0],
    cameraTarget: [0.45, 0.6, 0.7],
    cameraPosition: [1.3, 1.1, 1.2],
    technicalOverview:
      'Bosch MED 17.3.1 Engine Management System with dual 500 kbps high-speed CAN-bus networks, centralized power distribution relay box with sealed fuses, and cross-linked polyethylene insulated harness loom.',
    specifications: {
      EngineController: 'Bosch Motronic MED 17.3.1 32-bit Tricore Processor',
      NetworkBus: 'Dual High-Speed CAN 2.0B (500 kbps) + LIN 2.1 Sub-busses',
      Alternator: '150A Liquid-Cooled Brushless Alternator with LIN Regulator',
      WireSpec: 'TXL Cross-Linked Polyethylene (-40°C to +125°C)',
      Protection: 'IP67 Sealed Multi-Pin Bayonet Connectors',
    },
    commonSymptoms: [
      'Intermittent CAN communication timeout errors (U-codes) across modules',
      'Unexplained fuse blow upon switching ignition or operating accessories',
      'Erratic sensor readings on throttle pedal or mass airflow circuit',
      'Corrosion or water intrusion inside fuse distribution panel terminals',
    ],
    diagnosticFaultCodes: [
      {
        code: 'U0100',
        description: 'Lost Communication with ECM / PCM A',
        severity: 'CRITICAL',
        triggerCondition: 'CAN-bus heartbeat packet absent for > 500ms',
      },
      {
        code: 'P0606',
        description: 'ECM / PCM Processor Internal Integrity Fault',
        severity: 'CRITICAL',
        triggerCondition: 'Watchdog timer mismatch inside microprocessor',
      },
      {
        code: 'P0685',
        description: 'ECM / PCM Power Relay Control Circuit / Open',
        severity: 'CRITICAL',
        triggerCondition: 'Main power supply relay coil signal circuit disconnected',
      },
    ],
    diagnosticProcedure: [
      'Check CAN-H and CAN-L bus termination resistance with ignition off (specification: 60 Ω ± 2 Ω).',
      'Scope CAN differential signal voltages with 2-channel oscilloscope (CAN-H: 2.5-3.5V, CAN-L: 1.5-2.5V).',
      'Inspect power ground distribution eyelets on chassis chassis ground straps for oxidation.',
      'Check main relay fuse contacts for thermal discoloration or fretting corrosion.',
    ],
    relatedRepairServices: [
      {
        name: 'CAN-Bus Integrity Scope Diagnostic & Harness Pinout Repair',
        laborHours: 3.5,
        estimatedLaborCost: 335,
        estimatedPartsCost: 75,
        priority: 'IMMEDIATE',
      },
      {
        name: 'Power Distribution Relay Box Terminal Service & Weatherseal',
        laborHours: 2.5,
        estimatedLaborCost: 240,
        estimatedPartsCost: 110,
        priority: 'HIGH',
      },
    ],
  },
};

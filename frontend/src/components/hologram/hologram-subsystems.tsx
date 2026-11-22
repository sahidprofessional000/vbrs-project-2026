'use client';

import React, { useRef, useMemo } from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { SubsystemId, DisplayMode, SUBSYSTEM_DEFINITIONS } from './inspection-types';

interface HologramSubsystemsProps {
  selectedSubsystem: SubsystemId | null;
  onSelectSubsystem: (id: SubsystemId) => void;
  displayMode: DisplayMode;
}

export function HologramSubsystems({
  selectedSubsystem,
  onSelectSubsystem,
  displayMode,
}: HologramSubsystemsProps) {
  // Exploded interpolation factor (0 = assembled, 1 = exploded)
  const explodedFactor = useRef(0);

  useFrame((_, delta) => {
    const target = displayMode === 'exploded' ? 1 : 0;
    explodedFactor.current = THREE.MathUtils.damp(explodedFactor.current, target, 4, delta);
  });

  const getSubsystemOffset = (id: SubsystemId): [number, number, number] => {
    const def = SUBSYSTEM_DEFINITIONS[id];
    const [ox, oy, oz] = def.explodedOffset;
    const f = explodedFactor.current;
    return [ox * f, oy * f, oz * f];
  };

  const isVisible = (id: SubsystemId) => {
    if (displayMode === 'isolated') {
      return selectedSubsystem === id;
    }
    return true;
  };

  return (
    <group name="subsystems-root">
      {/* 1. Engine Subsystem Assembly */}
      {isVisible('engine') && (
        <EngineAssembly
          isSelected={selectedSubsystem === 'engine'}
          onClick={() => onSelectSubsystem('engine')}
          offset={getSubsystemOffset('engine')}
          displayMode={displayMode}
        />
      )}

      {/* 2. Battery Module Assembly */}
      {isVisible('battery') && (
        <BatteryAssembly
          isSelected={selectedSubsystem === 'battery'}
          onClick={() => onSelectSubsystem('battery')}
          offset={getSubsystemOffset('battery')}
          displayMode={displayMode}
        />
      )}

      {/* 3. Transmission / Transaxle Assembly */}
      {isVisible('transmission') && (
        <TransmissionAssembly
          isSelected={selectedSubsystem === 'transmission'}
          onClick={() => onSelectSubsystem('transmission')}
          offset={getSubsystemOffset('transmission')}
          displayMode={displayMode}
        />
      )}

      {/* 4. Braking System Assembly */}
      {isVisible('brakes') && (
        <BrakingAssembly
          isSelected={selectedSubsystem === 'brakes'}
          onClick={() => onSelectSubsystem('brakes')}
          offset={getSubsystemOffset('brakes')}
          displayMode={displayMode}
        />
      )}

      {/* 5. Wheels and Tyres Assembly */}
      {isVisible('wheels') && (
        <WheelsAssembly
          isSelected={selectedSubsystem === 'wheels'}
          onClick={() => onSelectSubsystem('wheels')}
          offset={getSubsystemOffset('wheels')}
          displayMode={displayMode}
        />
      )}

      {/* 6. Suspension Subsystem Assembly */}
      {isVisible('suspension') && (
        <SuspensionAssembly
          isSelected={selectedSubsystem === 'suspension'}
          onClick={() => onSelectSubsystem('suspension')}
          offset={getSubsystemOffset('suspension')}
          displayMode={displayMode}
        />
      )}

      {/* 7. Cooling System Assembly */}
      {isVisible('cooling') && (
        <CoolingAssembly
          isSelected={selectedSubsystem === 'cooling'}
          onClick={() => onSelectSubsystem('cooling')}
          offset={getSubsystemOffset('cooling')}
          displayMode={displayMode}
        />
      )}

      {/* 8. Electrical & ECU Harness Assembly */}
      {isVisible('electrical') && (
        <ElectricalAssembly
          isSelected={selectedSubsystem === 'electrical'}
          onClick={() => onSelectSubsystem('electrical')}
          offset={getSubsystemOffset('electrical')}
          displayMode={displayMode}
        />
      )}
    </group>
  );
}

// =====================================================================
// 1. ENGINE ASSEMBLY (V8 BLOCK, INTAKE PLENUM, HEADERS, PULLEYS)
// =====================================================================
function EngineAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const basePos: [number, number, number] = [0, 0.48, -0.65];
  const pos: [number, number, number] = [
    basePos[0] + offset[0],
    basePos[1] + offset[1],
    basePos[2] + offset[2],
  ];

  const highlightColor = isSelected ? '#D93829' : undefined;
  const emissiveIntensity = isSelected ? 0.75 : 0;

  return (
    <group
      position={pos}
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {/* V8 Engine Cylinder Crankcase Block */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[0.55, 0.36, 0.65]} />
        <meshStandardMaterial
          color="#33383f"
          metalness={0.85}
          roughness={0.25}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Left Cylinder Head Valve Cover (Ferrari Red Wrinkle Finish) */}
      <mesh position={[-0.22, 0.22, 0]} rotation={[0, 0, -0.45]}>
        <boxGeometry args={[0.18, 0.12, 0.62]} />
        <meshStandardMaterial
          color={isSelected ? '#ef4444' : '#991b1b'}
          roughness={0.4}
          metalness={0.6}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Right Cylinder Head Valve Cover */}
      <mesh position={[0.22, 0.22, 0]} rotation={[0, 0, 0.45]}>
        <boxGeometry args={[0.18, 0.12, 0.62]} />
        <meshStandardMaterial
          color={isSelected ? '#ef4444' : '#991b1b'}
          roughness={0.4}
          metalness={0.6}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Intake Plenum Chamber (Brushed Cast Aluminum) */}
      <mesh position={[0, 0.3, 0]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.16, 0.16, 0.52, 16]} />
        <meshStandardMaterial
          color="#8b929a"
          metalness={0.92}
          roughness={0.2}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* 8 Curved Intake Runners */}
      {[-0.18, -0.06, 0.06, 0.18].map((z, idx) => (
        <group key={idx}>
          {/* Left Runner */}
          <mesh position={[-0.12, 0.25, z]} rotation={[0, 0, -0.5]}>
            <cylinderGeometry args={[0.024, 0.024, 0.18, 12]} />
            <meshStandardMaterial color="#6b7280" metalness={0.9} roughness={0.25} />
          </mesh>
          {/* Right Runner */}
          <mesh position={[0.12, 0.25, z]} rotation={[0, 0, 0.5]}>
            <cylinderGeometry args={[0.024, 0.024, 0.18, 12]} />
            <meshStandardMaterial color="#6b7280" metalness={0.9} roughness={0.25} />
          </mesh>
        </group>
      ))}

      {/* Serpentine Pulley & Harmonic Balancer (Front of Engine) */}
      <mesh position={[0, -0.05, 0.35]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.11, 0.11, 0.04, 24]} />
        <meshStandardMaterial color="#1f2937" metalness={0.8} roughness={0.3} />
      </mesh>

      {/* Auxiliary Alternator/Waterpump Pulley */}
      <mesh position={[0.18, 0.08, 0.34]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.065, 0.065, 0.03, 16]} />
        <meshStandardMaterial color="#9ca3af" metalness={0.9} roughness={0.2} />
      </mesh>
    </group>
  );
}

// =====================================================================
// 2. BATTERY ASSEMBLY (12V AGM / HV PACK, CASING, BUSBARS, TERMINALS)
// =====================================================================
function BatteryAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const basePos: [number, number, number] = [0, 0.24, 0.4];
  const pos: [number, number, number] = [
    basePos[0] + offset[0],
    basePos[1] + offset[1],
    basePos[2] + offset[2],
  ];

  const highlightColor = isSelected ? '#E5A93C' : undefined;
  const emissiveIntensity = isSelected ? 0.8 : 0;

  return (
    <group
      position={pos}
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {/* Heavy-Duty Reinforced Battery Enclosure */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[0.34, 0.22, 0.24]} />
        <meshStandardMaterial
          color="#1e2229"
          roughness={0.5}
          metalness={0.4}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Casing Top Lid with Cell Caps */}
      <mesh position={[0, 0.12, 0]}>
        <boxGeometry args={[0.35, 0.03, 0.25]} />
        <meshStandardMaterial color="#0f1115" roughness={0.3} metalness={0.6} />
      </mesh>

      {/* Positive Terminal (+) Brass / Copper Post */}
      <mesh position={[0.11, 0.16, -0.06]}>
        <cylinderGeometry args={[0.02, 0.02, 0.05, 12]} />
        <meshStandardMaterial color="#d97706" metalness={0.9} roughness={0.2} />
      </mesh>

      {/* Negative Terminal (-) Lead Post */}
      <mesh position={[-0.11, 0.16, -0.06]}>
        <cylinderGeometry args={[0.018, 0.018, 0.05, 12]} />
        <meshStandardMaterial color="#64748b" metalness={0.8} roughness={0.3} />
      </mesh>

      {/* High-Voltage Shielded Orange Cable Conduit */}
      <mesh position={[0.13, 0.17, 0.08]} rotation={[0.4, 0, 0]}>
        <cylinderGeometry args={[0.014, 0.014, 0.22, 12]} />
        <meshStandardMaterial
          color={isSelected ? '#f97316' : '#ea580c'}
          roughness={0.4}
          emissive={isSelected ? '#ea580c' : undefined}
          emissiveIntensity={emissiveIntensity * 0.6}
        />
      </mesh>
    </group>
  );
}

// =====================================================================
// 3. TRANSMISSION & TRANSAXLE ASSEMBLY (DCT CASING, E-DIFF, DRIVESHAFTS)
// =====================================================================
function TransmissionAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const basePos: [number, number, number] = [0, 0.35, -1.35];
  const pos: [number, number, number] = [
    basePos[0] + offset[0],
    basePos[1] + offset[1],
    basePos[2] + offset[2],
  ];

  const highlightColor = isSelected ? '#38BDF8' : undefined;
  const emissiveIntensity = isSelected ? 0.8 : 0;

  return (
    <group
      position={pos}
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {/* Transaxle Main Gearbox Casing */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[0.42, 0.32, 0.48]} />
        <meshStandardMaterial
          color="#3f454e"
          metalness={0.88}
          roughness={0.24}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Bell Housing Flange Connecting to Engine */}
      <mesh position={[0, 0.05, 0.28]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.22, 0.18, 0.12, 24]} />
        <meshStandardMaterial
          color="#4b5563"
          metalness={0.9}
          roughness={0.2}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Electronic Differential (E-Diff) Hub */}
      <mesh position={[0, -0.04, -0.12]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.14, 0.14, 0.46, 20]} />
        <meshStandardMaterial
          color="#2e343d"
          metalness={0.85}
          roughness={0.3}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Left Drive Half-Shaft leading to rear wheel */}
      <mesh position={[-0.42, -0.04, -0.12]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.028, 0.028, 0.4, 16]} />
        <meshStandardMaterial color="#9ca3af" metalness={0.92} roughness={0.18} />
      </mesh>

      {/* Right Drive Half-Shaft */}
      <mesh position={[0.42, -0.04, -0.12]} rotation={[0, 0, Math.PI / 2]}>
        <cylinderGeometry args={[0.028, 0.028, 0.4, 16]} />
        <meshStandardMaterial color="#9ca3af" metalness={0.92} roughness={0.18} />
      </mesh>
    </group>
  );
}

// =====================================================================
// 4. BRAKING SYSTEM (CARBON-CERAMIC DISCS & 4-CORNER BREMBO CALIPERS)
// =====================================================================
function BrakingAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const corners: Array<{ pos: [number, number, number]; isLeft: boolean; isFront: boolean }> = [
    { pos: [-0.86, 0.35, 1.45], isLeft: true, isFront: true },
    { pos: [0.86, 0.35, 1.45], isLeft: false, isFront: true },
    { pos: [-0.86, 0.35, -1.45], isLeft: true, isFront: false },
    { pos: [0.86, 0.35, -1.45], isLeft: false, isFront: false },
  ];

  const highlightColor = isSelected ? '#ef4444' : undefined;
  const emissiveIntensity = isSelected ? 0.85 : 0;

  return (
    <group
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {corners.map((corner, i) => {
        const lateralOffset = (corner.isLeft ? -1 : 1) * offset[0] * 0.4;
        const cornerPos: [number, number, number] = [
          corner.pos[0] + lateralOffset,
          corner.pos[1] + offset[1],
          corner.pos[2] + offset[2],
        ];

        return (
          <group key={i} position={cornerPos}>
            {/* Cross-Drilled Carbon-Ceramic Rotor Disc */}
            <mesh rotation={[0, 0, Math.PI / 2]}>
              <cylinderGeometry args={[0.2, 0.2, 0.022, 28]} />
              <meshStandardMaterial
                color="#4b5563"
                metalness={0.92}
                roughness={0.3}
                emissive={highlightColor}
                emissiveIntensity={emissiveIntensity * 0.4}
              />
            </mesh>

            {/* Aluminum Monobloc High-Performance Brake Caliper (Brembo Red) */}
            <mesh
              position={[
                corner.isLeft ? -0.015 : 0.015,
                0.1,
                corner.isFront ? -0.08 : 0.08,
              ]}
              rotation={[0, 0, corner.isLeft ? -0.2 : 0.2]}
            >
              <boxGeometry args={[0.06, 0.14, 0.16]} />
              <meshStandardMaterial
                color={isSelected ? '#dc2626' : '#b91c1c'}
                metalness={0.75}
                roughness={0.25}
                emissive={highlightColor}
                emissiveIntensity={emissiveIntensity}
              />
            </mesh>
          </group>
        );
      })}
    </group>
  );
}

// =====================================================================
// 5. WHEELS AND TYRES ASSEMBLY (FORGED RIMS & PERFORMANCE TYRES)
// =====================================================================
function WheelsAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const corners: Array<{ pos: [number, number, number]; isLeft: boolean }> = [
    { pos: [-0.94, 0.35, 1.45], isLeft: true },
    { pos: [0.94, 0.35, 1.45], isLeft: false },
    { pos: [-0.94, 0.35, -1.45], isLeft: true },
    { pos: [0.94, 0.35, -1.45], isLeft: false },
  ];

  const highlightColor = isSelected ? '#A5A39D' : undefined;
  const emissiveIntensity = isSelected ? 0.7 : 0;

  return (
    <group
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {corners.map((corner, i) => {
        const lateralOffset = (corner.isLeft ? -1 : 1) * offset[0];
        const cornerPos: [number, number, number] = [
          corner.pos[0] + lateralOffset,
          corner.pos[1] + offset[1],
          corner.pos[2] + offset[2],
        ];

        return (
          <group key={i} position={cornerPos}>
            {/* Outer Rubber Tyre Tread */}
            <mesh rotation={[0, 0, Math.PI / 2]}>
              <cylinderGeometry args={[0.34, 0.34, 0.24, 32]} />
              <meshStandardMaterial
                color="#141619"
                metalness={0.05}
                roughness={0.9}
                emissive={highlightColor}
                emissiveIntensity={emissiveIntensity * 0.25}
              />
            </mesh>

            {/* Inner Forged Aluminum Rim */}
            <mesh rotation={[0, 0, Math.PI / 2]}>
              <cylinderGeometry args={[0.24, 0.24, 0.25, 24]} />
              <meshStandardMaterial
                color={isSelected ? '#e2e8f0' : '#94a3b8'}
                metalness={0.94}
                roughness={0.16}
                emissive={highlightColor}
                emissiveIntensity={emissiveIntensity}
              />
            </mesh>

            {/* Central Wheel Hub Cap */}
            <mesh position={[corner.isLeft ? -0.13 : 0.13, 0, 0]} rotation={[0, 0, Math.PI / 2]}>
              <cylinderGeometry args={[0.06, 0.06, 0.02, 16]} />
              <meshStandardMaterial color="#facc15" metalness={0.8} roughness={0.3} />
            </mesh>
          </group>
        );
      })}
    </group>
  );
}

// =====================================================================
// 6. SUSPENSION SUBASSEMBLY (COIL SPRINGS, HYDRAULIC STRUTS & WISHBONES)
// =====================================================================
function SuspensionAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const corners: Array<{ pos: [number, number, number]; isLeft: boolean }> = [
    { pos: [-0.68, 0.44, 1.45], isLeft: true },
    { pos: [0.68, 0.44, 1.45], isLeft: false },
    { pos: [-0.68, 0.44, -1.45], isLeft: true },
    { pos: [0.68, 0.44, -1.45], isLeft: false },
  ];

  const highlightColor = isSelected ? '#10B981' : undefined;
  const emissiveIntensity = isSelected ? 0.8 : 0;

  return (
    <group
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {corners.map((corner, i) => {
        const lateralOffset = (corner.isLeft ? -1 : 1) * offset[0] * 0.5;
        const cornerPos: [number, number, number] = [
          corner.pos[0] + lateralOffset,
          corner.pos[1] + offset[1],
          corner.pos[2] + offset[2],
        ];

        return (
          <group key={i} position={cornerPos}>
            {/* Damper Cylinder Body */}
            <mesh position={[0, 0, 0]}>
              <cylinderGeometry args={[0.038, 0.038, 0.32, 16]} />
              <meshStandardMaterial
                color="#1e293b"
                metalness={0.9}
                roughness={0.2}
                emissive={highlightColor}
                emissiveIntensity={emissiveIntensity * 0.5}
              />
            </mesh>

            {/* Piston Shaft Rod (Hard Chrome) */}
            <mesh position={[0, 0.16, 0]}>
              <cylinderGeometry args={[0.016, 0.016, 0.18, 16]} />
              <meshStandardMaterial color="#f8fafc" metalness={1.0} roughness={0.05} />
            </mesh>

            {/* Helical Coil Spring Rings (Stacked Rings to Represent Coil) */}
            {[-0.08, -0.04, 0, 0.04, 0.08, 0.12].map((y, ringIdx) => (
              <mesh key={ringIdx} position={[0, y, 0]} rotation={[Math.PI / 2, 0, 0]}>
                <torusGeometry args={[0.052, 0.009, 8, 20]} />
                <meshStandardMaterial
                  color={isSelected ? '#34d399' : '#059669'}
                  metalness={0.8}
                  roughness={0.25}
                  emissive={highlightColor}
                  emissiveIntensity={emissiveIntensity}
                />
              </mesh>
            ))}

            {/* Upper Strut Hat Mount */}
            <mesh position={[0, 0.24, 0]}>
              <cylinderGeometry args={[0.065, 0.065, 0.024, 16]} />
              <meshStandardMaterial color="#0f172a" metalness={0.7} roughness={0.4} />
            </mesh>
          </group>
        );
      })}
    </group>
  );
}

// =====================================================================
// 7. COOLING SYSTEM (ALUMINUM RADIATOR, DUAL SUCTION FANS & SHROUD)
// =====================================================================
function CoolingAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const basePos: [number, number, number] = [0, 0.38, 1.75];
  const pos: [number, number, number] = [
    basePos[0] + offset[0],
    basePos[1] + offset[1],
    basePos[2] + offset[2],
  ];

  const highlightColor = isSelected ? '#06B6D4' : undefined;
  const emissiveIntensity = isSelected ? 0.8 : 0;

  return (
    <group
      position={pos}
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {/* High-Density Aluminum Radiator Core Grid */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[0.72, 0.28, 0.06]} />
        <meshStandardMaterial
          color="#94a3b8"
          metalness={0.92}
          roughness={0.28}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* Top End Tank Header */}
      <mesh position={[0, 0.15, 0]}>
        <boxGeometry args={[0.74, 0.04, 0.07]} />
        <meshStandardMaterial color="#334155" metalness={0.8} roughness={0.3} />
      </mesh>

      {/* Bottom End Tank Header */}
      <mesh position={[0, -0.15, 0]}>
        <boxGeometry args={[0.74, 0.04, 0.07]} />
        <meshStandardMaterial color="#334155" metalness={0.8} roughness={0.3} />
      </mesh>

      {/* Left Cooling Fan Shroud */}
      <mesh position={[-0.18, 0, -0.04]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.11, 0.11, 0.03, 20]} />
        <meshStandardMaterial
          color="#1e293b"
          roughness={0.6}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity * 0.5}
        />
      </mesh>

      {/* Right Cooling Fan Shroud */}
      <mesh position={[0.18, 0, -0.04]} rotation={[Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[0.11, 0.11, 0.03, 20]} />
        <meshStandardMaterial
          color="#1e293b"
          roughness={0.6}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity * 0.5}
        />
      </mesh>

      {/* Coolant Inlet Hose */}
      <mesh position={[-0.32, 0.12, -0.05]} rotation={[0, 0.4, 0.5]}>
        <cylinderGeometry args={[0.022, 0.022, 0.16, 12]} />
        <meshStandardMaterial color="#0f172a" roughness={0.8} />
      </mesh>
    </group>
  );
}

// =====================================================================
// 8. ELECTRICAL HARNESS & ECU (DISTRIBUTION BOX, BOSCH ECU, FUSES)
// =====================================================================
function ElectricalAssembly({
  isSelected,
  onClick,
  offset,
  displayMode,
}: {
  isSelected: boolean;
  onClick: () => void;
  offset: [number, number, number];
  displayMode: DisplayMode;
}) {
  const basePos: [number, number, number] = [0.45, 0.6, 0.7];
  const pos: [number, number, number] = [
    basePos[0] + offset[0],
    basePos[1] + offset[1],
    basePos[2] + offset[2],
  ];

  const highlightColor = isSelected ? '#F59E0B' : undefined;
  const emissiveIntensity = isSelected ? 0.85 : 0;

  return (
    <group
      position={pos}
      onClick={(e) => {
        e.stopPropagation();
        onClick();
      }}
      onPointerOver={(e) => {
        e.stopPropagation();
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        document.body.style.cursor = 'auto';
      }}
    >
      {/* Bosch Motronic Electronic Control Unit (ECU) Housing */}
      <mesh position={[0, 0, 0]}>
        <boxGeometry args={[0.22, 0.15, 0.08]} />
        <meshStandardMaterial
          color="#475569"
          metalness={0.9}
          roughness={0.2}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity}
        />
      </mesh>

      {/* ECU Heatsink Ribs */}
      {[-0.06, -0.02, 0.02, 0.06].map((x, idx) => (
        <mesh key={idx} position={[x, 0, 0.045]}>
          <boxGeometry args={[0.012, 0.14, 0.018]} />
          <meshStandardMaterial color="#334155" metalness={0.95} roughness={0.15} />
        </mesh>
      ))}

      {/* Multi-Pin Bayonet Harness Wire Loom Connector */}
      <mesh position={[0, -0.09, 0]}>
        <boxGeometry args={[0.18, 0.04, 0.06]} />
        <meshStandardMaterial color="#0284c7" metalness={0.4} roughness={0.4} />
      </mesh>

      {/* Primary Fuse & Relay Power Distribution Box */}
      <mesh position={[-0.24, -0.05, -0.02]}>
        <boxGeometry args={[0.18, 0.12, 0.14]} />
        <meshStandardMaterial
          color="#1e293b"
          roughness={0.4}
          metalness={0.5}
          emissive={highlightColor}
          emissiveIntensity={emissiveIntensity * 0.6}
        />
      </mesh>

      {/* Translucent Fuse Box Protective Lid */}
      <mesh position={[-0.24, 0.02, -0.02]}>
        <boxGeometry args={[0.19, 0.02, 0.15]} />
        <meshPhysicalMaterial
          color="#94a3b8"
          transmission={0.8}
          roughness={0.1}
          transparent
          opacity={0.7}
        />
      </mesh>

      {/* Braided Wiring Spine Bundle Conduit */}
      <mesh position={[-0.12, -0.14, -0.1]} rotation={[0.4, 0, 0.6]}>
        <cylinderGeometry args={[0.018, 0.018, 0.28, 12]} />
        <meshStandardMaterial color="#0f172a" roughness={0.9} />
      </mesh>
    </group>
  );
}

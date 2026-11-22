'use client';

import React, { useState, useEffect } from 'react';
import dynamic from 'next/dynamic';
import Link from 'next/link';
import {
  SubsystemId,
  DisplayMode,
  SUBSYSTEM_DEFINITIONS,
  SubsystemDefinition
} from './inspection-types';
import {
  Wrench,
  RotateCcw,
  Layers,
  Box,
  Eye,
  Activity,
  AlertTriangle,
  CheckCircle2,
  Sliders,
  DollarSign,
  Clock,
  Compass,
  FileText,
  ShieldAlert,
  ChevronRight,
  Maximize2,
  Sparkles,
  Info,
  ArrowRight,
  ExternalLink
} from 'lucide-react';

// Dynamic import for 3D Hologram Scene to prevent SSR errors
const HologramScene = dynamic(
  () => import('./hologram-scene').then((mod) => mod.HologramScene),
  {
    ssr: false,
    loading: () => (
      <div className="w-full h-full min-h-[440px] bg-carbon border border-divider flex flex-col items-center justify-center gap-3 text-stone-muted">
        <div className="w-8 h-8 rounded-full border-2 border-stone-dim border-t-porcelain animate-spin" />
        <span className="text-xs font-mono uppercase tracking-widest">
          Calibrating 3D Digital Twin Matrix...
        </span>
      </div>
    ),
  }
);

export interface InspectionTerminalProps {
  variant?: 'workshop' | 'overview';
  initialSubsystem?: SubsystemId;
  className?: string;
}

export function InspectionTerminal({
  variant = 'workshop',
  initialSubsystem = 'engine',
  className = '',
}: InspectionTerminalProps) {
  const [selectedId, setSelectedId] = useState<SubsystemId | null>(initialSubsystem);
  const [displayMode, setDisplayMode] = useState<DisplayMode>('standard');
  const [resetCounter, setResetCounter] = useState(0);
  const [isWebGLEnabled, setIsWebGLEnabled] = useState(true);

  // Check for WebGL capability
  useEffect(() => {
    try {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      if (!gl) {
        setIsWebGLEnabled(false);
      }
    } catch {
      setIsWebGLEnabled(false);
    }
  }, []);

  const activeDefinition: SubsystemDefinition | null = selectedId
    ? SUBSYSTEM_DEFINITIONS[selectedId]
    : null;

  const handleReset = () => {
    setSelectedId(null);
    setDisplayMode('standard');
    setResetCounter((prev) => prev + 1);
  };

  const subsystemList: SubsystemId[] = [
    'engine',
    'battery',
    'transmission',
    'brakes',
    'wheels',
    'suspension',
    'cooling',
    'electrical',
  ];

  const subsystemLabels: Record<SubsystemId, string> = {
    engine: '1. Engine Block',
    battery: '2. Battery Module',
    transmission: '3. Transmission',
    brakes: '4. Braking System',
    wheels: '5. Wheels & Tyres',
    suspension: '6. Suspension Struts',
    cooling: '7. Radiator Cooling',
    electrical: '8. Electrical Harness',
  };

  // Compact labels for Overview Mode HUD
  const overviewSubsystemLabels: Record<SubsystemId, string> = {
    engine: '1. Engine',
    battery: '2. Battery',
    transmission: '3. Transmission',
    brakes: '4. Brakes',
    wheels: '5. Wheels',
    suspension: '6. Suspension',
    cooling: '7. Cooling',
    electrical: '8. Electrical',
  };

  // =========================================================================
  // PRESENTATION MODE 1: OVERVIEW HERO MODE (COMPACT & CINEMATIC)
  // =========================================================================
  if (variant === 'overview') {
    return (
      <div className={`w-full border border-divider/80 bg-graphite/40 rounded-sm overflow-hidden flex flex-col shadow-architectural relative ${className}`}>
        
        {/* Top Control Overlay: Digital Twin Telemetry & Viewport Controls */}
        <div className="p-3 sm:p-4 border-b border-divider/60 bg-carbon/90 backdrop-blur-md flex items-center justify-between gap-3 z-10">
          <div className="flex items-center gap-2.5 min-w-0">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse shrink-0" />
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <span className="text-xs font-mono font-medium text-porcelain uppercase tracking-wider truncate">
                  3D Holographic Twin
                </span>
                <span className="hidden sm:inline-block px-1.5 py-0.5 rounded-sm bg-cyan-950/60 border border-cyan-800/50 text-cyan-400 text-[9px] font-mono uppercase tracking-widest">
                  F458 Platform
                </span>
              </div>
              <div className="text-[10px] font-mono text-stone-muted truncate">
                {activeDefinition ? (
                  <span className="text-porcelain font-semibold">Target: {activeDefinition.name}</span>
                ) : (
                  'Select component below or click 3D vehicle'
                )}
              </div>
            </div>
          </div>

          {/* Viewport Action Controls: CAD / X-Ray Toggle + Camera Reset */}
          <div className="flex items-center gap-1.5 shrink-0">
            <div className="inline-flex rounded-sm p-0.5 bg-elevated border border-divider text-[10px] font-mono">
              <button
                type="button"
                onClick={() => setDisplayMode('standard')}
                className={`px-2.5 py-1 rounded-sm uppercase tracking-wider transition-all ${
                  displayMode === 'standard'
                    ? 'bg-carbon text-porcelain font-medium shadow-sm'
                    : 'text-stone-muted hover:text-porcelain'
                }`}
                title="Standard High-Contrast CAD Finish"
              >
                CAD
              </button>
              <button
                type="button"
                onClick={() => setDisplayMode('xray')}
                className={`px-2.5 py-1 rounded-sm uppercase tracking-wider transition-all ${
                  displayMode === 'xray'
                    ? 'bg-carbon text-cyan-400 font-medium shadow-sm'
                    : 'text-stone-muted hover:text-porcelain'
                }`}
                title="Translucent X-Ray Hologram"
              >
                X-Ray
              </button>
            </div>

            <button
              type="button"
              onClick={handleReset}
              className="p-1.5 rounded-sm bg-elevated hover:bg-carbon border border-divider text-stone-muted hover:text-porcelain transition-colors"
              title="Reset Camera View & Selection"
              aria-label="Reset Camera View"
            >
              <RotateCcw className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        {/* 3D Viewport Area */}
        <div className="relative w-full h-[420px] sm:h-[460px] lg:h-[520px] bg-carbon overflow-hidden">
          {isWebGLEnabled ? (
            <HologramScene
              selectedSubsystem={selectedId}
              onSelectSubsystem={(id) => setSelectedId(id)}
              displayMode={displayMode}
              resetTrigger={resetCounter}
            />
          ) : (
            <div className="w-full h-full flex flex-col items-center justify-center p-6 text-center text-stone-muted space-y-2">
              <AlertTriangle className="w-6 h-6 text-ochre mx-auto" />
              <h4 className="text-xs font-mono text-porcelain uppercase">WebGL Acceleration Offline</h4>
              <p className="text-[11px] max-w-xs text-stone-dim">
                Explore mechanical subsystems using the interactive selector strip below.
              </p>
            </div>
          )}

          {/* Viewport Floating Coordinates Overlay (Top-Left) */}
          <div className="absolute top-3 left-3 pointer-events-none text-[9px] font-mono text-stone-dim space-y-0.5 bg-carbon/80 backdrop-blur-sm p-1.5 rounded-sm border border-divider/40">
            <div>SCALE: 1:1 TRUE CAD</div>
            <div>RAYCAST: ACTIVE</div>
            <div className="text-stone-muted">ROTATION: 360° ORBIT</div>
          </div>

          {/* Viewport Floating Interaction Hint (Top-Right) */}
          <div className="absolute top-3 right-3 pointer-events-none text-[9px] font-mono text-stone-dim bg-carbon/75 backdrop-blur-sm px-2 py-0.5 rounded-sm border border-divider/30 hidden sm:block">
            Drag to Orbit • Scroll to Zoom
          </div>

          {/* Contextual Technical Overlay Card (Bottom Overlay) */}
          {activeDefinition && (
            <div className="absolute bottom-3 left-3 right-3 sm:right-auto sm:max-w-md p-3.5 bg-carbon/92 backdrop-blur-md border border-divider/80 rounded-sm shadow-architectural z-10 animate-fadeIn space-y-2">
              <div className="flex items-center justify-between gap-2 border-b border-divider/50 pb-1.5">
                <div className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-cyan-400" />
                  <span className="text-[10px] font-mono uppercase text-stone-dim tracking-wider">
                    {activeDefinition.category}
                  </span>
                </div>
                <div className="flex items-center gap-1.5">
                  {activeDefinition.diagnosticFaultCodes[0] && (
                    <span className="px-1.5 py-0.5 rounded-sm bg-elevated border border-divider text-[9px] font-mono text-stone-muted">
                      DTC {activeDefinition.diagnosticFaultCodes[0].code}
                    </span>
                  )}
                  <span className="text-[9px] font-mono text-forest font-semibold">
                    Subsystem #{subsystemList.indexOf(activeDefinition.id) + 1}
                  </span>
                </div>
              </div>

              <div>
                <h4 className="text-xs sm:text-sm font-medium text-porcelain tracking-tight">
                  {activeDefinition.name}
                </h4>
                <p className="text-[11px] text-stone-muted leading-relaxed line-clamp-2 mt-1">
                  {activeDefinition.technicalOverview}
                </p>
              </div>

              {/* Quick Specifications & Symptoms Grid */}
              <div className="grid grid-cols-2 gap-2 pt-1 border-t border-divider/40 text-[10px] font-mono">
                <div>
                  <span className="text-stone-dim block">PRIMARY METRIC</span>
                  <span className="text-porcelain truncate block">
                    {Object.values(activeDefinition.specifications)[0] || 'Nominal OEM Spec'}
                  </span>
                </div>
                <div>
                  <span className="text-stone-dim block">COMMON SYMPTOM</span>
                  <span className="text-ochre truncate block">
                    {activeDefinition.commonSymptoms[0] || 'Diagnostic inspection'}
                  </span>
                </div>
              </div>

              {/* Action Link to Workshop */}
              <div className="pt-1 flex items-center justify-between">
                <span className="text-[9px] font-mono text-stone-dim">
                  Est. Service: ${activeDefinition.relatedRepairServices[0]?.estimatedLaborCost ? activeDefinition.relatedRepairServices[0].estimatedLaborCost + (activeDefinition.relatedRepairServices[0].estimatedPartsCost || 0) : 'Custom'}
                </span>
                <Link
                  href="/mechanic/home#inspection-terminal"
                  className="inline-flex items-center gap-1 text-[10px] font-mono uppercase text-porcelain hover:text-cyan-400 transition-colors tracking-wider"
                >
                  <span>Full Diagnostics</span>
                  <ArrowRight className="w-3 h-3" />
                </Link>
              </div>
            </div>
          )}
        </div>

        {/* Bottom Subsystem Quick Selector Strip */}
        <div className="p-2 sm:p-2.5 bg-graphite border-t border-divider/60 overflow-x-auto scrollbar-none z-10">
          <div className="flex items-center gap-1.5 min-w-max">
            <span className="text-[9px] font-mono uppercase text-stone-dim px-1 hidden sm:inline">
              Subsystems:
            </span>
            {subsystemList.map((id) => {
              const isActive = selectedId === id;
              return (
                <button
                  key={id}
                  type="button"
                  onClick={() => setSelectedId(id)}
                  className={`px-2.5 py-1 rounded-sm text-[11px] font-mono uppercase tracking-wider transition-all flex items-center gap-1.5 ${
                    isActive
                      ? 'bg-porcelain text-carbon font-semibold shadow-sm'
                      : 'bg-carbon text-stone-muted hover:text-porcelain border border-divider hover:border-divider-strong'
                  }`}
                >
                  <span>{overviewSubsystemLabels[id]}</span>
                </button>
              );
            })}
          </div>
        </div>

      </div>
    );
  }

  // =========================================================================
  // PRESENTATION MODE 2: WORKSHOP FULL INSPECTION TERMINAL (DEFAULT)
  // =========================================================================
  return (
    <div className={`w-full border border-divider/80 bg-graphite rounded-sm overflow-hidden flex flex-col shadow-architectural ${className}`}>
      
      {/* 1. TERMINAL HEADER & VIEW MODE CONTROLS */}
      <div className="p-4 sm:p-5 border-b border-divider/60 bg-carbon flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        
        {/* Terminal Title Lockup */}
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-sm bg-elevated border border-divider flex items-center justify-center text-porcelain shrink-0">
            <Box className="w-4 h-4 text-porcelain" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base sm:text-lg font-medium tracking-tight text-porcelain">
                Interactive 3D Engineering Inspection Terminal
              </h2>
              <span className="px-2 py-0.5 rounded-sm bg-forest/10 border border-forest/30 text-forest text-[10px] font-mono uppercase tracking-wider">
                Digital Twin
              </span>
            </div>
            <span className="text-[11px] font-mono text-stone-muted">
              Ferrari 458 Italia Platform • 8 Subsystem Assemblies
            </span>
          </div>
        </div>

        {/* View Mode Segmented Controls */}
        <div className="flex flex-wrap items-center gap-2">
          
          {/* Mode Selector */}
          <div className="inline-flex rounded-sm p-1 bg-elevated border border-divider text-xs font-mono">
            <button
              type="button"
              onClick={() => setDisplayMode('standard')}
              className={`px-3 py-1.5 rounded-sm transition-all uppercase tracking-wider ${
                displayMode === 'standard'
                  ? 'bg-carbon text-porcelain font-medium shadow-sm'
                  : 'text-stone-muted hover:text-porcelain'
              }`}
            >
              Standard CAD
            </button>

            <button
              type="button"
              onClick={() => setDisplayMode('xray')}
              className={`px-3 py-1.5 rounded-sm transition-all uppercase tracking-wider ${
                displayMode === 'xray'
                  ? 'bg-carbon text-cyan-400 font-medium shadow-sm'
                  : 'text-stone-muted hover:text-porcelain'
              }`}
            >
              X-Ray Hologram
            </button>

            <button
              type="button"
              onClick={() => setDisplayMode('exploded')}
              className={`px-3 py-1.5 rounded-sm transition-all uppercase tracking-wider ${
                displayMode === 'exploded'
                  ? 'bg-carbon text-ochre font-medium shadow-sm'
                  : 'text-stone-muted hover:text-porcelain'
              }`}
            >
              Exploded View
            </button>

            <button
              type="button"
              onClick={() => setDisplayMode('isolated')}
              disabled={!selectedId}
              className={`px-3 py-1.5 rounded-sm transition-all uppercase tracking-wider ${
                displayMode === 'isolated'
                  ? 'bg-carbon text-forest font-medium shadow-sm'
                  : 'text-stone-muted hover:text-porcelain disabled:opacity-40 disabled:cursor-not-allowed'
              }`}
            >
              Isolated
            </button>
          </div>

          {/* Reset Camera & Selection */}
          <button
            type="button"
            onClick={handleReset}
            className="px-3 py-2 rounded-sm bg-elevated hover:bg-carbon border border-divider text-xs font-mono uppercase tracking-wider text-stone-muted hover:text-porcelain transition-colors flex items-center gap-1.5"
            title="Reset Camera & Selection"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Reset View</span>
          </button>
        </div>

      </div>

      {/* 2. SPLIT LAYOUT: 3D CANVAS & CONTEXTUAL ENGINEERING PANEL */}
      <div className="grid lg:grid-cols-12 min-h-[580px]">
        
        {/* Left Column: 3D Viewport (7 cols) */}
        <div className="lg:col-span-7 bg-carbon relative flex flex-col justify-between border-b lg:border-b-0 lg:border-r border-divider/60">
          
          {/* Main 3D Canvas Container */}
          <div className="w-full h-[440px] sm:h-[480px] lg:h-[580px] relative overflow-hidden">
            {isWebGLEnabled ? (
              <HologramScene
                selectedSubsystem={selectedId}
                onSelectSubsystem={(id) => setSelectedId(id)}
                displayMode={displayMode}
                resetTrigger={resetCounter}
              />
            ) : (
              /* Fallback for WebGL failure */
              <div className="w-full h-full flex flex-col items-center justify-center p-6 text-center text-stone-muted space-y-3">
                <AlertTriangle className="w-8 h-8 text-ochre mx-auto" />
                <h4 className="text-sm font-medium text-porcelain font-mono">
                  Hardware Acceleration Unavailable
                </h4>
                <p className="text-xs max-w-md">
                  WebGL initialization failed on this device. The engineering panel remains fully interactive. Select subsystems from the quick-switch toolbar below.
                </p>
              </div>
            )}

            {/* Viewport Floating Coordinates & Telemetry Overlay */}
            <div className="absolute top-4 left-4 pointer-events-none text-[10px] font-mono text-stone-dim space-y-0.5 bg-carbon/80 backdrop-blur-sm p-2 rounded-sm border border-divider/40">
              <div>PLATFORM: F458 COUPE</div>
              <div>SCALE: 1:1 TRUE CAD</div>
              <div>RAYCAST SELECTION: ACTIVE</div>
              <div>MODE: {displayMode.toUpperCase()}</div>
              {selectedId && (
                <div className="text-porcelain font-semibold">
                  TARGET: {SUBSYSTEM_DEFINITIONS[selectedId].name}
                </div>
              )}
            </div>

            {/* Instruction Tip */}
            <div className="absolute bottom-3 right-4 pointer-events-none text-[10px] font-mono text-stone-dim bg-carbon/70 backdrop-blur-sm px-2.5 py-1 rounded-sm border border-divider/30 hidden sm:block">
              Rotate: Drag • Zoom: Wheel • Select: Click Subsystem
            </div>
          </div>

          {/* Quick Subsystem Selector Strip (Pinned at Bottom of 3D Canvas) */}
          <div className="p-3 bg-graphite border-t border-divider/60 overflow-x-auto scrollbar-none">
            <div className="flex items-center gap-2 min-w-max">
              <span className="text-[10px] font-mono uppercase text-stone-dim pr-1">
                Subsystems:
              </span>
              {subsystemList.map((id) => {
                const isActive = selectedId === id;

                return (
                  <button
                    key={id}
                    type="button"
                    onClick={() => setSelectedId(id)}
                    className={`px-3 py-1.5 rounded-sm text-xs font-mono uppercase tracking-wider transition-all flex items-center gap-1.5 ${
                      isActive
                        ? 'bg-porcelain text-carbon font-semibold shadow-sm'
                        : 'bg-carbon text-stone-muted hover:text-porcelain border border-divider hover:border-divider-strong'
                    }`}
                  >
                    <span>{subsystemLabels[id]}</span>
                  </button>
                );
              })}
            </div>
          </div>

        </div>

        {/* Right Column: Contextual Engineering Diagnostics Console (5 cols) */}
        <div className="lg:col-span-5 p-6 bg-graphite space-y-6 overflow-y-auto max-h-[640px]">
          
          {activeDefinition ? (
            <div className="space-y-6 animate-fadeIn">
              
              {/* Active Component Header */}
              <div className="border-b border-divider/60 pb-4 space-y-1.5">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-mono uppercase tracking-wider text-forest font-semibold">
                    {activeDefinition.category}
                  </span>
                  <span className="px-2 py-0.5 rounded-sm bg-elevated border border-divider text-[10px] font-mono text-stone-muted">
                    Subsystem #{subsystemList.indexOf(activeDefinition.id) + 1}
                  </span>
                </div>

                <h3 className="text-lg font-medium text-porcelain tracking-tight">
                  {activeDefinition.name}
                </h3>

                <p className="text-xs text-stone-dim font-mono">
                  Location: {activeDefinition.locationDescription}
                </p>
              </div>

              {/* Technical Overview Description */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  Technical Architecture
                </span>
                <p className="text-xs text-stone-muted leading-relaxed">
                  {activeDefinition.technicalOverview}
                </p>
              </div>

              {/* Specifications Matrix */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  OEM Specifications
                </span>
                <div className="p-3 bg-carbon border border-divider/60 rounded-sm divide-y divide-divider/40 text-xs font-mono">
                  {Object.entries(activeDefinition.specifications).map(([key, value]) => (
                    <div key={key} className="py-1.5 flex items-center justify-between first:pt-0 last:pb-0">
                      <span className="text-stone-dim">{key}:</span>
                      <span className="text-porcelain font-medium">{value}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Common Symptoms Checklist */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  Observed Failure Symptoms
                </span>
                <ul className="space-y-1.5">
                  {activeDefinition.commonSymptoms.map((sym, idx) => (
                    <li key={idx} className="text-xs text-stone-muted flex items-start gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-ochre shrink-0 mt-1.5" />
                      <span>{sym}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* SAE Diagnostic Fault Codes (DTC) */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  Associated SAE Diagnostic Fault Codes
                </span>
                <div className="space-y-2">
                  {activeDefinition.diagnosticFaultCodes.map((dtc) => (
                    <div
                      key={dtc.code}
                      className="p-3 bg-carbon border border-divider/60 rounded-sm space-y-1"
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold font-mono text-porcelain">
                          {dtc.code}
                        </span>
                        <span
                          className={`px-1.5 py-0.5 rounded-sm text-[9px] font-mono uppercase ${
                            dtc.severity === 'CRITICAL'
                              ? 'bg-crimson/20 text-crimson font-medium'
                              : dtc.severity === 'WARNING'
                              ? 'bg-ochre/20 text-ochre'
                              : 'bg-forest/20 text-forest'
                          }`}
                        >
                          {dtc.severity}
                        </span>
                      </div>
                      <div className="text-xs text-stone-muted">{dtc.description}</div>
                      <div className="text-[10px] font-mono text-stone-dim">
                        Trigger: {dtc.triggerCondition}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Recommended Diagnostic Protocol */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  Field Diagnostic Triage Routine
                </span>
                <div className="p-3 bg-carbon border border-divider/60 rounded-sm space-y-2">
                  {activeDefinition.diagnosticProcedure.map((step, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-xs text-stone-muted font-mono">
                      <span className="text-stone-dim">{idx + 1}.</span>
                      <span>{step}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Related Repair Services & Estimates */}
              <div className="space-y-2">
                <span className="text-[11px] font-mono uppercase tracking-wider text-stone-muted block">
                  Authorized Repair Packages
                </span>
                <div className="space-y-2">
                  {activeDefinition.relatedRepairServices.map((service, idx) => (
                    <div
                      key={idx}
                      className="p-3 bg-carbon border border-divider/60 rounded-sm flex items-center justify-between gap-3"
                    >
                      <div className="space-y-0.5">
                        <div className="text-xs font-medium text-porcelain tracking-tight">
                          {service.name}
                        </div>
                        <div className="text-[10px] font-mono text-stone-dim">
                          Labor: {service.laborHours}h (${service.estimatedLaborCost}) • Parts: ${service.estimatedPartsCost}
                        </div>
                      </div>

                      <div className="text-right shrink-0">
                        <div className="text-sm font-semibold font-mono text-forest">
                          ${service.estimatedLaborCost + service.estimatedPartsCost}
                        </div>
                        <span className="text-[9px] font-mono uppercase text-stone-dim">
                          Est. Total
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

            </div>
          ) : (
            <div className="py-16 text-center space-y-3">
              <Compass className="w-8 h-8 mx-auto text-stone-dim stroke-[1.5]" />
              <div className="text-xs text-stone-muted">No subsystem currently selected.</div>
              <div className="text-[11px] text-stone-dim">
                Click any mechanical component in the 3D viewport or use the selector strip above to inspect engineering diagnostics.
              </div>
            </div>
          )}

        </div>

      </div>

    </div>
  );
}

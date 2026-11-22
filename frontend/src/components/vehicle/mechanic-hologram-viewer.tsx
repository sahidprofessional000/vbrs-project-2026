'use client';

import React from 'react';
import { InspectionTerminal, InspectionTerminalProps } from '@/components/hologram/inspection-terminal';
import { SubsystemId, DisplayMode } from '@/components/hologram/inspection-types';

export interface MechanicHologramViewerProps extends InspectionTerminalProps {
  // Pass-through props
}

/**
 * MechanicHologramViewer
 * Dedicated presentation component EXCLUSIVELY for Mechanic Overview and Mechanic Workshop.
 * Encapsulates the Interactive 3D Automotive Hologram featuring 8 selectable mechanical subsystems,
 * CAD & X-Ray shaders, exploded/isolated views, SAE DTC trouble codes, and diagnostic telemetry.
 */
export function MechanicHologramViewer({
  variant = 'workshop',
  initialSubsystem = 'engine',
  className = '',
}: MechanicHologramViewerProps) {
  return (
    <div
      data-testid="mechanic-hologram-viewer"
      data-variant={variant}
      className={`relative w-full ${className}`}
    >
      <InspectionTerminal
        variant={variant}
        initialSubsystem={initialSubsystem}
      />
    </div>
  );
}

export type { SubsystemId, DisplayMode };

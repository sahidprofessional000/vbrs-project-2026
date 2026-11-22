'use client';

import React, { useState, useEffect, useRef } from 'react';
import dynamic from 'next/dynamic';
import { RotateCw, Camera, ShieldCheck, Eye, Layers } from 'lucide-react';

// Dynamic import with SSR disabled to prevent hydration errors on browser-only WebGL APIs
const VehicleCanvas = dynamic(() => import('@/components/hero/vehicle-canvas'), {
  ssr: false,
  loading: () => <VehicleLoadingPlaceholder />,
});

const PAINT_SWATCHES = [
  { id: 'carbon', label: 'Obsidian Carbon', hex: '#16181b', ring: '#40444c' },
  { id: 'crimson', label: 'Safety Crimson', hex: '#8b1510', ring: '#a82620' },
  { id: 'alpine', label: 'Alpine Slate', hex: '#202e29', ring: '#3b524a' },
  { id: 'porcelain', label: 'Chalk Porcelain', hex: '#d2d0ca', ring: '#e8e6e0' },
];

function VehicleLoadingPlaceholder() {
  return (
    <div className="relative w-full h-full bg-carbon flex flex-col items-center justify-center border border-divider">
      <div className="w-8 h-8 border border-divider border-t-porcelain rounded-full animate-spin mb-3" />
      <span className="font-mono text-[10px] uppercase tracking-wider text-stone-muted">
        STREAMING VEHICLE TELEMETRY // 3D STAGE
      </span>
    </div>
  );
}

function StaticFallbackImage() {
  return (
    <div className="relative w-full h-full bg-carbon">
      <img
        src="/images/hero-fallback.jpg"
        alt="Automotive precision vehicle headlights"
        className="w-full h-full object-cover grayscale-[25%] contrast-[110%] brightness-[90%]"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-carbon/95 via-transparent to-transparent pointer-events-none" />
      <div className="absolute top-4 left-4 font-mono text-[10px] text-amber-500 bg-carbon/80 border border-amber-500/30 px-2 py-1 uppercase tracking-wider">
        HARDWARE ACCELERATION UNAVAILABLE // STATIC FALLBACK ACTIVE
      </div>
    </div>
  );
}

export interface OriginalVehicleViewerProps {
  variant?: 'hero' | 'compact' | 'dashboard';
  title?: string;
  className?: string;
}

/**
 * OriginalVehicleViewer
 * Dedicated presentation component for Public Landing, Customer Portal, and Admin Dashboard.
 * Renders the original PBR clearcoat 3D car model (/models/car.glb) with turntable rotation,
 * architectural paint swatches, and hardware acceleration detection.
 */
export function OriginalVehicleViewer({
  variant = 'hero',
  title = 'Designated Vehicle Asset',
  className = '',
}: OriginalVehicleViewerProps) {
  const [paintColor, setPaintColor] = useState(PAINT_SWATCHES[0].hex);
  const [isRotating, setIsRotating] = useState(true);
  const [hasWebGL, setHasWebGL] = useState<boolean | null>(null);
  const controlsRef = useRef<any>(null);

  useEffect(() => {
    try {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      setHasWebGL(Boolean(gl));
    } catch {
      setHasWebGL(false);
    }

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      setIsRotating(false);
    }
  }, []);

  const handleResetCamera = () => {
    if (controlsRef.current) {
      controlsRef.current.reset();
      controlsRef.current.target.set(0, 0.4, 0);
      controlsRef.current.update();
    }
  };

  // Compact / Dashboard Mode for Customer & Admin
  if (variant === 'compact' || variant === 'dashboard') {
    return (
      <div
        data-testid="original-vehicle-viewer"
        data-variant={variant}
        className={`relative border border-divider bg-graphite/40 shadow-elevated rounded-sm overflow-hidden ${className}`}
      >
        <div className="relative h-64 sm:h-72 w-full overflow-hidden bg-carbon">
          {hasWebGL === false ? (
            <StaticFallbackImage />
          ) : (
            <VehicleCanvas
              paintColor={paintColor}
              isRotating={isRotating}
              onControlsReady={(controls) => {
                controlsRef.current = controls;
              }}
            />
          )}

          {/* Floating Controls Overlay */}
          <div className="absolute top-2.5 left-2.5 right-2.5 flex items-center justify-between pointer-events-auto z-10">
            <div className="flex items-center gap-1.5 p-1 bg-carbon/85 backdrop-blur-md border border-divider rounded-sm">
              <span className="text-[9px] font-mono text-stone-dim uppercase px-1">COLOR:</span>
              {PAINT_SWATCHES.map((swatch) => (
                <button
                  key={swatch.id}
                  type="button"
                  onClick={() => setPaintColor(swatch.hex)}
                  title={swatch.label}
                  aria-label={swatch.label}
                  className={`w-3.5 h-3.5 rounded-full border transition-all ${
                    paintColor === swatch.hex
                      ? 'scale-110 border-porcelain shadow-sm'
                      : 'border-transparent opacity-70 hover:opacity-100'
                  }`}
                  style={{ backgroundColor: swatch.hex }}
                />
              ))}
            </div>

            <div className="flex items-center gap-1 p-1 bg-carbon/85 backdrop-blur-md border border-divider rounded-sm font-mono text-[9px]">
              <button
                type="button"
                onClick={() => setIsRotating((prev) => !prev)}
                className={`flex items-center gap-1 px-1.5 py-0.5 rounded-sm uppercase tracking-wider transition-colors ${
                  isRotating ? 'text-porcelain bg-elevated' : 'text-stone-dim hover:text-stone-muted'
                }`}
                title="Toggle Rotation"
              >
                <RotateCw className={`w-2.5 h-2.5 ${isRotating ? 'animate-spin' : ''}`} style={{ animationDuration: '8s' }} />
                <span>ORBIT</span>
              </button>

              <button
                type="button"
                onClick={handleResetCamera}
                className="flex items-center gap-1 px-1.5 py-0.5 rounded-sm uppercase tracking-wider text-stone-dim hover:text-stone-muted transition-colors"
                title="Reset Camera"
              >
                <Camera className="w-2.5 h-2.5" />
                <span>RESET</span>
              </button>
            </div>
          </div>

          {/* Status Badge */}
          <div className="absolute bottom-2.5 left-2.5 right-2.5 flex items-center justify-between font-mono text-[9px] text-stone-muted pointer-events-none z-10">
            <div className="bg-carbon/85 backdrop-blur-sm px-2 py-1 border border-divider/60 rounded-sm flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-porcelain uppercase font-medium">{title}</span>
            </div>
            <div className="bg-carbon/85 backdrop-blur-sm px-2 py-1 border border-divider/60 rounded-sm text-stone-dim">
              PBR CLEARCOAT // 360° INSPECT
            </div>
          </div>

          <div className="absolute inset-0 bg-gradient-to-t from-carbon/70 via-transparent to-transparent pointer-events-none" />
        </div>
      </div>
    );
  }

  // Hero Mode for Public Landing Page
  return (
    <div
      data-testid="original-vehicle-viewer"
      data-variant="hero"
      className={`relative border border-divider p-2 bg-graphite/40 shadow-elevated rounded-sm ${className}`}
    >
      <div className="relative aspect-[4/3] sm:aspect-[16/11] xl:aspect-[16/11] overflow-hidden bg-carbon">
        {hasWebGL === false ? (
          <StaticFallbackImage />
        ) : (
          <VehicleCanvas
            paintColor={paintColor}
            isRotating={isRotating}
            onControlsReady={(controls) => {
              controlsRef.current = controls;
            }}
          />
        )}

        {/* Top Control Overlay: Paint Finishes + Turntable Controls */}
        <div className="absolute top-3 left-3 right-3 flex items-center justify-between pointer-events-auto z-10">
          {/* Paint Swatches */}
          <div className="flex items-center gap-1.5 p-1 bg-carbon/85 backdrop-blur-md border border-divider rounded-sm">
            <span className="text-[10px] font-mono text-stone-dim uppercase px-1.5 hidden sm:inline">
              FINISH:
            </span>
            {PAINT_SWATCHES.map((swatch) => (
              <button
                key={swatch.id}
                type="button"
                onClick={() => setPaintColor(swatch.hex)}
                title={swatch.label}
                aria-label={swatch.label}
                className={`w-4 h-4 rounded-full border transition-all ${
                  paintColor === swatch.hex
                    ? 'scale-110 border-porcelain shadow-sm'
                    : 'border-transparent opacity-70 hover:opacity-100'
                }`}
                style={{ backgroundColor: swatch.hex }}
              />
            ))}
          </div>

          {/* Turntable & Camera Actions */}
          <div className="flex items-center gap-1.5 p-1 bg-carbon/85 backdrop-blur-md border border-divider rounded-sm font-mono text-[10px]">
            <button
              type="button"
              onClick={() => setIsRotating((prev) => !prev)}
              className={`flex items-center gap-1 px-2 py-0.5 rounded-sm uppercase tracking-wider transition-colors ${
                isRotating
                  ? 'text-porcelain bg-elevated border border-divider'
                  : 'text-stone-dim hover:text-stone-muted'
              }`}
              title="Toggle Turntable Rotation"
            >
              <RotateCw className={`w-3 h-3 ${isRotating ? 'animate-spin' : ''}`} style={{ animationDuration: '8s' }} />
              <span className="hidden sm:inline">ORBIT</span>
            </button>

            <button
              type="button"
              onClick={handleResetCamera}
              className="flex items-center gap-1 px-2 py-0.5 rounded-sm uppercase tracking-wider text-stone-dim hover:text-stone-muted transition-colors"
              title="Reset Camera View"
            >
              <Camera className="w-3 h-3" />
              <span className="hidden sm:inline">RESET</span>
            </button>
          </div>
        </div>

        {/* Bottom Editorial Telemetry Overlay */}
        <div className="absolute bottom-3 left-3 right-3 flex items-end justify-between font-mono text-[11px] text-stone-muted pointer-events-none z-10">
          <div className="bg-carbon/80 backdrop-blur-sm p-1.5 border border-divider/60 rounded-sm">
            <div className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              <span className="text-porcelain uppercase font-semibold tracking-wider text-[10px]">
                3D PBR REALTIME STUDIO
              </span>
            </div>
            <div className="text-[10px] text-stone-dim mt-0.5">
              <span>DRACO OPTIMIZED // 360° INTERACTIVE INSPECT</span>
            </div>
          </div>

          <div className="text-right bg-carbon/80 backdrop-blur-sm p-1.5 border border-divider/60 rounded-sm">
            <span className="text-stone-dim text-[10px] uppercase block tracking-wider">
              DRAG TO ROTATE
            </span>
            <span className="text-porcelain text-[10px]">40.7128° N, 74.0060° W</span>
          </div>
        </div>

        {/* Ambient Vignette Gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-carbon/70 via-transparent to-transparent pointer-events-none" />
      </div>
    </div>
  );
}

'use client';

import React, { Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import * as THREE from 'three';
import { VehicleScene, VehicleSceneProps } from './vehicle-scene';

function CanvasLoader() {
  return (
    <div className="absolute inset-0 flex flex-col items-center justify-center bg-carbon/90 text-stone-muted z-10">
      <div className="w-8 h-8 border border-divider border-t-porcelain rounded-full animate-spin mb-3" />
      <span className="font-mono text-[11px] uppercase tracking-wider text-stone-dim">
        INITIALIZING 3D ENGINE // LOADING ASSETS
      </span>
    </div>
  );
}

export default function VehicleCanvas({
  paintColor,
  isRotating,
  onControlsReady,
}: VehicleSceneProps) {
  return (
    <div className="relative w-full h-full select-none cursor-grab active:cursor-grabbing">
      <Suspense fallback={<CanvasLoader />}>
        <Canvas
          shadows
          dpr={[1, 1.5]}
          camera={{
            position: [4.4, 1.35, -4.2],
            fov: 37,
            near: 0.1,
            far: 50,
          }}
          gl={{
            antialias: true,
            alpha: true,
            powerPreference: 'high-performance',
            toneMapping: THREE.ACESFilmicToneMapping,
            toneMappingExposure: 0.92,
          }}
          className="w-full h-full"
          onCreated={({ gl, scene }) => {
            scene.fog = new THREE.Fog('#111214', 9, 20);
          }}
        >
          <VehicleScene
            paintColor={paintColor}
            isRotating={isRotating}
            onControlsReady={onControlsReady}
          />
        </Canvas>
      </Suspense>
    </div>
  );
}

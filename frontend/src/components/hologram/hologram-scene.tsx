'use client';

import React, { useRef, useEffect, useMemo } from 'react';
import * as THREE from 'three';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { useGLTF, OrbitControls, ContactShadows } from '@react-three/drei';
import { SubsystemId, DisplayMode, SUBSYSTEM_DEFINITIONS } from './inspection-types';
import { HologramSubsystems } from './hologram-subsystems';

// Configure local Draco decoder
useGLTF.setDecoderPath('/draco/');

interface HologramSceneProps {
  selectedSubsystem: SubsystemId | null;
  onSelectSubsystem: (id: SubsystemId) => void;
  displayMode: DisplayMode;
  resetTrigger: number;
}

function ChassisModel({
  displayMode,
  selectedSubsystem,
}: {
  displayMode: DisplayMode;
  selectedSubsystem: SubsystemId | null;
}) {
  const { scene } = useGLTF('/models/car.glb', '/draco/');

  // Clone scene to avoid shared material mutations
  const clonedScene = useMemo(() => {
    return scene.clone(true);
  }, [scene]);

  useEffect(() => {
    if (!clonedScene) return;

    clonedScene.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        const mesh = child as THREE.Mesh;
        const name = (mesh.name || '').toLowerCase();

        // If isolated mode is active, hide exterior chassis completely
        if (displayMode === 'isolated' && selectedSubsystem) {
          mesh.visible = false;
          return;
        }

        mesh.visible = true;

        if (displayMode === 'xray') {
          // Holographic X-Ray mode: Translucent cyan-tinted glass/matrix
          mesh.material = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color('#38bdf8'),
            roughness: 0.1,
            metalness: 0.3,
            transmission: 0.88,
            transparent: true,
            opacity: 0.14,
            wireframe: false,
            depthWrite: false,
          });
        } else if (displayMode === 'exploded') {
          // Exploded mode: Semi-translucent body panels so internal components pop
          if (name === 'body' || name === 'glass' || name === 'trim') {
            mesh.material = new THREE.MeshPhysicalMaterial({
              color: new THREE.Color('#1f2329'),
              metalness: 0.8,
              roughness: 0.3,
              transparent: true,
              opacity: 0.35,
              depthWrite: false,
            });
          }
        } else {
          // Standard Engineering CAD Mode: High-contrast Dark Carbon Finish
          if (name === 'body') {
            mesh.material = new THREE.MeshPhysicalMaterial({
              color: new THREE.Color('#181a1d'),
              metalness: 0.85,
              roughness: 0.32,
              clearcoat: 0.9,
              clearcoatRoughness: 0.08,
            });
          } else if (name === 'glass') {
            mesh.material = new THREE.MeshPhysicalMaterial({
              color: new THREE.Color('#0f1114'),
              roughness: 0.05,
              transmission: 0.85,
              transparent: true,
              opacity: 0.6,
            });
          } else if (name.startsWith('rim_') || name === 'centre') {
            mesh.material = new THREE.MeshStandardMaterial({
              color: new THREE.Color('#94a3b8'),
              metalness: 0.92,
              roughness: 0.2,
            });
          } else if (name === 'tire') {
            mesh.material = new THREE.MeshStandardMaterial({
              color: new THREE.Color('#0f1012'),
              roughness: 0.9,
              metalness: 0.05,
            });
          } else {
            mesh.material = new THREE.MeshStandardMaterial({
              color: new THREE.Color('#24272c'),
              metalness: 0.7,
              roughness: 0.4,
            });
          }
        }
      }
    });
  }, [clonedScene, displayMode, selectedSubsystem]);

  return (
    <primitive object={clonedScene} position={[0, 0, 0]} />
  );
}

function HologramControls({
  resetTrigger,
}: {
  resetTrigger: number;
}) {
  const controlsRef = useRef<any>(null);
  const { camera } = useThree();

  const defaultPos = useMemo(() => new THREE.Vector3(4.2, 2.2, 4.2), []);
  const defaultTarget = useMemo(() => new THREE.Vector3(0, 0.4, 0), []);

  const isResetting = useRef(false);
  const resetStartTime = useRef(0);
  const resetStartPos = useRef(new THREE.Vector3());
  const resetStartTarget = useRef(new THREE.Vector3());

  // Trigger smooth reset animation only on explicit reset button trigger
  useEffect(() => {
    if (resetTrigger > 0 && controlsRef.current) {
      isResetting.current = true;
      resetStartTime.current = performance.now();
      resetStartPos.current.copy(camera.position);
      resetStartTarget.current.copy(controlsRef.current.target);
    }
  }, [resetTrigger, camera]);

  useFrame(() => {
    if (isResetting.current && controlsRef.current) {
      const elapsed = (performance.now() - resetStartTime.current) / 500; // 500ms smooth reset
      if (elapsed >= 1) {
        isResetting.current = false;
        camera.position.copy(defaultPos);
        controlsRef.current.target.copy(defaultTarget);
        controlsRef.current.update();
      } else {
        const t = 1 - Math.pow(1 - elapsed, 3); // cubic ease-out
        camera.position.lerpVectors(resetStartPos.current, defaultPos, t);
        controlsRef.current.target.lerpVectors(resetStartTarget.current, defaultTarget, t);
        controlsRef.current.update();
      }
    }
  });

  return (
    <OrbitControls
      ref={controlsRef}
      makeDefault
      enableRotate={true}
      rotateSpeed={0.9}
      enableZoom={true}
      zoomSpeed={1.0}
      enablePan={true}
      panSpeed={0.8}
      screenSpacePanning={true}
      enableDamping={true}
      dampingFactor={0.05}
      minDistance={1.4}
      maxDistance={14.0}
      minPolarAngle={0}
      maxPolarAngle={Math.PI}
      minAzimuthAngle={-Infinity}
      maxAzimuthAngle={Infinity}
      touches={{
        ONE: THREE.TOUCH.ROTATE,
        TWO: THREE.TOUCH.DOLLY_PAN,
      }}
      target={[0, 0.4, 0]}
      onStart={() => {
        // Cancel active reset immediately if user grabs the viewport
        isResetting.current = false;
      }}
    />
  );
}

export function HologramScene({
  selectedSubsystem,
  onSelectSubsystem,
  displayMode,
  resetTrigger,
}: HologramSceneProps) {
  return (
    <Canvas
      camera={{ position: [4.2, 2.2, 4.2], fov: 42 }}
      gl={{ antialias: true, alpha: true, powerPreference: 'high-performance' }}
      className="w-full h-full cursor-grab active:cursor-grabbing touch-none select-none"
    >
      {/* Studio Ambient & Key Lighting */}
      <ambientLight intensity={0.5} color="#e2e8f0" />

      {/* Primary Overhead Softbox Light */}
      <directionalLight
        position={[5, 8, 4]}
        intensity={1.6}
        color="#ffffff"
        castShadow
        shadow-mapSize={[1024, 1024]}
        shadow-bias={-0.0001}
      />

      {/* Silhouette & Rim Light */}
      <directionalLight position={[-6, 4, -5]} intensity={1.2} color="#93c5fd" />

      {/* Front Nose Fill Light */}
      <directionalLight position={[0, 2, 5]} intensity={0.7} color="#f8fafc" />

      {/* Ground Contact Shadow */}
      <ContactShadows
        position={[0, 0, 0]}
        opacity={0.75}
        scale={10}
        blur={1.8}
        far={4}
        resolution={512}
        color="#000000"
      />

      {/* Exterior Chassis Model */}
      <ChassisModel
        displayMode={displayMode}
        selectedSubsystem={selectedSubsystem}
      />

      {/* 8 Selectable Subsystem Assemblies */}
      <HologramSubsystems
        selectedSubsystem={selectedSubsystem}
        onSelectSubsystem={onSelectSubsystem}
        displayMode={displayMode}
      />

      {/* Free 360-Degree Damped Orbit Controls */}
      <HologramControls
        resetTrigger={resetTrigger}
      />
    </Canvas>
  );
}

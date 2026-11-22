'use client';

import React, { useRef, useEffect, useMemo } from 'react';
import * as THREE from 'three';
import { useFrame } from '@react-three/fiber';
import { useGLTF, OrbitControls, ContactShadows, Environment, Lightformer } from '@react-three/drei';

// Configure local Draco decoder path
useGLTF.setDecoderPath('/draco/');

export interface VehicleSceneProps {
  paintColor: string;
  isRotating: boolean;
  onControlsReady?: (controls: any) => void;
}

export function VehicleModel({ paintColor }: { paintColor: string }) {
  const groupRef = useRef<THREE.Group>(null);
  const { scene } = useGLTF('/models/car.glb', '/draco/');

  // Clone scene so we can mutate materials safely without cache leaks
  const clonedScene = useMemo(() => {
    return scene.clone(true);
  }, [scene]);

  // Apply high-fidelity PBR automotive materials
  useEffect(() => {
    if (!clonedScene) return;

    clonedScene.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        const mesh = child as THREE.Mesh;
        mesh.castShadow = true;
        mesh.receiveShadow = true;

        const name = (mesh.name || '').toLowerCase();

        // 1. Car Body & Exterior Panels: High-Gloss Clearcoat Automotive Paint
        if (name === 'body') {
          mesh.material = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color(paintColor),
            metalness: 0.88,
            roughness: 0.28,
            clearcoat: 1.0,
            clearcoatRoughness: 0.04,
            reflectivity: 0.9,
          });
        }
        // 2. Windshield & Glass: Physically based transmission
        else if (name === 'glass') {
          mesh.material = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color('#14171a'),
            metalness: 0.1,
            roughness: 0.05,
            transmission: 0.88,
            thickness: 0.5,
            transparent: true,
            opacity: 0.65,
            ior: 1.52,
          });
        }
        // 3. Alloy Rims: Machined metallic finish
        else if (name.startsWith('rim_') || name === 'centre') {
          mesh.material = new THREE.MeshStandardMaterial({
            color: new THREE.Color('#b0b4b8'),
            metalness: 0.94,
            roughness: 0.18,
          });
        }
        // 4. Tires: Matte vulcanized rubber
        else if (name === 'tire') {
          mesh.material = new THREE.MeshStandardMaterial({
            color: new THREE.Color('#111214'),
            metalness: 0.04,
            roughness: 0.88,
          });
        }
        // 5. Exterior Trim, Diffuser & Grilles
        else if (name === 'trim' || name === 'grills' || name === 'wipers' || name === 'plastic_gray') {
          mesh.material = new THREE.MeshStandardMaterial({
            color: new THREE.Color('#16181b'),
            metalness: 0.6,
            roughness: 0.42,
          });
        }
        // 6. Chrome Details & Badging
        else if (name === 'chrome') {
          mesh.material = new THREE.MeshStandardMaterial({
            color: new THREE.Color('#ffffff'),
            metalness: 1.0,
            roughness: 0.08,
          });
        }
        // 7. Carbon Fiber Weave
        else if (name.includes('carbon')) {
          mesh.material = new THREE.MeshStandardMaterial({
            color: new THREE.Color('#121315'),
            metalness: 0.7,
            roughness: 0.35,
          });
        }
        // 8. Headlight projector glass & lenses
        else if (name === 'lights' || name === 'leds') {
          mesh.material = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color('#ffffff'),
            transmission: 0.9,
            roughness: 0.02,
            metalness: 0.1,
          });
        }
        // 9. Taillight red glass
        else if (name === 'lights_red') {
          mesh.material = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color('#8b1008'),
            transmission: 0.75,
            roughness: 0.1,
            metalness: 0.2,
          });
        }
      }
    });
  }, [clonedScene, paintColor]);

  // Gentle subtle breathing movement
  useFrame((state) => {
    if (groupRef.current) {
      const t = state.clock.getElapsedTime();
      // Subtle suspension micro-idle (0.5mm amplitude)
      groupRef.current.position.y = Math.sin(t * 1.5) * 0.003;
    }
  });

  return (
    <group ref={groupRef} position={[0, 0, 0]} dispose={null}>
      <primitive object={clonedScene} />
    </group>
  );
}

export function StudioLighting() {
  return (
    <>
      {/* Warm ambient studio base */}
      <ambientLight intensity={0.4} color="#f0ede6" />

      {/* Main Overhead Softbox Key Light */}
      <directionalLight
        position={[4, 7, 3]}
        intensity={1.8}
        color="#ffffff"
        castShadow
        shadow-mapSize={[1024, 1024]}
        shadow-camera-near={1}
        shadow-camera-far={20}
        shadow-bias={-0.0001}
      />

      {/* Rear High-Contrast Edge/Rim Light (traces vehicle silhouette) */}
      <directionalLight
        position={[-5, 4, -4]}
        intensity={2.2}
        color="#d8dde3"
      />

      {/* Low Warm Under-chassis & Front Quarter Bounce */}
      <directionalLight
        position={[0, -1, 3]}
        intensity={0.3}
        color="#303236"
      />

      {/* Procedural High-Gloss Studio Environment (100% offline, zero-budget) */}
      <Environment resolution={256}>
        {/* Overhead rectangular bank softbox */}
        <Lightformer
          form="rect"
          intensity={2.2}
          position={[0, 6, 0]}
          scale={[10, 4, 1]}
          target={[0, 0, 0]}
        />
        {/* Driver side horizon strip */}
        <Lightformer
          form="rect"
          intensity={1.6}
          position={[-6, 1.8, -1]}
          scale={[14, 0.4, 1]}
          target={[0, 0.5, 0]}
        />
        {/* Passenger side horizon strip */}
        <Lightformer
          form="rect"
          intensity={1.6}
          position={[6, 1.8, 1]}
          scale={[14, 0.4, 1]}
          target={[0, 0.5, 0]}
        />
        {/* Front accent kicker */}
        <Lightformer
          form="circle"
          intensity={1.0}
          position={[0, 2, 6]}
          scale={[4, 4, 1]}
          target={[0, 0.5, 0]}
        />
      </Environment>
    </>
  );
}

export function VehicleScene({ paintColor, isRotating, onControlsReady }: VehicleSceneProps) {
  const controlsRef = useRef<any>(null);

  useEffect(() => {
    if (controlsRef.current && onControlsReady) {
      onControlsReady(controlsRef.current);
    }
  }, [onControlsReady]);

  return (
    <>
      {/* Studio Lighting & Reflections */}
      <StudioLighting />

      {/* 3D Car Model */}
      <VehicleModel paintColor={paintColor} />

      {/* Realistic Ground Contact Shadows */}
      <ContactShadows
        position={[0, 0, 0]}
        opacity={0.75}
        scale={8.5}
        blur={1.6}
        far={3.5}
        resolution={512}
        color="#08080a"
      />

      {/* Subtle Studio Floor Grid (Architectural hairline, non-neon) */}
      <gridHelper
        args={[16, 24, '#26292d', '#181a1d']}
        position={[0, -0.002, 0]}
      />

      {/* Camera Orbit Controls (Constrained for cinematic automotive showcase) */}
      <OrbitControls
        ref={controlsRef}
        enableZoom={false}
        enablePan={false}
        autoRotate={isRotating}
        autoRotateSpeed={0.7}
        minPolarAngle={Math.PI / 3.8} // Prevents awkward top-down view
        maxPolarAngle={Math.PI / 2.04} // Prevents clipping beneath floor
        minDistance={4}
        maxDistance={8}
        target={[0, 0.4, 0]}
        dampingFactor={0.05}
      />
    </>
  );
}

// Preload model with local decoder path for instant rendering
useGLTF.preload('/models/car.glb', '/draco/');

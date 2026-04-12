"use client";

import { useRef, useMemo } from "react";
import { Canvas, useFrame, useLoader } from "@react-three/fiber";
import { Float, MeshDistortMaterial, Stars } from "@react-three/drei";
import * as THREE from "three";

function EmblemPlane() {
  const meshRef = useRef<THREE.Mesh>(null);
  const texture = useLoader(THREE.TextureLoader, "/logo/emblem.png");

  useFrame(({ clock }) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = Math.sin(clock.getElapsedTime() * 0.3) * 0.15;
      meshRef.current.position.y = Math.sin(clock.getElapsedTime() * 0.5) * 0.3;
    }
  });

  return (
    <Float speed={1} rotationIntensity={0.2} floatIntensity={0.8}>
      <mesh ref={meshRef} position={[0, 0, 0]}>
        <planeGeometry args={[3.5, 3.5]} />
        <meshStandardMaterial
          map={texture}
          transparent
          opacity={0.12}
          emissive="#1A6BF5"
          emissiveIntensity={0.4}
          side={THREE.DoubleSide}
        />
      </mesh>
    </Float>
  );
}

function GlowOrb() {
  const meshRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (meshRef.current) {
      meshRef.current.rotation.x = clock.getElapsedTime() * 0.1;
      meshRef.current.rotation.y = clock.getElapsedTime() * 0.15;
    }
  });

  return (
    <Float speed={1.2} rotationIntensity={0.3} floatIntensity={1}>
      <mesh ref={meshRef}>
        <sphereGeometry args={[1.4, 64, 64]} />
        <MeshDistortMaterial
          color="#1A6BF5"
          distort={0.25}
          speed={1.5}
          roughness={0.3}
          metalness={0.9}
          transparent
          opacity={0.5}
        />
      </mesh>
    </Float>
  );
}

function OrbitalRings() {
  const groupRef = useRef<THREE.Group>(null);

  useFrame(({ clock }) => {
    if (groupRef.current) {
      groupRef.current.rotation.z = clock.getElapsedTime() * 0.08;
    }
  });

  return (
    <group ref={groupRef}>
      {[2.2, 2.8, 3.4].map((radius, i) => (
        <mesh key={i} rotation={[Math.PI / 2.5 + i * 0.25, i * 0.2, 0]}>
          <torusGeometry args={[radius, 0.015, 16, 80]} />
          <meshStandardMaterial
            color="#4D8FF7"
            transparent
            opacity={0.25 - i * 0.06}
            emissive="#1A6BF5"
            emissiveIntensity={0.3}
          />
        </mesh>
      ))}
    </group>
  );
}

function ParticleField() {
  const count = 80;
  const meshRef = useRef<THREE.Points>(null);

  const positions = useMemo(() => {
    const pos = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 18;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 18;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 18;
    }
    return pos;
  }, []);

  useFrame(({ clock }) => {
    if (meshRef.current) {
      meshRef.current.rotation.y = clock.getElapsedTime() * 0.015;
    }
  });

  return (
    <points ref={meshRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      <pointsMaterial
        size={0.04}
        color="#4D8FF7"
        transparent
        opacity={0.5}
        sizeAttenuation
      />
    </points>
  );
}

export function HeroScene() {
  return (
    <div className="absolute inset-0 -z-10">
      <Canvas
        camera={{ position: [0, 0, 7], fov: 45 }}
        dpr={[1, 1.5]}
        gl={{ antialias: false, alpha: true, powerPreference: "high-performance" }}
        performance={{ min: 0.5 }}
        style={{ background: "transparent" }}
      >
        <ambientLight intensity={0.3} />
        <directionalLight position={[5, 5, 5]} intensity={0.8} />
        <pointLight position={[-4, -4, 4]} intensity={0.4} color="#4D8FF7" />
        <pointLight position={[4, 2, -3]} intensity={0.3} color="#8B5CF6" />
        <EmblemPlane />
        <GlowOrb />
        <OrbitalRings />
        <ParticleField />
        <Stars
          radius={40}
          depth={40}
          count={400}
          factor={2.5}
          saturation={0}
          fade
          speed={0.3}
        />
      </Canvas>
    </div>
  );
}

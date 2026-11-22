'use client';

import React from 'react';
import Link from 'next/link';
import { Navbar } from '@/components/shared/navbar';
import { 
  ArrowRight, 
  MapPin, 
  Compass, 
  Radio, 
  ShieldCheck, 
  Clock, 
  ArrowUpRight 
} from 'lucide-react';
import { VehicleHero3D } from '@/components/hero/vehicle-hero-3d';
import { RobustImage } from '@/components/shared/robust-image';

export default function EditorialLandingPage() {
  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1">
        {/* ================================================================= */}
        {/* 1. CINEMATIC ASYMMETRIC HERO SECTION (WIDE EXPANSIVE LAYOUT)       */}
        {/* ================================================================= */}
        <section className="relative border-b border-divider/60 pt-16 pb-24 lg:pt-20 lg:pb-32 overflow-hidden">
          <div className="layout-container">
            <div className="grid lg:grid-cols-12 gap-12 lg:gap-12 xl:gap-16 items-center">
              
              {/* Editorial Typography Column (Left: 6 cols) */}
              <div className="lg:col-span-6 space-y-8">
                <div className="inline-flex items-center gap-3">
                  <span className="w-1.5 h-1.5 rounded-full bg-crimson" />
                  <span className="text-[11px] font-mono tracking-widest uppercase text-stone-muted">
                    Automotive Emergency Dispatch Protocol
                  </span>
                </div>

                <div className="space-y-5">
                  <h1 className="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-medium tracking-tightest text-porcelain leading-[1.05]">
                    Precision Roadside Rescue. <br />
                    <span className="text-stone-muted font-normal">
                      Zero Friction.
                    </span>
                  </h1>
                  
                  <p className="text-stone-muted text-base sm:text-lg lg:text-xl leading-relaxed max-w-xl xl:max-w-2xl font-normal pt-1">
                    An open-source assistance architecture bridging stranded drivers and certified field mechanics through high-accuracy spherical trigonometry and live telemetry.
                  </p>
                </div>

                {/* Primary Restrained Call-to-Actions */}
                <div className="pt-2 flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                  <Link
                    href="/login?redirect=/report-breakdown"
                    className="inline-flex items-center justify-center gap-2.5 px-7 py-4 rounded-sm bg-crimson hover:bg-crimson-hover active:bg-crimson text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    <span>Request Emergency Assistance</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>

                  <Link
                    href="/login?role=MECHANIC"
                    className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-graphite hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    <span>Mechanic Terminal</span>
                  </Link>
                </div>

                {/* Editorial Telemetry Bar */}
                <div className="pt-10 border-t border-divider/40 grid grid-cols-3 gap-6 sm:gap-8 text-left">
                  <div>
                    <div className="text-2xl font-mono font-medium text-porcelain tracking-tight">4.2 min</div>
                    <div className="text-[11px] font-mono text-stone-dim uppercase tracking-wider mt-1">Average Dispatch</div>
                  </div>
                  <div>
                    <div className="text-2xl font-mono font-medium text-porcelain tracking-tight">&lt; 50ms</div>
                    <div className="text-[11px] font-mono text-stone-dim uppercase tracking-wider mt-1">Haversine Vector</div>
                  </div>
                  <div>
                    <div className="text-2xl font-mono font-medium text-porcelain tracking-tight">100%</div>
                    <div className="text-[11px] font-mono text-stone-dim uppercase tracking-wider mt-1">ASE Vetted Network</div>
                  </div>
                </div>
              </div>

              {/* 3D Realtime Automotive Hero Showcase (Right: 6 cols - Proportional Expansion) */}
              <div className="lg:col-span-6">
                <VehicleHero3D />
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 2. ARCHITECTURAL PROTOCOL: HOW IT WORKS (WIDE 3-COLUMN LAYOUT)    */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 pb-14 border-b border-divider/40">
              <div className="space-y-2">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  System Architecture
                </span>
                <h2 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
                  Roadside Incident Resolution Protocol
                </h2>
              </div>
              <p className="text-sm font-normal text-stone-muted max-w-lg leading-relaxed">
                Three deterministic stages designed to eliminate communication ambiguity during mechanical breakdown emergencies.
              </p>
            </div>

            <div className="grid md:grid-cols-3 divide-y md:divide-y-0 md:divide-x divide-divider/60 pt-8">
              
              {/* Step 1 */}
              <div className="pt-8 md:pt-0 md:pr-10 lg:pr-12 xl:pr-16 space-y-4">
                <div className="font-mono text-xs text-stone-dim">01 // INTAKE</div>
                <h3 className="text-xl font-medium text-porcelain">Coordinate Pinpointing & Fault Categorization</h3>
                <p className="text-sm text-stone-muted leading-relaxed font-normal">
                  Immediate acquisition of device GPS coordinates paired with an interactive Leaflet fallback pin. The driver selects symptoms from a standardized automotive matrix with optional damage imagery.
                </p>
                <div className="pt-2 font-mono text-[11px] text-stone-dim flex items-center gap-2">
                  <span className="w-1 h-1 bg-stone-muted rounded-full" />
                  <span>Sub-second coordinate resolution</span>
                </div>
              </div>

              {/* Step 2 */}
              <div className="pt-8 md:pt-0 md:px-10 lg:px-12 xl:px-16 space-y-4">
                <div className="font-mono text-xs text-stone-dim">02 // DISCOVERY</div>
                <h3 className="text-xl font-medium text-porcelain">Haversine Great-Circle Proximity Calculation</h3>
                <p className="text-sm text-stone-muted leading-relaxed font-normal">
                  The backend executes pure trigonometric spherical distance calculations directly in PostgreSQL without proprietary mapping fees, querying active technicians within the configurable operational radius.
                </p>
                <div className="pt-2 font-mono text-[11px] text-stone-dim flex items-center gap-2">
                  <span className="w-1 h-1 bg-stone-muted rounded-full" />
                  <span>Zero paid third-party API dependencies</span>
                </div>
              </div>

              {/* Step 3 */}
              <div className="pt-8 md:pt-0 md:pl-10 lg:pl-12 xl:pl-16 space-y-4">
                <div className="font-mono text-xs text-stone-dim">03 // RESOLUTION</div>
                <h3 className="text-xl font-medium text-porcelain">Bidirectional Telemetry & Service Sign-off</h3>
                <p className="text-sm text-stone-muted leading-relaxed font-normal">
                  Socket.IO WebSocket rooms stream the technician’s en-route position live to the customer’s terminal. State transitions are immutably logged until verified on-site service completion.
                </p>
                <div className="pt-2 font-mono text-[11px] text-stone-dim flex items-center gap-2">
                  <span className="w-1 h-1 bg-sage-light rounded-full" />
                  <span>Validated lifecycle state machine</span>
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 3. CRAFT & PHOTOGRAPHY EDITORIAL SECTION                          */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-graphite/30">
          <div className="layout-container">
            <div className="grid lg:grid-cols-12 gap-12 lg:gap-14 xl:gap-20 items-center">
              
              <div className="lg:col-span-5 space-y-6">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  Craft & Capability
                </span>
                <h2 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain leading-tight">
                  Engineered for Automotive Integrity
                </h2>
                <p className="text-sm lg:text-base text-stone-muted leading-relaxed font-normal">
                  From flat tires and high-voltage electric powertrain faults to emergency flatbed winch extractions, every technician registered on the VBRS platform undergoes trade credential and master certification vetting before dispatch eligibility.
                </p>

                <div className="pt-4 space-y-3 font-mono text-xs text-stone-muted">
                  <div className="flex items-center gap-3 pb-3 border-b border-divider/60">
                    <span className="text-porcelain">01</span>
                    <span className="text-porcelain font-sans font-medium text-sm">Mechanical Powertrain Diagnostics</span>
                    <span className="ml-auto text-stone-dim">ICE & Hybrid</span>
                  </div>
                  <div className="flex items-center gap-3 pb-3 border-b border-divider/60">
                    <span className="text-porcelain">02</span>
                    <span className="text-porcelain font-sans font-medium text-sm">High-Voltage EV Roadside Safe Triage</span>
                    <span className="ml-auto text-stone-dim">400V - 800V</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-porcelain">03</span>
                    <span className="text-porcelain font-sans font-medium text-sm">Heavy Flatbed & Winch Recovery</span>
                    <span className="ml-auto text-stone-dim">Low-Clearance</span>
                  </div>
                </div>
              </div>

              <div className="lg:col-span-7">
                <div className="grid grid-cols-2 gap-5 lg:gap-6">
                  <div className="border border-divider p-2 bg-graphite/60 shadow-architectural">
                    <RobustImage
                      src="/images/mechanic-engine.jpg"
                      fallbackSrc="/images/mechanic-engine-fallback.jpg"
                      alt="Mechanic inspecting vehicle engine bay"
                      className="w-full aspect-[4/5] object-cover grayscale-[30%] contrast-[105%]"
                    />
                  </div>
                  <div className="border border-divider p-2 bg-graphite/60 shadow-architectural mt-10">
                    <RobustImage
                      src="/images/vehicle-rear.jpg"
                      fallbackSrc="/images/mechanic-engine-fallback.jpg"
                      alt="Automotive rear profile in dusk setting"
                      className="w-full aspect-[4/5] object-cover grayscale-[20%] contrast-[110%]"
                    />
                  </div>
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 4. NETWORK RADAR OVERVIEW (WIDE CONTAINER)                        */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="border border-divider bg-graphite/50 p-8 sm:p-12 lg:p-16 shadow-elevated">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-8 pb-10 border-b border-divider/60">
                <div className="space-y-1">
                  <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim block">
                    Coverage Spectrum
                  </span>
                  <h2 className="text-2xl sm:text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
                    Autonomous Dispatch Readiness
                  </h2>
                </div>

                <div className="flex items-center gap-4 text-xs font-mono uppercase tracking-wider shrink-0">
                  <Link
                    href="/customer/vehicles"
                    className="px-6 py-3 rounded-sm bg-porcelain text-carbon font-medium hover:bg-porcelain-dim transition-colors"
                  >
                    Open My Garage
                  </Link>
                  <Link
                    href="/login?role=MECHANIC"
                    className="px-6 py-3 rounded-sm border border-divider text-stone-muted hover:text-porcelain transition-colors"
                  >
                    Mechanic Portal
                  </Link>
                </div>
              </div>

              <div className="pt-10 grid grid-cols-2 md:grid-cols-4 gap-8 font-mono text-xs">
                <div>
                  <div className="text-stone-dim uppercase">Active DB Engine</div>
                  <div className="text-porcelain font-medium text-base mt-1.5">PostgreSQL 18 Local</div>
                </div>
                <div>
                  <div className="text-stone-dim uppercase">Distance Metric</div>
                  <div className="text-porcelain font-medium text-base mt-1.5">Great-Circle Haversine</div>
                </div>
                <div>
                  <div className="text-stone-dim uppercase">Cost Model</div>
                  <div className="text-porcelain font-medium text-base mt-1.5">$0.00 / 100% FOSS</div>
                </div>
                <div>
                  <div className="text-stone-dim uppercase">API Specification</div>
                  <div className="text-porcelain font-medium text-base mt-1.5">OpenAPI 3.0 (NestJS)</div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* ================================================================= */}
      {/* 5. MINIMALIST ARCHITECTURAL FOOTER                                */}
      {/* ================================================================= */}
      <footer className="py-14 bg-carbon border-t border-divider/40 text-stone-dim text-xs font-mono">
        <div className="layout-container flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
          <div className="space-y-1">
            <span className="text-porcelain block font-sans font-medium text-sm">
              Vehicle Breakdown Reporting System (VBRS)
            </span>
            <span>Architectural Roadside Emergency Assistance Network</span>
          </div>

          <div className="flex items-center gap-6 uppercase tracking-wider text-[11px]">
            <a href="http://localhost:4000/api/docs" target="_blank" rel="noreferrer" className="hover:text-porcelain transition-colors">
              Swagger Documentation
            </a>
            <span className="text-divider">•</span>
            <Link href="/login" className="hover:text-porcelain transition-colors">
              Access Terminal
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}

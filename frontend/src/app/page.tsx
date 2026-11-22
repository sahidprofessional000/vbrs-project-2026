'use client';

import React from 'react';
import Link from 'next/link';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { 
  ArrowRight, 
  MapPin, 
  Compass, 
  Radio, 
  ShieldCheck, 
  Clock, 
  ArrowUpRight,
  Car,
  Wrench,
  ShieldAlert,
  Layers,
  Box,
  CheckCircle2
} from 'lucide-react';
import { InspectionTerminal } from '@/components/hologram/inspection-terminal';
import { RobustImage } from '@/components/shared/robust-image';

export default function EditorialLandingPage() {
  const { user } = useAuth();

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

                {/* Role-Aware Call-to-Actions */}
                <div className="pt-2 flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                  {user?.role === 'CUSTOMER' ? (
                    <>
                      <Link
                        href="/customer/home"
                        className="inline-flex items-center justify-center gap-2.5 px-7 py-4 rounded-sm bg-porcelain text-carbon hover:bg-porcelain-dim font-medium text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Open Driver Workspace</span>
                        <ArrowRight className="w-3.5 h-3.5" />
                      </Link>

                      <Link
                        href="/report-breakdown"
                        className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-crimson hover:bg-crimson-hover text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <ShieldAlert className="w-3.5 h-3.5" />
                        <span>Request Rescue</span>
                      </Link>
                    </>
                  ) : user?.role === 'MECHANIC' ? (
                    <>
                      <Link
                        href="/mechanic/home"
                        className="inline-flex items-center justify-center gap-2.5 px-7 py-4 rounded-sm bg-porcelain text-carbon hover:bg-porcelain-dim font-medium text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Open Mechanic Workshop</span>
                        <ArrowRight className="w-3.5 h-3.5" />
                      </Link>

                      <Link
                        href="/mechanic/portal"
                        className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-graphite hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <Radio className="w-3.5 h-3.5 text-cyan-400" />
                        <span>Dispatch Radar</span>
                      </Link>
                    </>
                  ) : (
                    <>
                      <Link
                        href="/login?role=CUSTOMER&redirect=/customer/home"
                        className="inline-flex items-center justify-center gap-2.5 px-7 py-4 rounded-sm bg-crimson hover:bg-crimson-hover active:bg-crimson text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Request Emergency Assistance</span>
                        <ArrowRight className="w-3.5 h-3.5" />
                      </Link>

                      <Link
                        href="/login?role=MECHANIC&redirect=/mechanic/home"
                        className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-graphite hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Mechanic Terminal</span>
                      </Link>
                    </>
                  )}
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

              {/* Interactive 3D Automotive Hologram (Right: 6 cols - Proportional Expansion) */}
              <div className="lg:col-span-6">
                <div id="overview-hologram">
                  <InspectionTerminal variant="overview" />
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 2. DEDICATED ARCHITECTURAL EXPERIENCES: CUSTOMER VS MECHANIC      */}
        {/* ================================================================= */}
        <section id="portal-gateways" className="py-20 lg:py-24 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 pb-12 border-b border-divider/40">
              <div className="space-y-2">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  01 // Dedicated Architectural Experiences
                </span>
                <h2 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
                  Two Specialized Automotive Portals
                </h2>
              </div>
              <p className="text-sm font-normal text-stone-muted max-w-lg leading-relaxed">
                Separated user journeys engineered for respective operational demands. Stranded drivers access rapid GPS intake; certified mechanics command diagnostic telemetry.
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-8 pt-10">
              
              {/* Customer Gateway Card */}
              <div id="customer-gateway" className="border border-divider/80 bg-graphite/40 p-8 sm:p-10 rounded-sm flex flex-col justify-between space-y-8 relative overflow-hidden group hover:border-divider-strong transition-colors">
                <div className="space-y-6">
                  <div className="flex items-center justify-between">
                    <div className="w-10 h-10 rounded-sm bg-crimson/10 border border-crimson/30 flex items-center justify-center text-crimson">
                      <Car className="w-5 h-5" />
                    </div>
                    <span className="text-[10px] font-mono uppercase tracking-wider px-2.5 py-1 rounded-sm bg-elevated border border-divider text-stone-muted">
                      ROUTE: /customer/home
                    </span>
                  </div>

                  <div className="space-y-2">
                    <h3 className="text-2xl font-medium text-porcelain tracking-tight">
                      Customer & Driver Experience
                    </h3>
                    <p className="text-sm text-stone-muted leading-relaxed font-normal">
                      Designed for individual motorists and fleet managers requiring frictionless emergency breakdown intake, real-time live map tracking, and comprehensive vehicle service history.
                    </p>
                  </div>

                  <div className="space-y-2.5 pt-2 border-t border-divider/40 text-xs font-mono text-stone-muted">
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-crimson" />
                      <span>One-Click GPS Pinpoint & Emergency Breakdown Intake</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Registered Automobile Garage (ICE, Hybrid, 800V EV)</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Real-Time Leaflet Map Tracking with ETA Stepper</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Saved Dispatch Location Bookmarks (Home, Hub, Fleet)</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Itemized Cost Invoices & 5-Star Technician Reviews</span>
                    </div>
                  </div>
                </div>

                <div className="pt-4 border-t border-divider/40 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                  {user?.role === 'CUSTOMER' ? (
                    <Link
                      href="/customer/home"
                      className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm bg-crimson hover:bg-crimson-hover text-porcelain text-xs font-mono uppercase tracking-wider font-medium transition-colors"
                    >
                      <span>Launch Customer Workspace</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  ) : user?.role === 'MECHANIC' ? (
                    <div className="text-[11px] font-mono text-stone-dim flex items-center gap-2 py-2">
                      <span className="w-2 h-2 rounded-full bg-ochre" />
                      <span>Active session: Field Mechanic (Restricted)</span>
                    </div>
                  ) : (
                    <>
                      <Link
                        href="/login?role=CUSTOMER&redirect=/customer/home"
                        className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm bg-porcelain hover:bg-porcelain-dim text-carbon text-xs font-mono uppercase tracking-wider font-medium transition-colors"
                      >
                        <span>Driver Sign In</span>
                        <ArrowRight className="w-3.5 h-3.5" />
                      </Link>
                      <Link
                        href="/report-breakdown"
                        className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm border border-divider text-stone-muted hover:text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Emergency Intake</span>
                      </Link>
                    </>
                  )}
                </div>
              </div>

              {/* Mechanic Gateway Card */}
              <div id="mechanic-gateway" className="border border-divider/80 bg-graphite/40 p-8 sm:p-10 rounded-sm flex flex-col justify-between space-y-8 relative overflow-hidden group hover:border-divider-strong transition-colors">
                <div className="space-y-6">
                  <div className="flex items-center justify-between">
                    <div className="w-10 h-10 rounded-sm bg-cyan-950/40 border border-cyan-800/40 flex items-center justify-center text-cyan-400">
                      <Wrench className="w-5 h-5" />
                    </div>
                    <span className="text-[10px] font-mono uppercase tracking-wider px-2.5 py-1 rounded-sm bg-elevated border border-divider text-stone-muted">
                      ROUTE: /mechanic/home
                    </span>
                  </div>

                  <div className="space-y-2">
                    <h3 className="text-2xl font-medium text-porcelain tracking-tight">
                      Mechanic Workspace & CAD Terminal
                    </h3>
                    <p className="text-sm text-stone-muted leading-relaxed font-normal">
                      A comprehensive operating desk for certified field technicians and workshops, featuring real-time Haversine dispatch discovery and 3D digital twin diagnostics.
                    </p>
                  </div>

                  <div className="space-y-2.5 pt-2 border-t border-divider/40 text-xs font-mono text-stone-muted">
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-cyan-400" />
                      <span>Interactive 3D Holographic Twin with 8 Subsystems</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>10-100km Operational Perimeter & Haversine Proximity</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Real Recorded Financials (Revenue, Labor, Parts, AOV)</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>Active Mission Control with Quotation Intake & Stepper</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-stone-muted" />
                      <span>ASE Accreditation & Automated Audit Governance</span>
                    </div>
                  </div>
                </div>

                <div className="pt-4 border-t border-divider/40 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                  {user?.role === 'MECHANIC' ? (
                    <Link
                      href="/mechanic/home"
                      className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm bg-cyan-600 hover:bg-cyan-500 text-porcelain text-xs font-mono uppercase tracking-wider font-medium transition-colors"
                    >
                      <span>Launch Mechanic Workshop</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  ) : user?.role === 'CUSTOMER' ? (
                    <div className="text-[11px] font-mono text-stone-dim flex items-center gap-2 py-2">
                      <span className="w-2 h-2 rounded-full bg-ochre" />
                      <span>Active session: Driver / Motorist (Restricted)</span>
                    </div>
                  ) : (
                    <>
                      <Link
                        href="/login?role=MECHANIC&redirect=/mechanic/home"
                        className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm bg-porcelain hover:bg-porcelain-dim text-carbon text-xs font-mono uppercase tracking-wider font-medium transition-colors"
                      >
                        <span>Technician Sign In</span>
                        <ArrowRight className="w-3.5 h-3.5" />
                      </Link>
                      <Link
                        href="/register?role=MECHANIC"
                        className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-sm border border-divider text-stone-muted hover:text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
                      >
                        <span>Accreditation Intake</span>
                      </Link>
                    </>
                  )}
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 3. ARCHITECTURAL PROTOCOL: HOW IT WORKS (WIDE 3-COLUMN LAYOUT)    */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 pb-14 border-b border-divider/40">
              <div className="space-y-2">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  02 // System Architecture
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
        {/* 4. CRAFT & PHOTOGRAPHY EDITORIAL SECTION                          */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-graphite/30">
          <div className="layout-container">
            <div className="grid lg:grid-cols-12 gap-12 lg:gap-14 xl:gap-20 items-center">
              
              <div className="lg:col-span-5 space-y-6">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  03 // Craft & Capability
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
        {/* 5. NETWORK RADAR OVERVIEW (WIDE CONTAINER)                        */}
        {/* ================================================================= */}
        <section className="py-24 lg:py-28 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="border border-divider bg-graphite/50 p-8 sm:p-12 lg:p-16 shadow-elevated">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-8 pb-10 border-b border-divider/60">
                <div className="space-y-1">
                  <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim block">
                    04 // Coverage Spectrum
                  </span>
                  <h2 className="text-2xl sm:text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
                    Autonomous Dispatch Readiness
                  </h2>
                </div>

                <div className="flex items-center gap-4 text-xs font-mono uppercase tracking-wider shrink-0">
                  <Link
                    href={user?.role === 'CUSTOMER' ? '/customer/home' : '/login?role=CUSTOMER&redirect=/customer/home'}
                    className="px-6 py-3 rounded-sm bg-porcelain text-carbon font-medium hover:bg-porcelain-dim transition-colors"
                  >
                    Driver Portal
                  </Link>
                  <Link
                    href={user?.role === 'MECHANIC' ? '/mechanic/home' : '/login?role=MECHANIC&redirect=/mechanic/home'}
                    className="px-6 py-3 rounded-sm border border-divider text-stone-muted hover:text-porcelain transition-colors"
                  >
                    Mechanic Workshop
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
      {/* 6. MINIMALIST ARCHITECTURAL FOOTER                                */}
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

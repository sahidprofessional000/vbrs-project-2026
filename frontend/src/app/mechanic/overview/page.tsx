'use client';

import React from 'react';
import Link from 'next/link';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { MechanicHologramViewer } from '@/components/vehicle/mechanic-hologram-viewer';
import {
  Wrench,
  Radio,
  Sliders,
  ShieldCheck,
  ArrowRight,
  Cpu,
  Layers,
  ChevronRight,
  Activity,
  Box,
  Compass
} from 'lucide-react';

export default function MechanicOverviewPage() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1">
        {/* ================================================================= */}
        {/* 1. CINEMATIC MECHANIC HERO WITH 3D AUTOMOTIVE HOLOGRAM            */}
        {/* ================================================================= */}
        <section className="relative border-b border-divider/60 pt-12 pb-20 lg:pt-16 lg:pb-28 overflow-hidden">
          <div className="layout-container">
            <div className="grid lg:grid-cols-12 gap-10 lg:gap-12 items-center">
              
              {/* Left Column: Mechanic Hero Editorial Telemetry (6 cols) */}
              <div className="lg:col-span-6 space-y-8">
                <div className="space-y-4">
                  <div className="inline-flex items-center gap-2.5 px-3 py-1 bg-graphite border border-divider rounded-sm text-[11px] font-mono tracking-widest uppercase text-stone-muted">
                    <span className="w-2 h-2 rounded-full bg-cyan-400 animate-pulse" />
                    <span>Technician Inspection Hub // Digital Twin</span>
                  </div>

                  <h1 className="text-4xl sm:text-5xl lg:text-5xl font-medium tracking-tight text-porcelain leading-[1.08]">
                    Precision Roadside Rescue.{' '}
                    <span className="text-stone-dim font-normal block sm:inline">Zero Friction.</span>
                  </h1>

                  <p className="text-sm sm:text-base text-stone-muted font-normal leading-relaxed max-w-xl">
                    Interactive CAD digital twin inspection station with 8 individually selectable automotive assemblies,
                    SAE diagnostic trouble codes, and real-time field triage telemetry.
                  </p>
                </div>

                {/* Primary Mechanic Action CTAs */}
                <div className="flex flex-wrap items-center gap-4 pt-2">
                  <Link
                    href="/mechanic/home"
                    className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-porcelain hover:bg-porcelain-dim text-carbon font-medium text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    <Wrench className="w-3.5 h-3.5" />
                    <span>Open Workshop Terminal</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>

                  <Link
                    href="/mechanic/portal"
                    className="inline-flex items-center justify-center gap-2 px-7 py-4 rounded-sm bg-graphite hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    <Radio className="w-3.5 h-3.5" />
                    <span>Dispatch Radar Matrix</span>
                  </Link>

                  <Link
                    href="/mechanic/profile"
                    className="inline-flex items-center justify-center gap-2 px-6 py-4 rounded-sm border border-divider/60 hover:border-divider text-stone-muted hover:text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
                  >
                    <ShieldCheck className="w-3.5 h-3.5" />
                    <span>Credentials & Bio</span>
                  </Link>
                </div>

                {/* Mechanic Telemetry Strip */}
                <div className="pt-8 border-t border-divider/40 grid grid-cols-3 gap-6 text-left font-mono">
                  <div>
                    <div className="text-2xl font-medium text-porcelain tracking-tight">8</div>
                    <div className="text-[11px] text-stone-dim uppercase tracking-wider mt-1">CAD Assemblies</div>
                  </div>
                  <div>
                    <div className="text-2xl font-medium text-porcelain tracking-tight">&lt; 15 min</div>
                    <div className="text-[11px] text-stone-dim uppercase tracking-wider mt-1">Arrival Target</div>
                  </div>
                  <div>
                    <div className="text-2xl font-medium text-porcelain tracking-tight">100%</div>
                    <div className="text-[11px] text-stone-dim uppercase tracking-wider mt-1">Verified Orders</div>
                  </div>
                </div>
              </div>

              {/* Right Column: Interactive 3D Automotive Hologram (6 cols) */}
              <div className="lg:col-span-6">
                <div id="mechanic-overview-hologram">
                  <MechanicHologramViewer variant="overview" />
                </div>
              </div>

            </div>
          </div>
        </section>

        {/* ================================================================= */}
        {/* 2. SUBASSEMBLY CAPABILITIES PROTOCOL                               */}
        {/* ================================================================= */}
        <section className="py-20 lg:py-24 border-b border-divider/60 bg-carbon">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 pb-12 border-b border-divider/40">
              <div className="space-y-2">
                <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                  Automotive Digital Twin Architecture
                </span>
                <h2 className="text-3xl font-medium tracking-tight text-porcelain">
                  Eight Selectable Engineering Subsystems
                </h2>
              </div>

              <Link
                href="/mechanic/home#inspection-terminal"
                className="text-xs font-mono uppercase tracking-wider text-stone-muted hover:text-porcelain inline-flex items-center gap-1.5 transition-colors"
              >
                <span>Full Workshop CAD Station</span>
                <ChevronRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            <div className="grid md:grid-cols-4 gap-6 pt-12">
              <div className="p-6 border border-divider/60 bg-graphite/40 rounded-sm space-y-3">
                <div className="w-8 h-8 rounded-sm bg-carbon border border-divider flex items-center justify-center text-porcelain font-mono text-xs">
                  01
                </div>
                <h3 className="text-base font-medium text-porcelain">Powertrain & Engine</h3>
                <p className="text-xs text-stone-muted leading-relaxed font-mono">
                  V8 cylinder block, cylinder heads, intake plenum, and serpentine pulley geometry with compression triage.
                </p>
              </div>

              <div className="p-6 border border-divider/60 bg-graphite/40 rounded-sm space-y-3">
                <div className="w-8 h-8 rounded-sm bg-carbon border border-divider flex items-center justify-center text-porcelain font-mono text-xs">
                  02
                </div>
                <h3 className="text-base font-medium text-porcelain">High-Voltage Battery</h3>
                <p className="text-xs text-stone-muted leading-relaxed font-mono">
                  Reinforced 12V AGM and HV pack enclosure, brass terminals, and high-voltage orange shielded busbars.
                </p>
              </div>

              <div className="p-6 border border-divider/60 bg-graphite/40 rounded-sm space-y-3">
                <div className="w-8 h-8 rounded-sm bg-carbon border border-divider flex items-center justify-center text-porcelain font-mono text-xs">
                  03
                </div>
                <h3 className="text-base font-medium text-porcelain">Dual-Clutch Gearbox</h3>
                <p className="text-xs text-stone-muted leading-relaxed font-mono">
                  7-speed DCT transmission casing, bell housing, differential hub, and dual drive half-shafts with CV boots.
                </p>
              </div>

              <div className="p-6 border border-divider/60 bg-graphite/40 rounded-sm space-y-3">
                <div className="w-8 h-8 rounded-sm bg-carbon border border-divider flex items-center justify-center text-porcelain font-mono text-xs">
                  04
                </div>
                <h3 className="text-base font-medium text-porcelain">Carbon-Ceramic Braking</h3>
                <p className="text-xs text-stone-muted leading-relaxed font-mono">
                  4-corner cross-drilled rotor discs and aluminum monobloc calipers with hydraulic line integrity monitoring.
                </p>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}

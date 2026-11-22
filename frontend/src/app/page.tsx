'use client';

import React from 'react';
import Link from 'next/link';
import { 
  ShieldAlert, 
  Wrench, 
  MapPin, 
  Radio, 
  CheckCircle2, 
  Clock, 
  Car, 
  ArrowRight,
  ShieldCheck,
  Zap,
  Activity,
  Layers,
  PhoneCall
} from 'lucide-react';

export default function LandingPage() {
  return (
    <div className="min-h-screen flex flex-col bg-slate-950 text-slate-100">
      {/* Top Navigation */}
      <header className="border-b border-slate-850 bg-slate-950/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-rose-600 to-amber-600 flex items-center justify-center shadow-lg shadow-rose-950/50">
              <ShieldAlert className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-bold tracking-tight text-lg text-white">VBRS</span>
              <span className="text-xs text-slate-400 block -mt-1 font-mono tracking-wider">RESCUE RADAR</span>
            </div>
          </div>

          <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-slate-300">
            <a href="#how-it-works" className="hover:text-white transition-colors">How It Works</a>
            <a href="#coverage" className="hover:text-white transition-colors">Network Map</a>
            <a href="#architecture" className="hover:text-white transition-colors">Architecture</a>
            <a href="http://localhost:4000/api/docs" target="_blank" rel="noreferrer" className="text-sky-400 hover:text-sky-300 transition-colors">Swagger API</a>
          </nav>

          <div className="flex items-center gap-3">
            <Link 
              href="/login" 
              className="text-sm px-4 py-2 rounded-lg text-slate-300 hover:text-white hover:bg-slate-900 border border-transparent hover:border-slate-800 transition-all font-medium"
            >
              Sign In
            </Link>
            <Link 
              href="/register" 
              className="text-sm px-4 py-2 rounded-lg bg-sky-600 hover:bg-sky-500 text-white font-medium shadow-sm transition-all"
            >
              Get Started
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1">
        <section className="relative pt-20 pb-28 overflow-hidden">
          {/* Subtle background glow */}
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[350px] bg-sky-600/10 blur-[130px] pointer-events-none rounded-full" />
          <div className="absolute top-1/3 left-1/4 w-[300px] h-[300px] bg-rose-600/10 blur-[120px] pointer-events-none rounded-full" />

          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
            {/* Live Status Pill */}
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-slate-900/90 border border-slate-800 text-xs font-mono text-emerald-400 mb-8 shadow-inner">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
              <span>RADAR ACTIVE: 100% OPEN-SOURCE & FREE TO USE</span>
            </div>

            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white max-w-4xl mx-auto leading-tight">
              Roadside Emergency Assistance <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-sky-400 via-teal-300 to-amber-300">
                Dispatched in Real-Time
              </span>
            </h1>

            <p className="mt-6 text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto font-normal leading-relaxed">
              Stranded with engine trouble, a flat tire, or a dead battery? VBRS instantly connects you with nearby certified mechanics using high-precision GPS and zero-cost open telemetry.
            </p>

            {/* Main Action CTAs */}
            <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4 max-w-md mx-auto">
              <Link
                href="/report-breakdown"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-7 py-3.5 rounded-xl bg-rose-600 hover:bg-rose-500 active:bg-rose-700 text-white font-semibold shadow-lg shadow-rose-950/40 transition-all text-base group"
              >
                <ShieldAlert className="w-5 h-5 group-hover:scale-110 transition-transform" />
                <span>Report Breakdown Now</span>
              </Link>

              <Link
                href="/mechanic/portal"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-xl bg-slate-850 hover:bg-slate-800 text-slate-200 border border-slate-700/80 font-medium transition-all text-base"
              >
                <Wrench className="w-5 h-5 text-sky-400" />
                <span>Mechanic Terminal</span>
              </Link>
            </div>

            {/* Quick Metrics Bar */}
            <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-4 max-w-4xl mx-auto text-left">
              <div className="p-4 rounded-xl bg-slate-900/60 border border-slate-850">
                <div className="flex items-center gap-2 text-slate-400 text-xs font-mono uppercase tracking-wider">
                  <Clock className="w-4 h-4 text-sky-400" />
                  <span>Avg Dispatch</span>
                </div>
                <div className="text-2xl font-bold text-white mt-1">4.2 min</div>
                <div className="text-xs text-slate-500 mt-0.5">Automated radial dispatch</div>
              </div>

              <div className="p-4 rounded-xl bg-slate-900/60 border border-slate-850">
                <div className="flex items-center gap-2 text-slate-400 text-xs font-mono uppercase tracking-wider">
                  <ShieldCheck className="w-4 h-4 text-emerald-400" />
                  <span>Verified Pros</span>
                </div>
                <div className="text-2xl font-bold text-white mt-1">100%</div>
                <div className="text-xs text-slate-500 mt-0.5">ASE & license vetted</div>
              </div>

              <div className="p-4 rounded-xl bg-slate-900/60 border border-slate-850">
                <div className="flex items-center gap-2 text-slate-400 text-xs font-mono uppercase tracking-wider">
                  <MapPin className="w-4 h-4 text-amber-400" />
                  <span>Haversine GIS</span>
                </div>
                <div className="text-2xl font-bold text-white mt-1">&lt; 50ms</div>
                <div className="text-xs text-slate-500 mt-0.5">Zero-cost math formula</div>
              </div>

              <div className="p-4 rounded-xl bg-slate-900/60 border border-slate-850">
                <div className="flex items-center gap-2 text-slate-400 text-xs font-mono uppercase tracking-wider">
                  <Radio className="w-4 h-4 text-indigo-400" />
                  <span>Telemetry</span>
                </div>
                <div className="text-2xl font-bold text-white mt-1">WebSocket</div>
                <div className="text-xs text-slate-500 mt-0.5">Real-time driver beaconing</div>
              </div>
            </div>
          </div>
        </section>

        {/* Portals Showcase Section */}
        <section className="py-20 bg-slate-900/30 border-t border-slate-850" id="portals">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-2xl mx-auto mb-16">
              <h2 className="text-3xl font-bold tracking-tight text-white">Three Specialized Operational Hubs</h2>
              <p className="mt-3 text-slate-400">
                Built specifically for distressed drivers, field mechanics, and central fleet dispatchers.
              </p>
            </div>

            <div className="grid md:grid-cols-3 gap-8">
              {/* Customer Hub Card */}
              <div className="rounded-2xl bg-slate-900/80 border border-slate-800 p-7 flex flex-col justify-between hover:border-slate-700 transition-all group">
                <div>
                  <div className="w-12 h-12 rounded-xl bg-sky-950/70 border border-sky-800/60 text-sky-400 flex items-center justify-center mb-5">
                    <Car className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-semibold text-white">Customer Portal</h3>
                  <p className="text-slate-400 text-sm mt-2 leading-relaxed">
                    Garage vehicle registry, one-touch breakdown submission, live en-route mechanic map tracking, and fair ratings.
                  </p>
                  <ul className="mt-5 space-y-2 text-xs text-slate-300">
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-emerald-400" /> GPS and manual Leaflet pin-drop
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-emerald-400" /> Multi-photo damage uploads
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-emerald-400" /> Real-time status progression
                    </li>
                  </ul>
                </div>
                <div className="mt-8 pt-5 border-t border-slate-800/80">
                  <Link 
                    href="/customer/dashboard" 
                    className="inline-flex items-center gap-2 text-sm font-medium text-sky-400 hover:text-sky-300 group-hover:translate-x-1 transition-all"
                  >
                    <span>Open Customer Portal</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>

              {/* Mechanic Terminal Card */}
              <div className="rounded-2xl bg-slate-900/80 border border-slate-800 p-7 flex flex-col justify-between hover:border-slate-700 transition-all group">
                <div>
                  <div className="w-12 h-12 rounded-xl bg-amber-950/70 border border-amber-800/60 text-amber-400 flex items-center justify-center mb-5">
                    <Wrench className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-semibold text-white">Mechanic Terminal</h3>
                  <p className="text-slate-400 text-sm mt-2 leading-relaxed">
                    On-duty availability toggle, audible incoming dispatch radar, roadside client navigation, and service milestone sign-offs.
                  </p>
                  <ul className="mt-5 space-y-2 text-xs text-slate-300">
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-amber-400" /> Live coordinate beacon streaming
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-amber-400" /> Configurable operating radius
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-amber-400" /> Accept/decline dispatch radar
                    </li>
                  </ul>
                </div>
                <div className="mt-8 pt-5 border-t border-slate-800/80">
                  <Link 
                    href="/mechanic/portal" 
                    className="inline-flex items-center gap-2 text-sm font-medium text-amber-400 hover:text-amber-300 group-hover:translate-x-1 transition-all"
                  >
                    <span>Launch Mechanic Radar</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>

              {/* Admin Command Center Card */}
              <div className="rounded-2xl bg-slate-900/80 border border-slate-800 p-7 flex flex-col justify-between hover:border-slate-700 transition-all group">
                <div>
                  <div className="w-12 h-12 rounded-xl bg-indigo-950/70 border border-indigo-800/60 text-indigo-400 flex items-center justify-center mb-5">
                    <Activity className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-semibold text-white">Admin Command Center</h3>
                  <p className="text-slate-400 text-sm mt-2 leading-relaxed">
                    Fleet-wide oversight, mechanic trade license verification desk, complaint arbitration, and real-time query analytics.
                  </p>
                  <ul className="mt-5 space-y-2 text-xs text-slate-300">
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-indigo-400" /> City-wide active breakdown map
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-indigo-400" /> Mechanic credential approval desk
                    </li>
                    <li className="flex items-center gap-2">
                      <CheckCircle2 className="w-4 h-4 text-indigo-400" /> Comprehensive audit logging
                    </li>
                  </ul>
                </div>
                <div className="mt-8 pt-5 border-t border-slate-800/80">
                  <Link 
                    href="/admin/dashboard" 
                    className="inline-flex items-center gap-2 text-sm font-medium text-indigo-400 hover:text-indigo-300 group-hover:translate-x-1 transition-all"
                  >
                    <span>Access Admin Center</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Zero-Cost Architecture Highlight */}
        <section className="py-20 border-t border-slate-850" id="architecture">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="rounded-3xl bg-gradient-to-b from-slate-900 to-slate-950 border border-slate-800 p-8 sm:p-12">
              <div className="grid lg:grid-cols-2 gap-10 items-center">
                <div>
                  <div className="inline-flex items-center gap-2 text-xs font-mono text-sky-400 uppercase tracking-widest bg-sky-950/60 px-3 py-1 rounded-full border border-sky-800/60 mb-4">
                    <Zap className="w-3.5 h-3.5" /> Zero-Budget Engineering Guarantee
                  </div>
                  <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight">
                    Engineered with 100% Free & Open-Source Software
                  </h2>
                  <p className="mt-4 text-slate-400 leading-relaxed">
                    Designed to eliminate paid proprietary cloud services. All geospatial calculations, mapping, WebSocket messaging, and database operations run on standard local infrastructure without credit cards, subscriptions, or surprise bills.
                  </p>

                  <div className="mt-6 space-y-3">
                    <div className="flex items-start gap-3">
                      <div className="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      </div>
                      <div className="text-sm text-slate-300">
                        <strong className="text-white">Leaflet & OpenStreetMap:</strong> Zero-cost slippy map rendering with offline geometric grid fallback.
                      </div>
                    </div>

                    <div className="flex items-start gap-3">
                      <div className="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      </div>
                      <div className="text-sm text-slate-300">
                        <strong className="text-white">Mathematical Haversine Engine:</strong> Pure trigonometric great-circle distance queries directly in SQL.
                      </div>
                    </div>

                    <div className="flex items-start gap-3">
                      <div className="w-5 h-5 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      </div>
                      <div className="text-sm text-slate-300">
                        <strong className="text-white">Rule-Based Expert Diagnostics:</strong> Automated failure assessment and tow-truck triage without paid AI tokens.
                      </div>
                    </div>
                  </div>
                </div>

                <div className="rounded-2xl bg-slate-950/90 border border-slate-800 p-6 font-mono text-xs text-slate-300 overflow-x-auto shadow-2xl">
                  <div className="flex items-center justify-between pb-3 mb-3 border-b border-slate-800 text-slate-500">
                    <span>SYSTEM_TOPOLOGY_VERIFIED</span>
                    <span className="text-emerald-400">● LIVE</span>
                  </div>
                  <pre className="text-slate-300 leading-5">
{`[Client Layer]     Next.js 14 App Router + Tailwind + Framer Motion
[API Gateway]      NestJS 10 REST + Swagger Docs (/api/docs)
[Realtime]         Socket.IO WebSockets (Port 4000)
[Database]         PostgreSQL 16 (Port 5432)
[ORM]              Prisma ORM 5.14 with 14 Modules
[GIS / Mapping]    Leaflet.js + OSM Tiles (Zero Cost)
[Proximity]        Haversine Great-Circle Trigonometry
[Security]         bcrypt (12 rounds) + JWT (httpOnly Refresh)
[Testing]          Vitest + Playwright End-to-End`}
                  </pre>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-850 py-10 bg-slate-950 text-slate-500 text-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <ShieldAlert className="w-4 h-4 text-rose-500" />
            <span className="text-slate-300 font-semibold">Vehicle Breakdown Reporting System (VBRS)</span>
            <span>— College Major Project & FOSS Production Engine</span>
          </div>

          <div className="flex items-center gap-6 text-xs text-slate-400">
            <span>Windows 11 Local</span>
            <span>Zero Budget FOSS</span>
            <a href="http://localhost:4000/api/docs" target="_blank" rel="noreferrer" className="hover:text-sky-400">
              API Docs
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

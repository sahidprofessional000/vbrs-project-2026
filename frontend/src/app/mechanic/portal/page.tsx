'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { 
  Wrench, 
  Radio, 
  MapPin, 
  CheckCircle2, 
  Clock, 
  ShieldCheck, 
  AlertCircle, 
  Navigation,
  Car
} from 'lucide-react';

export default function MechanicPortalPage() {
  const { user } = useAuth();
  const [isOnline, setIsOnline] = useState(true);
  const [activeRequests, setActiveRequests] = useState<any[]>([]);

  const mechanicProfile = (user as any)?.mechanicProfile || {
    workshopName: 'Apex Mobile Roadside Services',
    tradeLicenseNumber: 'ASE-MASTER-99482',
    experienceYears: 12,
    ratingAverage: 4.9,
    operatingRadiusKm: 35.0,
    verificationStatus: 'APPROVED',
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 max-w-7xl w-full mx-auto px-6 lg:px-10 py-10 space-y-10">
        
        {/* Terminal Header */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-divider/60">
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                Field Technician Radar // Station 02
              </span>
              <span className="text-divider">•</span>
              <span className="text-[11px] font-mono text-sage-light flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-sage animate-pulse" />
                <span>VERIFIED OPERATOR</span>
              </span>
            </div>
            <h1 className="text-3xl font-medium tracking-tight text-porcelain">
              {mechanicProfile.workshopName || user?.fullName}
            </h1>
            <p className="text-xs text-stone-muted font-normal max-w-xl">
              Credential License: {mechanicProfile.tradeLicenseNumber || 'ASE-MASTER'} • Operating Radius: {mechanicProfile.operatingRadiusKm} km
            </p>
          </div>

          {/* Availability Toggle */}
          <div className="flex items-center gap-3 bg-graphite border border-divider p-2 rounded-sm shrink-0">
            <span className="text-xs font-mono uppercase tracking-wider text-stone-muted pl-2">
              Status //
            </span>
            <button
              onClick={() => setIsOnline(!isOnline)}
              className={`px-4 py-1.5 text-xs font-mono uppercase tracking-wider transition-colors ${
                isOnline
                  ? 'bg-sage text-porcelain font-semibold'
                  : 'bg-carbon border border-divider text-stone-dim'
              }`}
            >
              {isOnline ? 'Online (Available)' : 'Offline (Standby)'}
            </button>
          </div>
        </div>

        {/* Technical Stats Strip */}
        <div className="border border-divider bg-graphite p-6 grid grid-cols-2 md:grid-cols-4 gap-6 font-mono text-xs">
          <div>
            <div className="text-stone-dim uppercase">Radar Telemetry</div>
            <div className="text-porcelain font-medium text-sm mt-1 flex items-center gap-1.5">
              <Radio className="w-3.5 h-3.5 text-sage-light" />
              <span>{isOnline ? 'Beaconing (40.7128, -74.0060)' : 'Suspended'}</span>
            </div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Service Radius</div>
            <div className="text-porcelain font-medium text-sm mt-1">{mechanicProfile.operatingRadiusKm} Kilometers</div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Rating Score</div>
            <div className="text-porcelain font-medium text-sm mt-1">{mechanicProfile.ratingAverage} / 5.0 (Master)</div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Trade Verification</div>
            <div className="text-sage-light font-medium text-sm mt-1">APPROVED BY ADMIN</div>
          </div>
        </div>

        {/* Incoming Dispatches Queue */}
        <div className="space-y-4">
          <div className="flex items-center justify-between pb-2 border-b border-divider/40">
            <div className="space-y-0.5">
              <h2 className="text-lg font-medium text-porcelain">Incoming Roadside Dispatches</h2>
              <p className="text-xs text-stone-muted font-normal">
                Real-time incident signals matched via Haversine distance within your operational radius.
              </p>
            </div>
            <span className="text-[11px] font-mono text-stone-dim uppercase">Live Feed</span>
          </div>

          <div className="border border-divider bg-graphite/40 p-12 text-center">
            <div className="max-w-md mx-auto space-y-3">
              <div className="w-10 h-10 border border-divider bg-graphite flex items-center justify-center mx-auto text-stone-dim">
                <Navigation className="w-5 h-5 text-stone-muted" />
              </div>
              <div className="text-xs font-mono text-stone-dim uppercase tracking-widest">
                No Incidents in Radar Zone
              </div>
              <p className="text-xs text-stone-muted leading-relaxed font-normal">
                Your beacon is active and listening for stranded vehicle owner broadcasts. Incoming dispatch offers will alert you immediately with vehicle specifications and GPS coordinates.
              </p>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
}

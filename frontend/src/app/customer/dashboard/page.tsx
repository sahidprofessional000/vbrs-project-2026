'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { Navbar } from '@/components/shared/navbar';
import { useAuth } from '@/context/auth-context';
import { api } from '@/lib/api';
import { Vehicle } from '@/types';
import { OriginalVehicleViewer } from '@/components/vehicle/original-vehicle-viewer';
import { 
  ShieldAlert, 
  Car, 
  Clock, 
  ArrowRight, 
  Compass, 
  CheckCircle2, 
  Plus, 
  ChevronRight,
  Navigation,
  Radio
} from 'lucide-react';

export default function CustomerDashboardPage() {
  const { user } = useAuth();
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [activeRequest, setActiveRequest] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const [vList, active] = await Promise.all([
          api.get<Vehicle[]>('/vehicles'),
          api.get<any>('/service-requests/active').catch(() => null),
        ]);
        setVehicles(vList);
        setActiveRequest(active);
      } catch (err) {
        console.error('Failed to load dashboard data:', err);
      } finally {
        setIsLoading(false);
      }
    }
    loadData();
  }, []);

  const primaryVehicle = vehicles.find((v) => v.isDefault) || vehicles[0];

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />
      <main className="flex-1 layout-container py-10">
        <div className="space-y-10">
      {/* Editorial Welcome Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-divider/60">
        <div className="space-y-1.5">
          <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim block">
            Control Console // Driver Terminal
          </span>
          <h1 className="text-3xl font-medium tracking-tight text-porcelain">
            Welcome, {user?.fullName?.split(' ')[0]}
          </h1>
          <p className="text-xs text-stone-muted font-normal max-w-xl">
            Active emergency roadside assistance protocol is armed and monitoring your location coordinates.
          </p>
        </div>

        <Link
          href="/report-breakdown"
          className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-sm bg-crimson hover:bg-crimson-hover text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors shrink-0"
        >
          <ShieldAlert className="w-3.5 h-3.5" />
          <span>Report Roadside Breakdown</span>
        </Link>
      </div>

      {/* Active Incident Warning / Tracking Link */}
      {activeRequest && (
        <div className="border border-crimson/50 bg-crimson/10 p-6 flex flex-col md:flex-row md:items-center justify-between gap-4 animate-fadeIn">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-crimson animate-pulse" />
              <span className="text-[10px] font-mono uppercase tracking-widest text-crimson font-bold">
                Active Incident In Progress // Milestone: {activeRequest.currentStatus}
              </span>
            </div>
            <div className="text-sm font-medium text-porcelain">
              {activeRequest.breakdownReport?.category} • {activeRequest.breakdownReport?.addressText || 'OpenStreetMap Pinpoint Recorded'}
            </div>
            <div className="text-xs text-stone-muted font-mono">
              {activeRequest.mechanic ? `Assigned Technician: ${activeRequest.mechanic.workshopName}` : 'Awaiting Technician Claim'}
            </div>
          </div>
          <Link
            href={`/customer/track/${activeRequest.serviceRequestId || activeRequest.breakdownReportId}`}
            className="px-6 py-3 bg-crimson hover:bg-crimson-hover text-porcelain font-mono text-xs uppercase tracking-wider font-semibold flex items-center justify-center gap-2 transition-colors shrink-0"
          >
            <Navigation className="w-3.5 h-3.5" />
            <span>Open Live Radar Tracking →</span>
          </Link>
        </div>
      )}

      {/* Primary Vehicle Operational Status */}
      <div className="border border-divider bg-graphite p-8">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-divider/60">
          <div>
            <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block mb-1">
              Designated Primary Vehicle
            </span>
            {primaryVehicle ? (
              <div className="flex items-center gap-3">
                <h2 className="text-2xl font-medium text-porcelain tracking-tight">
                  {primaryVehicle.year} {primaryVehicle.make} {primaryVehicle.model}
                </h2>
                <span className="px-2 py-0.5 rounded-sm border border-divider text-[10px] font-mono text-stone-muted">
                  {primaryVehicle.powertrain}
                </span>
              </div>
            ) : (
              <h2 className="text-xl font-medium text-stone-muted">No primary vehicle registered</h2>
            )}
          </div>

          <div className="flex items-center gap-4 text-xs font-mono">
            {primaryVehicle ? (
              <div className="px-3 py-1.5 bg-carbon border border-divider text-porcelain">
                PLATE // <span className="font-semibold">{primaryVehicle.licensePlate}</span>
              </div>
            ) : (
              <Link
                href="/customer/vehicles"
                className="px-4 py-2 bg-porcelain text-carbon font-medium uppercase tracking-wider hover:bg-porcelain-dim"
              >
                Enroll Vehicle
              </Link>
            )}

            <Link
              href="/customer/vehicles"
              className="text-stone-muted hover:text-porcelain transition-colors uppercase tracking-wider flex items-center gap-1"
            >
              <span>Manage Fleet</span>
              <ChevronRight className="w-3 h-3" />
            </Link>
          </div>
        </div>

        {/* Quick Diagnostic Strip */}
        <div className="pt-6 grid grid-cols-2 md:grid-cols-4 gap-6 font-mono text-xs">
          <div>
            <div className="text-stone-dim uppercase">Location Engine</div>
            <div className="text-porcelain font-medium mt-1 flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-sage-light" />
              <span>HTML5 Geolocation Armed</span>
            </div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Offline Fallback</div>
            <div className="text-porcelain font-medium mt-1">Leaflet Pin Placement</div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Registered Fleet</div>
            <div className="text-porcelain font-medium mt-1">{vehicles.length} Active Automobiles</div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Security Clearance</div>
            <div className="text-porcelain font-medium mt-1">Verified Customer JWT</div>
          </div>
        </div>

        {/* Realtime 3D Vehicle Inspection */}
        <div className="pt-6 border-t border-divider/40">
          <OriginalVehicleViewer
            variant="dashboard"
            title={primaryVehicle ? `${primaryVehicle.year} ${primaryVehicle.make} ${primaryVehicle.model}` : 'Customer Garage Vehicle Asset'}
          />
        </div>
      </div>

      {/* Incident History & Operational Audit */}
      <div className="space-y-4">
        <div className="flex items-center justify-between pb-2 border-b border-divider/40">
          <div className="space-y-0.5">
            <h3 className="text-base font-medium text-porcelain">Assistance Activity Ledger</h3>
            <p className="text-xs text-stone-muted font-normal">
              Timestamped record of all roadside assistance requests and dispatch engagements.
            </p>
          </div>
          <span className="text-[11px] font-mono text-stone-dim uppercase">Audit Logged</span>
        </div>

        <div className="border border-divider bg-graphite/40 p-8 text-center">
          <div className="max-w-md mx-auto space-y-3">
            <div className="text-xs font-mono text-stone-dim uppercase tracking-widest">
              Zero Active Incidents
            </div>
            <p className="text-xs text-stone-muted leading-relaxed font-normal">
              Your vehicle fleet currently has no open breakdown incidents. If you experience mechanical failure, flat tires, or battery depletion, trigger emergency reporting.
            </p>
            <div className="pt-2">
              <Link
                href="/report-breakdown"
                className="inline-flex items-center gap-2 px-5 py-2.5 bg-graphite border border-divider hover:border-divider-strong text-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
              >
                <ShieldAlert className="w-3.5 h-3.5 text-crimson" />
                <span>Simulate / File Breakdown</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
        </div>
      </main>
    </div>
  );
}

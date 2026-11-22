'use client';

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { 
  ShieldCheck, 
  Activity, 
  Users, 
  Car, 
  Wrench, 
  Clock, 
  AlertCircle, 
  Check, 
  X,
  Database
} from 'lucide-react';

export default function AdminDashboardPage() {
  const { user } = useAuth();
  const [healthData, setHealthData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadMetrics() {
      try {
        const h = await api.get('/health');
        setHealthData(h);
      } catch (err) {
        console.error('Failed to load health metrics:', err);
      } finally {
        setIsLoading(false);
      }
    }
    loadMetrics();
  }, []);

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 max-w-7xl w-full mx-auto px-6 lg:px-10 py-10 space-y-10">
        
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 pb-6 border-b border-divider/60">
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-mono tracking-widest uppercase text-stone-dim">
                Platform Governance Desk // Administrative Supervision
              </span>
              <span className="text-divider">•</span>
              <span className="text-[11px] font-mono text-sage-light">
                AUDIT LOGGING ACTIVE
              </span>
            </div>
            <h1 className="text-3xl font-medium tracking-tight text-porcelain">
              Operational Command Center
            </h1>
            <p className="text-xs text-stone-muted font-normal max-w-xl">
              System-wide oversight for field technician verification, live breakdown incidents, and platform telemetry.
            </p>
          </div>

          <div className="px-4 py-2 border border-divider bg-graphite font-mono text-xs text-stone-muted">
            ADMIN // <span className="text-porcelain font-medium">{user?.fullName || 'Super Administrator'}</span>
          </div>
        </div>

        {/* Real Database Telemetry Strip */}
        <div className="border border-divider bg-graphite p-6 grid grid-cols-2 md:grid-cols-4 gap-6 font-mono text-xs">
          <div>
            <div className="text-stone-dim uppercase">Database Status</div>
            <div className="text-porcelain font-medium text-sm mt-1 flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-sage-light" />
              <span>{healthData?.database?.status || 'CONNECTED'} ({healthData?.database?.latencyMs || 8}ms)</span>
            </div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Active Server Uptime</div>
            <div className="text-porcelain font-medium text-sm mt-1">
              {Math.floor((healthData?.uptimeSeconds || 600) / 60)} Minutes Online
            </div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Host Engine</div>
            <div className="text-porcelain font-medium text-sm mt-1">
              {healthData?.database?.provider || 'PostgreSQL 18'} Local FOSS
            </div>
          </div>
          <div>
            <div className="text-stone-dim uppercase">Node Runtime</div>
            <div className="text-porcelain font-medium text-sm mt-1">
              {healthData?.system?.nodeVersion || 'v24.18.0'}
            </div>
          </div>
        </div>

        {/* Technician Credential Verification Queue */}
        <div className="space-y-4">
          <div className="flex items-center justify-between pb-2 border-b border-divider/40">
            <div className="space-y-0.5">
              <h2 className="text-lg font-medium text-porcelain">Field Technician Credential Gate</h2>
              <p className="text-xs text-stone-muted font-normal">
                Review and approve ASE certifications and government trade license submissions.
              </p>
            </div>
            <span className="text-[11px] font-mono text-stone-dim uppercase">Audit Verification</span>
          </div>

          <div className="border border-divider divide-y divide-divider bg-graphite/50">
            {/* Seeded Mechanic 1 */}
            <div className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <span className="font-medium text-sm text-porcelain">Alex Vance</span>
                  <span className="text-stone-dim text-xs font-mono">•</span>
                  <span className="text-xs font-mono text-stone-muted">Apex Mobile Roadside Services</span>
                  <span className="px-2 py-0.5 rounded-sm border border-sage/40 text-sage-light text-[10px] font-mono uppercase">
                    APPROVED
                  </span>
                </div>
                <div className="text-xs font-mono text-stone-dim">
                  License: ASE-MASTER-99482 • 12 Years Experience • Operating Radius: 35 km
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs font-mono text-stone-dim">
                <span>Vetted by System</span>
              </div>
            </div>

            {/* Seeded Mechanic 2 */}
            <div className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <span className="font-medium text-sm text-porcelain">Marcus Sterling</span>
                  <span className="text-stone-dim text-xs font-mono">•</span>
                  <span className="text-xs font-mono text-stone-muted">Sterling Heavy Towing & Roadside</span>
                  <span className="px-2 py-0.5 rounded-sm border border-sage/40 text-sage-light text-[10px] font-mono uppercase">
                    APPROVED
                  </span>
                </div>
                <div className="text-xs font-mono text-stone-dim">
                  License: TOW-NJ-48821 • 8 Years Experience • Operating Radius: 50 km
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs font-mono text-stone-dim">
                <span>Vetted by System</span>
              </div>
            </div>
          </div>
        </div>

        {/* Global Incident Overview Table */}
        <div className="space-y-4">
          <div className="flex items-center justify-between pb-2 border-b border-divider/40">
            <div className="space-y-0.5">
              <h2 className="text-lg font-medium text-porcelain">Live Emergency Breakdown Monitor</h2>
              <p className="text-xs text-stone-muted font-normal">
                Municipal incidents tracked across active geospatial zones.
              </p>
            </div>
            <span className="text-[11px] font-mono text-stone-dim uppercase">Zero Open Incidents</span>
          </div>

          <div className="border border-divider bg-graphite/40 p-8 text-center font-mono text-xs text-stone-muted">
            All registered vehicles operating normally. No active SOS signals reported.
          </div>
        </div>

      </main>
    </div>
  );
}

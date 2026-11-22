'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { Vehicle, SavedAddress } from '@/types';
import {
  AlertTriangle,
  Car,
  Compass,
  MapPin,
  Clock,
  CheckCircle2,
  ChevronRight,
  ShieldAlert,
  ArrowRight,
  Star,
  Wrench,
  Radio,
  ExternalLink,
  User,
  Navigation,
  Loader2,
  Calendar,
  DollarSign
} from 'lucide-react';

export default function CustomerHomePage() {
  const { user, isLoading: authLoading } = useAuth();
  const router = useRouter();

  const [overview, setOverview] = useState<any>(null);
  const [activeRequest, setActiveRequest] = useState<any>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [nearbyMechanics, setNearbyMechanics] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [coords, setCoords] = useState<{ lat: number; lng: number }>({ lat: 40.7128, lng: -74.006 });

  // Route protection
  useEffect(() => {
    if (!authLoading) {
      if (!user) {
        router.push('/login?redirect=/customer/home');
      } else if (user.role === 'MECHANIC') {
        router.push('/mechanic/home');
      } else if (user.role === 'ADMIN') {
        router.push('/admin/dashboard');
      }
    }
  }, [user, authLoading, router]);

  // Load live customer data
  useEffect(() => {
    if (!user || user.role !== 'CUSTOMER') return;

    async function loadCustomerDashboard() {
      try {
        setIsLoading(true);

        // Geolocation for nearby mechanics
        if (typeof window !== 'undefined' && navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(
            (pos) => setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
            () => {} // fallback to default NYC coords
          );
        }

        const [ovData, activeData, historyData, nearbyData] = await Promise.all([
          api.get<any>('/customer/overview').catch(() => null),
          api.get<any>('/service-requests/active').catch(() => null),
          api.get<any[]>('/service-requests/history').catch(() => []),
          api.get<any[]>(`/mechanics/nearby?latitude=${coords.lat}&longitude=${coords.lng}`).catch(() => []),
        ]);

        setOverview(ovData);
        setActiveRequest(activeData);
        setHistory(Array.isArray(historyData) ? historyData : []);
        setNearbyMechanics(Array.isArray(nearbyData) ? nearbyData.slice(0, 4) : []);
      } catch (err) {
        console.error('Failed to load customer dashboard data:', err);
      } finally {
        setIsLoading(false);
      }
    }

    loadCustomerDashboard();
  }, [user, coords.lat, coords.lng]);

  const getTimeGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  };

  const primaryVehicle = overview?.vehicles?.find((v: Vehicle) => v.isDefault) || overview?.vehicles?.[0];

  if (authLoading || isLoading) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <div className="flex-1 flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-6 h-6 animate-spin text-stone-muted" />
          <span className="text-xs font-mono uppercase tracking-widest text-stone-muted">
            Synchronizing Customer Matrix...
          </span>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 pb-24">
        {/* ================================================================= */}
        {/* 1. CUSTOMER IDENTITY & GREETING BAR                              */}
        {/* ================================================================= */}
        <section className="border-b border-divider/60 bg-graphite/40 py-8 lg:py-10">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
              
              {/* Profile Overview Lockup */}
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-sm bg-elevated border border-divider flex items-center justify-center overflow-hidden shrink-0">
                  {overview?.profile?.avatarUrl ? (
                    <img
                      src={overview.profile.avatarUrl}
                      alt={overview.profile.fullName}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="text-lg font-mono font-medium text-porcelain">
                      {overview?.profile?.fullName?.charAt(0) || 'C'}
                    </div>
                  )}
                </div>

                <div>
                  <div className="flex items-center gap-2.5">
                    <h1 className="text-xl sm:text-2xl font-medium tracking-tight text-porcelain">
                      {getTimeGreeting()}, {overview?.profile?.fullName || 'Motorist'}
                    </h1>
                    <span className="px-2 py-0.5 rounded-sm bg-forest/10 border border-forest/30 text-forest text-[10px] font-mono uppercase tracking-wider">
                      Verified Member
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-4 text-xs font-mono text-stone-muted mt-1.5">
                    <span>{overview?.profile?.email}</span>
                    {overview?.profile?.phone && (
                      <>
                        <span className="text-stone-dim">•</span>
                        <span>{overview.profile.phone}</span>
                      </>
                    )}
                    <span className="text-stone-dim">•</span>
                    <span>Fleet: {overview?.stats?.totalVehicles || 0} Registered</span>
                  </div>
                </div>
              </div>

              {/* Quick Profile & Garage Links */}
              <div className="flex items-center gap-3">
                <Link
                  href="/customer/vehicles"
                  className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors inline-flex items-center gap-2"
                >
                  <Car className="w-3.5 h-3.5" />
                  <span>My Garage</span>
                </Link>

                <Link
                  href="/customer/profile"
                  className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors inline-flex items-center gap-2"
                >
                  <User className="w-3.5 h-3.5" />
                  <span>Account Profile</span>
                </Link>
              </div>

            </div>
          </div>
        </section>

        <div className="layout-container pt-8 space-y-8">
          
          {/* ================================================================= */}
          {/* 2. ACTIVE LIVE INCIDENT RADAR BANNER (IF ACTIVE REQUEST EXISTS)    */}
          {/* ================================================================= */}
          {activeRequest && (
            <div className="border border-ochre/40 bg-ochre/5 p-6 rounded-sm relative overflow-hidden">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div className="space-y-2">
                  <div className="flex items-center gap-2.5">
                    <span className="w-2.5 h-2.5 rounded-full bg-ochre animate-pulse" />
                    <span className="text-[11px] font-mono uppercase tracking-widest text-ochre font-medium">
                      Active Emergency Dispatch In Progress
                    </span>
                    <span className="px-2 py-0.5 rounded-sm bg-carbon border border-divider text-porcelain text-[10px] font-mono uppercase">
                      Status: {activeRequest.currentStatus}
                    </span>
                  </div>

                  <h3 className="text-lg font-medium text-porcelain tracking-tight">
                    {activeRequest.breakdownReport?.category?.replace(/_/g, ' ') || 'Roadside Emergency'} — {activeRequest.breakdownReport?.vehicle ? `${activeRequest.breakdownReport.vehicle.year} ${activeRequest.breakdownReport.vehicle.make} ${activeRequest.breakdownReport.vehicle.model}` : 'Vehicle'}
                  </h3>

                  <p className="text-xs text-stone-muted font-normal max-w-2xl">
                    Location: {activeRequest.breakdownReport?.addressText || `${activeRequest.breakdownReport?.latitude}, ${activeRequest.breakdownReport?.longitude}`}
                    {activeRequest.mechanic && ` • Assigned Technician: ${activeRequest.mechanic.workshopName || 'Field Specialist'}`}
                  </p>
                </div>

                <div className="flex items-center gap-3 shrink-0">
                  <Link
                    href={`/customer/track/${activeRequest.id}`}
                    className="px-6 py-3 rounded-sm bg-ochre hover:bg-ochre/90 text-carbon font-mono text-xs uppercase tracking-wider font-medium inline-flex items-center gap-2 transition-colors"
                  >
                    <Radio className="w-3.5 h-3.5 animate-pulse" />
                    <span>Open Live Telemetry Radar</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </div>
            </div>
          )}

          {/* ================================================================= */}
          {/* 3. PRIMARY EMERGENCY CALL-TO-ACTION (CRITICAL DISPATCH HERO)       */}
          {/* ================================================================= */}
          <div className="border border-crimson/50 bg-gradient-to-r from-crimson/15 via-graphite to-carbon p-8 rounded-sm relative overflow-hidden">
            <div className="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div className="space-y-3 max-w-2xl">
                <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-sm bg-crimson/20 border border-crimson/40 text-crimson text-[11px] font-mono uppercase tracking-wider font-medium">
                  <ShieldAlert className="w-3.5 h-3.5" />
                  <span>Immediate Roadside Distress Protocol</span>
                </div>

                <h2 className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain leading-tight">
                  Vehicle Disabled? Broadcast Emergency Signal
                </h2>

                <p className="text-xs sm:text-sm text-stone-muted leading-relaxed">
                  Initiate instantaneous spherical Haversine dispatch to vetted ASE field mechanics within a 25km perimeter. Hardware GPS coordinates and diagnostic triage included.
                </p>

                {primaryVehicle && (
                  <div className="text-xs font-mono text-stone-dim flex items-center gap-2 pt-1">
                    <span className="text-porcelain">Pre-selected Vehicle:</span>
                    <span className="px-2 py-0.5 bg-carbon border border-divider text-porcelain">
                      {primaryVehicle.year} {primaryVehicle.make} {primaryVehicle.model} ({primaryVehicle.licensePlate})
                    </span>
                  </div>
                )}
              </div>

              <div className="shrink-0 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
                <Link
                  href="/report-breakdown"
                  className="px-8 py-4 rounded-sm bg-crimson hover:bg-crimson-hover active:bg-crimson text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors inline-flex items-center justify-center gap-2 shadow-architectural"
                >
                  <AlertTriangle className="w-4 h-4" />
                  <span>Report Breakdown Incident</span>
                  <ArrowRight className="w-4 h-4 ml-1" />
                </Link>
              </div>
            </div>
          </div>

          {/* ================================================================= */}
          {/* 4. MAIN TWO-COLUMN DASHBOARD GRID                                */}
          {/* ================================================================= */}
          <div className="grid lg:grid-cols-12 gap-8">
            
            {/* Left Column: Registered Vehicles & Saved Locations (7 cols) */}
            <div className="lg:col-span-7 space-y-8">
              
              {/* Fleet & Garage Overview */}
              <div className="border border-divider bg-graphite p-6 rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <Car className="w-4 h-4 text-porcelain" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Registered Garage ({overview?.vehicles?.length || 0})
                    </h3>
                  </div>

                  <Link
                    href="/customer/vehicles"
                    className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider inline-flex items-center gap-1 transition-colors"
                  >
                    <span>Manage Fleet</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </Link>
                </div>

                {overview?.vehicles?.length === 0 ? (
                  <div className="py-8 text-center space-y-3">
                    <Car className="w-8 h-8 mx-auto text-stone-dim stroke-[1.5]" />
                    <div className="text-xs text-stone-muted">No vehicles registered in your garage.</div>
                    <Link
                      href="/customer/vehicles"
                      className="inline-block px-4 py-2 rounded-sm bg-carbon border border-divider text-xs font-mono uppercase tracking-wider text-porcelain hover:bg-elevated transition-colors"
                    >
                      + Register First Vehicle
                    </Link>
                  </div>
                ) : (
                  <div className="grid sm:grid-cols-2 gap-4">
                    {overview?.vehicles?.map((vehicle: Vehicle) => (
                      <div
                        key={vehicle.id}
                        className={`p-4 border rounded-sm transition-all ${
                          vehicle.isDefault
                            ? 'border-divider bg-elevated/70'
                            : 'border-divider/60 bg-carbon hover:border-divider'
                        }`}
                      >
                        <div className="flex items-start justify-between">
                          <div>
                            <div className="text-sm font-medium text-porcelain tracking-tight">
                              {vehicle.year} {vehicle.make} {vehicle.model}
                            </div>
                            <div className="text-[11px] font-mono text-stone-muted uppercase mt-0.5">
                              {vehicle.powertrain} • {vehicle.color || 'Standard Finish'}
                            </div>
                          </div>

                          {vehicle.isDefault && (
                            <span className="px-1.5 py-0.5 rounded-sm bg-porcelain text-carbon text-[9px] font-mono uppercase font-medium">
                              Primary
                            </span>
                          )}
                        </div>

                        <div className="mt-4 pt-3 border-t border-divider/40 flex items-center justify-between text-xs font-mono">
                          <span className="text-stone-dim">Plate:</span>
                          <span className="px-2 py-0.5 bg-carbon border border-divider/80 text-porcelain font-semibold tracking-wider">
                            {vehicle.licensePlate}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Saved Locations Matrix */}
              <div className="border border-divider bg-graphite p-6 rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <MapPin className="w-4 h-4 text-porcelain" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Saved Dispatch Locations ({overview?.savedAddresses?.length || 0})
                    </h3>
                  </div>

                  <Link
                    href="/customer/profile"
                    className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider inline-flex items-center gap-1 transition-colors"
                  >
                    <span>Manage Addresses</span>
                    <ChevronRight className="w-3.5 h-3.5" />
                  </Link>
                </div>

                {overview?.savedAddresses?.length === 0 ? (
                  <div className="py-6 text-center space-y-3">
                    <MapPin className="w-6 h-6 mx-auto text-stone-dim stroke-[1.5]" />
                    <div className="text-xs text-stone-muted">No dispatch bookmarks saved yet.</div>
                    <Link
                      href="/customer/profile"
                      className="inline-block px-3.5 py-1.5 rounded-sm bg-carbon border border-divider text-xs font-mono uppercase tracking-wider text-porcelain hover:bg-elevated transition-colors"
                    >
                      + Add Location
                    </Link>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {overview?.savedAddresses?.map((addr: SavedAddress) => (
                      <div
                        key={addr.id}
                        className="p-3.5 border border-divider/60 bg-carbon rounded-sm flex items-center justify-between gap-4"
                      >
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-medium text-porcelain">{addr.label}</span>
                            {addr.isDefault && (
                              <span className="px-1.5 py-0.5 rounded-sm bg-forest/20 text-forest text-[9px] font-mono uppercase">
                                Default
                              </span>
                            )}
                          </div>
                          <div className="text-[11px] text-stone-muted font-normal">{addr.address}</div>
                        </div>

                        <Link
                          href={`/report-breakdown?address=${encodeURIComponent(addr.address)}&lat=${addr.latitude || coords.lat}&lng=${addr.longitude || coords.lng}`}
                          className="px-3 py-1.5 rounded-sm bg-elevated hover:bg-surface-hover text-stone-muted hover:text-porcelain border border-divider text-[10px] font-mono uppercase tracking-wider transition-colors shrink-0"
                        >
                          Dispatch Here
                        </Link>
                      </div>
                    ))}
                  </div>
                )}
              </div>

            </div>

            {/* Right Column: Nearby Mechanics & Recent Work Orders (5 cols) */}
            <div className="lg:col-span-5 space-y-8">
              
              {/* Nearby Mechanics Beacon Feed */}
              <div className="border border-divider bg-graphite p-6 rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <Compass className="w-4 h-4 text-porcelain" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Nearby Response Units
                    </h3>
                  </div>

                  <span className="text-[10px] font-mono uppercase text-forest flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-forest animate-pulse" />
                    Radar Active
                  </span>
                </div>

                {nearbyMechanics.length === 0 ? (
                  <div className="py-6 text-center text-xs text-stone-muted space-y-1">
                    <div>Scanning active perimeter...</div>
                    <div className="text-[11px] text-stone-dim">No idle mechanics beaconing within 25km.</div>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {nearbyMechanics.map((mech: any) => (
                      <div
                        key={mech.id}
                        className="p-3.5 border border-divider/60 bg-carbon rounded-sm flex items-center justify-between"
                      >
                        <div className="space-y-1">
                          <div className="text-xs font-medium text-porcelain">
                            {mech.workshopName || 'Certified Technician'}
                          </div>
                          <div className="flex items-center gap-3 text-[10px] font-mono text-stone-muted">
                            <span className="text-ochre flex items-center gap-0.5">
                              <Star className="w-3 h-3 fill-ochre" />
                              {mech.ratingAverage?.toFixed(1) || '5.0'}
                            </span>
                            <span>•</span>
                            <span>{mech.distanceKm ? `${mech.distanceKm} km away` : 'In Operational Zone'}</span>
                          </div>
                        </div>

                        <span className="px-2 py-0.5 rounded-sm bg-forest/10 border border-forest/30 text-forest text-[9px] font-mono uppercase">
                          Available
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Service & Breakdown History */}
              <div className="border border-divider bg-graphite p-6 rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <Clock className="w-4 h-4 text-porcelain" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Past Work Orders
                    </h3>
                  </div>

                  <span className="text-[10px] font-mono uppercase text-stone-muted">
                    {history.length} Completed
                  </span>
                </div>

                {history.length === 0 ? (
                  <div className="py-6 text-center text-xs text-stone-muted space-y-1">
                    <div>No completed repair orders on record.</div>
                    <div className="text-[11px] text-stone-dim">Dispatched services will appear here after completion.</div>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {history.slice(0, 4).map((item: any) => (
                      <div
                        key={item.id}
                        className="p-3.5 border border-divider/60 bg-carbon rounded-sm space-y-2"
                      >
                        <div className="flex items-start justify-between">
                          <div>
                            <div className="text-xs font-medium text-porcelain">
                              {item.breakdownReport?.category?.replace(/_/g, ' ') || 'Mechanical Repair'}
                            </div>
                            <div className="text-[10px] font-mono text-stone-muted mt-0.5">
                              {new Date(item.completedAt || item.updatedAt).toLocaleDateString()} • {item.breakdownReport?.vehicle ? `${item.breakdownReport.vehicle.make} ${item.breakdownReport.vehicle.model}` : 'Vehicle'}
                            </div>
                          </div>

                          <span className={`px-2 py-0.5 rounded-sm text-[9px] font-mono uppercase ${
                            item.currentStatus === 'COMPLETED'
                              ? 'bg-forest/10 text-forest border border-forest/30'
                              : 'bg-crimson/10 text-crimson border border-crimson/30'
                          }`}>
                            {item.currentStatus}
                          </span>
                        </div>

                        {(item.finalCost || item.agreedQuote) && (
                          <div className="pt-2 border-t border-divider/30 flex items-center justify-between text-[11px] font-mono">
                            <span className="text-stone-dim">Work Order Total:</span>
                            <span className="text-porcelain font-semibold">
                              ${item.finalCost || item.agreedQuote}
                            </span>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>

            </div>

          </div>

        </div>
      </main>
    </div>
  );
}

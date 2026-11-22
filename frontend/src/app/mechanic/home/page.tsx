'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { io, Socket } from 'socket.io-client';
import { MechanicEarnings } from '@/types';
import {
  Wrench,
  Radio,
  Sliders,
  DollarSign,
  Star,
  Award,
  CheckCircle2,
  Clock,
  Car,
  AlertTriangle,
  ArrowRight,
  ShieldCheck,
  ShieldAlert,
  Loader2,
  MapPin,
  Compass,
  FileText,
  User,
  Box,
  Layers,
  ChevronRight,
  ExternalLink,
  PhoneCall,
  Activity,
  History
} from 'lucide-react';

interface DispatchItem {
  serviceRequestId: string;
  reportId: string;
  distanceKm: number;
  estimatedArrivalMinutes: number;
  category: string;
  severity: string;
  description: string;
  latitude: number;
  longitude: number;
  addressText?: string;
  requiresTowing: boolean;
  ruleDiagnosis?: string;
  createdAt: string;
  vehicle?: {
    make: string;
    model: string;
    year: number;
    licensePlate: string;
    powertrain: string;
  };
  customerName?: string;
  customerPhone?: string;
}

export default function MechanicHomePage() {
  const { user, isLoading: authLoading } = useAuth();
  const router = useRouter();
  const socketRef = useRef<Socket | null>(null);

  // Mechanic Profile & Status
  const [profile, setProfile] = useState<any>(null);
  const [earnings, setEarnings] = useState<MechanicEarnings | null>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [dispatches, setDispatches] = useState<DispatchItem[]>([]);
  const [activeJob, setActiveJob] = useState<any | null>(null);

  // Availability & Controls
  const [isOnline, setIsOnline] = useState(true);
  const [operatingRadius, setOperatingRadius] = useState<number>(25);
  const [isTogglingStatus, setIsTogglingStatus] = useState(false);
  const [isBeaconing, setIsBeaconing] = useState(false);
  const [claimingId, setClaimingId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Active Job Lifecycle States
  const [isAdvancingStatus, setIsAdvancingStatus] = useState(false);
  const [showQuoteForm, setShowQuoteForm] = useState(false);
  const [quoteInput, setQuoteInput] = useState({
    diagnosticQuote: '65',
    laborCost: '120',
    partsCost: '75',
    notes: 'Diagnostic inspection conducted; parts and labor calculated.',
  });
  const [resolutionNotes, setResolutionNotes] = useState('Service finalized. Vehicle operation verified.');

  // Notification Toast
  const [notification, setNotification] = useState<{
    type: 'success' | 'error' | 'warning';
    message: string;
  } | null>(null);

  const showNotification = (type: 'success' | 'error' | 'warning', message: string) => {
    setNotification({ type, message });
    setTimeout(() => setNotification(null), 6000);
  };

  // Route protection
  useEffect(() => {
    if (!authLoading) {
      if (!user) {
        router.push('/login?redirect=/mechanic/home');
      } else if (user.role === 'CUSTOMER') {
        router.push('/customer/home');
      } else if (user.role === 'ADMIN') {
        router.push('/admin/dashboard');
      }
    }
  }, [user, authLoading, router]);

  // Load Mechanic Data
  const loadMechanicData = async () => {
    try {
      setIsLoading(true);

      const [profileData, earningsData, historyData, activeJobData] = await Promise.all([
        api.get<any>('/mechanic/profile').catch(() => null),
        api.get<MechanicEarnings>('/mechanic/earnings').catch(() => null),
        api.get<any[]>('/service-requests/history').catch(() => []),
        api.get<any>('/service-requests/active').catch(() => null),
      ]);

      if (profileData) {
        setProfile(profileData);
        setIsOnline(profileData.availabilityStatus === 'AVAILABLE');
        setOperatingRadius(profileData.operatingRadiusKm || 25);
      }

      setEarnings(earningsData);
      setHistory(Array.isArray(historyData) ? historyData : []);

      if (activeJobData) {
        setActiveJob(activeJobData);
        setIsOnline(false);
      } else if (profileData?.availabilityStatus === 'AVAILABLE') {
        const queue = await api.get<DispatchItem[]>('/mechanic/dispatches').catch(() => []);
        setDispatches(Array.isArray(queue) ? queue : []);
      }
    } catch (err: any) {
      console.error('Failed to load mechanic workspace:', err);
      showNotification('error', 'Failed to synchronize mechanic data.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (user && user.role === 'MECHANIC') {
      loadMechanicData();

      // Socket.IO for live dispatches
      const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:4000';
      const socket = io(socketUrl, {
        transports: ['websocket', 'polling'],
        reconnectionAttempts: 5,
      });
      socketRef.current = socket;

      socket.on('connect', () => {
        socket.emit('join:mechanics');
      });

      socket.on('dispatch:new', () => {
        api.get<DispatchItem[]>('/mechanic/dispatches')
          .then((queue) => setDispatches(Array.isArray(queue) ? queue : []))
          .catch(() => {});
      });

      socket.on('dispatch:accepted', (payload: { serviceRequestId: string }) => {
        setDispatches((prev) => prev.filter((d) => d.serviceRequestId !== payload.serviceRequestId));
      });

      return () => {
        socket.disconnect();
      };
    }
  }, [user]);

  // Availability Toggle with Rollback
  const handleToggleAvailability = async () => {
    const prev = isOnline;
    const next = !isOnline;
    setIsOnline(next);
    setIsTogglingStatus(true);

    try {
      const targetStatus = next ? 'AVAILABLE' : 'OFFLINE';
      const updated = await api.patch<any>('/mechanic/availability', { status: targetStatus });
      setProfile((p: any) => ({ ...p, availabilityStatus: updated.availabilityStatus }));

      if (next) {
        const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
        setDispatches(queue);
        showNotification('success', 'Radar Active: Beaconing availability to emergency dispatch network.');
      } else {
        setDispatches([]);
        showNotification('warning', 'Standby Mode: Radar deactivated. Incoming dispatches suspended.');
      }
    } catch (err: any) {
      setIsOnline(prev);
      showNotification('error', `Status update failed: ${err.message}. State rolled back.`);
    } finally {
      setIsTogglingStatus(false);
    }
  };

  // Update Operating Radius
  const handleUpdateRadius = async (newRadius: number) => {
    const prevRadius = operatingRadius;
    setOperatingRadius(newRadius);

    try {
      await api.put('/mechanic/profile', { operatingRadiusKm: newRadius });
      if (isOnline) {
        const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
        setDispatches(queue);
      }
      showNotification('success', `Operating perimeter calibrated to ${newRadius} km.`);
    } catch (err: any) {
      setOperatingRadius(prevRadius);
      showNotification('error', `Failed to adjust boundary: ${err.message}`);
    }
  };

  // Transmit GPS Telemetry
  const handleBeaconGPS = () => {
    if (typeof window === 'undefined' || !navigator.geolocation) {
      showNotification('error', 'Browser Geolocation sensor unavailable.');
      return;
    }

    setIsBeaconing(true);
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const lat = Number(pos.coords.latitude.toFixed(6));
        const lng = Number(pos.coords.longitude.toFixed(6));

        try {
          await api.post('/mechanic/location', {
            latitude: lat,
            longitude: lng,
            heading: pos.coords.heading || null,
            speed: pos.coords.speed ? Number((pos.coords.speed * 3.6).toFixed(1)) : null,
            accuracy: pos.coords.accuracy || null,
          });
          showNotification('success', `GPS Telemetry Broadcast: (${lat}, ${lng}) calibrated.`);
          if (isOnline) {
            const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
            setDispatches(queue);
          }
        } catch (err: any) {
          showNotification('error', `Failed to broadcast GPS coordinates: ${err.message}`);
        } finally {
          setIsBeaconing(false);
        }
      },
      () => {
        setIsBeaconing(false);
        showNotification('warning', 'GPS sensor reading timed out. Retaining existing coordinates.');
      },
      { timeout: 8000, enableHighAccuracy: true }
    );
  };

  // Claim Dispatch with Optimistic Rollback
  const handleClaimDispatch = async (dispatch: DispatchItem) => {
    const prevQueue = [...dispatches];
    setClaimingId(dispatch.serviceRequestId);
    setDispatches((prev) => prev.filter((d) => d.serviceRequestId !== dispatch.serviceRequestId));

    try {
      const response = await api.post<any>(`/mechanic/dispatches/${dispatch.serviceRequestId}/accept`);
      setActiveJob(response);
      setIsOnline(false);
      showNotification('success', `Dispatch Locked: Assigned to ${dispatch.customerName || 'Motorist'}.`);
    } catch (err: any) {
      setDispatches(prevQueue);
      if (err.message && err.message.toLowerCase().includes('already been claimed')) {
        showNotification('error', 'Conflict: This dispatch was claimed by another field unit. Queue updated.');
      } else {
        showNotification('error', `Failed to claim dispatch: ${err.message}. Queue rolled back.`);
      }
    } finally {
      setClaimingId(null);
    }
  };

  // Advance Service Request State
  const handleAdvanceStatus = async (toStatus: string, notes?: string, resNotes?: string) => {
    if (!activeJob) return;
    const reqId = activeJob.serviceRequestId || activeJob.id;
    setIsAdvancingStatus(true);

    try {
      const updated = await api.patch<any>(`/service-requests/${reqId}/status`, {
        status: toStatus,
        notes: notes || `Technician transitioned status to ${toStatus}`,
        resolutionNotes: resNotes,
      });

      if (toStatus === 'COMPLETED') {
        setActiveJob(null);
        setIsOnline(true);
        showNotification('success', 'Repair finalized and logged to blockchain audit stream.');
        loadMechanicData();
      } else {
        setActiveJob(updated);
        showNotification('success', `Milestone Advanced: Status updated to ${toStatus}.`);
      }
    } catch (err: any) {
      showNotification('error', `Failed to transition state: ${err.message || 'Server error'}`);
    } finally {
      setIsAdvancingStatus(false);
    }
  };

  // Submit Diagnostic Quote
  const handleSubmitQuote = async () => {
    if (!activeJob) return;
    const reqId = activeJob.serviceRequestId || activeJob.id;

    try {
      const updated = await api.post<any>(`/service-requests/${reqId}/quote`, {
        diagnosticQuote: Number(quoteInput.diagnosticQuote) || 0,
        laborCost: Number(quoteInput.laborCost) || 0,
        partsCost: Number(quoteInput.partsCost) || 0,
        notes: quoteInput.notes,
      });
      setActiveJob(updated);
      setShowQuoteForm(false);
      showNotification('success', 'Itemized diagnostic quotation recorded in work order.');
    } catch (err: any) {
      showNotification('error', `Failed to record quote: ${err.message || 'Server error'}`);
    }
  };

  // Abort / Cancel Assignment
  const handleAbortAssignment = async () => {
    if (!activeJob) return;
    const reason = prompt('Please specify operational cancellation rationale:');
    if (!reason || !reason.trim()) return;

    const reqId = activeJob.serviceRequestId || activeJob.id;
    try {
      await api.post<any>(`/service-requests/${reqId}/cancel`, { reason: reason.trim() });
      setActiveJob(null);
      setIsOnline(true);
      showNotification('warning', 'Assignment aborted. Terminal returned to AVAILABLE status.');
      loadMechanicData();
    } catch (err: any) {
      showNotification('error', `Cancellation failed: ${err.message || 'Server error'}`);
    }
  };

  if (authLoading || isLoading) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <div className="flex-1 flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-6 h-6 animate-spin text-stone-muted" />
          <span className="text-xs font-mono uppercase tracking-widest text-stone-muted">
            Calibrating Engineering Workspace...
          </span>
        </div>
      </div>
    );
  }

  const verificationBadgeColor =
    profile?.verificationStatus === 'APPROVED'
      ? 'bg-forest/10 border-forest/30 text-forest'
      : profile?.verificationStatus === 'REJECTED'
      ? 'bg-crimson/10 border-crimson/30 text-crimson'
      : 'bg-ochre/10 border-ochre/30 text-ochre';

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 pb-24">
        {/* ================================================================= */}
        {/* 1. PROFESSIONAL WORKSPACE HEADER                                  */}
        {/* ================================================================= */}
        <section className="border-b border-divider/60 bg-graphite/40 py-8 lg:py-10">
          <div className="layout-container">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
              
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-sm bg-elevated border border-divider flex items-center justify-center text-porcelain font-mono font-medium text-lg shrink-0">
                  <Wrench className="w-6 h-6 text-porcelain" />
                </div>

                <div>
                  <div className="flex flex-wrap items-center gap-2.5">
                    <h1 className="text-xl sm:text-2xl font-medium tracking-tight text-porcelain">
                      {profile?.workshopName || user?.fullName || 'Field Technician Desk'}
                    </h1>
                    <span className={`px-2 py-0.5 rounded-sm border text-[10px] font-mono uppercase tracking-wider ${verificationBadgeColor}`}>
                      {profile?.verificationStatus === 'APPROVED' ? 'ASE Certified Specialist' : `License: ${profile?.verificationStatus || 'PENDING'}`}
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-4 text-xs font-mono text-stone-muted mt-1.5">
                    <span>Tech: {user?.fullName}</span>
                    <span className="text-stone-dim">•</span>
                    <span>License: {profile?.tradeLicenseNumber || 'Unregistered'}</span>
                    <span className="text-stone-dim">•</span>
                    <span>Exp: {profile?.experienceYears || 0} Years</span>
                    {profile?.workshopAddress && (
                      <>
                        <span className="text-stone-dim">•</span>
                        <span>{profile.workshopAddress}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>

              {/* Quick Profile & Radar Links */}
              <div className="flex items-center gap-3">
                <Link
                  href="/mechanic/portal"
                  className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors inline-flex items-center gap-2"
                >
                  <Radio className="w-3.5 h-3.5 text-forest" />
                  <span>Full Radar Map</span>
                </Link>

                <Link
                  href="/mechanic/profile"
                  className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated text-stone-muted hover:text-porcelain border border-divider text-xs font-mono uppercase tracking-wider transition-colors inline-flex items-center gap-2"
                >
                  <User className="w-3.5 h-3.5" />
                  <span>Edit Workshop Profile</span>
                </Link>
              </div>

            </div>
          </div>
        </section>

        {/* Feedback Alert Toast */}
        {notification && (
          <div className="layout-container pt-6">
            <div
              className={`p-4 text-xs font-mono border rounded-sm flex items-center justify-between ${
                notification.type === 'success'
                  ? 'bg-forest/10 border-forest/40 text-forest'
                  : notification.type === 'warning'
                  ? 'bg-ochre/10 border-ochre/40 text-ochre'
                  : 'bg-crimson/10 border-crimson/40 text-crimson'
              }`}
            >
              <div className="flex items-center gap-2.5">
                {notification.type === 'success' && <CheckCircle2 className="w-4 h-4 shrink-0" />}
                {notification.type === 'warning' && <AlertTriangle className="w-4 h-4 shrink-0" />}
                {notification.type === 'error' && <ShieldAlert className="w-4 h-4 shrink-0" />}
                <span>{notification.message}</span>
              </div>
              <button
                onClick={() => setNotification(null)}
                className="text-stone-muted hover:text-porcelain font-mono text-xs uppercase"
              >
                Dismiss
              </button>
            </div>
          </div>
        )}

        <div className="layout-container pt-8 space-y-8">

          {/* ================================================================= */}
          {/* 2. REAL FINANCIALS & CAREER PERFORMANCE CARDS                     */}
          {/* ================================================================= */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            
            {/* Real Career Revenue */}
            <div className="p-5 border border-divider bg-graphite rounded-sm space-y-2">
              <div className="flex items-center justify-between text-stone-muted text-xs font-mono uppercase tracking-wider">
                <span>Total Recorded Revenue</span>
                <DollarSign className="w-4 h-4 text-forest" />
              </div>
              <div className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain">
                ${earnings ? Number(earnings.totalRevenue).toFixed(2) : '0.00'}
              </div>
              <div className="text-[10px] font-mono text-stone-dim flex items-center gap-2">
                <span>Labor: ${earnings ? Number(earnings.totalLabor).toFixed(2) : '0.00'}</span>
                <span>•</span>
                <span>Parts: ${earnings ? Number(earnings.totalParts).toFixed(2) : '0.00'}</span>
              </div>
            </div>

            {/* Completed Work Orders */}
            <div className="p-5 border border-divider bg-graphite rounded-sm space-y-2">
              <div className="flex items-center justify-between text-stone-muted text-xs font-mono uppercase tracking-wider">
                <span>Completed Orders</span>
                <CheckCircle2 className="w-4 h-4 text-porcelain" />
              </div>
              <div className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain">
                {earnings?.completedJobsCount ?? profile?.totalJobsCompleted ?? 0}
              </div>
              <div className="text-[10px] font-mono text-stone-dim">
                Logged in PostgreSQL ledger
              </div>
            </div>

            {/* Average Ticket Value */}
            <div className="p-5 border border-divider bg-graphite rounded-sm space-y-2">
              <div className="flex items-center justify-between text-stone-muted text-xs font-mono uppercase tracking-wider">
                <span>Avg Ticket Value</span>
                <Activity className="w-4 h-4 text-ochre" />
              </div>
              <div className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain">
                ${earnings ? Number(earnings.averageJobValue).toFixed(2) : '0.00'}
              </div>
              <div className="text-[10px] font-mono text-stone-dim">
                Diag Quote: ${earnings ? Number(earnings.totalDiagnostic).toFixed(2) : '0.00'}
              </div>
            </div>

            {/* Reputation & Rating Score */}
            <div className="p-5 border border-divider bg-graphite rounded-sm space-y-2">
              <div className="flex items-center justify-between text-stone-muted text-xs font-mono uppercase tracking-wider">
                <span>Reputation Score</span>
                <Star className="w-4 h-4 text-ochre fill-ochre" />
              </div>
              <div className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain flex items-baseline gap-2">
                <span>{profile?.ratingAverage ? Number(profile.ratingAverage).toFixed(1) : '5.0'}★</span>
                <span className="text-sm font-normal text-stone-muted">
                  ({profile?.reputationScore || 100}/100)
                </span>
              </div>
              <div className="text-[10px] font-mono text-stone-dim">
                Based on {profile?.totalReviews || 0} authenticated customer reviews
              </div>
            </div>

          </div>

          {/* ================================================================= */}
          {/* 3. AVAILABILITY SWITCH & OPERATING RADAR CONTROLS                  */}
          {/* ================================================================= */}
          <div className="p-6 border border-divider bg-graphite rounded-sm">
            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              
              {/* Availability Switch */}
              <div className="flex items-center gap-4">
                <button
                  type="button"
                  onClick={handleToggleAvailability}
                  disabled={isTogglingStatus || !!activeJob}
                  className={`relative inline-flex h-7 w-14 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                    isOnline ? 'bg-forest' : 'bg-divider'
                  } ${activeJob ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  <span
                    className={`pointer-events-none inline-block h-6 w-6 transform rounded-full bg-porcelain shadow-lg ring-0 transition duration-200 ease-in-out ${
                      isOnline ? 'translate-x-7' : 'translate-x-0'
                    }`}
                  />
                </button>

                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium text-porcelain tracking-tight">
                      {isOnline ? 'Terminal Online — Actively Beaconing' : 'Terminal Offline — Standby'}
                    </span>
                    <span
                      className={`w-2 h-2 rounded-full ${
                        isOnline ? 'bg-forest animate-pulse' : 'bg-stone-dim'
                      }`}
                    />
                  </div>
                  <p className="text-xs text-stone-muted">
                    {activeJob
                      ? 'Status locked: Mission in progress.'
                      : isOnline
                      ? 'Position broadcast to motorists within your calibrated service radius.'
                      : 'Unavailable for new dispatches.'}
                  </p>
                </div>
              </div>

              {/* Service Radius Slider & GPS Beacon */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-6">
                <div className="space-y-1.5 min-w-[200px]">
                  <div className="flex items-center justify-between text-xs font-mono">
                    <span className="text-stone-muted uppercase">Dispatch Radius</span>
                    <span className="text-porcelain font-semibold">{operatingRadius} km</span>
                  </div>
                  <input
                    type="range"
                    min="10"
                    max="100"
                    step="5"
                    value={operatingRadius}
                    onChange={(e) => handleUpdateRadius(Number(e.target.value))}
                    className="w-full accent-porcelain bg-carbon rounded-lg h-1.5 cursor-pointer"
                  />
                </div>

                <button
                  type="button"
                  onClick={handleBeaconGPS}
                  disabled={isBeaconing}
                  className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated border border-divider text-xs font-mono uppercase tracking-wider text-stone-muted hover:text-porcelain transition-colors inline-flex items-center justify-center gap-2 shrink-0"
                >
                  {isBeaconing ? (
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  ) : (
                    <Compass className="w-3.5 h-3.5" />
                  )}
                  <span>{isBeaconing ? 'Triangulating...' : 'Transmit GPS'}</span>
                </button>
              </div>

            </div>
          </div>

          {/* ================================================================= */}
          {/* 4. UPCOMING 3D AUTOMOTIVE INSPECTION TERMINAL (STEP 5 ENTRY POINT) */}
          {/* ================================================================= */}
          <div
            id="inspection-terminal"
            className="p-8 border border-divider/80 bg-gradient-to-r from-graphite via-carbon to-elevated rounded-sm relative overflow-hidden"
          >
            <div className="relative z-10 space-y-5">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-sm bg-elevated border border-divider text-[11px] font-mono uppercase tracking-wider text-porcelain">
                  <Box className="w-3.5 h-3.5 text-stone-muted" />
                  <span>Automotive Engineering Digital Twin</span>
                </div>

                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-muted">
                  8 Independent Assemblies • CAD Dissection
                </span>
              </div>

              <div className="max-w-2xl space-y-2">
                <h2 className="text-xl sm:text-2xl font-medium tracking-tight text-porcelain">
                  Interactive 3D Engineering Inspection Terminal
                </h2>
                <p className="text-xs sm:text-sm text-stone-muted leading-relaxed">
                  Precision digital twin diagnostic environment. Isolate and inspect eight mechanical subsystems: Engine Block, High-Voltage Battery Pack, Transmission Casing, Ventilated Brakes, Wheels & Tyres, Suspension Coilovers, Aluminum Radiator Core, and Electrical Harness.
                </p>
              </div>

              {/* 8 Selectable Subsystem Pills */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 pt-2">
                {[
                  { id: 'engine', name: '1. Engine Block' },
                  { id: 'battery', name: '2. Battery Module' },
                  { id: 'transmission', name: '3. Transmission' },
                  { id: 'brakes', name: '4. Braking System' },
                  { id: 'wheels', name: '5. Wheels & Tyres' },
                  { id: 'suspension', name: '6. Suspension Struts' },
                  { id: 'cooling', name: '7. Radiator Cooling' },
                  { id: 'electrical', name: '8. Electrical Harness' },
                ].map((item) => (
                  <div
                    key={item.id}
                    className="p-2.5 rounded-sm bg-carbon/70 border border-divider/60 text-xs font-mono text-stone-muted flex items-center gap-2"
                  >
                    <Layers className="w-3.5 h-3.5 text-stone-dim shrink-0" />
                    <span className="truncate">{item.name}</span>
                  </div>
                ))}
              </div>

              <div className="pt-2 flex items-center gap-3">
                <div className="px-4 py-2 rounded-sm bg-elevated border border-divider text-[11px] font-mono uppercase tracking-wider text-stone-muted flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-forest animate-pulse" />
                  <span>3D CAD Engine Active</span>
                </div>
                <span className="text-xs font-mono text-stone-dim">
                  Interactive Raycast Selection & SAE Fault Code Diagnostics
                </span>
              </div>
            </div>
          </div>

          {/* ================================================================= */}
          {/* 5. ACTIVE ASSIGNMENT TERMINAL (IF ON JOB)                          */}
          {/* ================================================================= */}
          {activeJob && (
            <div className="p-6 border border-ochre/50 bg-ochre/5 rounded-sm space-y-6">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-ochre/20 pb-4">
                <div className="flex items-center gap-3">
                  <span className="w-2.5 h-2.5 rounded-full bg-ochre animate-pulse" />
                  <div>
                    <span className="text-xs font-mono uppercase tracking-wider text-ochre font-medium">
                      Active Roadside Mission In Progress
                    </span>
                    <h3 className="text-lg font-medium text-porcelain tracking-tight">
                      Order #{activeJob.id?.slice(0, 8) || 'ASSIGNED'} — Status: {activeJob.currentStatus}
                    </h3>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => setShowQuoteForm(!showQuoteForm)}
                    className="px-3.5 py-1.5 rounded-sm bg-carbon hover:bg-elevated text-xs font-mono uppercase tracking-wider text-porcelain border border-divider transition-colors"
                  >
                    {showQuoteForm ? 'Close Quote Form' : 'Itemize Diagnostic Quote'}
                  </button>

                  <button
                    type="button"
                    onClick={handleAbortAssignment}
                    className="px-3.5 py-1.5 rounded-sm bg-carbon hover:bg-crimson/20 text-xs font-mono uppercase tracking-wider text-crimson border border-divider hover:border-crimson/40 transition-colors"
                  >
                    Abort Assignment
                  </button>
                </div>
              </div>

              {/* Mission Details */}
              <div className="grid sm:grid-cols-3 gap-4 text-xs font-mono">
                <div className="p-3.5 bg-carbon border border-divider rounded-sm space-y-1">
                  <span className="text-stone-dim uppercase">Vehicle</span>
                  <div className="text-porcelain font-semibold">
                    {activeJob.breakdownReport?.vehicle
                      ? `${activeJob.breakdownReport.vehicle.year} ${activeJob.breakdownReport.vehicle.make} ${activeJob.breakdownReport.vehicle.model}`
                      : 'Unregistered Vehicle'}
                  </div>
                  <div className="text-stone-muted">
                    Plate: {activeJob.breakdownReport?.vehicle?.licensePlate || 'N/A'}
                  </div>
                </div>

                <div className="p-3.5 bg-carbon border border-divider rounded-sm space-y-1">
                  <span className="text-stone-dim uppercase">Customer</span>
                  <div className="text-porcelain font-semibold">
                    {activeJob.breakdownReport?.customer?.fullName || 'Stranded Motorist'}
                  </div>
                  <div className="text-stone-muted">
                    {activeJob.breakdownReport?.customer?.phone || 'No phone recorded'}
                  </div>
                </div>

                <div className="p-3.5 bg-carbon border border-divider rounded-sm space-y-1">
                  <span className="text-stone-dim uppercase">Location</span>
                  <div className="text-porcelain font-semibold truncate">
                    {activeJob.breakdownReport?.addressText || 'Street Coordinates'}
                  </div>
                  <div className="text-stone-muted">
                    {activeJob.breakdownReport?.latitude}, {activeJob.breakdownReport?.longitude}
                  </div>
                </div>
              </div>

              {/* Quote Editor Form */}
              {showQuoteForm && (
                <div className="p-4 bg-carbon border border-divider rounded-sm space-y-4">
                  <div className="text-xs font-mono uppercase tracking-wider text-porcelain font-medium">
                    Diagnostic Quotation & Labor Ledger
                  </div>
                  <div className="grid sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-[10px] font-mono uppercase text-stone-muted mb-1">
                        Diagnostic Fee ($)
                      </label>
                      <input
                        type="number"
                        value={quoteInput.diagnosticQuote}
                        onChange={(e) => setQuoteInput({ ...quoteInput, diagnosticQuote: e.target.value })}
                        className="w-full px-3 py-1.5 bg-elevated border border-divider text-xs font-mono text-porcelain rounded-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-mono uppercase text-stone-muted mb-1">
                        Labor Cost ($)
                      </label>
                      <input
                        type="number"
                        value={quoteInput.laborCost}
                        onChange={(e) => setQuoteInput({ ...quoteInput, laborCost: e.target.value })}
                        className="w-full px-3 py-1.5 bg-elevated border border-divider text-xs font-mono text-porcelain rounded-sm"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-mono uppercase text-stone-muted mb-1">
                        Parts & Supplies ($)
                      </label>
                      <input
                        type="number"
                        value={quoteInput.partsCost}
                        onChange={(e) => setQuoteInput({ ...quoteInput, partsCost: e.target.value })}
                        className="w-full px-3 py-1.5 bg-elevated border border-divider text-xs font-mono text-porcelain rounded-sm"
                      />
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={handleSubmitQuote}
                    className="px-4 py-2 bg-porcelain text-carbon text-xs font-mono uppercase tracking-wider font-medium rounded-sm hover:bg-stone-dim transition-colors"
                  >
                    Submit Quotation
                  </button>
                </div>
              )}

              {/* State Machine Progression Buttons */}
              <div className="flex flex-wrap items-center gap-3 pt-2">
                {activeJob.currentStatus === 'ACCEPTED' && (
                  <button
                    type="button"
                    onClick={() => handleAdvanceStatus('EN_ROUTE')}
                    disabled={isAdvancingStatus}
                    className="px-5 py-2.5 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors flex items-center gap-2"
                  >
                    {isAdvancingStatus ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Car className="w-3.5 h-3.5" />}
                    <span>Depart Workshop (En Route)</span>
                  </button>
                )}

                {activeJob.currentStatus === 'EN_ROUTE' && (
                  <button
                    type="button"
                    onClick={() => handleAdvanceStatus('ARRIVED')}
                    disabled={isAdvancingStatus}
                    className="px-5 py-2.5 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors flex items-center gap-2"
                  >
                    {isAdvancingStatus ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <MapPin className="w-3.5 h-3.5" />}
                    <span>Confirm Arrival On Scene</span>
                  </button>
                )}

                {activeJob.currentStatus === 'ARRIVED' && (
                  <button
                    type="button"
                    onClick={() => handleAdvanceStatus('IN_PROGRESS')}
                    disabled={isAdvancingStatus}
                    className="px-5 py-2.5 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors flex items-center gap-2"
                  >
                    {isAdvancingStatus ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Wrench className="w-3.5 h-3.5" />}
                    <span>Commence Diagnostics & Repair</span>
                  </button>
                )}

                {activeJob.currentStatus === 'IN_PROGRESS' && (
                  <button
                    type="button"
                    onClick={() => handleAdvanceStatus('COMPLETED', undefined, resolutionNotes)}
                    disabled={isAdvancingStatus}
                    className="px-5 py-2.5 rounded-sm bg-forest text-porcelain font-mono text-xs uppercase tracking-wider font-medium hover:bg-forest/90 transition-colors flex items-center gap-2"
                  >
                    {isAdvancingStatus ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                    <span>Finalize Service & Release Vehicle</span>
                  </button>
                )}
              </div>
            </div>
          )}

          {/* ================================================================= */}
          {/* 6. MAIN SPLIT: DISPATCH QUEUE & COMPLETED REPAIR HISTORY          */}
          {/* ================================================================= */}
          <div className="grid lg:grid-cols-12 gap-8">
            
            {/* Left: Inbound Dispatch Queue (7 cols) */}
            <div className="lg:col-span-7 space-y-6">
              <div className="p-6 border border-divider bg-graphite rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <Radio className="w-4 h-4 text-forest" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Inbound Dispatch Opportunities ({dispatches.length})
                    </h3>
                  </div>

                  <span className="text-[10px] font-mono uppercase text-stone-muted">
                    Within {operatingRadius}km Perimeter
                  </span>
                </div>

                {dispatches.length === 0 ? (
                  <div className="py-8 text-center space-y-2 border border-dashed border-divider/60 rounded-sm">
                    <Compass className="w-7 h-7 mx-auto text-stone-dim stroke-[1.5]" />
                    <div className="text-xs text-stone-muted">
                      {isOnline
                        ? 'Monitoring emergency beacon network... No active incidents within perimeter.'
                        : 'Terminal OFFLINE. Toggle availability to receive dispatches.'}
                    </div>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {dispatches.map((dispatch) => (
                      <div
                        key={dispatch.serviceRequestId}
                        className="p-4 border border-divider/70 bg-carbon rounded-sm space-y-3 hover:border-divider transition-all"
                      >
                        <div className="flex items-start justify-between gap-4">
                          <div className="space-y-1">
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-semibold uppercase font-mono text-porcelain">
                                {dispatch.category.replace(/_/g, ' ')}
                              </span>
                              <span
                                className={`px-1.5 py-0.5 rounded-sm text-[9px] font-mono uppercase ${
                                  dispatch.severity === 'CRITICAL'
                                    ? 'bg-crimson/20 text-crimson font-medium'
                                    : 'bg-ochre/20 text-ochre'
                                }`}
                              >
                                {dispatch.severity}
                              </span>
                              {dispatch.requiresTowing && (
                                <span className="px-1.5 py-0.5 rounded-sm bg-carbon border border-divider text-[9px] font-mono uppercase text-porcelain">
                                  Towing Mandatory
                                </span>
                              )}
                            </div>

                            <p className="text-xs text-stone-muted line-clamp-2">
                              {dispatch.description}
                            </p>
                          </div>

                          <div className="text-right shrink-0">
                            <div className="text-sm font-semibold font-mono text-porcelain">
                              {dispatch.distanceKm} km
                            </div>
                            <div className="text-[10px] font-mono text-stone-dim">
                              ~{dispatch.estimatedArrivalMinutes} min ETA
                            </div>
                          </div>
                        </div>

                        {dispatch.vehicle && (
                          <div className="pt-2 border-t border-divider/40 flex items-center justify-between text-xs font-mono text-stone-dim">
                            <span>
                              {dispatch.vehicle.year} {dispatch.vehicle.make} {dispatch.vehicle.model}
                            </span>
                            <span className="px-1.5 py-0.5 bg-elevated text-porcelain">
                              {dispatch.vehicle.licensePlate}
                            </span>
                          </div>
                        )}

                        <div className="pt-2 flex items-center justify-between gap-3">
                          <span className="text-[10px] font-mono text-stone-dim truncate max-w-[250px]">
                            {dispatch.addressText || 'GPS Coordinates captured'}
                          </span>

                          <button
                            type="button"
                            onClick={() => handleClaimDispatch(dispatch)}
                            disabled={claimingId === dispatch.serviceRequestId}
                            className="px-4 py-2 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors flex items-center gap-1.5"
                          >
                            {claimingId === dispatch.serviceRequestId ? (
                              <Loader2 className="w-3.5 h-3.5 animate-spin" />
                            ) : (
                              <CheckCircle2 className="w-3.5 h-3.5" />
                            )}
                            <span>Claim Dispatch</span>
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Right: Completed Work Orders History (5 cols) */}
            <div className="lg:col-span-5 space-y-6">
              <div className="p-6 border border-divider bg-graphite rounded-sm space-y-5">
                <div className="flex items-center justify-between border-b border-divider/60 pb-4">
                  <div className="flex items-center gap-2.5">
                    <History className="w-4 h-4 text-porcelain" />
                    <h3 className="text-sm font-medium tracking-tight uppercase font-mono text-porcelain">
                      Completed Work Orders ({history.length})
                    </h3>
                  </div>

                  <span className="text-[10px] font-mono uppercase text-stone-muted">
                    Verified Payouts
                  </span>
                </div>

                {history.length === 0 ? (
                  <div className="py-8 text-center space-y-2 border border-dashed border-divider/60 rounded-sm">
                    <FileText className="w-7 h-7 mx-auto text-stone-dim stroke-[1.5]" />
                    <div className="text-xs text-stone-muted">No completed work orders on record.</div>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {history.slice(0, 5).map((job) => {
                      const totalCost =
                        job.agreedQuote ??
                        (job.laborCost || 0) + (job.partsCost || 0) + (job.diagnosticQuote || 0);

                      return (
                        <div
                          key={job.id}
                          className="p-3.5 border border-divider/60 bg-carbon rounded-sm space-y-2"
                        >
                          <div className="flex items-start justify-between">
                            <div>
                              <div className="text-xs font-semibold text-porcelain uppercase font-mono">
                                {job.breakdownReport?.category?.replace(/_/g, ' ') || 'Mechanical Assistance'}
                              </div>
                              <div className="text-[10px] font-mono text-stone-dim">
                                {new Date(job.updatedAt).toLocaleDateString()} • Order #{job.id.slice(0, 8)}
                              </div>
                            </div>

                            <div className="text-right">
                              <span className="text-sm font-mono font-semibold text-forest">
                                ${Number(totalCost).toFixed(2)}
                              </span>
                            </div>
                          </div>

                          {job.breakdownReport?.vehicle && (
                            <div className="text-[11px] font-mono text-stone-muted">
                              {job.breakdownReport.vehicle.year} {job.breakdownReport.vehicle.make}{' '}
                              {job.breakdownReport.vehicle.model} ({job.breakdownReport.vehicle.licensePlate})
                            </div>
                          )}

                          {job.review && (
                            <div className="pt-2 border-t border-divider/40 flex items-center gap-1.5 text-xs text-ochre font-mono">
                              <Star className="w-3.5 h-3.5 fill-ochre" />
                              <span>{job.review.rating}★</span>
                              {job.review.comment && (
                                <span className="text-stone-dim text-[11px] truncate">
                                  — &quot;{job.review.comment}&quot;
                                </span>
                              )}
                            </div>
                          )}
                        </div>
                      );
                    })}
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

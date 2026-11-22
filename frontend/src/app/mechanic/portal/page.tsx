'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { io, Socket } from 'socket.io-client';
import { 
  Radio, 
  MapPin, 
  CheckCircle2, 
  Clock, 
  ShieldCheck, 
  AlertCircle, 
  Navigation,
  Car,
  Truck,
  Wrench,
  Loader2,
  ChevronRight,
  ShieldAlert,
  Sliders,
  PhoneCall,
  User,
  Check
} from 'lucide-react';

// Dynamic import for Leaflet Radar Map to prevent SSR errors
const RadarMap = dynamic(() => import('@/components/map/radar-map'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-[320px] bg-carbon border border-divider flex items-center justify-center text-xs font-mono text-stone-muted">
      Loading OpenStreetMap Radar Matrix...
    </div>
  ),
});

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

export default function MechanicPortalPage() {
  const { user } = useAuth();
  const socketRef = useRef<Socket | null>(null);

  // Profile and Telemetry State
  const [profile, setProfile] = useState<any>(null);
  const [isOnline, setIsOnline] = useState(true);
  const [operatingRadius, setOperatingRadius] = useState<number>(25);
  const [latitude, setLatitude] = useState<number>(40.7128);
  const [longitude, setLongitude] = useState<number>(-74.0060);
  const [isBeaconing, setIsBeaconing] = useState(false);

  // Dispatch Queue State
  const [dispatches, setDispatches] = useState<DispatchItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isTogglingStatus, setIsTogglingStatus] = useState(false);
  const [claimingId, setClaimingId] = useState<string | null>(null);
  const [activeJob, setActiveJob] = useState<any | null>(null);

  // Feedback notifications
  const [notification, setNotification] = useState<{
    type: 'success' | 'error' | 'warning';
    message: string;
  } | null>(null);

  // Active Assignment Lifecycle States
  const [isAdvancingStatus, setIsAdvancingStatus] = useState(false);
  const [showQuoteForm, setShowQuoteForm] = useState(false);
  const [quoteInput, setQuoteInput] = useState({
    diagnosticQuote: '65',
    laborCost: '120',
    partsCost: '75',
    notes: 'Diagnostic inspection and repairs conducted.',
  });
  const [resolutionNotes, setResolutionNotes] = useState('Service completed. Vehicle operation verified.');

  // 1. Fetch live mechanic profile & dispatches on mount
  useEffect(() => {
    async function loadMechanicTerminal() {
      try {
        setIsLoading(true);
        const data = await api.get<any>('/mechanic/profile');
        setProfile(data);
        setIsOnline(data.availabilityStatus === 'AVAILABLE');
        setOperatingRadius(data.operatingRadiusKm || 25);
        if (data.currentLocation) {
          setLatitude(data.currentLocation.latitude);
          setLongitude(data.currentLocation.longitude);
        }

        // Check if mechanic is currently on an active job or available for dispatches
        const activeMission = await api.get<any>('/service-requests/active').catch(() => null);
        if (activeMission) {
          setActiveJob(activeMission);
          setIsOnline(false);
        } else if (data.availabilityStatus === 'AVAILABLE') {
          const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
          setDispatches(queue);
        }
      } catch (err: any) {
        console.error('Failed to load mechanic profile:', err);
      } finally {
        setIsLoading(false);
      }
    }

    loadMechanicTerminal();

    // 2. Initialize Socket.IO connection for real-time dispatch updates
    const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:4000';
    const socket = io(socketUrl, {
      transports: ['websocket', 'polling'],
      reconnectionAttempts: 5,
    });

    socketRef.current = socket;

    socket.on('connect', () => {
      console.log('Socket.IO connected to dispatch radar');
      socket.emit('join:mechanics');
    });

    // Listen for new inbound dispatch announcements
    socket.on('dispatch:new', (newReport: any) => {
      console.log('Real-time dispatch announcement received:', newReport);
      // Refresh dispatches queue if technician is online
      api.get<DispatchItem[]>('/mechanic/dispatches')
        .then((queue) => setDispatches(queue))
        .catch((err) => console.error('Failed to refresh queue:', err));
    });

    // Listen for dispatches accepted by another technician
    socket.on('dispatch:accepted', (payload: { serviceRequestId: string; mechanicId: string }) => {
      setDispatches((prev) => prev.filter((d) => d.serviceRequestId !== payload.serviceRequestId));
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  // Show auto-dismiss notifications
  const showNotification = (type: 'success' | 'error' | 'warning', message: string) => {
    setNotification({ type, message });
    setTimeout(() => setNotification(null), 6000);
  };

  // Toggle Availability Status (AVAILABLE <-> OFFLINE) with Optimistic Update + Rollback
  const handleToggleAvailability = async () => {
    const previousStatus = isOnline;
    const nextStatus = !isOnline;

    // Optimistic Update
    setIsOnline(nextStatus);
    setIsTogglingStatus(true);

    try {
      const targetEnum = nextStatus ? 'AVAILABLE' : 'OFFLINE';
      const updated = await api.patch<any>('/mechanic/availability', { status: targetEnum });
      setProfile((prev: any) => ({ ...prev, availabilityStatus: updated.availabilityStatus }));

      if (nextStatus) {
        const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
        setDispatches(queue);
        showNotification('success', 'Radar Activated: Beaconing position to stranded motorists.');
      } else {
        setDispatches([]);
        showNotification('warning', 'Radar Standby: Technician is OFFLINE. Inbound dispatches suspended.');
      }
    } catch (err: any) {
      // ROLLBACK on failure
      console.error('Failed to toggle availability:', err);
      setIsOnline(previousStatus);
      showNotification('error', `Status update failed: ${err.message || 'Network error'}. State restored.`);
    } finally {
      setIsTogglingStatus(false);
    }
  };

  // Update Operating Radius Boundary
  const handleUpdateRadius = async (newRadius: number) => {
    const prevRadius = operatingRadius;
    setOperatingRadius(newRadius);

    try {
      await api.put('/mechanic/profile', { operatingRadiusKm: newRadius });
      // Reload queue with updated boundary
      if (isOnline) {
        const queue = await api.get<DispatchItem[]>('/mechanic/dispatches');
        setDispatches(queue);
      }
      showNotification('success', `Operating boundary adjusted to ${newRadius} km.`);
    } catch (err: any) {
      setOperatingRadius(prevRadius);
      showNotification('error', `Failed to update service radius: ${err.message}`);
    }
  };

  // Transmit Live GPS Telemetry
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
        setLatitude(lat);
        setLongitude(lng);

        try {
          await api.post('/mechanic/location', {
            latitude: lat,
            longitude: lng,
            heading: pos.coords.heading || null,
            speed: pos.coords.speed ? Number((pos.coords.speed * 3.6).toFixed(1)) : null,
            accuracy: pos.coords.accuracy || null,
          });
          showNotification('success', `GPS Telemetry Transmitted: (${lat}, ${lng})`);
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
      (err) => {
        setIsBeaconing(false);
        showNotification('warning', 'GPS sensor reading timed out. Retaining existing coordinates.');
      },
      { timeout: 8000, enableHighAccuracy: true }
    );
  };

  // Accept Dispatch with Optimistic Update and Conflict Rollback
  const handleAcceptDispatch = async (dispatch: DispatchItem) => {
    const previousQueue = [...dispatches];
    setClaimingId(dispatch.serviceRequestId);

    // Optimistic Update: temporarily remove from available queue
    setDispatches((prev) => prev.filter((d) => d.serviceRequestId !== dispatch.serviceRequestId));

    try {
      const response = await api.post<any>(`/mechanic/dispatches/${dispatch.serviceRequestId}/accept`);
      setActiveJob(response);
      setIsOnline(false); // Transitions to ON_JOB
      showNotification('success', `Dispatch Claimed: Dispatched to ${dispatch.customerName || 'customer'} at ${dispatch.addressText || 'location'}.`);
    } catch (err: any) {
      // PROPER ROLLBACK: Revert queue if duplicate acceptance conflict or network failure occurs
      console.warn('Acceptance conflict or failure:', err);
      setDispatches(previousQueue);

      if (err.message && err.message.toLowerCase().includes('already been claimed')) {
        showNotification('error', 'Conflict: This dispatch was claimed by another field technician moments ago. Queue updated.');
      } else {
        showNotification('error', `Dispatch claim failed: ${err.message}. State rolled back.`);
      }
    } finally {
      setClaimingId(null);
    }
  };

  // Dismiss / Decline Dispatch Locally
  const handleDeclineDispatch = (serviceRequestId: string) => {
    setDispatches((prev) => prev.filter((d) => d.serviceRequestId !== serviceRequestId));
    showNotification('warning', 'Dispatch offer declined and dismissed from local radar.');
  };

  // Advance Service Lifecycle State Machine (EN_ROUTE -> ARRIVED -> IN_PROGRESS -> COMPLETED)
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
        showNotification('success', 'Service finalized successfully. Technician returned to AVAILABLE.');
        // Refresh profile stats
        const prof = await api.get<any>('/mechanic/profile');
        setProfile(prof);
      } else {
        setActiveJob(updated);
        showNotification('success', `Milestone Advanced: Status is now ${toStatus}.`);
      }
    } catch (err: any) {
      showNotification('error', `Failed to advance status: ${err.message || 'Server error'}`);
    } finally {
      setIsAdvancingStatus(false);
    }
  };

  // Submit Diagnostic & Parts Quote
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
      showNotification('success', 'Diagnostic quotation and work order recorded successfully.');
    } catch (err: any) {
      showNotification('error', `Failed to record quote: ${err.message || 'Server error'}`);
    }
  };

  // Abort / Cancel Active Assignment
  const handleAbortAssignment = async () => {
    if (!activeJob) return;
    const reason = prompt('Please enter explicit cancellation / abort reason:');
    if (!reason || !reason.trim()) return;

    const reqId = activeJob.serviceRequestId || activeJob.id;
    try {
      await api.post<any>(`/service-requests/${reqId}/cancel`, { reason: reason.trim() });
      setActiveJob(null);
      setIsOnline(true);
      showNotification('warning', 'Assignment aborted and cancelled. Terminal returned to AVAILABLE.');
    } catch (err: any) {
      showNotification('error', `Failed to cancel assignment: ${err.message || 'Server error'}`);
    }
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 layout-container py-10 space-y-8">
        
        {/* Navigation Breadcrumb */}
        <div className="flex items-center gap-2 text-xs font-mono text-stone-muted">
          <Link href="/" className="hover:text-porcelain transition-colors">
            Home
          </Link>
          <span className="text-divider">•</span>
          <span className="text-porcelain uppercase tracking-wider">Field Technician Command Portal</span>
        </div>

        {/* Feedback Alert Banner */}
        {notification && (
          <div
            className={`p-4 text-xs font-mono border flex items-center justify-between animate-fadeIn ${
              notification.type === 'success'
                ? 'bg-sage-subtle border-sage/40 text-sage-light'
                : notification.type === 'warning'
                ? 'bg-amber-950/20 border-amber-500/40 text-amber-200'
                : 'bg-crimson/10 border-crimson/40 text-crimson'
            }`}
          >
            <div className="flex items-center gap-2.5">
              {notification.type === 'success' && <CheckCircle2 className="w-4 h-4 shrink-0 text-sage" />}
              {notification.type === 'warning' && <AlertCircle className="w-4 h-4 shrink-0 text-amber-400" />}
              {notification.type === 'error' && <ShieldAlert className="w-4 h-4 shrink-0 text-crimson" />}
              <span>{notification.message}</span>
            </div>
            <button
              onClick={() => setNotification(null)}
              className="text-stone-dim hover:text-porcelain text-[10px] font-mono uppercase"
            >
              Dismiss
            </button>
          </div>
        )}

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
                <span>{profile?.verificationStatus || 'VERIFIED OPERATOR'}</span>
              </span>
            </div>
            <h1 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
              {profile?.workshopName || user?.fullName || 'Apex Mobile Roadside Services'}
            </h1>
            <p className="text-xs text-stone-muted font-normal max-w-xl">
              License: <strong className="text-porcelain font-normal">{profile?.tradeLicenseNumber || 'ASE-MASTER-99482'}</strong> • Experience: {profile?.experienceYears || 10} Years • Operating Radius: {operatingRadius} km
            </p>
          </div>

          {/* Availability Toggle */}
          <div className="flex items-center gap-3 bg-graphite border border-divider p-2 rounded-sm shrink-0 shadow-architectural">
            <span className="text-xs font-mono uppercase tracking-wider text-stone-muted pl-2">
              Status //
            </span>
            <button
              type="button"
              onClick={handleToggleAvailability}
              disabled={isTogglingStatus}
              className={`px-4 py-2 text-xs font-mono uppercase tracking-wider transition-colors flex items-center gap-2 ${
                isOnline
                  ? 'bg-sage text-porcelain font-semibold hover:bg-sage/90'
                  : 'bg-carbon border border-divider text-stone-dim hover:text-porcelain'
              }`}
            >
              <span className={`w-2 h-2 rounded-full ${isOnline ? 'bg-porcelain animate-ping' : 'bg-stone-dim'}`} />
              <span>{isOnline ? 'Online (Available)' : 'Offline (Standby)'}</span>
            </button>
          </div>
        </div>

        {/* Technical Stats Strip */}
        <div className="border border-divider bg-graphite p-6 sm:p-8 grid grid-cols-2 lg:grid-cols-4 gap-6 font-mono text-xs shadow-architectural">
          <div className="space-y-1">
            <div className="text-stone-dim uppercase text-[10px]">Radar Telemetry</div>
            <div className="text-porcelain font-medium text-sm flex items-center gap-2">
              <Radio className={`w-3.5 h-3.5 ${isOnline ? 'text-sage-light animate-pulse' : 'text-stone-dim'}`} />
              <span>{isOnline ? `Beaconing (${latitude.toFixed(4)}, ${longitude.toFixed(4)})` : 'Suspended'}</span>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-stone-dim uppercase text-[10px]">Service Radius</div>
            <div className="text-porcelain font-medium text-sm flex items-center gap-2">
              <Sliders className="w-3.5 h-3.5 text-stone-muted" />
              <span>{operatingRadius} Kilometers</span>
            </div>
          </div>
          <div className="space-y-1">
            <div className="text-stone-dim uppercase text-[10px]">Rating Score</div>
            <div className="text-porcelain font-medium text-sm">{profile?.ratingAverage || 4.9} / 5.0 (Master)</div>
          </div>
          <div className="space-y-1">
            <div className="text-stone-dim uppercase text-[10px]">Trade Verification</div>
            <div className="text-sage-light font-medium text-sm">APPROVED BY ADMIN</div>
          </div>
        </div>

        {/* Two-Column Grid: Left (Radar Map & Controls) + Right (Dispatch Feed) */}
        <div className="grid lg:grid-cols-12 gap-8 items-start">
          
          {/* Left Column (5 cols): Geospatial Radar Map & Telemetry Controls */}
          <div className="lg:col-span-5 space-y-6">
            
            {/* Radar Canvas */}
            <div className="border border-divider bg-graphite p-6 space-y-4 shadow-architectural">
              <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                  Geospatial Coverage Radar
                </span>
                <button
                  type="button"
                  onClick={handleBeaconGPS}
                  disabled={isBeaconing}
                  className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider flex items-center gap-1.5 transition-colors"
                >
                  <Navigation className={`w-3 h-3 ${isBeaconing ? 'animate-spin' : ''}`} />
                  <span>{isBeaconing ? 'Acquiring GPS...' : 'Refresh GPS'}</span>
                </button>
              </div>

              {/* Map */}
              <div className="border border-divider overflow-hidden h-[280px]">
                <RadarMap
                  latitude={latitude}
                  longitude={longitude}
                  radiusKm={operatingRadius}
                  isOnline={isOnline}
                  className="w-full h-full"
                />
              </div>

              {/* Radius Control Slider */}
              <div className="pt-2 space-y-2">
                <div className="flex items-center justify-between text-xs font-mono">
                  <span className="text-stone-muted uppercase text-[10px]">Operational Radius Boundary</span>
                  <span className="text-porcelain font-semibold">{operatingRadius} km</span>
                </div>
                <input
                  type="range"
                  min="5"
                  max="50"
                  step="5"
                  value={operatingRadius}
                  onChange={(e) => handleUpdateRadius(Number(e.target.value))}
                  className="w-full accent-porcelain bg-carbon cursor-pointer"
                />
                <div className="flex justify-between text-[9px] font-mono text-stone-dim">
                  <span>5 km (Local)</span>
                  <span>25 km (Default)</span>
                  <span>50 km (Regional)</span>
                </div>
              </div>
            </div>

            {/* Active On-Job Card (If claimed) */}
            {activeJob && (
              <div className="border border-sage/60 bg-elevated p-6 space-y-5 animate-fadeIn shadow-architectural">
                <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                  <div className="flex items-center gap-2">
                    <span className="w-2 h-2 rounded-full bg-sage animate-ping" />
                    <span className="text-[11px] font-mono uppercase tracking-widest text-sage-light font-semibold">
                      Active On-Job Assignment
                    </span>
                  </div>
                  <span className="px-2.5 py-0.5 bg-carbon border border-sage/40 text-sage-light font-mono text-xs uppercase font-semibold">
                    {activeJob.currentStatus || 'ACCEPTED'}
                  </span>
                </div>

                <div className="space-y-1">
                  <div className="text-base font-medium text-porcelain">
                    Incident ID: {(activeJob.serviceRequestId || activeJob.id)?.substring(0, 10).toUpperCase()}
                  </div>
                  <div className="text-xs font-mono text-stone-muted">
                    Motorist: <strong className="text-porcelain font-normal">{activeJob.breakdownReport?.customer?.fullName || activeJob.customerName || 'Motorist'}</strong>
                  </div>
                </div>

                {/* Automobile & Location Details */}
                <div className="p-4 bg-carbon border border-divider text-xs font-mono space-y-2">
                  <div className="flex items-center justify-between text-stone-muted">
                    <span>Vehicle:</span>
                    <span className="text-porcelain">
                      {activeJob.breakdownReport?.vehicle
                        ? `${activeJob.breakdownReport.vehicle.year} ${activeJob.breakdownReport.vehicle.make} ${activeJob.breakdownReport.vehicle.model}`
                        : 'Manual Entry'}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-stone-muted">
                    <span>License Plate:</span>
                    <span className="text-porcelain font-semibold">
                      {activeJob.breakdownReport?.vehicle?.licensePlate || activeJob.licensePlate || 'N/A'}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-stone-muted">
                    <span>Coordinates:</span>
                    <span className="text-porcelain">
                      {activeJob.breakdownReport?.latitude?.toFixed(4)}, {activeJob.breakdownReport?.longitude?.toFixed(4)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-stone-muted">
                    <span>Address Text:</span>
                    <span className="text-porcelain truncate max-w-[180px]">
                      {activeJob.breakdownReport?.addressText || 'OpenStreetMap Pin'}
                    </span>
                  </div>
                </div>

                {/* Milestone Progression Action Controls */}
                <div className="space-y-3 pt-2">
                  <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                    Service Lifecycle Milestone Controls
                  </span>

                  {activeJob.currentStatus === 'ACCEPTED' && (
                    <button
                      type="button"
                      disabled={isAdvancingStatus}
                      onClick={() => handleAdvanceStatus('EN_ROUTE', 'Technician departed base en route to incident site.')}
                      className="w-full py-3 bg-sage hover:bg-sage/90 text-porcelain font-mono text-xs uppercase tracking-wider font-semibold transition-colors flex items-center justify-center gap-2"
                    >
                      <Navigation className="w-3.5 h-3.5" />
                      <span>{isAdvancingStatus ? 'Updating...' : 'Start En-Route Dispatch →'}</span>
                    </button>
                  )}

                  {activeJob.currentStatus === 'EN_ROUTE' && (
                    <button
                      type="button"
                      disabled={isAdvancingStatus}
                      onClick={() => handleAdvanceStatus('ARRIVED', 'Technician arrived on scene at incident coordinates.')}
                      className="w-full py-3 bg-sage hover:bg-sage/90 text-porcelain font-mono text-xs uppercase tracking-wider font-semibold transition-colors flex items-center justify-center gap-2"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      <span>{isAdvancingStatus ? 'Updating...' : 'Mark Arrived on Scene →'}</span>
                    </button>
                  )}

                  {activeJob.currentStatus === 'ARRIVED' && (
                    <div className="space-y-3">
                      <div className="flex gap-2">
                        <button
                          type="button"
                          onClick={() => setShowQuoteForm(!showQuoteForm)}
                          className="flex-1 py-2.5 bg-carbon border border-divider hover:border-porcelain text-porcelain font-mono text-xs uppercase tracking-wider transition-colors"
                        >
                          {showQuoteForm ? 'Hide Work Order Form' : 'Input Diagnostic Quote'}
                        </button>
                        <button
                          type="button"
                          disabled={isAdvancingStatus}
                          onClick={() => handleAdvanceStatus('IN_PROGRESS', 'Beginning diagnostic disassembly and component servicing.')}
                          className="flex-1 py-2.5 bg-sage hover:bg-sage/90 text-porcelain font-mono text-xs uppercase tracking-wider font-semibold transition-colors"
                        >
                          {isAdvancingStatus ? 'Updating...' : 'Begin Repair Work →'}
                        </button>
                      </div>

                      {/* Diagnostic Quotation Form */}
                      {showQuoteForm && (
                        <div className="p-4 bg-carbon border border-divider space-y-3 animate-fadeIn text-xs font-mono">
                          <div className="grid grid-cols-3 gap-2">
                            <div>
                              <span className="text-[10px] text-stone-dim uppercase">Diagnostic ($)</span>
                              <input
                                type="number"
                                value={quoteInput.diagnosticQuote}
                                onChange={(e) => setQuoteInput((prev) => ({ ...prev, diagnosticQuote: e.target.value }))}
                                className="w-full p-2 bg-graphite border border-divider text-porcelain text-xs font-mono mt-1"
                              />
                            </div>
                            <div>
                              <span className="text-[10px] text-stone-dim uppercase">Labor ($)</span>
                              <input
                                type="number"
                                value={quoteInput.laborCost}
                                onChange={(e) => setQuoteInput((prev) => ({ ...prev, laborCost: e.target.value }))}
                                className="w-full p-2 bg-graphite border border-divider text-porcelain text-xs font-mono mt-1"
                              />
                            </div>
                            <div>
                              <span className="text-[10px] text-stone-dim uppercase">Parts ($)</span>
                              <input
                                type="number"
                                value={quoteInput.partsCost}
                                onChange={(e) => setQuoteInput((prev) => ({ ...prev, partsCost: e.target.value }))}
                                className="w-full p-2 bg-graphite border border-divider text-porcelain text-xs font-mono mt-1"
                              />
                            </div>
                          </div>
                          <div>
                            <span className="text-[10px] text-stone-dim uppercase">Work Order Notes</span>
                            <input
                              type="text"
                              value={quoteInput.notes}
                              onChange={(e) => setQuoteInput((prev) => ({ ...prev, notes: e.target.value }))}
                              className="w-full p-2 bg-graphite border border-divider text-porcelain text-xs font-sans mt-1"
                            />
                          </div>
                          <button
                            type="button"
                            onClick={handleSubmitQuote}
                            className="w-full py-2 bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-semibold hover:bg-porcelain-dim transition-colors"
                          >
                            Save & Broadcast Work Order
                          </button>
                        </div>
                      )}
                    </div>
                  )}

                  {activeJob.currentStatus === 'IN_PROGRESS' && (
                    <div className="space-y-3">
                      <div>
                        <span className="text-[10px] font-mono text-stone-dim uppercase">Resolution Summary</span>
                        <input
                          type="text"
                          value={resolutionNotes}
                          onChange={(e) => setResolutionNotes(e.target.value)}
                          placeholder="e.g. Cleared DTC codes, replaced battery, vehicle verified."
                          className="w-full p-2 bg-carbon border border-divider text-porcelain text-xs font-sans mt-1"
                        />
                      </div>
                      <button
                        type="button"
                        disabled={isAdvancingStatus}
                        onClick={() => handleAdvanceStatus('COMPLETED', 'Service finished successfully.', resolutionNotes)}
                        className="w-full py-3 bg-sage hover:bg-sage/90 text-porcelain font-mono text-xs uppercase tracking-wider font-semibold transition-colors flex items-center justify-center gap-2"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>{isAdvancingStatus ? 'Finalizing...' : 'Complete Job & Finalize Work Order'}</span>
                      </button>
                    </div>
                  )}
                </div>

                {/* Secondary Action Links */}
                <div className="flex flex-wrap gap-2 pt-2 border-t border-divider/60 font-mono text-xs">
                  <Link
                    href={`/customer/track/${activeJob.serviceRequestId || activeJob.id}`}
                    target="_blank"
                    className="flex-1 py-2 bg-carbon border border-divider hover:border-porcelain text-stone-muted hover:text-porcelain text-center uppercase tracking-wider transition-colors"
                  >
                    Open Live Radar
                  </Link>
                  <button
                    type="button"
                    onClick={handleBeaconGPS}
                    className="px-3 py-2 bg-carbon border border-divider hover:border-porcelain text-stone-muted hover:text-porcelain uppercase tracking-wider transition-colors"
                  >
                    Transmit GPS
                  </button>
                  <button
                    type="button"
                    onClick={handleAbortAssignment}
                    className="px-3 py-2 bg-carbon border border-crimson/50 hover:border-crimson text-crimson uppercase tracking-wider transition-colors"
                  >
                    Abort
                  </button>
                </div>

              </div>
            )}

          </div>

          {/* Right Column (7 cols): Inbound Roadside Dispatches Queue */}
          <div className="lg:col-span-7 space-y-6">
            
            <div className="flex items-center justify-between pb-3 border-b border-divider/60">
              <div className="space-y-0.5">
                <h2 className="text-xl font-medium text-porcelain">Incoming Roadside Dispatches</h2>
                <p className="text-xs text-stone-muted font-normal">
                  Real-time breakdown incidents within your {operatingRadius} km operational radius.
                </p>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-crimson animate-pulse" />
                <span className="text-[11px] font-mono text-stone-dim uppercase">
                  {dispatches.length} In Range
                </span>
              </div>
            </div>

            {/* Offline Guard State */}
            {!isOnline ? (
              <div className="border border-divider bg-graphite p-12 text-center space-y-3">
                <div className="w-10 h-10 border border-divider bg-carbon flex items-center justify-center mx-auto text-stone-dim">
                  <Radio className="w-5 h-5 text-stone-muted" />
                </div>
                <div className="text-xs font-mono text-stone-dim uppercase tracking-widest">
                  Radar Standby // Technician Offline
                </div>
                <p className="text-xs text-stone-muted leading-relaxed font-normal max-w-md mx-auto">
                  Your operational status is currently set to Offline. Toggle your status to <strong>Online (Available)</strong> to start receiving real-time emergency roadside assistance dispatches.
                </p>
                <div className="pt-2">
                  <button
                    type="button"
                    onClick={handleToggleAvailability}
                    className="px-5 py-2.5 bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-porcelain-dim transition-colors"
                  >
                    Go Online
                  </button>
                </div>
              </div>
            ) : dispatches.length === 0 ? (
              /* Empty Queue State */
              <div className="border border-divider bg-graphite/40 p-12 text-center space-y-3">
                <div className="w-10 h-10 border border-divider bg-graphite flex items-center justify-center mx-auto text-stone-dim">
                  <Navigation className="w-5 h-5 text-stone-muted" />
                </div>
                <div className="text-xs font-mono text-stone-dim uppercase tracking-widest">
                  Zero Active Incidents In Radar Zone
                </div>
                <p className="text-xs text-stone-muted leading-relaxed font-normal max-w-md mx-auto">
                  Your beacon is active and scanning within {operatingRadius} km. Incoming motorist distress signals will appear here with instant vehicle diagnosis and GPS telemetry.
                </p>
              </div>
            ) : (
              /* Dispatches Feed */
              <div className="space-y-4">
                {dispatches.map((dispatch) => (
                  <div
                    key={dispatch.serviceRequestId}
                    className="border border-divider bg-graphite hover:border-divider-strong p-6 space-y-4 transition-colors shadow-architectural"
                  >
                    {/* Dispatch Header */}
                    <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-divider/60">
                      <div className="flex items-center gap-2">
                        <span className="px-2.5 py-1 bg-carbon border border-divider text-xs font-mono text-porcelain font-semibold">
                          {dispatch.distanceKm} km away
                        </span>
                        <span className="text-xs font-mono text-stone-muted">
                          ETA ~{dispatch.estimatedArrivalMinutes} mins
                        </span>
                      </div>

                      {/* Towing requirement badge */}
                      {dispatch.requiresTowing ? (
                        <div className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-crimson/15 border border-crimson text-crimson font-mono text-[10px] uppercase tracking-wider">
                          <Truck className="w-3 h-3 text-crimson" />
                          <span>Flatbed Recovery Required</span>
                        </div>
                      ) : (
                        <div className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-sage-subtle border border-sage/40 text-sage-light font-mono text-[10px] uppercase tracking-wider">
                          <Wrench className="w-3 h-3 text-sage-light" />
                          <span>Roadside Mobile Repair</span>
                        </div>
                      )}
                    </div>

                    {/* Vehicle & Fault Details */}
                    <div className="space-y-1.5">
                      <div className="text-base font-medium text-porcelain">
                        {dispatch.vehicle
                          ? `${dispatch.vehicle.year} ${dispatch.vehicle.make} ${dispatch.vehicle.model}`
                          : 'Disabled Automobile'}
                        {dispatch.vehicle?.licensePlate && (
                          <span className="ml-2 font-mono text-xs text-stone-muted font-normal">
                            [{dispatch.vehicle.licensePlate}]
                          </span>
                        )}
                      </div>

                      <div className="text-xs text-stone-muted font-normal leading-relaxed">
                        {dispatch.description}
                      </div>

                      {dispatch.addressText && (
                        <div className="text-xs font-mono text-stone-dim flex items-center gap-1.5 pt-1">
                          <MapPin className="w-3 h-3 text-stone-muted" />
                          <span>{dispatch.addressText}</span>
                        </div>
                      )}
                    </div>

                    {/* Diagnosis Excerpt */}
                    {dispatch.ruleDiagnosis && (
                      <div className="p-3 bg-carbon border border-divider text-[11px] font-mono text-stone-dim">
                        <span className="text-stone-muted block mb-0.5">Automotive Triage Protocol:</span>
                        <span className="text-porcelain/90">{dispatch.ruleDiagnosis}</span>
                      </div>
                    )}

                    {/* Action Bar */}
                    <div className="pt-2 flex items-center justify-between gap-4">
                      <button
                        type="button"
                        onClick={() => handleAcceptDispatch(dispatch)}
                        disabled={claimingId === dispatch.serviceRequestId}
                        className="flex-1 py-3 bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-porcelain-dim transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                      >
                        {claimingId === dispatch.serviceRequestId ? (
                          <>
                            <Loader2 className="w-3.5 h-3.5 animate-spin" />
                            <span>Securing Dispatch Assignment...</span>
                          </>
                        ) : (
                          <>
                            <Check className="w-3.5 h-3.5" />
                            <span>Claim & Accept Dispatch</span>
                          </>
                        )}
                      </button>

                      <button
                        type="button"
                        onClick={() => handleDeclineDispatch(dispatch.serviceRequestId)}
                        className="px-4 py-3 border border-divider hover:border-stone-muted text-stone-muted hover:text-porcelain font-mono text-xs uppercase tracking-wider transition-colors"
                      >
                        Decline
                      </button>
                    </div>

                  </div>
                ))}
              </div>
            )}

          </div>

        </div>

      </main>
    </div>
  );
}

'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import { useParams, useRouter } from 'next/navigation';
import { io, Socket } from 'socket.io-client';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { 
  ShieldAlert, 
  MapPin, 
  Car, 
  AlertCircle, 
  Loader2, 
  CheckCircle2, 
  Navigation,
  ChevronLeft,
  Phone,
  Clock,
  Wrench,
  Truck,
  DollarSign,
  FileText,
  Activity,
  Radio,
  EyeOff,
  Eye,
  Check,
  AlertTriangle,
  X
} from 'lucide-react';

// Dynamic import for Leaflet Tracking Map
const TrackingMap = dynamic(() => import('@/components/map/tracking-map'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-[400px] bg-carbon border border-divider flex flex-col items-center justify-center gap-2 text-xs font-mono text-stone-muted">
      <Loader2 className="w-5 h-5 animate-spin text-stone-muted" />
      <span>Loading Geospatial Tracking Matrix...</span>
    </div>
  ),
});

export default function CustomerTrackingPage() {
  const { user } = useAuth();
  const params = useParams();
  const router = useRouter();
  const requestId = params?.id as string;

  const [trackingData, setTrackingData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [arrivalToast, setArrivalToast] = useState<string | null>(null);

  // Cancellation modal state
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [cancelReason, setCancelReason] = useState('');
  const [isCancelling, setIsCancelling] = useState(false);

  // Socket reference
  const socketRef = useRef<Socket | null>(null);

  // Function to fetch fresh tracking payload
  const fetchTracking = async (silent = false) => {
    if (!silent) setIsLoading(true);
    try {
      const data = await api.get<any>(`/service-requests/${requestId}/tracking`);
      setTrackingData(data);
      setError(null);
    } catch (err: any) {
      console.error('Failed to fetch tracking data:', err);
      setError(err.message || 'Unable to load real-time tracking session.');
    } finally {
      if (!silent) setIsLoading(false);
    }
  };

  useEffect(() => {
    if (!requestId) return;

    fetchTracking();

    // Initialize Socket.IO connection
    const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:4000';
    const socket = io(socketUrl, {
      transports: ['websocket', 'polling'],
      withCredentials: true,
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
    });
    socketRef.current = socket;

    socket.on('connect', () => {
      // Join isolated room for this service request
      socket.emit('join:request', { requestId });
      // Fresh fetch on reconnect to prevent stale UI
      fetchTracking(true);
    });

    // Listen to real-time status transitions
    socket.on('request:status_update', (payload: any) => {
      fetchTracking(true);
    });

    socket.on('request:status', (payload: any) => {
      fetchTracking(true);
    });

    // Listen to real-time technician location telemetry
    socket.on('mechanic:location_update', (payload: any) => {
      setTrackingData((prev: any) => {
        if (!prev) return prev;
        return {
          ...prev,
          liveTelemetry: {
            ...prev.liveTelemetry,
            distanceKm: payload.distanceKm ?? prev.liveTelemetry?.distanceKm,
            estimatedArrivalMinutes: payload.estimatedArrivalMinutes ?? prev.liveTelemetry?.estimatedArrivalMinutes,
            isStale: payload.isStale ?? false,
            coordinates: payload.coordinates ?? prev.liveTelemetry?.coordinates,
          },
        };
      });
    });

    // Listen to diagnostic quotes and costs
    socket.on('service:quote_update', (payload: any) => {
      setTrackingData((prev: any) => {
        if (!prev) return prev;
        return {
          ...prev,
          quote: {
            ...prev.quote,
            diagnosticQuote: payload.diagnosticQuote,
            laborCost: payload.laborCost,
            partsCost: payload.partsCost,
            agreedQuote: payload.agreedQuote,
          },
        };
      });
    });

    // Listen to on-scene arrival alert
    socket.on('service:arrival_alert', (payload: any) => {
      setArrivalToast(payload.message || 'Technician has arrived at your breakdown site.');
      fetchTracking(true);
      setTimeout(() => setArrivalToast(null), 8000);
    });

    return () => {
      if (socketRef.current) {
        socketRef.current.emit('leave:request', { requestId });
        socketRef.current.disconnect();
      }
    };
  }, [requestId]);

  // Handle location consent toggle
  const handleToggleConsent = async () => {
    if (!trackingData) return;
    const newConsent = !(trackingData.locationConsent !== false);
    try {
      const updated = await api.patch<any>(`/service-requests/${requestId}/location-consent`, {
        locationConsent: newConsent,
      });
      setTrackingData(updated);
    } catch (err: any) {
      console.error('Failed to update location consent:', err);
    }
  };

  // Handle cancellation
  const handleCancelRequest = async () => {
    if (!cancelReason.trim()) return;
    setIsCancelling(true);
    try {
      const updated = await api.post<any>(`/service-requests/${requestId}/cancel`, {
        reason: cancelReason.trim(),
      });
      setTrackingData(updated);
      setShowCancelModal(false);
    } catch (err: any) {
      alert(`Cancellation failed: ${err.message || 'Server error'}`);
    } finally {
      setIsCancelling(false);
    }
  };

  // Milestone Steps
  const STEPS = [
    { key: 'SUBMITTED', label: 'Reported', sub: 'Incident Intake' },
    { key: 'ACCEPTED', label: 'Dispatched', sub: 'Mechanic Assigned' },
    { key: 'EN_ROUTE', label: 'En Route', sub: 'Transit Telemetry' },
    { key: 'ARRIVED', label: 'On Scene', sub: 'Initial Triage' },
    { key: 'IN_PROGRESS', label: 'In Progress', sub: 'Diagnostics & Repair' },
    { key: 'COMPLETED', label: 'Completed', sub: 'Final Resolution' },
  ];

  const getStepStatus = (stepKey: string) => {
    if (!trackingData) return 'upcoming';
    const status = trackingData.currentStatus;
    if (status === 'CANCELLED') return 'cancelled';

    const order = ['SUBMITTED', 'SEARCHING', 'ASSIGNED', 'ACCEPTED', 'EN_ROUTE', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED'];
    const currentIndex = order.indexOf(status);
    const stepIndex = order.indexOf(stepKey);

    if (stepIndex === -1) return 'upcoming';
    if (stepIndex < currentIndex) return 'completed';
    if (stepIndex === currentIndex) return 'active';
    return 'upcoming';
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <main className="flex-1 flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-8 h-8 animate-spin text-stone-muted" />
          <div className="text-xs font-mono uppercase tracking-widest text-stone-dim">
            Connecting to Telemetry Grid...
          </div>
        </main>
      </div>
    );
  }

  if (error || !trackingData) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <main className="flex-1 layout-container py-12 flex flex-col items-center justify-center gap-4 text-center">
          <AlertCircle className="w-10 h-10 text-crimson" />
          <h2 className="text-xl font-medium text-porcelain">Tracking Session Unavailable</h2>
          <p className="text-xs text-stone-muted max-w-md">
            {error || 'The requested service tracking session could not be authenticated or does not exist.'}
          </p>
          <Link
            href="/customer/vehicles"
            className="px-6 py-2.5 bg-graphite border border-divider hover:border-porcelain text-xs font-mono uppercase tracking-wider transition-colors"
          >
            Return to Fleet Terminal
          </Link>
        </main>
      </div>
    );
  }

  const {
    currentStatus,
    timestamps,
    breakdownReport,
    mechanic,
    liveTelemetry,
    quote,
    statusHistory,
  } = trackingData;

  const isTerminal = currentStatus === 'COMPLETED' || currentStatus === 'CANCELLED';

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      {/* Arrival Alert Toast */}
      {arrivalToast && (
        <div className="fixed top-20 right-6 z-50 p-4 bg-sage border border-sage-light text-porcelain text-xs font-mono uppercase tracking-wider shadow-2xl flex items-center gap-3 animate-slideDown">
          <Radio className="w-4 h-4 text-porcelain animate-pulse" />
          <span>{arrivalToast}</span>
        </div>
      )}

      <main className="flex-1 layout-container py-8 space-y-8">
        
        {/* Navigation Breadcrumb & Incident Metadata */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-divider/60">
          <div className="flex items-center gap-2 text-xs font-mono text-stone-muted">
            <Link href="/customer/dashboard" className="hover:text-porcelain flex items-center gap-1 transition-colors">
              <ChevronLeft className="w-3.5 h-3.5" />
              <span>Customer Console</span>
            </Link>
            <span className="text-divider">•</span>
            <span className="text-porcelain uppercase tracking-wider">Live Response Radar</span>
          </div>

          <div className="flex items-center gap-3 font-mono text-xs">
            <span className="text-stone-dim uppercase text-[10px]">Request Ref</span>
            <span className="px-2.5 py-1 bg-graphite border border-divider text-porcelain font-semibold">
              {trackingData.serviceRequestId?.substring(0, 10).toUpperCase()}
            </span>
            <span className={`px-3 py-1 font-semibold uppercase tracking-wider text-[11px] ${
              currentStatus === 'COMPLETED'
                ? 'bg-sage-subtle text-sage-light border border-sage/40'
                : currentStatus === 'CANCELLED'
                ? 'bg-crimson/15 text-crimson border border-crimson/50'
                : 'bg-carbon text-porcelain border border-divider'
            }`}>
              {currentStatus}
            </span>
          </div>
        </div>

        {/* ARCHITECTURAL MILESTONE PROGRESSION STEPPER */}
        <div className="border border-divider bg-graphite p-6 shadow-architectural">
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4">
            {STEPS.map((step, idx) => {
              const state = getStepStatus(step.key);
              return (
                <div key={step.key} className="space-y-2 relative">
                  <div className="flex items-center gap-2">
                    <div className={`w-5 h-5 rounded-full flex items-center justify-center font-mono text-[10px] font-bold ${
                      state === 'completed'
                        ? 'bg-sage text-porcelain'
                        : state === 'active'
                        ? 'bg-porcelain text-carbon ring-2 ring-sage ring-offset-2 ring-offset-carbon'
                        : 'bg-carbon border border-divider text-stone-dim'
                    }`}>
                      {state === 'completed' ? <Check className="w-3 h-3" /> : idx + 1}
                    </div>
                    <span className={`text-[11px] font-mono uppercase tracking-wider ${
                      state === 'active' ? 'text-porcelain font-semibold' : state === 'completed' ? 'text-sage-light' : 'text-stone-dim'
                    }`}>
                      {step.label}
                    </span>
                  </div>
                  <div className="text-[10px] text-stone-muted truncate">
                    {step.sub}
                  </div>
                  {/* Step Timestamp */}
                  <div className="text-[10px] font-mono text-stone-dim">
                    {step.key === 'SUBMITTED' && timestamps.createdAt ? new Date(timestamps.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                    {step.key === 'ACCEPTED' && timestamps.acceptedAt ? new Date(timestamps.acceptedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                    {step.key === 'EN_ROUTE' && timestamps.enRouteAt ? new Date(timestamps.enRouteAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                    {step.key === 'ARRIVED' && timestamps.arrivedAt ? new Date(timestamps.arrivedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                    {step.key === 'IN_PROGRESS' && timestamps.inProgressAt ? new Date(timestamps.inProgressAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                    {step.key === 'COMPLETED' && timestamps.completedAt ? new Date(timestamps.completedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* MAIN TELEMETRY & MAP MATRIX (2-COLUMN GRID) */}
        <div className="grid lg:grid-cols-12 gap-8 items-start">
          
          {/* LEFT COLUMN: MAP & TELEMETRY (7 COLS) */}
          <div className="lg:col-span-7 space-y-6">
            
            {/* Live Leaflet OpenStreetMap Canvas */}
            <div className="border border-divider bg-graphite p-1 shadow-architectural">
              <div className="h-[420px] w-full overflow-hidden relative">
                <TrackingMap
                  incidentLat={breakdownReport.latitude}
                  incidentLng={breakdownReport.longitude}
                  mechanicLat={liveTelemetry?.coordinates?.latitude}
                  mechanicLng={liveTelemetry?.coordinates?.longitude}
                  mechanicHeading={liveTelemetry?.coordinates?.heading}
                  mechanicName={mechanic?.workshopName}
                  status={currentStatus}
                  isStale={liveTelemetry?.isStale}
                  className="w-full h-full"
                />

                {/* Map Floating HUD Overlay */}
                <div className="absolute top-4 left-4 z-[400] bg-carbon/90 backdrop-blur-md border border-divider p-3 font-mono text-xs space-y-1">
                  <div className="flex items-center gap-2">
                    <span className={`w-2 h-2 rounded-full ${
                      liveTelemetry?.isStale ? 'bg-stone-muted' : 'bg-sage-light animate-pulse'
                    }`} />
                    <span className="text-porcelain font-semibold uppercase text-[10px] tracking-wider">
                      {liveTelemetry?.isStale ? 'Telemetry Stale (>5m)' : 'Live GPS Transmission'}
                    </span>
                  </div>
                  <div className="text-[10px] text-stone-muted">
                    {liveTelemetry?.coordinates
                      ? `Lat: ${liveTelemetry.coordinates.latitude.toFixed(4)}, Lon: ${liveTelemetry.coordinates.longitude.toFixed(4)}`
                      : 'Coordinates suppressed by privacy consent'}
                  </div>
                </div>
              </div>
            </div>

            {/* Proximity Telemetry Strip */}
            <div className="grid grid-cols-3 gap-4 font-mono">
              <div className="p-4 bg-graphite border border-divider space-y-1">
                <span className="text-[10px] uppercase text-stone-dim block tracking-widest">Calculated Distance</span>
                <div className="text-xl font-bold text-porcelain">
                  {liveTelemetry?.distanceKm !== undefined ? `${liveTelemetry.distanceKm} km` : 'Searching...'}
                </div>
                <div className="text-[10px] text-stone-muted">Haversine Great-Circle</div>
              </div>

              <div className="p-4 bg-graphite border border-divider space-y-1">
                <span className="text-[10px] uppercase text-stone-dim block tracking-widest">Estimated Arrival</span>
                <div className="text-xl font-bold text-porcelain">
                  {liveTelemetry?.estimatedArrivalMinutes !== undefined
                    ? liveTelemetry.estimatedArrivalMinutes === 0
                      ? 'On Scene'
                      : `~${liveTelemetry.estimatedArrivalMinutes} mins`
                    : 'Awaiting Claim'}
                </div>
                <div className="text-[10px] text-stone-muted">Urban Speed Vector</div>
              </div>

              <div className="p-4 bg-graphite border border-divider space-y-1">
                <span className="text-[10px] uppercase text-stone-dim block tracking-widest">GPS Freshness</span>
                <div className="text-xl font-bold text-porcelain">
                  {liveTelemetry?.ageSeconds !== undefined ? `${liveTelemetry.ageSeconds}s ago` : 'Active'}
                </div>
                <div className="text-[10px] text-stone-muted">Sub-Meter Satellite</div>
              </div>
            </div>

            {/* Diagnostic Quotation & Cost Breakdown Card */}
            {(quote?.diagnosticQuote || quote?.laborCost || quote?.partsCost || quote?.agreedQuote) && (
              <div className="border border-divider bg-graphite p-6 space-y-4 shadow-architectural">
                <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                  <div className="space-y-0.5">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Authorized Work Order
                    </span>
                    <h3 className="text-base font-medium text-porcelain">Quotation & Parts Specification</h3>
                  </div>
                  <DollarSign className="w-5 h-5 text-sage-light" />
                </div>

                <div className="grid grid-cols-3 gap-4 font-mono text-xs">
                  <div className="p-3 bg-carbon border border-divider space-y-1">
                    <span className="text-[10px] text-stone-dim uppercase">Diagnostic Fee</span>
                    <div className="text-sm font-semibold text-porcelain">
                      ${quote.diagnosticQuote?.toFixed(2) || '0.00'}
                    </div>
                  </div>
                  <div className="p-3 bg-carbon border border-divider space-y-1">
                    <span className="text-[10px] text-stone-dim uppercase">Technician Labor</span>
                    <div className="text-sm font-semibold text-porcelain">
                      ${quote.laborCost?.toFixed(2) || '0.00'}
                    </div>
                  </div>
                  <div className="p-3 bg-carbon border border-divider space-y-1">
                    <span className="text-[10px] text-stone-dim uppercase">Parts & Supplies</span>
                    <div className="text-sm font-semibold text-porcelain">
                      ${quote.partsCost?.toFixed(2) || '0.00'}
                    </div>
                  </div>
                </div>

                <div className="p-4 bg-carbon border border-divider flex items-center justify-between font-mono">
                  <span className="text-xs uppercase text-stone-dim">Total Agreed Work Order</span>
                  <span className="text-lg font-bold text-sage-light">
                    ${quote.agreedQuote?.toFixed(2) || '0.00'}
                  </span>
                </div>

                {quote.resolutionNotes && (
                  <div className="p-4 bg-carbon border border-divider space-y-1">
                    <span className="text-[10px] font-mono uppercase text-stone-dim block">Technician Resolution Summary</span>
                    <p className="text-xs text-porcelain/90 font-sans leading-relaxed">{quote.resolutionNotes}</p>
                  </div>
                )}
              </div>
            )}

          </div>

          {/* RIGHT COLUMN: MECHANIC DOSSIER & ACTIONS (5 COLS) */}
          <div className="lg:col-span-5 space-y-6">
            
            {/* Field Technician Dossier Card */}
            <div className="border border-divider bg-graphite p-6 space-y-5 shadow-architectural">
              <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                  Assigned Field Technician
                </span>
                <span className="w-2 h-2 rounded-full bg-sage-light" />
              </div>

              {mechanic ? (
                <div className="space-y-4">
                  <div className="space-y-1">
                    <h3 className="text-xl font-medium text-porcelain tracking-tight">
                      {mechanic.workshopName}
                    </h3>
                    <div className="text-xs font-mono text-stone-muted flex items-center gap-3">
                      <span>Rating: ★ {mechanic.ratingAverage?.toFixed(1) || '5.0'}</span>
                      <span className="text-divider">•</span>
                      <span>Missions: {mechanic.totalJobsCompleted || 0}</span>
                    </div>
                  </div>

                  {/* Direct Contact Button */}
                  {mechanic.phone && (
                    <a
                      href={`tel:${mechanic.phone}`}
                      className="w-full py-3 bg-porcelain hover:bg-porcelain-dim text-carbon font-mono text-xs uppercase tracking-wider font-semibold flex items-center justify-center gap-2 transition-colors"
                    >
                      <Phone className="w-3.5 h-3.5" />
                      <span>Direct Cellular Line ({mechanic.phone})</span>
                    </a>
                  )}
                </div>
              ) : (
                <div className="py-6 text-center space-y-2">
                  <Radio className="w-6 h-6 animate-pulse text-stone-dim mx-auto" />
                  <div className="text-xs font-mono text-stone-muted uppercase tracking-wider">
                    Awaiting Nearby Technician Claim
                  </div>
                </div>
              )}
            </div>

            {/* Breakdown Incident Dossier */}
            <div className="border border-divider bg-graphite p-6 space-y-4 shadow-architectural">
              <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                  Incident Telemetry Dossier
                </span>
                <span className="text-xs font-mono text-crimson font-medium">
                  {breakdownReport.severity} SEVERITY
                </span>
              </div>

              <div className="space-y-3 text-xs">
                <div>
                  <span className="text-stone-dim uppercase text-[10px] font-mono block">Vehicle</span>
                  <div className="text-porcelain font-medium text-sm">
                    {breakdownReport.vehicle
                      ? `${breakdownReport.vehicle.year} ${breakdownReport.vehicle.make} ${breakdownReport.vehicle.model}`
                      : 'Manual Vehicle Entry'}
                  </div>
                  <div className="text-[11px] font-mono text-stone-muted">
                    Plate: {breakdownReport.vehicle?.licensePlate || 'N/A'} • {breakdownReport.vehicle?.powertrain || 'ICE'}
                  </div>
                </div>

                <div>
                  <span className="text-stone-dim uppercase text-[10px] font-mono block">Diagnosis Rule</span>
                  <div className="text-porcelain font-medium">
                    {breakdownReport.ruleDiagnosis || breakdownReport.category}
                  </div>
                </div>

                <div>
                  <span className="text-stone-dim uppercase text-[10px] font-mono block">Dispatched Location</span>
                  <div className="text-porcelain font-mono text-[11px]">
                    {breakdownReport.addressText || `${breakdownReport.latitude.toFixed(5)}, ${breakdownReport.longitude.toFixed(5)}`}
                  </div>
                </div>
              </div>
            </div>

            {/* Location Privacy Consent Toggle */}
            <div className="border border-divider bg-graphite p-5 flex items-center justify-between font-mono text-xs">
              <div className="space-y-0.5">
                <div className="text-porcelain font-medium flex items-center gap-2">
                  {trackingData.locationConsent !== false ? (
                    <Eye className="w-3.5 h-3.5 text-sage-light" />
                  ) : (
                    <EyeOff className="w-3.5 h-3.5 text-stone-muted" />
                  )}
                  <span>High-Precision Location Consent</span>
                </div>
                <div className="text-[10px] text-stone-muted">
                  {trackingData.locationConsent !== false
                    ? 'Sharing active sub-meter GPS coordinates'
                    : 'Coordinates masked for privacy protection'}
                </div>
              </div>

              <button
                type="button"
                onClick={handleToggleConsent}
                className="px-3 py-1.5 border border-divider hover:border-porcelain text-[10px] uppercase tracking-wider text-porcelain transition-colors"
              >
                {trackingData.locationConsent !== false ? 'Mask Location' : 'Allow Precision'}
              </button>
            </div>

            {/* Cancel Request Button */}
            {!isTerminal && (
              <div>
                <button
                  type="button"
                  onClick={() => setShowCancelModal(true)}
                  className="w-full py-3 bg-carbon border border-crimson/50 hover:border-crimson text-crimson hover:bg-crimson/10 font-mono text-xs uppercase tracking-wider transition-colors flex items-center justify-center gap-2"
                >
                  <AlertTriangle className="w-3.5 h-3.5" />
                  <span>Cancel Emergency Assistance Request</span>
                </button>
              </div>
            )}

            {/* Chronological Status Audit Ledger */}
            {statusHistory && statusHistory.length > 0 && (
              <div className="border border-divider bg-graphite p-6 space-y-3 shadow-architectural">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block pb-2 border-b border-divider/60">
                  Chronological Mission Audit Ledger
                </span>
                <div className="space-y-2 max-h-56 overflow-y-auto pr-1">
                  {statusHistory.map((h: any, i: number) => (
                    <div key={h.id || i} className="p-2.5 bg-carbon border border-divider font-mono text-[11px] space-y-0.5">
                      <div className="flex items-center justify-between text-stone-muted text-[10px]">
                        <span className="text-porcelain font-semibold uppercase">{h.toStatus}</span>
                        <span>{new Date(h.timestamp).toLocaleTimeString()}</span>
                      </div>
                      <p className="text-stone-dim text-[10px] leading-tight font-sans">{h.notes}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

          </div>

        </div>

      </main>

      {/* CANCELLATION MODAL */}
      {showCancelModal && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="border border-divider bg-carbon p-6 max-w-md w-full space-y-4 animate-scaleUp">
            <div className="flex items-center justify-between pb-3 border-b border-divider/60">
              <div className="flex items-center gap-2 text-crimson font-mono text-xs uppercase font-semibold">
                <AlertTriangle className="w-4 h-4" />
                <span>Confirm Service Cancellation</span>
              </div>
              <button
                onClick={() => setShowCancelModal(false)}
                className="text-stone-dim hover:text-porcelain"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <p className="text-xs text-stone-muted leading-relaxed font-sans">
              Cancelling releases the assigned field technician back to municipal standby. Please state an explicit operational reason for the audit ledger:
            </p>

            <textarea
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
              placeholder="e.g. Vehicle restarted independently; private towing secured."
              className="w-full h-24 p-3 bg-graphite border border-divider text-porcelain text-xs font-sans focus:outline-none focus:border-stone-muted rounded-none"
            />

            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                type="button"
                onClick={() => setShowCancelModal(false)}
                className="px-4 py-2 border border-divider text-stone-muted hover:text-porcelain text-xs font-mono uppercase tracking-wider"
              >
                Abort
              </button>
              <button
                type="button"
                disabled={isCancelling || !cancelReason.trim()}
                onClick={handleCancelRequest}
                className="px-5 py-2 bg-crimson hover:bg-crimson-hover text-porcelain font-mono text-xs uppercase tracking-wider font-semibold disabled:opacity-50"
              >
                {isCancelling ? 'Cancelling...' : 'Confirm Cancellation'}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

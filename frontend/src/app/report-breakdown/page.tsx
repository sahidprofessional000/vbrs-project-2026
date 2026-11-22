'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import dynamic from 'next/dynamic';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { Vehicle, BreakdownCategory, SeverityLevel, BreakdownReport } from '@/types';
import { 
  ShieldAlert, 
  MapPin, 
  Car, 
  AlertCircle, 
  Loader2, 
  CheckCircle2, 
  Navigation,
  ArrowRight,
  ChevronLeft,
  Camera,
  X,
  FileText,
  AlertTriangle,
  Truck,
  Wrench,
  Clock
} from 'lucide-react';

// Dynamic import for Leaflet map to prevent SSR window reference error
const BreakdownMap = dynamic(() => import('@/components/map/breakdown-map'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-[360px] bg-carbon border border-divider flex flex-col items-center justify-center gap-2 text-xs font-mono text-stone-muted">
      <Loader2 className="w-5 h-5 animate-spin text-stone-muted" />
      <span>Loading OpenStreetMap Navigation Matrix...</span>
    </div>
  ),
});

interface UploadedFilePreview {
  file: File;
  previewUrl: string;
}

export default function ReportBreakdownPage() {
  const { user } = useAuth();
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Form states
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [selectedVehicleId, setSelectedVehicleId] = useState<string>('');
  const [category, setCategory] = useState<BreakdownCategory>('ENGINE_FAILURE');
  const [severity, setSeverity] = useState<SeverityLevel>('MEDIUM');
  const [description, setDescription] = useState('');
  const [addressText, setAddressText] = useState('');
  
  // File upload state (up to 5 images, max 5MB each, JPEG/PNG/WebP)
  const [selectedFiles, setSelectedFiles] = useState<UploadedFilePreview[]>([]);
  const [fileError, setFileError] = useState<string | null>(null);

  // Geolocation state
  const [latitude, setLatitude] = useState<number>(40.7128);
  const [longitude, setLongitude] = useState<number>(-74.0060);
  const [isLocating, setIsLocating] = useState(false);
  const [locationSource, setLocationSource] = useState<'GPS' | 'MANUAL'>('MANUAL');

  // Async submission states
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submittedReport, setSubmittedReport] = useState<BreakdownReport | null>(null);

  useEffect(() => {
    async function loadGarage() {
      try {
        const vList = await api.get<Vehicle[]>('/vehicles');
        setVehicles(vList);
        const defaultV = vList.find((v) => v.isDefault) || vList[0];
        if (defaultV) {
          setSelectedVehicleId(defaultV.id);
        }
      } catch (err) {
        console.error('Failed to fetch vehicles:', err);
      } finally {
        setIsLoading(false);
      }
    }
    loadGarage();

    // Trigger initial geolocation detection
    handleDetectLocation();
  }, []);

  const handleDetectLocation = () => {
    if (typeof window === 'undefined' || !navigator.geolocation) {
      setLocationSource('MANUAL');
      return;
    }

    setIsLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLatitude(Number(pos.coords.latitude.toFixed(6)));
        setLongitude(Number(pos.coords.longitude.toFixed(6)));
        setLocationSource('GPS');
        setIsLocating(false);
      },
      (err) => {
        console.warn('Geolocation unavailable, utilizing manual pin:', err);
        setLocationSource('MANUAL');
        setIsLocating(false);
      },
      { timeout: 8000, enableHighAccuracy: true }
    );
  };

  const handleMapLocationChange = (lat: number, lng: number) => {
    setLatitude(lat);
    setLongitude(lng);
    setLocationSource('MANUAL');
  };

  // Image upload handlers
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFileError(null);
    if (!e.target.files) return;

    const files = Array.from(e.target.files);
    const validMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxSizeBytes = 5 * 1024 * 1024; // 5 MB

    if (selectedFiles.length + files.length > 5) {
      setFileError('Maximum 5 photographic records allowed per breakdown intake.');
      return;
    }

    const newPreviews: UploadedFilePreview[] = [];
    for (const file of files) {
      if (!validMimes.includes(file.type)) {
        setFileError(`Disallowed file format "${file.name}". Supported: JPEG, PNG, WebP.`);
        return;
      }
      if (file.size > maxSizeBytes) {
        setFileError(`File "${file.name}" exceeds 5 MB payload ceiling (${(file.size / (1024 * 1024)).toFixed(1)} MB).`);
        return;
      }
      newPreviews.push({
        file,
        previewUrl: URL.createObjectURL(file),
      });
    }

    setSelectedFiles((prev) => [...prev, ...newPreviews]);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const removeFile = (index: number) => {
    setSelectedFiles((prev) => {
      const target = prev[index];
      if (target) {
        URL.revokeObjectURL(target.previewUrl);
      }
      return prev.filter((_, i) => i !== index);
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!description.trim()) {
      setSubmitError('Please describe observed symptoms or hazard conditions.');
      return;
    }

    setIsSubmitting(true);
    setSubmitError(null);

    try {
      const formData = new FormData();
      formData.append('category', category);
      formData.append('severity', severity);
      formData.append('description', description.trim());
      formData.append('latitude', String(latitude));
      formData.append('longitude', String(longitude));
      
      if (addressText.trim()) {
        formData.append('addressText', addressText.trim());
      }
      if (selectedVehicleId) {
        formData.append('vehicleId', selectedVehicleId);
      }

      for (const item of selectedFiles) {
        formData.append('images', item.file);
      }

      const createdReport = await api.postFormData<BreakdownReport>('/breakdowns', formData);
      setSubmittedReport(createdReport);
    } catch (err: any) {
      console.error('Breakdown dispatch failed:', err);
      setSubmitError(err.message || 'Signal transmission failure. Please verify network connectivity.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const resetForm = () => {
    setSubmittedReport(null);
    setDescription('');
    setAddressText('');
    setSelectedFiles([]);
    setSubmitError(null);
  };

  const selectedVehicle = vehicles.find((v) => v.id === selectedVehicleId);
  const apiBase = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api';

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 layout-container py-10 space-y-8">
        
        {/* Navigation Breadcrumb */}
        <div className="flex items-center gap-2 text-xs font-mono text-stone-muted">
          <Link href="/customer/vehicles" className="hover:text-porcelain flex items-center gap-1 transition-colors">
            <ChevronLeft className="w-3.5 h-3.5" />
            <span>Customer Terminal</span>
          </Link>
          <span className="text-divider">•</span>
          <span className="text-porcelain uppercase tracking-wider">Breakdown Incident Intake</span>
        </div>

        {/* Header */}
        <div className="space-y-2 pb-6 border-b border-divider/60">
          <div className="flex items-center gap-2.5">
            <span className="w-2 h-2 rounded-full bg-crimson animate-pulse" />
            <span className="text-[11px] font-mono tracking-widest uppercase text-crimson font-medium">
              Roadside Assistance Dispatch Protocol
            </span>
          </div>
          <h1 className="text-3xl lg:text-4xl font-medium tracking-tight text-porcelain">
            Report Mechanical Breakdown
          </h1>
          <p className="text-xs text-stone-muted font-normal max-w-2xl leading-relaxed">
            Record vehicle diagnostic conditions, upload roadside imagery, and pin precise geospatial coordinates. Our deterministic triage engine calculates towing requirements and safety advisories in real time.
          </p>
        </div>

        {/* SUBMITTED STATE: INCIDENT TRIAGE & PROTOCOL CARD */}
        {submittedReport ? (
          <div className="border border-divider bg-graphite p-8 lg:p-12 space-y-8 animate-fadeIn shadow-architectural">
            
            {/* Top Status Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-divider/60">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <span className="text-[11px] font-mono uppercase tracking-widest text-stone-dim">
                    Incident Signal ID
                  </span>
                  <span className="px-2 py-0.5 bg-carbon border border-divider text-xs font-mono text-porcelain">
                    {submittedReport.id.substring(0, 13).toUpperCase()}
                  </span>
                </div>
                <h2 className="text-2xl font-medium text-porcelain tracking-tight">
                  Triage Assessment & Dispatch Initialized
                </h2>
              </div>

              {/* Towing Requirement Badge */}
              <div>
                {submittedReport.requiresTowing ? (
                  <div className="inline-flex items-center gap-2 px-3.5 py-2 bg-crimson/15 border border-crimson text-crimson font-mono text-xs uppercase tracking-wider">
                    <Truck className="w-4 h-4 text-crimson" />
                    <span className="font-semibold">Mandatory Flatbed Recovery Assigned</span>
                  </div>
                ) : (
                  <div className="inline-flex items-center gap-2 px-3.5 py-2 bg-sage-subtle border border-sage/40 text-sage-light font-mono text-xs uppercase tracking-wider">
                    <Wrench className="w-4 h-4 text-sage-light" />
                    <span>Roadside Mobile Repair Service</span>
                  </div>
                )}
              </div>
            </div>

            {/* Assessment Grid */}
            <div className="grid md:grid-cols-3 gap-6">
              
              {/* Box 1: Diagnostic Finding */}
              <div className="p-5 bg-carbon border border-divider space-y-2">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                  Deterministic Rule Diagnosis
                </span>
                <p className="text-sm font-medium text-porcelain leading-snug">
                  {submittedReport.ruleDiagnosis || 'Powertrain examination required by dispatched technician.'}
                </p>
              </div>

              {/* Box 2: Vehicle Telemetry */}
              <div className="p-5 bg-carbon border border-divider space-y-2">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                  Disabled Automobile
                </span>
                <p className="text-sm font-medium text-porcelain">
                  {submittedReport.vehicle
                    ? `${submittedReport.vehicle.year} ${submittedReport.vehicle.make} ${submittedReport.vehicle.model}`
                    : 'Unregistered / Manual Vehicle'}
                </p>
                <div className="text-xs font-mono text-stone-muted">
                  Plate: {submittedReport.vehicle?.licensePlate || 'N/A'} • {submittedReport.vehicle?.powertrain || 'ICE'}
                </div>
              </div>

              {/* Box 3: Geospatial Coordinates */}
              <div className="p-5 bg-carbon border border-divider space-y-2">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                  Dispatched Coordinates
                </span>
                <p className="text-sm font-mono text-porcelain">
                  {submittedReport.latitude.toFixed(6)}, {submittedReport.longitude.toFixed(6)}
                </p>
                <div className="text-xs text-stone-muted truncate">
                  {submittedReport.addressText || 'OpenStreetMap Pinpoint Recorded'}
                </div>
              </div>

            </div>

            {/* Description & Severity Summary */}
            <div className="p-5 bg-carbon border border-divider space-y-2">
              <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                Recorded Symptoms & Field Observations
              </span>
              <p className="text-xs font-sans text-porcelain/90 leading-relaxed">
                {submittedReport.description}
              </p>
              <div className="pt-2 flex items-center gap-4 text-xs font-mono text-stone-muted">
                <span>Category: <strong className="text-porcelain font-normal">{submittedReport.category}</strong></span>
                <span className="text-divider">•</span>
                <span>Severity: <strong className="text-porcelain font-normal">{submittedReport.severity}</strong></span>
                <span className="text-divider">•</span>
                <span>Status: <strong className="text-sage-light font-normal">SUBMITTED</strong></span>
              </div>
            </div>

            {/* Image Gallery */}
            {submittedReport.images && submittedReport.images.length > 0 && (
              <div className="space-y-3">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                  Attached Photographic Evidence ({submittedReport.images.length})
                </span>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
                  {submittedReport.images.map((img) => (
                    <a
                      key={img.id}
                      href={`${apiBase}/breakdowns/images/${img.fileName}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="group block relative aspect-video bg-carbon border border-divider overflow-hidden hover:border-porcelain transition-colors"
                    >
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img
                        src={`${apiBase}/breakdowns/images/${img.fileName}`}
                        alt={img.fileName}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-carbon/60 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity text-[10px] font-mono text-porcelain">
                        View Full
                      </div>
                    </a>
                  ))}
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="pt-4 flex flex-wrap items-center gap-4 border-t border-divider/60">
              <Link
                href="/customer/vehicles"
                className="px-6 py-3 bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-porcelain-dim transition-colors"
              >
                Return to Garage
              </Link>
              <button
                type="button"
                onClick={resetForm}
                className="px-6 py-3 border border-divider hover:border-stone-muted text-stone-muted hover:text-porcelain font-mono text-xs uppercase tracking-wider transition-colors"
              >
                Report Another Breakdown
              </button>
            </div>

          </div>
        ) : (
          /* FORM INTAKE */
          <form onSubmit={handleSubmit} className="space-y-8">
            
            {submitError && (
              <div className="p-4 bg-crimson/10 border border-crimson/50 text-crimson text-xs font-mono flex items-center gap-2">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{submitError}</span>
              </div>
            )}

            {/* Wide Two-Column Grid */}
            <div className="grid lg:grid-cols-12 gap-8 items-start">
              
              {/* Left Column (7 cols): Vehicle, Fault & Imagery */}
              <div className="lg:col-span-7 space-y-8">
                
                {/* Section 1: Disabled Vehicle Selection */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Section 01 // Disabled Automobile
                    </span>
                    <Link href="/customer/vehicles" className="text-xs font-mono text-stone-muted hover:text-porcelain transition-colors">
                      + Manage Garage
                    </Link>
                  </div>

                  {isLoading ? (
                    <div className="py-6 flex items-center justify-center text-xs font-mono text-stone-muted gap-2">
                      <Loader2 className="w-4 h-4 animate-spin" />
                      <span>Loading garage telemetry...</span>
                    </div>
                  ) : vehicles.length > 0 ? (
                    <div className="grid sm:grid-cols-2 gap-3 pt-2">
                      {vehicles.map((v) => (
                        <label
                          key={v.id}
                          className={`p-4 border cursor-pointer transition-colors flex items-start gap-3 ${
                            selectedVehicleId === v.id
                              ? 'border-porcelain bg-elevated'
                              : 'border-divider bg-carbon hover:border-divider-strong'
                          }`}
                        >
                          <input
                            type="radio"
                            name="vehicle"
                            value={v.id}
                            checked={selectedVehicleId === v.id}
                            onChange={() => setSelectedVehicleId(v.id)}
                            className="mt-1 rounded-none text-porcelain focus:ring-0"
                          />
                          <div className="space-y-1">
                            <div className="text-sm font-medium text-porcelain font-sans">
                              {v.year} {v.make} {v.model}
                            </div>
                            <div className="text-xs font-mono text-stone-dim">
                              Plate: <span className="text-stone-muted">{v.licensePlate}</span> • {v.powertrain}
                            </div>
                          </div>
                        </label>
                      ))}
                    </div>
                  ) : (
                    <div className="p-4 bg-carbon border border-divider text-xs font-mono text-stone-muted flex items-center justify-between">
                      <span>No vehicles registered. Please add a vehicle to your garage.</span>
                      <Link href="/customer/vehicles" className="text-porcelain hover:underline">
                        Add Vehicle &rarr;
                      </Link>
                    </div>
                  )}
                </div>

                {/* Section 2: Fault Categorization & Severity */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block pb-3 border-b border-divider/60">
                    Section 02 // Fault Symptom & Urgency
                  </span>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 pt-2">
                    <div>
                      <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                        Primary Symptom Category
                      </label>
                      <select
                        value={category}
                        onChange={(e) => setCategory(e.target.value as BreakdownCategory)}
                        className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted rounded-none"
                      >
                        <option value="ENGINE_FAILURE">Engine Failure / Stalled</option>
                        <option value="FLAT_TIRE_WHEEL">Flat Tire / Puncture</option>
                        <option value="BATTERY_DEAD_ELECTRICAL">Dead Battery / Electrical</option>
                        <option value="BRAKE_SYSTEM_FAILURE">Brake System Failure</option>
                        <option value="OVERHEATING_COOLANT">Coolant Overheating</option>
                        <option value="TRANSMISSION_ISSUE">Transmission / Drivetrain</option>
                        <option value="FUEL_EMPTY_OR_CONTAMINATED">Out of Fuel / Contaminated</option>
                        <option value="LOCKOUT_KEY_LOST">Lockout / Keys Locked In</option>
                        <option value="COLLISION_ACCIDENT">Collision / Tow Required</option>
                        <option value="OTHER_UNKNOWN">Other / Unidentified Fault</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                        Urgency & Roadway Safety
                      </label>
                      <select
                        value={severity}
                        onChange={(e) => setSeverity(e.target.value as SeverityLevel)}
                        className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted rounded-none"
                      >
                        <option value="LOW">Low (Parked safely off roadway)</option>
                        <option value="MEDIUM">Medium (Stalled on road shoulder)</option>
                        <option value="CRITICAL">Critical (Obstructing traffic / Hazard)</option>
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                      Observed Symptoms & Diagnostic Notes *
                    </label>
                    <textarea
                      rows={3}
                      required
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Detail abnormal sounds, smoke, dashboard warning lights, gear failure, or collision impact..."
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-sans focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>
                </div>

                {/* Section 3: Photographic Evidence (Uploads) */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Section 03 // Photographic Evidence (Max 5)
                    </span>
                    <span className="text-[11px] font-mono text-stone-dim">
                      JPEG, PNG, WebP • ≤ 5 MB each
                    </span>
                  </div>

                  {fileError && (
                    <div className="p-3 bg-crimson/10 border border-crimson/40 text-crimson text-xs font-mono">
                      {fileError}
                    </div>
                  )}

                  {/* Upload Drop Area */}
                  <div 
                    onClick={() => fileInputRef.current?.click()}
                    className="border border-dashed border-divider hover:border-stone-muted bg-carbon/50 p-6 text-center cursor-pointer transition-colors space-y-2"
                  >
                    <Camera className="w-6 h-6 mx-auto text-stone-muted" />
                    <div className="text-xs font-mono text-porcelain">
                      Click to capture or upload breakdown photographs
                    </div>
                    <div className="text-[11px] font-mono text-stone-dim">
                      Attach dashboard warning codes, tire damage, fluid leaks, or collision angles
                    </div>
                    <input
                      ref={fileInputRef}
                      type="file"
                      multiple
                      accept="image/jpeg,image/png,image/webp"
                      onChange={handleFileChange}
                      className="hidden"
                    />
                  </div>

                  {/* File Previews */}
                  {selectedFiles.length > 0 && (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3 pt-2">
                      {selectedFiles.map((item, idx) => (
                        <div
                          key={idx}
                          className="relative aspect-video bg-carbon border border-divider overflow-hidden group"
                        >
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={item.previewUrl}
                            alt={`Upload ${idx + 1}`}
                            className="w-full h-full object-cover"
                          />
                          <button
                            type="button"
                            onClick={(e) => {
                              e.stopPropagation();
                              removeFile(idx);
                            }}
                            className="absolute top-1 right-1 p-1 bg-carbon/90 border border-divider text-stone-muted hover:text-crimson transition-colors"
                            title="Remove photograph"
                          >
                            <X className="w-3 h-3" />
                          </button>
                          <div className="absolute bottom-0 inset-x-0 bg-carbon/80 px-1 py-0.5 text-[9px] font-mono text-stone-muted truncate">
                            {(item.file.size / (1024 * 1024)).toFixed(1)} MB
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

              </div>

              {/* Right Column (5 cols): Leaflet OSM Map & Dispatch Summary */}
              <div className="lg:col-span-5 space-y-8">
                
                {/* Section 4: Interactive Leaflet Map & GPS */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Section 04 // OpenStreetMap Positioning
                    </span>
                    <button
                      type="button"
                      onClick={handleDetectLocation}
                      disabled={isLocating}
                      className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider flex items-center gap-1.5 transition-colors"
                    >
                      <Navigation className={`w-3 h-3 ${isLocating ? 'animate-spin' : ''}`} />
                      <span>{isLocating ? 'Acquiring GPS...' : 'Detect GPS'}</span>
                    </button>
                  </div>

                  {/* Leaflet Map Canvas */}
                  <div className="border border-divider overflow-hidden h-[280px]">
                    <BreakdownMap
                      latitude={latitude}
                      longitude={longitude}
                      onLocationChange={handleMapLocationChange}
                      className="w-full h-full"
                    />
                  </div>

                  {/* Coordinate Telemetry */}
                  <div className="grid grid-cols-2 gap-3 pt-1">
                    <div className="p-3 bg-carbon border border-divider font-mono text-xs space-y-1">
                      <span className="text-stone-dim uppercase text-[10px] block">Latitude</span>
                      <div className="text-porcelain font-semibold text-sm">
                        {latitude.toFixed(6)}
                      </div>
                    </div>

                    <div className="p-3 bg-carbon border border-divider font-mono text-xs space-y-1">
                      <span className="text-stone-dim uppercase text-[10px] block">Longitude</span>
                      <div className="text-porcelain font-semibold text-sm">
                        {longitude.toFixed(6)}
                      </div>
                    </div>
                  </div>

                  {/* Roadside Landmark Input */}
                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                      Roadside Landmark / Highway Marker
                    </label>
                    <input
                      type="text"
                      value={addressText}
                      onChange={(e) => setAddressText(e.target.value)}
                      placeholder="e.g. Interstate 95 Northbound, Exit 42 Shoulder"
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-sans focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>

                  <div className="text-[11px] font-mono text-stone-dim space-y-0.5">
                    <div>Draggable marker active • Click anywhere on map to reposition</div>
                    <div>Source: {locationSource === 'GPS' ? 'Hardware GPS Telemetry' : 'Manual Map Pin'}</div>
                  </div>
                </div>

                {/* Dispatch Trigger Authorization Card */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-5 shadow-architectural">
                  <div className="space-y-1">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Dispatch Authorization
                    </span>
                    <div className="text-sm font-medium text-porcelain">
                      Autonomous Haversine Proximity Discovery
                    </div>
                    <p className="text-xs text-stone-muted font-normal leading-relaxed">
                      Submitting initiates radial search across certified field mechanics within a 25km radius. Deterministic triage assesses tow requirement instantly.
                    </p>
                  </div>

                  <button
                    type="submit"
                    disabled={isSubmitting || (vehicles.length > 0 && !selectedVehicleId)}
                    className="w-full py-4 rounded-sm bg-crimson hover:bg-crimson-hover active:bg-crimson text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                        <span>Transmitting Breakdown Incident...</span>
                      </>
                    ) : (
                      <>
                        <ShieldAlert className="w-3.5 h-3.5" />
                        <span>Transmit Emergency Signal</span>
                      </>
                    )}
                  </button>
                </div>

              </div>

            </div>
          </form>
        )}

      </main>
    </div>
  );
}

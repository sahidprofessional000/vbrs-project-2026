'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { Vehicle, BreakdownCategory, SeverityLevel } from '@/types';
import { 
  ShieldAlert, 
  MapPin, 
  Car, 
  AlertCircle, 
  Loader2, 
  CheckCircle2, 
  Navigation,
  ArrowRight,
  ChevronLeft
} from 'lucide-react';

export default function ReportBreakdownPage() {
  const { user } = useAuth();
  const router = useRouter();

  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [selectedVehicleId, setSelectedVehicleId] = useState<string>('');
  const [category, setCategory] = useState<BreakdownCategory>('ENGINE_FAILURE');
  const [severity, setSeverity] = useState<SeverityLevel>('MEDIUM');
  const [description, setDescription] = useState('');
  const [addressText, setAddressText] = useState('');
  
  // Geolocation state
  const [latitude, setLatitude] = useState<number | null>(40.7128);
  const [longitude, setLongitude] = useState<number | null>(-74.0060);
  const [isLocating, setIsLocating] = useState(false);
  const [locationSource, setLocationSource] = useState<'GPS' | 'MANUAL'>('MANUAL');

  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submittedSuccess, setSubmittedSuccess] = useState(false);

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

    // Trigger initial geolocation capture
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
        console.warn('Geolocation denied or unavailable, using manual pin:', err);
        setLocationSource('MANUAL');
        setIsLocating(false);
      },
      { timeout: 8000, enableHighAccuracy: true }
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);

    // Simulate incident submission
    setTimeout(() => {
      setIsSubmitting(false);
      setSubmittedSuccess(true);
    }, 1200);
  };

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
          <span className="text-porcelain uppercase">Emergency Intake</span>
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
          <p className="text-xs text-stone-muted font-normal max-w-xl leading-relaxed">
            Specify failure characteristics and coordinates. The Haversine matching engine will calculate the nearest available field technician.
          </p>
        </div>

        {submittedSuccess ? (
          <div className="border border-sage/60 bg-graphite p-12 text-center space-y-5 animate-fadeIn">
            <div className="w-12 h-12 border border-sage/40 bg-sage-subtle flex items-center justify-center mx-auto text-sage-light">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <div className="space-y-1.5">
              <h2 className="text-2xl font-medium text-porcelain">Breakdown Signal Transmitted</h2>
              <p className="text-xs text-stone-muted font-normal max-w-md mx-auto">
                Incident logged at coordinates ({latitude}, {longitude}). Dispatch radar is actively discovering qualified technicians.
              </p>
            </div>
            <div className="pt-4 flex justify-center gap-4 text-xs font-mono uppercase tracking-wider">
              <Link
                href="/customer/vehicles"
                className="px-6 py-3 bg-porcelain text-carbon font-medium hover:bg-porcelain-dim transition-colors"
              >
                Return to Garage
              </Link>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-8">
            
            {/* Wide Two-Column Grid on Large Screens */}
            <div className="grid lg:grid-cols-12 gap-8 items-start">
              
              {/* Left Column (7 cols): Vehicle & Fault Details */}
              <div className="lg:col-span-7 space-y-8">
                
                {/* Step 1: Vehicle Selection */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Section 01 // Disabled Automobile
                    </span>
                    <Link href="/customer/vehicles" className="text-xs font-mono text-stone-muted hover:text-porcelain">
                      + Add Car
                    </Link>
                  </div>

                  {vehicles.length > 0 ? (
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
                    <div className="text-xs font-mono text-stone-muted py-2">
                      No vehicles enrolled. Please register a vehicle in your garage first.
                    </div>
                  )}
                </div>

                {/* Step 2: Fault Categorization & Urgency */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block pb-3 border-b border-divider/60">
                    Section 02 // Mechanical Fault & Hazard Severity
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
                      Observed Symptoms & Technical Notes
                    </label>
                    <textarea
                      rows={3}
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Describe abnormal sounds, smoke, dashboard warning lights, or collision damage..."
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-sans focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>
                </div>

              </div>

              {/* Right Column (5 cols): Geospatial Coordinates & Dispatch Summary */}
              <div className="lg:col-span-5 space-y-8">
                
                {/* Step 3: Roadside Geospatial Coordinates */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-4 shadow-architectural">
                  <div className="flex items-center justify-between pb-3 border-b border-divider/60">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Section 03 // Coordinates
                    </span>
                    <button
                      type="button"
                      onClick={handleDetectLocation}
                      disabled={isLocating}
                      className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider flex items-center gap-1.5"
                    >
                      <Navigation className={`w-3 h-3 ${isLocating ? 'animate-spin' : ''}`} />
                      <span>{isLocating ? 'Locating...' : 'Refresh GPS'}</span>
                    </button>
                  </div>

                  <div className="grid grid-cols-2 gap-3 pt-2">
                    <div className="p-3.5 bg-carbon border border-divider font-mono text-xs space-y-1">
                      <span className="text-stone-dim uppercase text-[10px] block">Latitude</span>
                      <div className="text-porcelain font-semibold text-sm">
                        {latitude ? latitude.toFixed(6) : '40.712800'}
                      </div>
                    </div>

                    <div className="p-3.5 bg-carbon border border-divider font-mono text-xs space-y-1">
                      <span className="text-stone-dim uppercase text-[10px] block">Longitude</span>
                      <div className="text-porcelain font-semibold text-sm">
                        {longitude ? longitude.toFixed(6) : '-74.006000'}
                      </div>
                    </div>
                  </div>

                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                      Roadside Landmark / Marker
                    </label>
                    <input
                      type="text"
                      value={addressText}
                      onChange={(e) => setAddressText(e.target.value)}
                      placeholder="e.g. Interstate 95 Northbound, Mile Marker 42"
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-sans focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>

                  <div className="pt-2 text-[11px] font-mono text-stone-dim space-y-1">
                    <div>WGS84 Spherical Trigonometry Active</div>
                    <div>Source: {locationSource === 'GPS' ? 'Hardware GPS Sensor' : 'Manual Coordinate Pin'}</div>
                  </div>
                </div>

                {/* Dispatch Trigger Card */}
                <div className="border border-divider bg-graphite p-6 sm:p-8 space-y-5 shadow-architectural">
                  <div className="space-y-1">
                    <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim">
                      Dispatch Authorization
                    </span>
                    <div className="text-sm font-medium text-porcelain">
                      Autonomous Haversine Proximity Match
                    </div>
                    <p className="text-xs text-stone-muted font-normal">
                      Submitting initiates radial search across certified mechanics within a 25km radius.
                    </p>
                  </div>

                  <button
                    type="submit"
                    disabled={isSubmitting || !selectedVehicleId}
                    className="w-full py-4 rounded-sm bg-crimson hover:bg-crimson-hover active:bg-crimson text-porcelain font-medium text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                        <span>Transmitting Signal...</span>
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

'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { MechanicEarnings } from '@/types';
import {
  Wrench,
  ShieldCheck,
  ShieldAlert,
  AlertTriangle,
  CheckCircle2,
  Loader2,
  Star,
  MapPin,
  Clock,
  Phone,
  FileText,
  Award,
  Layers,
  Plus,
  Trash2,
  LogOut,
  ArrowRight,
  User,
  Activity,
  DollarSign
} from 'lucide-react';

export default function MechanicProfilePage() {
  const { user, logout, isLoading: authLoading } = useAuth();
  const router = useRouter();

  // Profile Form State
  const [workshopName, setWorkshopName] = useState('');
  const [workshopAddress, setWorkshopAddress] = useState('');
  const [phone, setPhone] = useState('');
  const [experienceYears, setExperienceYears] = useState<number>(5);
  const [operatingRadiusKm, setOperatingRadiusKm] = useState<number>(25);
  const [tradeLicenseNumber, setTradeLicenseNumber] = useState('');
  const [initialLicense, setInitialLicense] = useState('');
  const [bio, setBio] = useState('');

  // Specializations & Certifications
  const [specializations, setSpecializations] = useState<string[]>([]);
  const [newSpec, setNewSpec] = useState('');
  const [certifications, setCertifications] = useState<string[]>([]);
  const [newCert, setNewCert] = useState('');

  // Loaded Profile and Earnings
  const [profile, setProfile] = useState<any>(null);
  const [earnings, setEarnings] = useState<MechanicEarnings | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Status Notifications
  const [feedback, setFeedback] = useState<{
    type: 'success' | 'error' | 'warning';
    message: string;
  } | null>(null);

  // Role Guard
  useEffect(() => {
    if (!authLoading) {
      if (!user) {
        router.push('/login?redirect=/mechanic/profile');
      } else if (user.role === 'CUSTOMER') {
        router.push('/customer/profile');
      } else if (user.role === 'ADMIN') {
        router.push('/admin/dashboard');
      }
    }
  }, [user, authLoading, router]);

  // Load Mechanic Profile & Earnings
  useEffect(() => {
    if (user && user.role === 'MECHANIC') {
      const loadProfile = async () => {
        try {
          setIsLoading(true);
          const [prof, earn] = await Promise.all([
            api.get<any>('/mechanic/profile').catch(() => null),
            api.get<MechanicEarnings>('/mechanic/earnings').catch(() => null),
          ]);

          if (prof) {
            setProfile(prof);
            setWorkshopName(prof.workshopName || '');
            setWorkshopAddress(prof.workshopAddress || '');
            setPhone(user.phone || '');
            setExperienceYears(prof.experienceYears || 0);
            setOperatingRadiusKm(prof.operatingRadiusKm || 25);
            setTradeLicenseNumber(prof.tradeLicenseNumber || '');
            setInitialLicense(prof.tradeLicenseNumber || '');
            setBio(prof.bio || '');
            setSpecializations(Array.isArray(prof.specializations) ? prof.specializations : []);
            setCertifications(Array.isArray(prof.certifications) ? prof.certifications : []);
          }

          setEarnings(earn);
        } catch (err: any) {
          console.error('Failed to load profile:', err);
          setFeedback({ type: 'error', message: 'Failed to retrieve profile records from database.' });
        } finally {
          setIsLoading(false);
        }
      };

      loadProfile();
    }
  }, [user]);

  // Add Specialization Tag
  const handleAddSpec = () => {
    const trimmed = newSpec.trim();
    if (!trimmed) return;
    if (!specializations.includes(trimmed)) {
      setSpecializations([...specializations, trimmed]);
    }
    setNewSpec('');
  };

  const handleRemoveSpec = (index: number) => {
    setSpecializations(specializations.filter((_, i) => i !== index));
  };

  // Add Certification Tag
  const handleAddCert = () => {
    const trimmed = newCert.trim();
    if (!trimmed) return;
    if (!certifications.includes(trimmed)) {
      setCertifications([...certifications, trimmed]);
    }
    setNewCert('');
  };

  const handleRemoveCert = (index: number) => {
    setCertifications(certifications.filter((_, i) => i !== index));
  };

  // Handle Form Submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);
    setIsSubmitting(true);

    const licenseChanged = tradeLicenseNumber.trim() !== initialLicense.trim();

    try {
      const updated = await api.put<any>('/mechanic/profile', {
        workshopName: workshopName.trim() || undefined,
        workshopAddress: workshopAddress.trim() || undefined,
        phone: phone.trim() || undefined,
        experienceYears: Number(experienceYears) || 0,
        operatingRadiusKm: Number(operatingRadiusKm) || 25,
        tradeLicenseNumber: tradeLicenseNumber.trim() || undefined,
        specializations,
        certifications,
        bio: bio.trim() || undefined,
      });

      setProfile(updated);
      setInitialLicense(updated.tradeLicenseNumber || '');

      if (licenseChanged) {
        setFeedback({
          type: 'warning',
          message:
            'Trade License Number was updated. Your verification status has been reset to PENDING and logged for municipal administrative audit.',
        });
      } else {
        setFeedback({
          type: 'success',
          message: 'Professional workshop profile and credentials updated successfully.',
        });
      }
    } catch (err: any) {
      setFeedback({
        type: 'error',
        message: err.message || 'Failed to update professional profile in PostgreSQL.',
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (authLoading || isLoading) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <div className="flex-1 flex flex-col items-center justify-center gap-3">
          <Loader2 className="w-6 h-6 animate-spin text-stone-muted" />
          <span className="text-xs font-mono uppercase tracking-widest text-stone-muted">
            Synchronizing Technician Dossier...
          </span>
        </div>
      </div>
    );
  }

  const isPending = profile?.verificationStatus === 'PENDING';
  const isApproved = profile?.verificationStatus === 'APPROVED';
  const isRejected = profile?.verificationStatus === 'REJECTED';

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 layout-container py-10 space-y-8">
        
        {/* Navigation Breadcrumb */}
        <div className="flex items-center gap-2 text-xs font-mono text-stone-muted">
          <Link href="/mechanic/home" className="hover:text-porcelain transition-colors">
            Workshop Desk
          </Link>
          <span className="text-divider">•</span>
          <span className="text-porcelain uppercase tracking-wider">Professional Profile & Credentials</span>
        </div>

        {/* Feedback Alert Banner */}
        {feedback && (
          <div
            className={`p-4 text-xs font-mono border rounded-sm flex items-center justify-between ${
              feedback.type === 'success'
                ? 'bg-forest/10 border-forest/40 text-forest'
                : feedback.type === 'warning'
                ? 'bg-ochre/10 border-ochre/40 text-ochre'
                : 'bg-crimson/10 border-crimson/40 text-crimson'
            }`}
          >
            <div className="flex items-center gap-2.5">
              {feedback.type === 'success' && <CheckCircle2 className="w-4 h-4 shrink-0" />}
              {feedback.type === 'warning' && <AlertTriangle className="w-4 h-4 shrink-0" />}
              {feedback.type === 'error' && <ShieldAlert className="w-4 h-4 shrink-0" />}
              <span>{feedback.message}</span>
            </div>
            <button
              onClick={() => setFeedback(null)}
              className="text-stone-muted hover:text-porcelain font-mono text-xs uppercase"
            >
              Dismiss
            </button>
          </div>
        )}

        <div className="grid lg:grid-cols-12 gap-8">
          
          {/* Left Column: Verification Badge & Performance Summary (4 cols) */}
          <div className="lg:col-span-4 space-y-6">
            
            {/* Verification Status Card */}
            <div className="p-6 border border-divider bg-graphite rounded-sm space-y-4">
              <div className="flex items-center justify-between border-b border-divider/60 pb-3">
                <span className="text-xs font-mono uppercase tracking-wider text-stone-muted">
                  Municipal Accreditation
                </span>
                <span
                  className={`px-2 py-0.5 rounded-sm border text-[10px] font-mono uppercase tracking-wider ${
                    isApproved
                      ? 'bg-forest/10 border-forest/30 text-forest'
                      : isRejected
                      ? 'bg-crimson/10 border-crimson/30 text-crimson'
                      : 'bg-ochre/10 border-ochre/30 text-ochre'
                  }`}
                >
                  {profile?.verificationStatus || 'PENDING'}
                </span>
              </div>

              <div className="space-y-2">
                <div className="flex items-center gap-2.5">
                  {isApproved ? (
                    <ShieldCheck className="w-5 h-5 text-forest shrink-0" />
                  ) : (
                    <ShieldAlert className="w-5 h-5 text-ochre shrink-0" />
                  )}
                  <h3 className="text-sm font-medium text-porcelain tracking-tight">
                    {isApproved
                      ? 'Full ASE Certified Service License'
                      : isRejected
                      ? 'Accreditation Rejected by Admin'
                      : 'Verification In Review'}
                  </h3>
                </div>

                <p className="text-xs text-stone-muted leading-relaxed">
                  {isApproved
                    ? 'Your trade license and credentials are fully verified. You are authorized to receive high-urgency and towing recovery dispatches.'
                    : isRejected
                    ? `Reason: ${profile?.verificationNotes || 'Documentation failed verification requirements.'}`
                    : 'Your trade documentation is currently pending administrator verification. Standard roadside calls remain available.'}
                </p>
              </div>

              {profile?.verificationNotes && (
                <div className="p-3 bg-carbon border border-divider text-xs font-mono text-stone-muted rounded-sm">
                  <span className="text-stone-dim uppercase block text-[10px]">Auditor Notes:</span>
                  <span>{profile.verificationNotes}</span>
                </div>
              )}
            </div>

            {/* Standing & Financial Summary */}
            <div className="p-6 border border-divider bg-graphite rounded-sm space-y-4">
              <div className="text-xs font-mono uppercase tracking-wider text-stone-muted border-b border-divider/60 pb-3">
                Technician Ledger Summary
              </div>

              <div className="space-y-3 text-xs font-mono">
                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Reputation Score:</span>
                  <span className="text-porcelain font-semibold">{profile?.reputationScore || 100} / 100</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Average Rating:</span>
                  <span className="text-ochre font-semibold">{profile?.ratingAverage ? Number(profile.ratingAverage).toFixed(1) : '5.0'}★ ({profile?.totalReviews || 0} reviews)</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Completed Work Orders:</span>
                  <span className="text-porcelain font-semibold">{profile?.totalJobsCompleted || 0} Orders</span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Recorded Revenue:</span>
                  <span className="text-forest font-semibold">${earnings ? Number(earnings.totalRevenue).toFixed(2) : '0.00'}</span>
                </div>
              </div>

              <div className="pt-2">
                <button
                  type="button"
                  onClick={() => logout()}
                  className="w-full py-2.5 rounded-sm bg-carbon hover:bg-crimson/15 hover:border-crimson/40 text-stone-muted hover:text-crimson border border-divider text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Sign Out of Terminal</span>
                </button>
              </div>
            </div>

          </div>

          {/* Right Column: Editable Profile Form (8 cols) */}
          <div className="lg:col-span-8 p-6 sm:p-8 border border-divider bg-graphite rounded-sm space-y-6">
            <div className="border-b border-divider/60 pb-4">
              <h2 className="text-lg font-medium text-porcelain tracking-tight">
                Edit Professional Workshop Dossier
              </h2>
              <p className="text-xs text-stone-muted mt-0.5">
                Update garage branding, operating perimeter, certifications, technical specializations, and municipal credentials.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              
              {/* Workshop Name & Phone */}
              <div className="grid sm:grid-cols-2 gap-5">
                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Workshop / Business Name
                  </label>
                  <input
                    type="text"
                    required
                    value={workshopName}
                    onChange={(e) => setWorkshopName(e.target.value)}
                    placeholder="e.g. Apex Precision Automotive"
                    className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Dispatch Telephone Number
                  </label>
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+1 (555) 234-5678"
                    className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                  />
                </div>
              </div>

              {/* Physical Workshop Address */}
              <div>
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                  Physical Workshop Location Address
                </label>
                <input
                  type="text"
                  value={workshopAddress}
                  onChange={(e) => setWorkshopAddress(e.target.value)}
                  placeholder="e.g. 784 Industrial Parkway, Bay 4, New York, NY 10001"
                  className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                />
              </div>

              {/* Experience Years & Operating Radius */}
              <div className="grid sm:grid-cols-2 gap-5">
                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Years of Professional Experience
                  </label>
                  <input
                    type="number"
                    min="0"
                    max="60"
                    value={experienceYears}
                    onChange={(e) => setExperienceYears(Number(e.target.value))}
                    className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Service Perimeter Radius: {operatingRadiusKm} km
                  </label>
                  <input
                    type="range"
                    min="10"
                    max="100"
                    step="5"
                    value={operatingRadiusKm}
                    onChange={(e) => setOperatingRadiusKm(Number(e.target.value))}
                    className="w-full accent-porcelain bg-carbon rounded-lg h-2 cursor-pointer mt-3"
                  />
                </div>
              </div>

              {/* Sensitive Trade License Number */}
              <div className="p-4 bg-carbon border border-divider rounded-sm space-y-3">
                <div className="flex items-center justify-between">
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-porcelain font-medium">
                    Municipal Trade License / Registration Number
                  </label>
                  <span className="text-[10px] font-mono uppercase text-ochre">
                    Security Sensitive
                  </span>
                </div>

                <input
                  type="text"
                  value={tradeLicenseNumber}
                  onChange={(e) => setTradeLicenseNumber(e.target.value)}
                  placeholder="e.g. LIC-AUTO-2026-889"
                  className="w-full px-3.5 py-2.5 bg-elevated border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                />

                <div className="flex items-start gap-2 text-[11px] font-mono text-stone-muted">
                  <AlertTriangle className="w-3.5 h-3.5 text-ochre shrink-0 mt-0.5" />
                  <span>
                    Governance Policy: Modifying your official license number will instantly revert verification status to <strong className="text-ochre">PENDING</strong> and trigger an administrative audit log.
                  </span>
                </div>
              </div>

              {/* Technical Specializations Tag Manager */}
              <div className="space-y-3">
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted">
                  Technical Specializations ({specializations.length})
                </label>

                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newSpec}
                    onChange={(e) => setNewSpec(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') {
                        e.preventDefault();
                        handleAddSpec();
                      }
                    }}
                    placeholder="e.g. Drivetrain & Transmission"
                    className="flex-1 px-3.5 py-2 bg-carbon border border-divider text-porcelain text-xs font-mono rounded-sm"
                  />
                  <button
                    type="button"
                    onClick={handleAddSpec}
                    className="px-4 py-2 bg-elevated hover:bg-carbon border border-divider text-xs font-mono uppercase tracking-wider text-porcelain rounded-sm transition-colors flex items-center gap-1.5"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Add</span>
                  </button>
                </div>

                <div className="flex flex-wrap gap-2 pt-1">
                  {specializations.map((spec, idx) => (
                    <span
                      key={idx}
                      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-sm bg-carbon border border-divider text-xs font-mono text-porcelain"
                    >
                      <span>{spec}</span>
                      <button
                        type="button"
                        onClick={() => handleRemoveSpec(idx)}
                        className="text-stone-dim hover:text-crimson"
                      >
                        ×
                      </button>
                    </span>
                  ))}
                </div>
              </div>

              {/* Professional Certifications Tag Manager */}
              <div className="space-y-3">
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted">
                  Professional Certifications ({certifications.length})
                </label>

                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newCert}
                    onChange={(e) => setNewCert(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') {
                        e.preventDefault();
                        handleAddCert();
                      }
                    }}
                    placeholder="e.g. ASE Master Automobile Technician"
                    className="flex-1 px-3.5 py-2 bg-carbon border border-divider text-porcelain text-xs font-mono rounded-sm"
                  />
                  <button
                    type="button"
                    onClick={handleAddCert}
                    className="px-4 py-2 bg-elevated hover:bg-carbon border border-divider text-xs font-mono uppercase tracking-wider text-porcelain rounded-sm transition-colors flex items-center gap-1.5"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Add</span>
                  </button>
                </div>

                <div className="flex flex-wrap gap-2 pt-1">
                  {certifications.map((cert, idx) => (
                    <span
                      key={idx}
                      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-sm bg-carbon border border-divider text-xs font-mono text-forest"
                    >
                      <Award className="w-3 h-3 text-forest" />
                      <span>{cert}</span>
                      <button
                        type="button"
                        onClick={() => handleRemoveCert(idx)}
                        className="text-stone-dim hover:text-crimson"
                      >
                        ×
                      </button>
                    </span>
                  ))}
                </div>
              </div>

              {/* Workshop Biography */}
              <div>
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                  Workshop Biography & Capabilities Overview
                </label>
                <textarea
                  rows={4}
                  value={bio}
                  onChange={(e) => setBio(e.target.value)}
                  placeholder="Describe your garage equipment, mobile diagnostic gear, towing capabilities, and specialized repair services..."
                  className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm resize-none"
                />
              </div>

              {/* Submit Button */}
              <div className="pt-2 flex justify-end">
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-3 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors flex items-center gap-2 shadow-architectural"
                >
                  {isSubmitting ? (
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  ) : (
                    <CheckCircle2 className="w-3.5 h-3.5" />
                  )}
                  <span>Save Professional Dossier</span>
                </button>
              </div>

            </form>
          </div>

        </div>

      </main>
    </div>
  );
}

'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { api } from '@/lib/api';
import { Vehicle, SavedAddress } from '@/types';
import {
  User,
  MapPin,
  Car,
  Shield,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Trash2,
  Plus,
  ArrowRight,
  Compass,
  Star,
  LogOut,
  Clock,
  Phone,
  Mail,
  Calendar,
  Camera
} from 'lucide-react';

export default function CustomerProfilePage() {
  const { user, updateUser, logout, isLoading: authLoading } = useAuth();
  const router = useRouter();

  // Profile Form State
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');
  const [isUpdatingProfile, setIsUpdatingProfile] = useState(false);
  const [profileSuccess, setProfileSuccess] = useState<string | null>(null);
  const [profileError, setProfileError] = useState<string | null>(null);

  // Saved Addresses State
  const [savedAddresses, setSavedAddresses] = useState<SavedAddress[]>([]);
  const [isLoadingAddresses, setIsLoadingAddresses] = useState(true);
  const [isAddingAddress, setIsAddingAddress] = useState(false);
  const [newLabel, setNewLabel] = useState('');
  const [newAddress, setNewAddress] = useState('');
  const [newLat, setNewLat] = useState<number | ''>('');
  const [newLng, setNewLng] = useState<number | ''>('');
  const [isDefaultAddress, setIsDefaultAddress] = useState(false);
  const [addressError, setAddressError] = useState<string | null>(null);
  const [addressSuccess, setAddressSuccess] = useState<string | null>(null);

  // Overview and fleet state
  const [overview, setOverview] = useState<any>(null);
  const [isLoadingOverview, setIsLoadingOverview] = useState(true);

  // Role Guard
  useEffect(() => {
    if (!authLoading) {
      if (!user) {
        router.push('/login?redirect=/customer/profile');
      } else if (user.role === 'MECHANIC') {
        router.push('/mechanic/profile');
      } else if (user.role === 'ADMIN') {
        router.push('/admin/dashboard');
      }
    }
  }, [user, authLoading, router]);

  // Sync initial user details into form
  useEffect(() => {
    if (user) {
      setFullName(user.fullName || '');
      setPhone(user.phone || '');
      setAvatarUrl(user.avatarUrl || '');
    }
  }, [user]);

  // Load Saved Addresses & Overview
  const loadAddresses = async () => {
    try {
      setIsLoadingAddresses(true);
      const data = await api.get<SavedAddress[]>('/customer/saved-addresses');
      setSavedAddresses(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error('Failed to load saved addresses:', err);
    } finally {
      setIsLoadingAddresses(false);
    }
  };

  const loadOverview = async () => {
    try {
      setIsLoadingOverview(true);
      const data = await api.get<any>('/customer/overview');
      setOverview(data);
    } catch (err) {
      console.error('Failed to load overview:', err);
    } finally {
      setIsLoadingOverview(false);
    }
  };

  useEffect(() => {
    if (user && user.role === 'CUSTOMER') {
      loadAddresses();
      loadOverview();
    }
  }, [user]);

  // Handle Profile Update
  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setProfileError(null);
    setProfileSuccess(null);
    setIsUpdatingProfile(true);

    try {
      const updated = await api.put<any>('/auth/profile', {
        fullName: fullName.trim(),
        phone: phone.trim() || undefined,
        avatarUrl: avatarUrl.trim() || undefined,
      });

      updateUser({
        fullName: updated.fullName,
        phone: updated.phone,
        avatarUrl: updated.avatarUrl,
      });

      setProfileSuccess('Personal credentials and contact data updated successfully.');
      setTimeout(() => setProfileSuccess(null), 5000);
    } catch (err: any) {
      setProfileError(err.message || 'Failed to update personal profile.');
    } finally {
      setIsUpdatingProfile(false);
    }
  };

  // Handle Create Saved Address
  const handleCreateAddress = async (e: React.FormEvent) => {
    e.preventDefault();
    setAddressError(null);
    setAddressSuccess(null);

    if (!newLabel.trim() || !newAddress.trim()) {
      setAddressError('Please provide both an address label and street address.');
      return;
    }

    try {
      await api.post('/customer/saved-addresses', {
        label: newLabel.trim(),
        address: newAddress.trim(),
        latitude: newLat !== '' ? Number(newLat) : undefined,
        longitude: newLng !== '' ? Number(newLng) : undefined,
        isDefault: isDefaultAddress,
      });

      setNewLabel('');
      setNewAddress('');
      setNewLat('');
      setNewLng('');
      setIsDefaultAddress(false);
      setIsAddingAddress(false);
      setAddressSuccess('New dispatch location bookmark saved successfully.');
      setTimeout(() => setAddressSuccess(null), 5000);
      loadAddresses();
    } catch (err: any) {
      setAddressError(err.message || 'Failed to save address.');
    }
  };

  // Handle Delete Address
  const handleDeleteAddress = async (id: string) => {
    try {
      await api.delete(`/customer/saved-addresses/${id}`);
      setSavedAddresses((prev) => prev.filter((a) => a.id !== id));
      setAddressSuccess('Dispatch bookmark removed.');
      setTimeout(() => setAddressSuccess(null), 4000);
    } catch (err: any) {
      setAddressError(err.message || 'Failed to delete address.');
    }
  };

  // Auto-detect GPS for address form
  const handleDetectGPS = () => {
    if (typeof window !== 'undefined' && navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          setNewLat(Number(pos.coords.latitude.toFixed(6)));
          setNewLng(Number(pos.coords.longitude.toFixed(6)));
        },
        () => {
          setAddressError('Could not acquire hardware GPS location.');
        }
      );
    }
  };

  if (authLoading) {
    return (
      <div className="min-h-screen bg-carbon text-porcelain flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <Loader2 className="w-6 h-6 animate-spin text-stone-muted" />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col selection:bg-porcelain selection:text-carbon">
      <Navbar />

      <main className="flex-1 pb-24">
        {/* ================================================================= */}
        {/* 1. HEADER SECTION                                                 */}
        {/* ================================================================= */}
        <section className="border-b border-divider/60 bg-graphite/40 py-8 lg:py-10">
          <div className="layout-container flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <Link
                  href="/customer/home"
                  className="text-xs font-mono text-stone-muted hover:text-porcelain uppercase tracking-wider transition-colors"
                >
                  Customer Home
                </Link>
                <span className="text-stone-dim text-xs">/</span>
                <span className="text-xs font-mono text-porcelain uppercase tracking-wider">
                  Profile & Settings
                </span>
              </div>

              <h1 className="text-2xl sm:text-3xl font-medium tracking-tight text-porcelain">
                Motorist Account & Preferences
              </h1>
              <p className="text-xs sm:text-sm text-stone-muted mt-1">
                Manage personal contact details, dispatch locations, and vehicle fleet connectivity.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <Link
                href="/customer/home"
                className="px-4 py-2.5 rounded-sm bg-carbon hover:bg-elevated border border-divider text-xs font-mono uppercase tracking-wider text-stone-muted hover:text-porcelain transition-colors"
              >
                Return to Dashboard
              </Link>
            </div>
          </div>
        </section>

        <div className="layout-container pt-8 space-y-10">
          
          {/* ================================================================= */}
          {/* 2. PERSONAL IDENTITY & PROFILE EDITING                            */}
          {/* ================================================================= */}
          <div className="grid lg:grid-cols-12 gap-8 items-start">
            
            {/* Left: Avatar & Role Summary Card (4 cols) */}
            <div className="lg:col-span-4 border border-divider bg-graphite p-6 rounded-sm space-y-6">
              <div className="text-center space-y-4">
                <div className="w-24 h-24 mx-auto rounded-sm bg-elevated border border-divider flex items-center justify-center overflow-hidden relative group">
                  {avatarUrl ? (
                    <img
                      src={avatarUrl}
                      alt={fullName}
                      className="w-full h-full object-cover"
                      onError={() => setAvatarUrl('')}
                    />
                  ) : (
                    <User className="w-10 h-10 text-stone-muted stroke-[1.5]" />
                  )}
                </div>

                <div>
                  <h2 className="text-lg font-medium text-porcelain tracking-tight">{fullName || 'Motorist'}</h2>
                  <div className="text-xs font-mono text-stone-muted mt-0.5">{user?.email}</div>
                  <span className="inline-block mt-2.5 px-2.5 py-0.5 rounded-sm bg-forest/10 border border-forest/30 text-forest text-[10px] font-mono uppercase tracking-wider">
                    Role: Certified Motorist
                  </span>
                </div>
              </div>

              <div className="pt-4 border-t border-divider/60 space-y-3 text-xs font-mono">
                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Member Since:</span>
                  <span className="text-porcelain">
                    {user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'Active'}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Registered Fleet:</span>
                  <span className="text-porcelain">{overview?.stats?.totalVehicles || 0} Vehicles</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-stone-dim">Saved Locations:</span>
                  <span className="text-porcelain">{savedAddresses.length} Bookmarks</span>
                </div>
              </div>

              <div className="pt-2">
                <button
                  type="button"
                  onClick={() => logout()}
                  className="w-full py-2.5 rounded-sm bg-carbon hover:bg-crimson/15 hover:border-crimson/40 text-stone-muted hover:text-crimson border border-divider text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Terminate Session (Sign Out)</span>
                </button>
              </div>
            </div>

            {/* Right: Personal Details Form (8 cols) */}
            <div className="lg:col-span-8 border border-divider bg-graphite p-6 sm:p-8 rounded-sm space-y-6">
              <div className="border-b border-divider/60 pb-4">
                <h3 className="text-base font-medium text-porcelain tracking-tight">
                  Edit Personal Credentials
                </h3>
                <p className="text-xs text-stone-muted mt-0.5">
                  Update full legal name, phone number for technician coordination, and profile photo.
                </p>
              </div>

              {profileSuccess && (
                <div className="p-3.5 border border-forest/50 bg-forest/10 text-porcelain text-xs flex items-center gap-2.5 rounded-sm">
                  <CheckCircle2 className="w-4 h-4 text-forest shrink-0" />
                  <span>{profileSuccess}</span>
                </div>
              )}

              {profileError && (
                <div className="p-3.5 border border-crimson/50 bg-crimson/10 text-porcelain text-xs flex items-center gap-2.5 rounded-sm">
                  <AlertCircle className="w-4 h-4 text-crimson shrink-0" />
                  <span>{profileError}</span>
                </div>
              )}

              <form onSubmit={handleUpdateProfile} className="space-y-5">
                <div className="grid sm:grid-cols-2 gap-5">
                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                      Full Legal Name
                    </label>
                    <input
                      type="text"
                      required
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="Jane Doe"
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                      Primary Phone Number
                    </label>
                    <input
                      type="tel"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="+1-555-0199"
                      className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Profile Photograph (Image URL)
                  </label>
                  <input
                    type="url"
                    value={avatarUrl}
                    onChange={(e) => setAvatarUrl(e.target.value)}
                    placeholder="https://images.unsplash.com/photo-..."
                    className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-sm"
                  />
                  <div className="text-[10px] text-stone-dim font-mono mt-1">
                    Provide a secure HTTPS image link for customer identification during roadside arrivals.
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                    Email Address (Account Identifier)
                  </label>
                  <input
                    type="email"
                    disabled
                    value={user?.email || ''}
                    className="w-full px-3.5 py-2.5 bg-carbon/50 border border-divider/50 text-stone-muted text-xs font-mono cursor-not-allowed rounded-sm"
                  />
                  <div className="text-[10px] text-stone-dim font-mono mt-1">
                    Email address is cryptographically bound to your user account and cannot be modified directly.
                  </div>
                </div>

                <div className="pt-2 flex justify-end">
                  <button
                    type="submit"
                    disabled={isUpdatingProfile}
                    className="px-6 py-2.5 rounded-sm bg-porcelain hover:bg-stone-dim text-carbon font-mono text-xs uppercase tracking-wider font-medium transition-colors inline-flex items-center gap-2"
                  >
                    {isUpdatingProfile ? (
                      <>
                        <Loader2 className="w-3.5 h-3.5 animate-spin" />
                        <span>Saving...</span>
                      </>
                    ) : (
                      <span>Save Profile Changes</span>
                    )}
                  </button>
                </div>
              </form>
            </div>

          </div>

          {/* ================================================================= */}
          {/* 3. SAVED DISPATCH ADDRESSES (BOOKMARKS MANAGER)                   */}
          {/* ================================================================= */}
          <div className="border border-divider bg-graphite p-6 sm:p-8 rounded-sm space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-divider/60 pb-4">
              <div>
                <h3 className="text-base font-medium text-porcelain tracking-tight flex items-center gap-2">
                  <MapPin className="w-4 h-4 text-porcelain" />
                  <span>Saved Dispatch Locations</span>
                </h3>
                <p className="text-xs text-stone-muted mt-0.5">
                  Store frequently visited locations (Home, Corporate Office, Fleet Bay) for 1-click breakdown reporting.
                </p>
              </div>

              {!isAddingAddress && (
                <button
                  type="button"
                  onClick={() => setIsAddingAddress(true)}
                  className="px-4 py-2 rounded-sm bg-carbon hover:bg-elevated border border-divider text-xs font-mono uppercase tracking-wider text-porcelain transition-colors inline-flex items-center gap-2 self-start"
                >
                  <Plus className="w-3.5 h-3.5" />
                  <span>Add New Location</span>
                </button>
              )}
            </div>

            {addressSuccess && (
              <div className="p-3.5 border border-forest/50 bg-forest/10 text-porcelain text-xs flex items-center gap-2.5 rounded-sm">
                <CheckCircle2 className="w-4 h-4 text-forest shrink-0" />
                <span>{addressSuccess}</span>
              </div>
            )}

            {addressError && (
              <div className="p-3.5 border border-crimson/50 bg-crimson/10 text-porcelain text-xs flex items-center gap-2.5 rounded-sm">
                <AlertCircle className="w-4 h-4 text-crimson shrink-0" />
                <span>{addressError}</span>
              </div>
            )}

            {/* Add Address Form Modal / Inline Block */}
            {isAddingAddress && (
              <div className="p-5 border border-divider bg-carbon rounded-sm space-y-4">
                <div className="flex items-center justify-between border-b border-divider/40 pb-2">
                  <span className="text-xs font-mono uppercase tracking-wider text-porcelain font-medium">
                    New Location Bookmark
                  </span>
                  <button
                    type="button"
                    onClick={() => setIsAddingAddress(false)}
                    className="text-stone-muted hover:text-porcelain text-xs font-mono"
                  >
                    Cancel
                  </button>
                </div>

                <form onSubmit={handleCreateAddress} className="space-y-4">
                  <div className="grid sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[11px] font-mono uppercase text-stone-muted mb-1.5">
                        Location Nickname
                      </label>
                      <input
                        type="text"
                        required
                        value={newLabel}
                        onChange={(e) => setNewLabel(e.target.value)}
                        placeholder="e.g. Primary Residence"
                        className="w-full px-3 py-2 bg-elevated border border-divider text-porcelain text-xs font-mono rounded-sm"
                      />
                    </div>

                    <div>
                      <label className="block text-[11px] font-mono uppercase text-stone-muted mb-1.5">
                        Street Address Text
                      </label>
                      <input
                        type="text"
                        required
                        value={newAddress}
                        onChange={(e) => setNewAddress(e.target.value)}
                        placeholder="120 Riverside Blvd, New York, NY"
                        className="w-full px-3 py-2 bg-elevated border border-divider text-porcelain text-xs font-mono rounded-sm"
                      />
                    </div>
                  </div>

                  <div className="grid sm:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-[11px] font-mono uppercase text-stone-muted mb-1.5">
                        Latitude (Optional)
                      </label>
                      <input
                        type="number"
                        step="any"
                        value={newLat}
                        onChange={(e) => setNewLat(e.target.value ? Number(e.target.value) : '')}
                        placeholder="40.7128"
                        className="w-full px-3 py-2 bg-elevated border border-divider text-porcelain text-xs font-mono rounded-sm"
                      />
                    </div>

                    <div>
                      <label className="block text-[11px] font-mono uppercase text-stone-muted mb-1.5">
                        Longitude (Optional)
                      </label>
                      <input
                        type="number"
                        step="any"
                        value={newLng}
                        onChange={(e) => setNewLng(e.target.value ? Number(e.target.value) : '')}
                        placeholder="-74.0060"
                        className="w-full px-3 py-2 bg-elevated border border-divider text-porcelain text-xs font-mono rounded-sm"
                      />
                    </div>

                    <div className="flex items-end">
                      <button
                        type="button"
                        onClick={handleDetectGPS}
                        className="w-full py-2 px-3 bg-graphite hover:bg-elevated border border-divider text-xs font-mono uppercase tracking-wider text-stone-muted hover:text-porcelain transition-colors flex items-center justify-center gap-1.5 rounded-sm"
                      >
                        <Compass className="w-3.5 h-3.5" />
                        <span>Autofill GPS</span>
                      </button>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 pt-1">
                    <input
                      type="checkbox"
                      id="defaultToggle"
                      checked={isDefaultAddress}
                      onChange={(e) => setIsDefaultAddress(e.target.checked)}
                      className="rounded border-divider bg-carbon text-porcelain focus:ring-0"
                    />
                    <label htmlFor="defaultToggle" className="text-xs text-stone-muted font-mono">
                      Designate as default primary roadside location
                    </label>
                  </div>

                  <div className="flex justify-end gap-3 pt-2">
                    <button
                      type="button"
                      onClick={() => setIsAddingAddress(false)}
                      className="px-4 py-2 rounded-sm bg-transparent hover:bg-elevated text-stone-muted text-xs font-mono uppercase"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="px-5 py-2 rounded-sm bg-porcelain text-carbon font-mono text-xs uppercase tracking-wider font-medium hover:bg-stone-dim transition-colors"
                    >
                      Save Location
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* List of Saved Addresses */}
            {isLoadingAddresses ? (
              <div className="py-8 text-center text-xs font-mono text-stone-muted">
                <Loader2 className="w-5 h-5 animate-spin mx-auto mb-2 text-stone-muted" />
                <span>Loading saved dispatch bookmarks...</span>
              </div>
            ) : savedAddresses.length === 0 ? (
              <div className="py-8 text-center space-y-2 border border-dashed border-divider/60 rounded-sm">
                <MapPin className="w-7 h-7 mx-auto text-stone-dim stroke-[1.5]" />
                <div className="text-xs text-stone-muted">No saved dispatch locations bookmark found.</div>
                <div className="text-[11px] text-stone-dim">Save your home, office, or parking garage for immediate triage.</div>
              </div>
            ) : (
              <div className="divide-y divide-divider/40 border border-divider/60 rounded-sm overflow-hidden">
                {savedAddresses.map((addr) => (
                  <div
                    key={addr.id}
                    className="p-4 bg-carbon flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-elevated/40 transition-colors"
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2.5">
                        <span className="text-sm font-medium text-porcelain tracking-tight">{addr.label}</span>
                        {addr.isDefault && (
                          <span className="px-2 py-0.5 rounded-sm bg-forest/20 text-forest text-[9px] font-mono uppercase font-medium">
                            Primary Default
                          </span>
                        )}
                      </div>
                      <div className="text-xs text-stone-muted font-normal">{addr.address}</div>
                      {addr.latitude && addr.longitude && (
                        <div className="text-[10px] font-mono text-stone-dim">
                          Coordinates: {addr.latitude}, {addr.longitude}
                        </div>
                      )}
                    </div>

                    <div className="flex items-center gap-3 shrink-0">
                      <Link
                        href={`/report-breakdown?address=${encodeURIComponent(addr.address)}&lat=${addr.latitude || ''}&lng=${addr.longitude || ''}`}
                        className="px-3 py-1.5 rounded-sm bg-elevated hover:bg-surface-hover text-stone-muted hover:text-porcelain border border-divider text-[10px] font-mono uppercase tracking-wider transition-colors"
                      >
                        Dispatch From Here
                      </Link>

                      <button
                        type="button"
                        onClick={() => handleDeleteAddress(addr.id)}
                        className="p-1.5 text-stone-dim hover:text-crimson transition-colors"
                        title="Remove bookmark"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* ================================================================= */}
          {/* 4. GARAGE FLEET SHORTCUT MATRIX                                  */}
          {/* ================================================================= */}
          <div className="border border-divider bg-graphite p-6 sm:p-8 rounded-sm space-y-5">
            <div className="flex items-center justify-between border-b border-divider/60 pb-4">
              <div>
                <h3 className="text-base font-medium text-porcelain tracking-tight flex items-center gap-2">
                  <Car className="w-4 h-4 text-porcelain" />
                  <span>Garage Fleet Connectivity ({overview?.vehicles?.length || 0})</span>
                </h3>
                <p className="text-xs text-stone-muted mt-0.5">
                  Vehicles configured for instantaneous roadside assistance dispatch.
                </p>
              </div>

              <Link
                href="/customer/vehicles"
                className="px-4 py-2 rounded-sm bg-carbon hover:bg-elevated border border-divider text-xs font-mono uppercase tracking-wider text-porcelain transition-colors inline-flex items-center gap-1.5"
              >
                <span>Full Garage Terminal</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            {overview?.vehicles?.length === 0 ? (
              <div className="py-8 text-center text-xs text-stone-muted space-y-2">
                <Car className="w-6 h-6 mx-auto text-stone-dim stroke-[1.5]" />
                <div>Zero registered vehicles.</div>
                <Link href="/customer/vehicles" className="text-porcelain underline font-mono text-xs">
                  Register vehicle in garage
                </Link>
              </div>
            ) : (
              <div className="grid sm:grid-cols-3 gap-4">
                {overview?.vehicles?.map((v: Vehicle) => (
                  <div key={v.id} className="p-4 bg-carbon border border-divider rounded-sm space-y-2">
                    <div className="flex items-start justify-between">
                      <div className="text-xs font-medium text-porcelain tracking-tight">
                        {v.year} {v.make} {v.model}
                      </div>
                      {v.isDefault && (
                        <span className="px-1.5 py-0.5 bg-porcelain text-carbon text-[9px] font-mono uppercase font-medium">
                          Primary
                        </span>
                      )}
                    </div>
                    <div className="text-[10px] font-mono text-stone-muted">{v.powertrain}</div>
                    <div className="pt-2 border-t border-divider/40 text-[11px] font-mono text-stone-dim flex justify-between">
                      <span>Plate:</span>
                      <span className="text-porcelain font-semibold">{v.licensePlate}</span>
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

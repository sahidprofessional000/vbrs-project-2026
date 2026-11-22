'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { 
  ShieldAlert, 
  Lock, 
  Mail, 
  User, 
  Phone, 
  Wrench, 
  Car, 
  Briefcase, 
  FileText, 
  ArrowRight, 
  AlertCircle, 
  Loader2, 
  CheckCircle2 
} from 'lucide-react';
import { UserRole } from '@/types';

export default function RegisterPage() {
  const router = useRouter();
  const { register } = useAuth();

  const [role, setRole] = useState<UserRole>('CUSTOMER');
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [workshopName, setWorkshopName] = useState('');
  const [tradeLicenseNumber, setTradeLicenseNumber] = useState('');
  const [experienceYears, setExperienceYears] = useState(3);

  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Simple password strength calculation
  const hasMinLength = password.length >= 8;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumberOrSymbol = /[\d\W]/.test(password);
  const isPasswordValid = hasMinLength && hasUppercase && hasLowercase && hasNumberOrSymbol;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!isPasswordValid) {
      setError('Password must meet all complexity requirements below.');
      return;
    }

    setIsSubmitting(true);

    try {
      const payload: any = {
        fullName,
        email,
        phone: phone || undefined,
        password,
        role,
      };

      if (role === 'MECHANIC') {
        payload.workshopName = workshopName || `${fullName}'s Roadside Assistance`;
        payload.tradeLicenseNumber = tradeLicenseNumber || undefined;
        payload.experienceYears = Number(experienceYears) || 1;
      }

      const user = await register(payload);
      if (user.role === 'MECHANIC') {
        router.push('/mechanic/portal');
      } else {
        router.push('/customer/vehicles');
      }
    } catch (err: any) {
      setError(err.message || 'Registration failed. Please check your inputs.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col justify-center items-center bg-slate-950 px-4 py-12 relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[550px] h-[350px] bg-rose-600/10 blur-[130px] pointer-events-none rounded-full" />

      <div className="w-full max-w-lg relative z-10">
        {/* Header */}
        <div className="text-center mb-6">
          <Link href="/" className="inline-flex items-center gap-2.5 group">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-rose-600 to-amber-600 flex items-center justify-center shadow-lg shadow-rose-950/50 group-hover:scale-105 transition-transform">
              <ShieldAlert className="w-5 h-5 text-white" />
            </div>
            <div className="text-left">
              <span className="font-extrabold tracking-tight text-xl text-white block">VBRS</span>
              <span className="text-[10px] text-slate-400 block -mt-1 font-mono tracking-widest">RESCUE RADAR</span>
            </div>
          </Link>
          <h1 className="text-2xl font-bold tracking-tight text-white mt-4">Create Your Account</h1>
          <p className="text-sm text-slate-400 mt-1">Join the open vehicle assistance network</p>
        </div>

        {/* Card */}
        <div className="rounded-2xl bg-slate-900/90 border border-slate-800 p-8 shadow-2xl backdrop-blur-sm">
          {/* Role Toggle Selector */}
          <div className="grid grid-cols-2 gap-3 mb-6 p-1.5 rounded-xl bg-slate-950 border border-slate-800">
            <button
              type="button"
              onClick={() => setRole('CUSTOMER')}
              className={`py-2.5 px-4 rounded-lg text-sm font-semibold flex items-center justify-center gap-2 transition-all ${
                role === 'CUSTOMER'
                  ? 'bg-sky-600 text-white shadow-md'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <Car className="w-4 h-4" />
              <span>Vehicle Owner</span>
            </button>

            <button
              type="button"
              onClick={() => setRole('MECHANIC')}
              className={`py-2.5 px-4 rounded-lg text-sm font-semibold flex items-center justify-center gap-2 transition-all ${
                role === 'MECHANIC'
                  ? 'bg-amber-600 text-white shadow-md'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <Wrench className="w-4 h-4" />
              <span>Field Mechanic</span>
            </button>
          </div>

          {error && (
            <div className="mb-6 p-3.5 rounded-xl bg-rose-950/50 border border-rose-800/80 text-rose-300 text-sm flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 shrink-0 mt-0.5 text-rose-400" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-slate-300 uppercase tracking-wider mb-1.5 font-mono">
                Full Legal Name
              </label>
              <div className="relative">
                <User className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="e.g. Marcus Sterling"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950/80 border border-slate-800 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-sky-500/50 focus:border-sky-500 transition-all"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-slate-300 uppercase tracking-wider mb-1.5 font-mono">
                  Email Address
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="name@domain.com"
                    className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950/80 border border-slate-800 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-sky-500/50 focus:border-sky-500 transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-300 uppercase tracking-wider mb-1.5 font-mono">
                  Phone Number
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+1-555-0100"
                    className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950/80 border border-slate-800 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-sky-500/50 focus:border-sky-500 transition-all"
                  />
                </div>
              </div>
            </div>

            {/* Mechanic Specific Inputs */}
            {role === 'MECHANIC' && (
              <div className="p-4 rounded-xl bg-slate-950/70 border border-amber-900/40 space-y-3">
                <div className="text-xs font-mono text-amber-400 font-semibold uppercase tracking-wider flex items-center gap-1.5">
                  <Wrench className="w-3.5 h-3.5" />
                  <span>Mechanic Trade Credentials</span>
                </div>

                <div>
                  <label className="block text-xs text-slate-400 mb-1">Workshop or Business Name</label>
                  <div className="relative">
                    <Briefcase className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={workshopName}
                      onChange={(e) => setWorkshopName(e.target.value)}
                      placeholder="e.g. Apex Mobile Roadside"
                      className="w-full pl-10 pr-4 py-2 rounded-lg bg-slate-900 border border-slate-800 text-white text-xs focus:outline-none focus:border-amber-500"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs text-slate-400 mb-1">Trade License / Cert #</label>
                    <div className="relative">
                      <FileText className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        value={tradeLicenseNumber}
                        onChange={(e) => setTradeLicenseNumber(e.target.value)}
                        placeholder="ASE-MASTER-99"
                        className="w-full pl-10 pr-4 py-2 rounded-lg bg-slate-900 border border-slate-800 text-white text-xs focus:outline-none focus:border-amber-500"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs text-slate-400 mb-1">Years of Experience</label>
                    <input
                      type="number"
                      min={0}
                      max={50}
                      value={experienceYears}
                      onChange={(e) => setExperienceYears(Number(e.target.value))}
                      className="w-full px-3 py-2 rounded-lg bg-slate-900 border border-slate-800 text-white text-xs focus:outline-none focus:border-amber-500"
                    />
                  </div>
                </div>
              </div>
            )}

            <div>
              <label className="block text-xs font-medium text-slate-300 uppercase tracking-wider mb-1.5 font-mono">
                Password
              </label>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950/80 border border-slate-800 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-sky-500/50 focus:border-sky-500 transition-all"
                />
              </div>

              {/* Password Requirements Meter */}
              <div className="mt-2 grid grid-cols-2 gap-1.5 text-[11px] text-slate-400 font-mono">
                <div className={`flex items-center gap-1 ${hasMinLength ? 'text-emerald-400' : ''}`}>
                  <CheckCircle2 className="w-3 h-3" /> 8+ Characters
                </div>
                <div className={`flex items-center gap-1 ${hasUppercase ? 'text-emerald-400' : ''}`}>
                  <CheckCircle2 className="w-3 h-3" /> 1 Uppercase Letter
                </div>
                <div className={`flex items-center gap-1 ${hasLowercase ? 'text-emerald-400' : ''}`}>
                  <CheckCircle2 className="w-3 h-3" /> 1 Lowercase Letter
                </div>
                <div className={`flex items-center gap-1 ${hasNumberOrSymbol ? 'text-emerald-400' : ''}`}>
                  <CheckCircle2 className="w-3 h-3" /> 1 Number or Symbol
                </div>
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting || !isPasswordValid}
              className={`w-full mt-4 py-3 px-4 rounded-xl font-semibold text-sm shadow-md transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed group ${
                role === 'MECHANIC'
                  ? 'bg-amber-600 hover:bg-amber-500 text-white'
                  : 'bg-sky-600 hover:bg-sky-500 text-white'
              }`}
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span>Creating Account...</span>
                </>
              ) : (
                <>
                  <span>Complete Registration</span>
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>
        </div>

        <p className="text-center text-sm text-slate-400 mt-6">
          Already registered?{' '}
          <Link href="/login" className="text-sky-400 hover:text-sky-300 font-medium">
            Sign In Here
          </Link>
        </p>
      </div>
    </div>
  );
}

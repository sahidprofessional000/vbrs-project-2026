'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { 
  ArrowRight, 
  AlertCircle, 
  Loader2,
  Car,
  Wrench,
  Check
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

  const hasMinLength = password.length >= 8;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumberOrSymbol = /[\d\W]/.test(password);
  const isPasswordValid = hasMinLength && hasUppercase && hasLowercase && hasNumberOrSymbol;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!isPasswordValid) {
      setError('Password must meet complexity rules: 8+ chars, uppercase, lowercase, number/symbol.');
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
        payload.workshopName = workshopName || `${fullName}'s Field Service`;
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
      setError(err.message || 'Registration failed. Please check input requirements.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col justify-center items-center px-6 py-16 selection:bg-porcelain selection:text-carbon">
      <div className="w-full max-w-lg">
        
        {/* Brand Header */}
        <div className="mb-8 text-center space-y-3">
          <Link href="/" className="inline-flex items-center gap-2.5 group">
            <div className="w-7 h-7 rounded-sm bg-graphite border border-divider flex items-center justify-center text-porcelain font-mono font-medium text-xs">
              VB
            </div>
            <span className="font-medium tracking-tight text-sm text-porcelain">VBRS</span>
          </Link>

          <h1 className="text-2xl font-medium tracking-tight text-porcelain">
            Register Network Access
          </h1>
          <p className="text-xs text-stone-muted font-normal">
            Select your operational role to begin account setup
          </p>
        </div>

        {/* Minimalist Architectural Container */}
        <div className="border border-divider bg-graphite p-8 shadow-architectural">
          
          {/* Role Segmented Controller */}
          <div className="grid grid-cols-2 gap-px bg-divider border border-divider mb-6">
            <button
              type="button"
              onClick={() => setRole('CUSTOMER')}
              className={`py-2.5 px-4 text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 ${
                role === 'CUSTOMER'
                  ? 'bg-porcelain text-carbon font-semibold'
                  : 'bg-graphite text-stone-muted hover:text-porcelain'
              }`}
            >
              <Car className="w-3.5 h-3.5" />
              <span>Vehicle Owner</span>
            </button>

            <button
              type="button"
              onClick={() => setRole('MECHANIC')}
              className={`py-2.5 px-4 text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 ${
                role === 'MECHANIC'
                  ? 'bg-porcelain text-carbon font-semibold'
                  : 'bg-graphite text-stone-muted hover:text-porcelain'
              }`}
            >
              <Wrench className="w-3.5 h-3.5" />
              <span>Field Mechanic</span>
            </button>
          </div>

          {error && (
            <div className="mb-6 p-3.5 border border-crimson/50 bg-crimson-subtle text-porcelain text-xs flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 text-crimson shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1.5">
                Full Legal Name *
              </label>
              <input
                type="text"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="Marcus Vance"
                className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-sans focus:outline-none focus:border-stone-muted transition-colors rounded-none"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1.5">
                  Email Address *
                </label>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@domain.com"
                  className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-none"
                />
              </div>

              <div>
                <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1.5">
                  Phone Number
                </label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+1-555-0100"
                  className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-none"
                />
              </div>
            </div>

            {/* Mechanic Credentials Intake */}
            {role === 'MECHANIC' && (
              <div className="p-4 border border-divider bg-carbon space-y-3 pt-4">
                <span className="text-[10px] font-mono uppercase tracking-widest text-stone-dim block">
                  Field Certification Details
                </span>

                <div>
                  <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1">
                    Workshop or Business Title
                  </label>
                  <input
                    type="text"
                    value={workshopName}
                    onChange={(e) => setWorkshopName(e.target.value)}
                    placeholder="e.g. Apex Mobile Roadside"
                    className="w-full px-3 py-2 bg-graphite border border-divider text-porcelain text-xs focus:outline-none focus:border-stone-muted rounded-none"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1">
                      License / Cert #
                    </label>
                    <input
                      type="text"
                      value={tradeLicenseNumber}
                      onChange={(e) => setTradeLicenseNumber(e.target.value)}
                      placeholder="ASE-MASTER-99"
                      className="w-full px-3 py-2 bg-graphite border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1">
                      Experience (Years)
                    </label>
                    <input
                      type="number"
                      min={0}
                      max={50}
                      value={experienceYears}
                      onChange={(e) => setExperienceYears(Number(e.target.value))}
                      className="w-full px-3 py-2 bg-graphite border border-divider text-porcelain text-xs font-mono focus:outline-none focus:border-stone-muted rounded-none"
                    />
                  </div>
                </div>
              </div>
            )}

            <div>
              <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-1.5">
                Password *
              </label>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-none"
              />

              <div className="mt-2 grid grid-cols-2 gap-2 text-[10px] font-mono text-stone-dim">
                <span className={hasMinLength ? 'text-porcelain flex items-center gap-1' : 'flex items-center gap-1'}>
                  {hasMinLength && <Check className="w-3 h-3 text-sage-light" />} 8+ Characters
                </span>
                <span className={hasUppercase ? 'text-porcelain flex items-center gap-1' : 'flex items-center gap-1'}>
                  {hasUppercase && <Check className="w-3 h-3 text-sage-light" />} 1 Uppercase
                </span>
                <span className={hasLowercase ? 'text-porcelain flex items-center gap-1' : 'flex items-center gap-1'}>
                  {hasLowercase && <Check className="w-3 h-3 text-sage-light" />} 1 Lowercase
                </span>
                <span className={hasNumberOrSymbol ? 'text-porcelain flex items-center gap-1' : 'flex items-center gap-1'}>
                  {hasNumberOrSymbol && <Check className="w-3 h-3 text-sage-light" />} 1 Number / Symbol
                </span>
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting || !isPasswordValid}
              className="w-full mt-4 py-3 px-4 bg-porcelain hover:bg-porcelain-dim text-carbon font-medium text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  <span>Enrolling Account...</span>
                </>
              ) : (
                <>
                  <span>Create Registered Profile</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </>
              )}
            </button>
          </form>
        </div>

        <p className="text-center text-xs text-stone-muted mt-6">
          Already registered?{' '}
          <Link href="/login" className="text-porcelain underline hover:text-porcelain-dim underline-offset-4">
            Sign In Here
          </Link>
        </p>
      </div>
    </div>
  );
}

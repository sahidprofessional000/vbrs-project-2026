'use client';

import React, { useState, Suspense } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { 
  ArrowRight, 
  AlertCircle, 
  Loader2, 
  Car, 
  Wrench, 
  ShieldCheck 
} from 'lucide-react';

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login } = useAuth();

  const redirectParam = searchParams.get('redirect');
  const roleParam = searchParams.get('role');

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsSubmitting(true);

    try {
      const user = await login(email, password);

      // Secure role-based redirection
      if (user.role === 'ADMIN') {
        const target = redirectParam && redirectParam.startsWith('/admin')
          ? redirectParam
          : '/admin/dashboard';
        router.push(target);
      } else if (user.role === 'MECHANIC') {
        // Enforce that a mechanic never gets redirected to customer pages
        const isCustomerTarget = redirectParam && (
          redirectParam.startsWith('/customer') || 
          redirectParam.startsWith('/report-breakdown')
        );
        const target = redirectParam && !isCustomerTarget
          ? redirectParam
          : '/mechanic/home';
        router.push(target);
      } else {
        // CUSTOMER: Enforce that customer never gets redirected to mechanic or admin pages
        const isRestrictedTarget = redirectParam && (
          redirectParam.startsWith('/mechanic') || 
          redirectParam.startsWith('/admin')
        );
        const target = redirectParam && !isRestrictedTarget
          ? redirectParam
          : '/customer/home';
        router.push(target);
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please verify credentials.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleQuickFill = (demoEmail: string) => {
    setEmail(demoEmail);
    setPassword('Password@123');
    setError(null);
  };

  return (
    <div className="min-h-screen bg-carbon text-porcelain flex flex-col justify-center items-center px-6 py-16 selection:bg-porcelain selection:text-carbon">
      <div className="w-full max-w-md">
        
        {/* Brand Header */}
        <div className="mb-10 text-center space-y-3">
          <Link href="/" className="inline-flex items-center gap-2.5 group">
            <div className="w-7 h-7 rounded-sm bg-graphite border border-divider flex items-center justify-center text-porcelain font-mono font-medium text-xs">
              VB
            </div>
            <span className="font-medium tracking-tight text-sm text-porcelain">VBRS</span>
          </Link>

          <h1 className="text-2xl font-medium tracking-tight text-porcelain">
            Sign In to Protocol
          </h1>
          <p className="text-xs text-stone-muted font-normal">
            {roleParam === 'MECHANIC'
              ? 'Authorized Field Technician & Workshop Console'
              : roleParam === 'CUSTOMER'
              ? 'Registered Motorist Emergency Dispatch System'
              : 'Enter your credentials to access vehicle assistance services'}
          </p>
        </div>

        {/* Minimalist Architectural Container */}
        <div className="border border-divider bg-graphite p-8 shadow-architectural">
          {error && (
            <div className="mb-6 p-3.5 border border-crimson/50 bg-crimson-subtle text-porcelain text-xs flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 text-crimson shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-[11px] font-mono uppercase tracking-wider text-stone-muted mb-2">
                Email Address
              </label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="operator@domain.com"
                className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-none"
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-[11px] font-mono uppercase tracking-wider text-stone-muted">
                  Password
                </label>
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-[11px] font-mono text-stone-dim hover:text-stone-muted transition-colors"
                >
                  {showPassword ? 'Hide' : 'Show'}
                </button>
              </div>
              <input
                type={showPassword ? 'text' : 'password'}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full px-3.5 py-2.5 bg-carbon border border-divider text-porcelain placeholder-stone-dim text-xs font-mono focus:outline-none focus:border-stone-muted transition-colors rounded-none"
              />
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full mt-2 py-3 px-4 bg-porcelain hover:bg-porcelain-dim text-carbon font-medium text-xs font-mono uppercase tracking-wider transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {isSubmitting ? (
                <>
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  <span>Verifying Session...</span>
                </>
              ) : (
                <>
                  <span>Authenticate Session</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </>
              )}
            </button>
          </form>

          {/* Seeded Quick-fill Options */}
          <div className="mt-8 pt-6 border-t border-divider/60">
            <span className="block text-[10px] font-mono uppercase tracking-widest text-stone-dim mb-3 text-center">
              Pre-configured Seed Accounts
            </span>
            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => handleQuickFill('customer.john@vbrs.local')}
                className={`p-2 border transition-colors flex flex-col items-center gap-1.5 text-[10px] font-mono uppercase tracking-wider ${
                  roleParam === 'CUSTOMER'
                    ? 'border-crimson bg-crimson/10 text-porcelain'
                    : 'border-divider hover:border-divider-strong bg-carbon text-stone-muted hover:text-porcelain'
                }`}
              >
                <Car className="w-3.5 h-3.5 text-stone-dim" />
                <span>Driver</span>
              </button>
              <button
                type="button"
                onClick={() => handleQuickFill('mechanic.alex@vbrs.local')}
                className={`p-2 border transition-colors flex flex-col items-center gap-1.5 text-[10px] font-mono uppercase tracking-wider ${
                  roleParam === 'MECHANIC'
                    ? 'border-cyan-500 bg-cyan-950/30 text-porcelain'
                    : 'border-divider hover:border-divider-strong bg-carbon text-stone-muted hover:text-porcelain'
                }`}
              >
                <Wrench className="w-3.5 h-3.5 text-stone-dim" />
                <span>Technician</span>
              </button>
              <button
                type="button"
                onClick={() => handleQuickFill('admin@vbrs.local')}
                className="p-2 border border-divider hover:border-divider-strong bg-carbon text-stone-muted hover:text-porcelain text-[10px] font-mono uppercase tracking-wider transition-colors flex flex-col items-center gap-1.5"
              >
                <ShieldCheck className="w-3.5 h-3.5 text-stone-dim" />
                <span>Admin</span>
              </button>
            </div>
          </div>
        </div>

        {/* Footer Link */}
        <p className="text-center text-xs text-stone-muted mt-6">
          New to the network?{' '}
          <Link href="/register" className="text-porcelain underline hover:text-porcelain-dim underline-offset-4">
            Register Account
          </Link>
        </p>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-carbon flex flex-col items-center justify-center text-stone-muted">
        <Loader2 className="w-7 h-7 animate-spin text-porcelain mb-3" />
        <span className="text-xs font-mono uppercase tracking-widest">
          Loading Authentication Gateway...
        </span>
      </div>
    }>
      <LoginForm />
    </Suspense>
  );
}

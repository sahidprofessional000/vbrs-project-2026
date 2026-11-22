'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { 
  Car, 
  Wrench, 
  LayoutDashboard, 
  LogOut, 
  ArrowUpRight,
  Shield
} from 'lucide-react';

export function Navbar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();

  const getPortalLink = () => {
    if (!user) return '/';
    if (user.role === 'ADMIN') return '/admin/dashboard';
    if (user.role === 'MECHANIC') return '/mechanic/portal';
    return '/customer/vehicles';
  };

  return (
    <header className="w-full border-b border-divider/60 bg-carbon/90 backdrop-blur-md sticky top-0 z-40">
      <div className="layout-container h-18 flex items-center justify-between">
        {/* Brand Lockup: Leica / Bang & Olufsen typography */}
        <div className="flex items-center gap-10">
          <Link href={getPortalLink()} className="flex items-center gap-3.5 group">
            <div className="w-8 h-8 rounded-sm bg-graphite border border-divider flex items-center justify-center text-porcelain font-mono font-medium text-xs tracking-wider group-hover:border-divider-strong transition-colors">
              VB
            </div>
            <div>
              <span className="font-medium tracking-tight text-sm text-porcelain block">VBRS</span>
              <span className="text-[10px] text-stone-dim block font-mono tracking-widest uppercase">
                Automotive Assistance
              </span>
            </div>
          </Link>

          {/* Editorial Navigation Links */}
          <nav className="hidden md:flex items-center gap-8 text-xs font-mono tracking-wider uppercase">
            <Link
              href="/"
              className={`transition-colors py-1 ${
                pathname === '/'
                  ? 'text-porcelain border-b border-porcelain'
                  : 'text-stone-muted hover:text-porcelain'
              }`}
            >
              Overview
            </Link>

            {user?.role === 'CUSTOMER' && (
              <>
                <Link
                  href="/customer/vehicles"
                  className={`transition-colors py-1 ${
                    pathname === '/customer/vehicles'
                      ? 'text-porcelain border-b border-porcelain'
                      : 'text-stone-muted hover:text-porcelain'
                  }`}
                >
                  My Garage
                </Link>

                <Link
                  href="/report-breakdown"
                  className="text-crimson hover:text-crimson-hover transition-colors py-1 flex items-center gap-1"
                >
                  <span>Request Rescue</span>
                </Link>
              </>
            )}

            {user?.role === 'MECHANIC' && (
              <Link
                href="/mechanic/portal"
                className={`transition-colors py-1 ${
                  pathname === '/mechanic/portal'
                    ? 'text-porcelain border-b border-porcelain'
                    : 'text-stone-muted hover:text-porcelain'
                }`}
              >
                Dispatch Terminal
              </Link>
            )}

            {user?.role === 'ADMIN' && (
              <Link
                href="/admin/dashboard"
                className={`transition-colors py-1 ${
                  pathname === '/admin/dashboard'
                    ? 'text-porcelain border-b border-porcelain'
                    : 'text-stone-muted hover:text-porcelain'
                }`}
              >
                Control Desk
              </Link>
            )}

            <a
              href="http://localhost:4000/api/docs"
              target="_blank"
              rel="noreferrer"
              className="text-stone-muted hover:text-porcelain transition-colors flex items-center gap-1"
            >
              <span>API Reference</span>
              <ArrowUpRight className="w-3 h-3 text-stone-dim" />
            </a>
          </nav>
        </div>

        {/* User Session & Actions */}
        <div className="flex items-center gap-5">
          {user ? (
            <div className="flex items-center gap-4">
              <div className="text-right hidden sm:block">
                <div className="text-xs font-medium text-porcelain tracking-tight">{user.fullName}</div>
                <div className="text-[10px] font-mono text-stone-muted uppercase tracking-wider">
                  {user.role}
                </div>
              </div>

              <div className="w-7 h-7 rounded-sm bg-elevated border border-divider text-porcelain flex items-center justify-center font-mono text-xs">
                {user.fullName.slice(0, 1).toUpperCase()}
              </div>

              <div className="w-[1px] h-4 bg-divider" />

              <button
                onClick={() => logout()}
                title="Sign Out"
                className="text-xs font-mono text-stone-muted hover:text-crimson transition-colors uppercase tracking-wider flex items-center gap-1.5"
              >
                <LogOut className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Sign Out</span>
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-5 text-xs font-mono tracking-wider uppercase">
              <Link
                href="/login"
                className="text-stone-muted hover:text-porcelain transition-colors py-1"
              >
                Sign In
              </Link>
              <Link
                href="/register"
                className="px-4 py-2 rounded-sm bg-porcelain text-carbon font-medium hover:bg-porcelain-dim transition-colors"
              >
                Register
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

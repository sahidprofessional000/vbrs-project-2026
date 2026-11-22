'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { 
  ShieldAlert, 
  Car, 
  Wrench, 
  LayoutDashboard, 
  LogOut, 
  User as UserIcon,
  ChevronDown
} from 'lucide-react';

export function Navbar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();

  const getPortalLink = () => {
    if (!user) return '/';
    if (user.role === 'ADMIN') return '/admin/dashboard';
    if (user.role === 'MECHANIC') return '/mechanic/portal';
    return '/customer/dashboard';
  };

  return (
    <header className="border-b border-slate-800 bg-slate-950/90 backdrop-blur-md sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        {/* Brand */}
        <div className="flex items-center gap-6">
          <Link href={getPortalLink()} className="flex items-center gap-3 group">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-rose-600 to-amber-600 flex items-center justify-center shadow-md shadow-rose-950/40 group-hover:scale-105 transition-transform">
              <ShieldAlert className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-bold tracking-tight text-white">VBRS</span>
              <span className="text-[10px] text-slate-400 block -mt-1 font-mono tracking-wider">RESCUE RADAR</span>
            </div>
          </Link>

          {/* Nav Links */}
          {user && (
            <nav className="hidden md:flex items-center gap-1 text-sm font-medium">
              {user.role === 'CUSTOMER' && (
                <>
                  <Link
                    href="/customer/vehicles"
                    className={`px-3 py-1.5 rounded-lg transition-colors flex items-center gap-1.5 ${
                      pathname === '/customer/vehicles'
                        ? 'bg-slate-850 text-white'
                        : 'text-slate-400 hover:text-white hover:bg-slate-900'
                    }`}
                  >
                    <Car className="w-4 h-4 text-sky-400" />
                    <span>My Garage</span>
                  </Link>

                  <Link
                    href="/report-breakdown"
                    className="px-3 py-1.5 rounded-lg text-rose-400 hover:text-rose-300 hover:bg-rose-950/30 transition-colors flex items-center gap-1.5 font-semibold"
                  >
                    <ShieldAlert className="w-4 h-4" />
                    <span>Report Breakdown</span>
                  </Link>
                </>
              )}

              {user.role === 'MECHANIC' && (
                <Link
                  href="/mechanic/portal"
                  className="px-3 py-1.5 rounded-lg text-amber-400 hover:bg-amber-950/30 transition-colors flex items-center gap-1.5 font-medium"
                >
                  <Wrench className="w-4 h-4" />
                  <span>Dispatch Terminal</span>
                </Link>
              )}

              {user.role === 'ADMIN' && (
                <Link
                  href="/admin/dashboard"
                  className="px-3 py-1.5 rounded-lg text-indigo-400 hover:bg-indigo-950/30 transition-colors flex items-center gap-1.5 font-medium"
                >
                  <LayoutDashboard className="w-4 h-4" />
                  <span>Command Center</span>
                </Link>
              )}
            </nav>
          )}
        </div>

        {/* User Account & Actions */}
        <div className="flex items-center gap-4">
          {user ? (
            <div className="flex items-center gap-3">
              <div className="text-right hidden sm:block">
                <div className="text-sm font-semibold text-white leading-tight">{user.fullName}</div>
                <div className="text-xs font-mono text-slate-400 flex items-center gap-1.5 justify-end">
                  <span
                    className={`inline-block w-1.5 h-1.5 rounded-full ${
                      user.role === 'ADMIN'
                        ? 'bg-indigo-400'
                        : user.role === 'MECHANIC'
                        ? 'bg-amber-400'
                        : 'bg-sky-400'
                    }`}
                  />
                  <span>{user.role}</span>
                </div>
              </div>

              {user.avatarUrl ? (
                <img
                  src={user.avatarUrl}
                  alt={user.fullName}
                  className="w-9 h-9 rounded-full object-cover ring-2 ring-slate-800"
                />
              ) : (
                <div className="w-9 h-9 rounded-full bg-slate-800 text-slate-300 flex items-center justify-center font-bold text-xs ring-2 ring-slate-700">
                  {user.fullName.slice(0, 2).toUpperCase()}
                </div>
              )}

              <button
                onClick={() => logout()}
                title="Sign Out"
                className="p-2 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-900 border border-transparent hover:border-slate-800 transition-colors"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <Link
                href="/login"
                className="text-sm font-medium text-slate-300 hover:text-white px-3 py-2 rounded-lg hover:bg-slate-900 transition-colors"
              >
                Sign In
              </Link>
              <Link
                href="/register"
                className="text-sm font-medium bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-lg shadow-sm transition-all"
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

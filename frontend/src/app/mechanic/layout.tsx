'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Loader2 } from 'lucide-react';

export default function MechanicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading) {
      if (!user) {
        router.push('/login?role=MECHANIC&redirect=/mechanic/home');
      } else if (user.role === 'CUSTOMER') {
        router.push('/customer/home');
      } else if (user.role === 'ADMIN') {
        router.push('/admin/dashboard');
      }
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-carbon flex flex-col items-center justify-center text-stone-muted">
        <Loader2 className="w-7 h-7 animate-spin text-porcelain mb-3" />
        <span className="text-xs font-mono uppercase tracking-widest">
          Authenticating Mechanic Station...
        </span>
      </div>
    );
  }

  if (!user || user.role !== 'MECHANIC') {
    return null;
  }

  return <>{children}</>;
}

'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Loader2 } from 'lucide-react';

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading) {
      if (!user) {
        router.push('/login?role=ADMIN&redirect=/admin/dashboard');
      } else if (user.role === 'CUSTOMER') {
        router.push('/customer/home');
      } else if (user.role === 'MECHANIC') {
        router.push('/mechanic/home');
      }
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-carbon flex flex-col items-center justify-center text-stone-muted">
        <Loader2 className="w-7 h-7 animate-spin text-porcelain mb-3" />
        <span className="text-xs font-mono uppercase tracking-widest">
          Verifying Supervisory Clearance...
        </span>
      </div>
    );
  }

  if (!user || user.role !== 'ADMIN') {
    return null;
  }

  return <>{children}</>;
}

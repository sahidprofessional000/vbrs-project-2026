'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/auth-context';
import { Navbar } from '@/components/shared/navbar';
import { Loader2 } from 'lucide-react';

export default function CustomerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-carbon flex flex-col items-center justify-center text-stone-muted">
        <Loader2 className="w-7 h-7 animate-spin text-porcelain mb-3" />
        <span className="text-xs font-mono uppercase tracking-widest">Restoring Secure Session...</span>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen flex flex-col bg-carbon text-porcelain selection:bg-porcelain selection:text-carbon">
      <Navbar />
      <main className="flex-1 layout-container py-10">
        {children}
      </main>
    </div>
  );
}

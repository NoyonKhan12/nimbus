'use client';

import { ReactNode, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Layout from '@/components/Layout';
import { checkAuth } from '@/services/auth';

/**
 * Layout for all dashboard routes.
 * Redirects to login if not authenticated.
 */
export default function DashboardLayout({ children }: { children: ReactNode }) {
  const router = useRouter();

  useEffect(() => {
    if (!checkAuth()) {
      router.replace('/login');
    }
  }, [router]);

  // Show a loading state while checking auth.
  if (!checkAuth()) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-100">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return <Layout>{children}</Layout>;
}

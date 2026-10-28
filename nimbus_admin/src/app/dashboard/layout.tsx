'use client';

import { ReactNode, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Layout from '@/components/Layout';
import { checkAuth } from '@/services/auth';

/**
 * Layout for all dashboard routes.
 * Redirects to login if not authenticated.
 *
 * Hydration-safe: the auth cookie is only readable on the client, so the
 * auth decision MUST NOT run during render (server would render the loading
 * shell while an already-authenticated client would render <Layout>, causing
 * "Expected server HTML to contain a matching <aside>" hydration errors).
 * Instead both server and the first client render output the identical
 * loading shell, and the switch happens after hydration in useEffect.
 */
export default function DashboardLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  // SSR + first client render: identical loading shell.
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!checkAuth()) {
      router.replace('/login');
    } else {
      setReady(true);
    }
  }, [router]);

  if (!ready) {
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

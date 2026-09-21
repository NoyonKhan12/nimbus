import { useTransition, useState } from 'react';
import { login as loginService, logout as logoutService, checkAuth } from '@/services/auth';
import { AdminLoginRequest, AdminAuthTokens } from '@/types';
import { useRouter } from 'next/navigation';

/**
 * Hook for authentication operations.
 * Provides login, logout, and authentication status.
 */
export const useAuth = () => {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [loginLoading, setLoginLoading] = useState(false);

  const login = async (data: AdminLoginRequest): Promise<AdminAuthTokens> => {
    setLoginLoading(true);
    try {
      const tokens = await loginService(data);
      router.push('/dashboard');
      return tokens;
    } finally {
      setLoginLoading(false);
    }
  };

  const logout = async (): Promise<void> => {
    startTransition(() => {
      logoutService().then(() => {
        router.push('/login');
      });
    });
  };

  const isAuthenticated = (): boolean => {
    return checkAuth();
  };

  return {
    login,
    logout,
    isAuthenticated,
    isLoading: isPending || loginLoading,
  };
};
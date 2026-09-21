'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { FiLogIn, FiMail, FiLock, FiAlertCircle, FiShield } from 'react-icons/fi';
import { useAuth } from '@/hooks/useAuth';
import { AdminLoginRequest } from '@/types';
import { getStoredEmail, checkAuth } from '@/services/auth';

/**
 * Login page for admin authentication.
 * Provides a form for email/password login with validation.
 * Redirects to dashboard if already authenticated.
 */
export default function LoginPage() {
  const router = useRouter();
  const { login, isLoading } = useAuth();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [authChecking, setAuthChecking] = useState(true);

  useEffect(() => {
    // If already authenticated, redirect to dashboard
    if (checkAuth()) {
      router.replace('/dashboard');
    } else {
      setAuthChecking(false);
    }
  }, [router]);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<AdminLoginRequest>({
    defaultValues: {
      email: getStoredEmail() ?? '',
      password: '',
    },
  });

  const onSubmit = async (data: AdminLoginRequest) => {
    setErrorMessage(null);
    try {
      await login(data);
      router.push('/dashboard');
    } catch (error: any) {
      setErrorMessage(error.message || 'Login failed');
    }
  };

  // Show loading state while checking auth
  if (authChecking) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Checking session...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100 p-4">
      <div className="max-w-md w-full bg-white rounded-xl shadow-lg p-8">
        <div className="text-center mb-6">
          <div className="flex items-center justify-center gap-2 mb-2">
            <FiShield className="text-indigo-600 text-3xl" />
            <h1 className="text-3xl font-bold text-indigo-700">Nimbus Admin</h1>
          </div>
          <p className="text-sm text-gray-500 mt-1">
            Sign in to access the admin panel
          </p>
        </div>

        {errorMessage && (
          <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg text-sm flex items-center gap-2">
            <FiAlertCircle className="text-rose-600" />
            {errorMessage}
          </div>
        )}

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1 flex items-center gap-2">
              <FiMail className="text-gray-400" />
              Email
            </label>
            <input
              type="email"
              {...register('email', {
                required: 'Email is required',
                pattern: {
                  value: /\S+@\S+\.\S+/,
                  message: 'Invalid email address',
                },
              })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              placeholder="admin@nimbus.com"
              disabled={isLoading}
            />
            {errors.email && (
              <p className="mt-1 text-sm text-rose-600 flex items-center gap-1">
                <FiAlertCircle className="text-xs" />
                {errors.email.message}
              </p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1 flex items-center gap-2">
              <FiLock className="text-gray-400" />
              Password
            </label>
            <input
              type="password"
              {...register('password', { required: 'Password is required' })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              placeholder="Enter password"
              disabled={isLoading}
            />
            {errors.password && (
              <p className="mt-1 text-sm text-rose-600 flex items-center gap-1">
                <FiAlertCircle className="text-xs" />
                {errors.password.message}
              </p>
            )}
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 bg-indigo-600 text-white rounded-lg font-medium hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Signing in...
              </>
            ) : (
              <>
                <FiLogIn className="text-sm" />
                Sign In
              </>
            )}
          </button>
        </form>

        {/* Credentials hint */}
        <div className="mt-6 p-3 bg-gray-50 rounded-lg">
          <p className="text-xs text-gray-500 text-center">
            Credentials: admin@nimbus.com / admin123
          </p>
        </div>
      </div>
    </div>
  );
}
import api, { setTokens, clearTokens, isAuthenticated } from './api';
import { AdminLoginRequest, AdminAuthTokens } from '@/types';

/**
 * Authenticate an admin user with email and password.
 * Stores JWT tokens in cookies on success.
 */
export const login = async (
  data: AdminLoginRequest,
): Promise<AdminAuthTokens> => {
  try {
    const response = await api.post('/admin/auth/login', data);

    const tokens: AdminAuthTokens =
      response.data.data || response.data;

    setTokens(tokens);
    localStorage.setItem('admin_email', data.email);

    return tokens;
  } catch (error: any) {
    throw new Error(
      error.response?.data?.error?.message ||
          error.message ||
          'Login failed',
    );
  }
};

/**
 * Log out the admin by clearing tokens and calling the API.
 */
export const logout = async (): Promise<void> => {
  try {
    await api.post('/auth/logout');
  } catch (e) {
    // Best-effort — proceed to clear tokens even if API fails.
  }
  clearTokens();
  localStorage.removeItem('admin_email');
};

/**
 * Check if an admin is currently authenticated.
 */
export const checkAuth = (): boolean => {
  return isAuthenticated();
};

/**
 * Get the stored admin email (if any) for pre-filling the login form.
 */
export const getStoredEmail = (): string | null => {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('admin_email');
  }
  return null;
};

import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import Cookies from 'js-cookie';
import { API_BASE_URL, API_TIMEOUT, STORAGE_KEYS, ERROR_CODES } from '@/lib/constants';
import { AdminAuthTokens, RefreshTokenResponse } from '@/types';

/**
 * Axios API client with JWT interceptor for automatic token refresh.
 */
const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

/**
 * Request interceptor — injects access token from cookies.
 */
api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const token = getAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => Promise.reject(error),
);

/**
 * Response interceptor — handles 401 Unauthorized (refresh + retry).
 */
api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const newTokens = await refreshTokens();
        if (newTokens) {
          setTokens(newTokens);
          originalRequest.headers.Authorization = `Bearer ${newTokens.accessToken}`;
          return api(originalRequest);
        }
      } catch (refreshError) {
        clearTokens();
        // Redirect to login.
        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  },
);

// ────────────────────────────────────────────────
// Token Management
// ────────────────────────────────────────────────

export const getAccessToken = (): string | undefined => {
  if (typeof window !== 'undefined') {
    return Cookies.get(STORAGE_KEYS.ACCESS_TOKEN);
  }
  return undefined;
};

export const getRefreshToken = (): string | undefined => {
  if (typeof window !== 'undefined') {
    return Cookies.get(STORAGE_KEYS.REFRESH_TOKEN);
  }
  return undefined;
};

export const setTokens = (tokens: {
  accessToken: string;
  refreshToken: string;
  expiresIn?: number;
}): void => {
  // Access token cookie expires based on the token's actual expiration
  // Admin tokens are 24h (86400s), so cookie lasts 1 day
  const accessTokenExpiry = tokens.expiresIn
    ? tokens.expiresIn / 86400  // Convert seconds to days
    : 1;  // Default 1 day for admin tokens

  Cookies.set(STORAGE_KEYS.ACCESS_TOKEN, tokens.accessToken, {
    expires: accessTokenExpiry,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
  });
  Cookies.set(STORAGE_KEYS.REFRESH_TOKEN, tokens.refreshToken, {
    expires: 30, // 30 days
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
  });
};

export const clearTokens = (): void => {
  Object.values(STORAGE_KEYS).forEach((key) => Cookies.remove(key));
};

/**
 * Refresh the access token using the stored refresh token.
 */
const refreshTokens = async (): Promise<AdminAuthTokens | null> => {
  try {
    const refreshToken = getRefreshToken();
    if (!refreshToken) return null;

    const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
      refreshToken,
    });

    const data: RefreshTokenResponse =
      response.data.data ?? response.data;
    return {
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      tokenType: data.tokenType,
      expiresIn: data.expiresIn,
    };
  } catch (error) {
    console.error('Token refresh failed:', error);
    return null;
  }
};

/**
 * Check if an access token is present and valid.
 */
export const isAuthenticated = (): boolean => {
  const token = getAccessToken();
  if (!token) return false;

  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    const expiry = payload.exp;
    if (expiry && Date.now() / 1000 > expiry - 60) {
      return false;
    }
    return true;
  } catch {
    return false;
  }
};

export default api;

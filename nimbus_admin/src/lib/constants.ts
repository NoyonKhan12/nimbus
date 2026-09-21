// ────────────────────────────────────────────────
// API Configuration
// ────────────────────────────────────────────────

export const API_BASE_URL =
  process.env.API_BASE_URL || 'http://localhost:9090/api/v1';

export const API_TIMEOUT = 30000;

// ────────────────────────────────────────────────
// Storage Keys
// ────────────────────────────────────────────────

export const STORAGE_KEYS = {
  ACCESS_TOKEN: 'admin_access_token',
  REFRESH_TOKEN: 'admin_refresh_token',
  SESSION_ID: 'admin_session_id',
  USER_ID: 'admin_user_id',
  EMAIL: 'admin_email',
} as const;

// ────────────────────────────────────────────────
// Routes
// ────────────────────────────────────────────────

export const ROUTES = {
  LOGIN: '/login',
  DASHBOARD: '/dashboard',
  USERS: '/dashboard/users',
  DRIVERS: '/dashboard/drivers',
  RIDES: '/dashboard/rides',
  PAYMENTS: '/dashboard/payments',
  SETTLEMENTS: '/dashboard/settlements',
} as const;

// ────────────────────────────────────────────────
// Error Codes (mirrors backend ErrorCode enum)
// ────────────────────────────────────────────────

export const ERROR_CODES = {
  UNAUTHORIZED: 'AUTH_001',
  INVALID_CREDENTIALS: 'AUTH_002',
  TOKEN_EXPIRED: 'AUTH_003',
  USER_NOT_FOUND: 'USER_001',
  DRIVER_NOT_FOUND: 'DRIVER_001',
  RIDE_NOT_FOUND: 'RIDE_001',
  PAYMENT_FAILED: 'PAYMENT_001',
  INSUFFICIENT_BALANCE: 'WALLET_001',
  VOUCHER_NOT_FOUND: 'VOUCHER_001',
  INTERNAL_ERROR: 'INTERNAL_001',
  ADMIN_ACCESS_DENIED: 'ADMIN_001',
  ADMIN_LOGIN_FAILED: 'ADMIN_002',
} as const;

export const ERROR_MESSAGES: Record<string, string> = {
  AUTH_001: 'Authentication required',
  AUTH_002: 'Invalid credentials',
  AUTH_003: 'Session expired. Please log in again.',
  USER_001: 'User not found',
  DRIVER_001: 'Driver not found',
  RIDE_001: 'Ride not found',
  PAYMENT_001: 'Payment failed',
  WALLET_001: 'Insufficient wallet balance',
  VOUCHER_001: 'Voucher not found',
  INTERNAL_001: 'An internal error occurred',
  ADMIN_001: 'Access denied',
  ADMIN_002: 'Admin login failed',
};

// ────────────────────────────────────────────────
// App Info
// ────────────────────────────────────────────────

export const APP_NAME = 'Nimbus Admin';
export const APP_VERSION = '1.0.0';

// ────────────────────────────────────────────────
// Pagination Defaults
// ────────────────────────────────────────────────

export const DEFAULT_PAGE_SIZE = 20;
export const PAGE_SIZE_OPTIONS = [10, 20, 50, 100];

// ────────────────────────────────────────────────
// Status Options
// ────────────────────────────────────────────────

export const RIDE_STATUSES = ['REQUESTED', 'ACTIVE', 'COMPLETED', 'CANCELLED'];

export const PAYMENT_STATUSES = ['PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'];

export const SETTLEMENT_STATUSES = ['PENDING', 'COMPLETED', 'FAILED'];

export const USER_STATUSES = ['ACTIVE', 'SUSPENDED', 'INACTIVE'];

export const DRIVER_STATUSES = ['ACTIVE', 'SUSPENDED', 'PENDING_APPROVAL'];

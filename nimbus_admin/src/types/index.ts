// ────────────────────────────────────────────────
// Auth Types
// ────────────────────────────────────────────────

export interface AdminLoginRequest {
  email: string;
  password: string;
}

export interface AdminAuthTokens {
  accessToken: string;
  refreshToken: string;
  tokenType?: string;
  expiresIn?: number;
}

export interface RefreshTokenResponse {
  accessToken: string;
  refreshToken: string;
  tokenType?: string;
  expiresIn?: number;
}

export interface AdminInfo {
  id: string;
  name: string;
  email: string;
  role?: string;
  avatarUrl?: string;
}

// ────────────────────────────────────────────────
// User Info
// ────────────────────────────────────────────────

export interface UserInfo {
  id: string;
  phone: string;
  email: string;
  status: string;
  role: string;
  phoneVerified: boolean;
  createdAt: string;
  firstName: string;
  lastName: string;
}

// ────────────────────────────────────────────────
// Driver Info
// ────────────────────────────────────────────────

export interface DriverInfo {
  id: string;
  userId: string;
  phone: string;
  email: string;
  approvalStatus: string;
  driverStatus: string;
  licenseNumber: string;
  rating: number;
  totalRides: number;
  totalEarnings: number;
  dueAmount: number;
  createdAt: string;
  driverFirstName?: string | null;
  driverLastName?: string | null;
}

// ────────────────────────────────────────────────
// Ride Info
// ────────────────────────────────────────────────

export interface RideInfo {
  id: string;
  driverId: string;
  userId: string;
  status: string;
  originAddress: string;
  destinationAddress: string;
  scheduledAt: string;
  actualStartAt: string;
  actualEndAt: string;
  createdAt: string;
}

// ────────────────────────────────────────────────
// Payment Info
// ────────────────────────────────────────────────

export interface PaymentInfo {
  id: string;
  bookingId: string;
  userId: string;
  amount: number;
  paymentMethod: string;
  status: string;
  providerReference: string;
  idempotencyKey: string;
  createdAt: string;
  updatedAt: string;
}

// ────────────────────────────────────────────────
// Settlement Info
// ────────────────────────────────────────────────

export interface SettlementInfo {
  id: string;
  driverId: string;
  periodStart: string;
  periodEnd: string;
  grossEarnings: number;
  commission: number;
  payable: number;
  status: string;
  createdAt: string;
  paymentReference: string;
}

// ────────────────────────────────────────────────
// Complaint Info (raw Complaint entity — relations serialize as nested objects)
// ────────────────────────────────────────────────

export interface ComplaintInfo {
  id: string;
  category: string;
  description: string;
  status: string;
  resolution?: string | null;
  createdAt: string;
  updatedAt?: string;
  bookingId?: string;
  passengerId?: string;
  booking?: { id?: string } | null;
  user?: { id?: string } | null;
}

// ────────────────────────────────────────────────
// Safety Event Info (raw SafetyEvent entity — relations serialize as nested objects)
// ────────────────────────────────────────────────

export interface SafetyEventInfo {
  id: string;
  eventType: string;
  status: string;
  description?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  vehicleId?: string | null;
  shareToken?: string | null;
  expiresAt?: string | null;
  createdAt: string;
  updatedAt?: string;
  ride?: { id?: string } | null;
  booking?: { id?: string } | null;
  user?: { id?: string } | null;
  driver?: { id?: string } | null;
}

// ────────────────────────────────────────────────
// System Configuration Info
// ────────────────────────────────────────────────

export interface SystemConfigInfo {
  id: string;
  configKey: string;
  configValue?: string | null;
  configType: string;
  description?: string | null;
  encrypted?: boolean;
  createdAt: string;
  updatedAt: string;
}

// ────────────────────────────────────────────────
// Common
// ────────────────────────────────────────────────

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  timestamp: string;
}

export type LoadingState = 'idle' | 'loading' | 'success' | 'error';

// Re-export paged types
export type { PagedResponse, PageMeta } from './paged';
export type { DashboardStats, RecentRide } from './dashboard';
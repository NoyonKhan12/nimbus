import api from './api';

// ── User detail (users + passengers) ────────────────────────────────────

export interface UserDetail {
  id: string;
  phone: string;
  email: string | null;
  status: string;
  role: string;
  phoneVerified: boolean;
  createdAt: string;
  profile: {
    firstName: string | null;
    lastName: string | null;
    gender: string | null;
    emergencyContactName: string | null;
    emergencyContactPhone: string | null;
    profilePhotoUrl: string | null;
  } | null;
  wallet: {
    balance: number;
    currency: string;
    ownerType: string;
  } | null;
  deviceCount: number;
}

/** GET /admin/users/{id} — full user detail. */
export const getUserDetail = async (id: string): Promise<UserDetail> => {
  const response = await api.get(`/admin/users/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as UserDetail;
};

// ── Driver detail ───────────────────────────────────────────────────────

export interface DocumentRow {
  documentType: string;
  documentNumber: string;
  status: string;
  expiresAt: string | null;
  verified: boolean;
  documentUrl: string | null;
}

export interface DriverVehicleRow {
  id: string;
  registrationNumber: string;
  type: string;
  model: string;
  year: number;
  color: string;
  seatCapacity: number;
  status: string;
}

export interface DriverDetail {
  id: string;
  userId: string | null;
  phone: string | null;
  email: string | null;
  approvalStatus: string;
  driverStatus: string;
  licenseNumber: string | null;
  licenseExpiry: string | null;
  rating: number;
  reliabilityScore: number;
  currentLocation: string | null;
  currentLocationUpdatedAt: string | null;
  totalRides: number;
  totalEarnings: number;
  dueAmount: number;
  commissionRate: number | null;
  createdAt: string;
  profile: {
    firstName: string | null;
    lastName: string | null;
    email: string | null;
  } | null;
  vehicles: DriverVehicleRow[];
  documents: DocumentRow[];
}

/** GET /admin/drivers/{id} — full driver detail. */
export const getDriverDetail = async (id: string): Promise<DriverDetail> => {
  const response = await api.get(`/admin/drivers/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as DriverDetail;
};

// ── Vehicle detail ──────────────────────────────────────────────────────

export interface VehicleDetail {
  id: string;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  registrationNumber: string;
  type: string;
  model: string;
  year: number;
  color: string;
  seatCapacity: number;
  status: string;
  createdAt: string;
  documents: DocumentRow[];
}

/** GET /admin/vehicles/{id} — full vehicle detail incl. documents + owner. */
export const getVehicleDetail = async (id: string): Promise<VehicleDetail> => {
  const response = await api.get(`/admin/vehicles/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as VehicleDetail;
};

// ── Ride detail ─────────────────────────────────────────────────────────

export interface RideDetail {
  id: string;
  status: string;
  type: string;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  creatorId: string | null;
  creatorName: string | null;
  creatorPhone: string | null;
  vehicleRegistration: string | null;
  originAddress: string;
  destinationAddress: string;
  scheduledAt: string | null;
  actualStartAt: string | null;
  actualEndAt: string | null;
  availableSeats: number;
  maxDetourMeters: number | null;
  notes: string | null;
  createdAt: string;
  passengers: Array<{
    id: string;
    passengerId: string | null;
    passengerName: string | null;
    passengerPhone: string | null;
    seats: number;
    journeyStatus: string;
    createdAt: string;
  }>;
  bookings: Array<{
    id: string;
    seats: number;
    status: string;
    pickupAddress: string;
    dropoffAddress: string;
    finalPayable: number | null;
    pickupPlannedTime: string | null;
    pickupLocation: string;
    dropoffLocation: string;
    createdAt: string;
  }>;
  payment: {
    id: string;
    amount: number;
    method: string;
    status: string;
    providerReference: string | null;
    createdAt: string;
  } | null;
}

/** GET /admin/rides/{id} — full ride detail incl. passengers, bookings, payment. */
export const getRideDetail = async (id: string): Promise<RideDetail> => {
  const response = await api.get(`/admin/rides/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as RideDetail;
};

// ── Payment detail ──────────────────────────────────────────────────────

export interface PaymentDetail {
  id: string;
  bookingId: string | null;
  rideId: string | null;
  payerId: string | null;
  payerName: string | null;
  payerPhone: string | null;
  amount: number;
  method: string;
  status: string;
  providerReference: string | null;
  idempotencyKey: string | null;
  pickupAddress: string | null;
  dropoffAddress: string | null;
  createdAt: string;
  updatedAt: string;
}

/** GET /admin/payments/{id} — payment detail with booking context + payer. */
export const getPaymentDetail = async (id: string): Promise<PaymentDetail> => {
  const response = await api.get(`/admin/payments/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as PaymentDetail;
};

// ── Settlement detail ───────────────────────────────────────────────────

export interface SettlementDetail {
  id: string;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  periodStart: string;
  periodEnd: string;
  grossEarnings: number;
  commission: number;
  adjustments: number;
  refunds: number;
  driverCredits: number;
  payable: number;
  status: string;
  paymentReference: string | null;
  createdAt: string;
  updatedAt: string;
}

/** GET /admin/settlements/{id} — settlement detail with full period math. */
export const getSettlementDetail = async (id: string): Promise<SettlementDetail> => {
  const response = await api.get(`/admin/settlements/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as SettlementDetail;
};

// ── Complaint detail ────────────────────────────────────────────────────

export interface ComplaintDetail {
  id: string;
  category: string;
  status: string;
  description: string;
  resolution: string | null;
  passengerId: string | null;
  passengerName: string | null;
  passengerPhone: string | null;
  bookingId: string | null;
  rideId: string | null;
  createdAt: string;
  updatedAt: string;
}

/** GET /admin/complaints/{id} — complaint detail with passenger/context links. */
export const getComplaintDetail = async (id: string): Promise<ComplaintDetail> => {
  const response = await api.get(`/admin/complaints/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as ComplaintDetail;
};

// ── Safety event detail ─────────────────────────────────────────────────

export interface SafetyDetail {
  id: string;
  eventType: string;
  status: string;
  userId: string | null;
  userName: string | null;
  userPhone: string | null;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  rideId: string | null;
  vehicleId: string | null;
  vehicleRegistration: string | null;
  latitude: number | null;
  longitude: number | null;
  description: string | null;
  shareToken: string | null;
  expiresAt: string | null;
  createdAt: string;
  updatedAt: string;
}

/** GET /admin/safety/{id} — safety event detail with participants + location. */
export const getSafetyDetail = async (id: string): Promise<SafetyDetail> => {
  const response = await api.get(`/admin/safety/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as SafetyDetail;
};

// ────────────────────────────────────────────────
// Dashboard Types
// ────────────────────────────────────────────────

export interface DashboardStats {
  totalUsers: number;
  totalDrivers: number;
  activeRides: number;
  totalRides: number;
  totalPayments: number;
  pendingSettlements: number;
  totalRevenue: string;
  recentRides: RecentRide[];
}

export interface RecentRide {
  id: string;
  userId: string;
  driverId: string;
  status: string;
  originAddress: string;
  destinationAddress: string;
  createdAt: string;
}
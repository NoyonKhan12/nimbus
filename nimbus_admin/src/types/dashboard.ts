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
  originAddress: string | null;
  destinationAddress: string | null;
  createdAt: string;
  /** WKT POINT fallbacks (e.g. "POINT(90.412 23.811)") when address is missing */
  originLocation?: string | null;
  destinationLocation?: string | null;
}

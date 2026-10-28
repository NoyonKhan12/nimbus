import api from './api';

/**
 * Vehicle admin row returned by GET /admin/vehicles.
 * Mirrors AdminVehicleService.VehicleAdminRow on the API.
 */
export interface VehicleAdminRow {
  id: string;
  driverId: string;
  registrationNumber: string;
  type: string;
  model: string;
  year: number;
  color: string;
  seatCapacity: number;
  status: string;
}

export const VEHICLE_STATUSES = ['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'] as const;

export const getVehicles = async (
  page = 0,
  size = 20,
  status?: string,
): Promise<{ data: VehicleAdminRow[]; meta: { page: number; totalPages: number; totalElements: number } }> => {
  const params = new URLSearchParams();
  params.set('page', String(page));
  params.set('size', String(size));
  if (status) params.set('status', status);
  const response = await api.get(`/admin/vehicles?${params.toString()}`);
  const payload = response.data.data ?? response.data;
  // Some endpoints double-wrap {success, data:{...}} inside ApiResponse — normalize both.
  const body = payload?.data ?? payload;
  return {
    data: (body?.data ?? body ?? []) as VehicleAdminRow[],
    meta: body?.meta ?? { page: 0, totalPages: 0, totalElements: 0 },
  };
};

export const updateVehicleStatus = async (id: string, status: string): Promise<void> => {
  await api.patch(`/admin/vehicles/${id}/status`, { status });
};

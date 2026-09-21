import api from './api';
import { DriverInfo } from '@/types';
import { PagedResponse } from '@/types/paged';

/**
 * Helper: unwrap ApiResponse → extract PagedResponse from data.data.
 */
function extractPagedResponse<T>(response: any): PagedResponse<T> {
  const wrapped = response.data; // ApiResponse wrapper
  const data = wrapped.data ?? wrapped; // PagedResponse
  return data as PagedResponse<T>;
}

/**
 * Fetch a paginated list of drivers.
 */
export const getDrivers = async (
  page: number = 0,
  size: number = 20,
  search?: string,
  status?: string,
): Promise<PagedResponse<DriverInfo>> => {
  const params = new URLSearchParams();
  params.set('page', page.toString());
  params.set('size', size.toString());
  if (search) params.set('search', search);
  if (status) params.set('status', status);

  const response = await api.get(`/admin/drivers?${params}`);
  return extractPagedResponse<DriverInfo>(response);
};

/**
 * Fetch a single driver by ID.
 */
export const getDriverById = async (id: string): Promise<DriverInfo> => {
  const response = await api.get(`/admin/drivers/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as DriverInfo;
};

/**
 * Approve a driver application.
 */
export const approveDriver = async (id: string): Promise<void> => {
  await api.patch(`/admin/drivers/${id}/approve`);
};

/**
 * Reject a driver application.
 */
export const rejectDriver = async (
  id: string,
  reason?: string,
): Promise<void> => {
  await api.patch(`/admin/drivers/${id}/reject`, reason ? { reason } : undefined);
};

/**
 * Update a driver's status (suspend/activate).
 */
export const updateDriverStatus = async (
  id: string,
  status: string,
): Promise<void> => {
  await api.patch(`/admin/drivers/${id}/status`, { status });
};
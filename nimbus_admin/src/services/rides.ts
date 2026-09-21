import api from './api';
import { RideInfo } from '@/types';
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
 * Fetch a paginated list of rides.
 */
export const getRides = async (
  page: number = 0,
  size: number = 20,
  status?: string,
  driverId?: string,
  userId?: string,
): Promise<PagedResponse<RideInfo>> => {
  const params = new URLSearchParams();
  params.set('page', page.toString());
  params.set('size', size.toString());
  if (status) params.set('status', status);
  if (driverId) params.set('driverId', driverId);
  if (userId) params.set('userId', userId);

  const response = await api.get(`/admin/rides?${params}`);
  return extractPagedResponse<RideInfo>(response);
};

/**
 * Fetch a single ride by ID.
 */
export const getRideById = async (id: string): Promise<RideInfo> => {
  const response = await api.get(`/admin/rides/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as RideInfo;
};
import api from './api';
import { SettlementInfo } from '@/types';
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
 * Fetch a paginated list of driver settlements.
 */
export const getSettlements = async (
  page: number = 0,
  size: number = 20,
  driverId?: string,
  status?: string,
): Promise<PagedResponse<SettlementInfo>> => {
  const params = new URLSearchParams();
  params.set('page', page.toString());
  params.set('size', size.toString());
  if (driverId) params.set('driverId', driverId);
  if (status) params.set('status', status);

  const response = await api.get(`/admin/settlements?${params}`);
  return extractPagedResponse<SettlementInfo>(response);
};

/**
 * Fetch a single settlement by ID.
 */
export const getSettlementById = async (
  id: string,
): Promise<SettlementInfo> => {
  const response = await api.get(`/admin/settlements/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as SettlementInfo;
};
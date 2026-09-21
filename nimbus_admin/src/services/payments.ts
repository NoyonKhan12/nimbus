import api from './api';
import { PaymentInfo } from '@/types';
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
 * Fetch a paginated list of payments.
 */
export const getPayments = async (
  page: number = 0,
  size: number = 20,
  status?: string,
  paymentMethod?: string,
): Promise<PagedResponse<PaymentInfo>> => {
  const params = new URLSearchParams();
  params.set('page', page.toString());
  params.set('size', size.toString());
  if (status) params.set('status', status);
  if (paymentMethod) params.set('paymentMethod', paymentMethod);

  const response = await api.get(`/admin/payments?${params}`);
  return extractPagedResponse<PaymentInfo>(response);
};

/**
 * Fetch a single payment by ID.
 */
export const getPaymentById = async (id: string): Promise<PaymentInfo> => {
  const response = await api.get(`/admin/payments/${id}`);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as PaymentInfo;
};

/**
 * Refund a payment (for card payments).
 */
export const refundPayment = async (
  id: string,
  amount: number,
  reason?: string,
): Promise<void> => {
  await api.post(`/admin/payments/${id}/refund`, { amount, reason });
};
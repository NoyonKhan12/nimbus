import api from './api';
import { ComplaintInfo } from '@/types';

/**
 * Fetch all complaints (optionally filtered by status).
 * Backend: GET /admin/complaints?status=OPEN — returns a plain list
 * wrapped in ApiResponse (no pagination).
 */
export const getComplaints = async (status?: string): Promise<ComplaintInfo[]> => {
  const query = status ? `?status=${encodeURIComponent(status)}` : '';
  const response = await api.get(`/admin/complaints${query}`);
  const wrapped = response.data; // ApiResponse wrapper
  return (Array.isArray(wrapped.data) ? wrapped.data : []) as ComplaintInfo[];
};

import api from './api';
import { DashboardStats } from '@/types';

/**
 * Fetch dashboard statistics (total users, drivers, rides, revenue, etc.).
 */
export const getDashboardStats = async (): Promise<DashboardStats> => {
  const response = await api.get('/admin/dashboard/stats');
  const wrapped = response.data; // ApiResponse wrapper
  return (wrapped.data ?? wrapped) as DashboardStats;
};
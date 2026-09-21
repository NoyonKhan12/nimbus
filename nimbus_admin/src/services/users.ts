import api from './api';
import { UserInfo } from '@/types';
import { PagedResponse } from '@/types/paged';

/**
 * Fetch a paginated list of users.
 * Returns both the list and pagination metadata.
 */
export const getUsers = async (
  page: number = 0,
  size: number = 20,
  search?: string,
  status?: string,
): Promise<PagedResponse<UserInfo>> => {
  const params = new URLSearchParams();
  params.set('page', page.toString());
  params.set('size', size.toString());
  if (search) params.set('search', search);
  if (status) params.set('status', status);

  const response = await api.get(`/admin/users?${params}`);
  const wrapped = response.data;
  const data = wrapped.data ?? wrapped;
  return data as PagedResponse<UserInfo>;
};

/**
 * Fetch a single user by ID.
 */
export const getUserById = async (id: string): Promise<UserInfo> => {
  const response = await api.get(`/admin/users/${id}`);
  const wrapped = response.data;
  return (wrapped.data || wrapped) as UserInfo;
};

/**
 * Update a user's status.
 */
export const updateUserStatus = async (
  id: string,
  status: string,
): Promise<void> => {
  await api.patch(`/admin/users/${id}/status`, { status });
};

/**
 * Delete a user.
 */
export const deleteUser = async (id: string): Promise<void> => {
  await api.delete(`/admin/users/${id}`);
};

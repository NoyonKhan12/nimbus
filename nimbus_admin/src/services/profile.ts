import api from './api';

export interface AdminProfile {
  id: string;
  phone: string;
  email: string | null;
  role: string;
  status: string;
  firstName: string | null;
  lastName: string | null;
  createdAt: string;
}

/**
 * Fetch the signed-in administrator's profile.
 * Backend: GET /admin/profile
 */
export const getProfile = async (): Promise<AdminProfile> => {
  const response = await api.get('/admin/profile');
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as AdminProfile;
};

/**
 * Update the signed-in administrator's name / email.
 * Backend: PATCH /admin/profile
 */
export const updateProfile = async (data: {
  firstName: string;
  lastName: string;
  email: string;
}): Promise<AdminProfile> => {
  const response = await api.patch('/admin/profile', data);
  const wrapped = response.data;
  return (wrapped.data ?? wrapped) as AdminProfile;
};

/**
 * Change the signed-in administrator's password (requires current password).
 * Backend: PATCH /admin/profile/password
 */
export const changePassword = async (data: {
  currentPassword: string;
  newPassword: string;
}): Promise<void> => {
  await api.patch('/admin/profile/password', data);
};

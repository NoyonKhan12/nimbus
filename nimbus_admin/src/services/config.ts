import api from './api';
import { SystemConfigInfo } from '@/types';

/**
 * Fetch all operational system configurations.
 * Backend: GET /admin/config — returns a plain list wrapped in ApiResponse
 * (no pagination). Fields are configKey/configValue, not key/value.
 */
export const getConfigurations = async (): Promise<SystemConfigInfo[]> => {
  const response = await api.get('/admin/config');
  const wrapped = response.data; // ApiResponse wrapper
  return (Array.isArray(wrapped.data) ? wrapped.data : []) as SystemConfigInfo[];
};

/**
 * Upsert a configuration value by key.
 * Backend: PUT /admin/config/{key}  body: { "value": "...", "description": "..." }
 * Description is only overwritten when provided.
 */
export const updateConfiguration = async (
  key: string,
  value: string,
  description?: string,
): Promise<SystemConfigInfo> => {
  const response = await api.put(`/admin/config/${encodeURIComponent(key)}`, {
    value,
    description,
  });
  const wrapped = response.data; // ApiResponse wrapper
  return (wrapped.data ?? wrapped) as SystemConfigInfo;
};

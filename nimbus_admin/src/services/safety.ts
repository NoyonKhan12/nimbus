import api from './api';
import { SafetyEventInfo } from '@/types';

/**
 * Fetch all open / unresolved safety events (SOS alerts etc.).
 * Backend: GET /safety/events/open (admin/safety roles only) — returns a
 * plain list wrapped in ApiResponse (no pagination).
 */
export const getOpenSafetyEvents = async (): Promise<SafetyEventInfo[]> => {
  const response = await api.get('/safety/events/open');
  const wrapped = response.data; // ApiResponse wrapper
  return (Array.isArray(wrapped.data) ? wrapped.data : []) as SafetyEventInfo[];
};

/**
 * Update a safety event's status
 * (acknowledge / escalate / resolve — OPEN, IN_PROGRESS, RESOLVED, ESCALATED).
 * Backend: PATCH /admin/safety/{eventId}/status  body: { "status": "ESCALATED" }
 */
export const updateSafetyEventStatus = async (
  eventId: string,
  status: string,
): Promise<SafetyEventInfo> => {
  const response = await api.patch(`/admin/safety/${eventId}/status`, { status });
  const wrapped = response.data; // ApiResponse wrapper
  return (wrapped.data ?? wrapped) as SafetyEventInfo;
};

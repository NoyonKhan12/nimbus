'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import { FiShield, FiRefreshCw } from 'react-icons/fi';
import { SafetyEventInfo } from '@/types';
import { getOpenSafetyEvents, updateSafetyEventStatus } from '@/services/safety';
import { SAFETY_EVENT_STATUSES } from '@/lib/constants';
import { formatDateTime, getBadgeClass, getStatusLabel, truncateId } from '@/lib/utils';
import { useToast } from '@/components/toast';

/**
 * Safety operations page — list open safety events (SOS alerts) and let
 * the admin change event status (acknowledge / escalate / resolve).
 */
export default function SafetyPage() {
  const router = useRouter();
  const [events, setEvents] = useState<SafetyEventInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const { toast } = useToast();

  const loadEvents = async () => {
    try {
      setLoading(true);
      const list: SafetyEventInfo[] = await getOpenSafetyEvents();
      setEvents(list);
      setError(null);
    } catch (err: any) {
      setError(err.response?.data?.message || err.message || 'Failed to load safety events');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadEvents();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleStatusChange = async (
    event: SafetyEventInfo,
    status: string,
  ) => {
    if (status === event.status || updatingId) return;
    try {
      setUpdatingId(event.id);
      await updateSafetyEventStatus(event.id, status);
      toast('success', `Event ${getStatusLabel(status).toLowerCase()}`,
        `Safety event ${truncateId(event.id)} is now ${getStatusLabel(status)}.`);
      loadEvents();
    } catch (err: any) {
      toast('error', 'Status change failed',
        err?.response?.data?.message ||
          `Failed to update safety event ${truncateId(event.id)}`);
      loadEvents();
    } finally {
      setUpdatingId(null);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-rose-100 rounded-lg">
            <FiShield className="text-rose-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Safety Events</h1>
        </div>
        <button
          onClick={loadEvents}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">{error}</div>
      )}

      <div className="overflow-x-auto bg-white rounded-xl shadow">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left">
              <th className="px-4 py-2 text-xs font-medium text-gray-500">ID</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Type</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Ride</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Passenger</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Location</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Description</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Status</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Created</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading
              ? [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-40"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                  </tr>
                ))
              : events.length === 0
              ? (
                  <tr>
                    <td colSpan={9} className="px-4 py-6 text-sm text-gray-500 text-center">
                      No open safety events — all clear
                    </td>
                  </tr>
                )
              : events.map((e) => (
                  <tr
                    key={e.id}
                    onClick={() => router.push(`/dashboard/safety/${e.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(e.id)}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${getBadgeClass(e.eventType)}`}>
                        {getStatusLabel(e.eventType)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {truncateId(e.ride?.id ?? e.booking?.id ?? undefined)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {truncateId(e.user?.id ?? undefined)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {e.latitude != null && e.longitude != null
                        ? `${Number(e.latitude).toFixed(5)}, ${Number(e.longitude).toFixed(5)}`
                        : '-'}
                    </td>
                    <td
                      className="px-4 py-3 text-sm text-gray-700 max-w-xs truncate"
                      title={e.description ?? ''}
                    >
                      {e.description
                        ? (e.description.length > 80
                            ? `${e.description.substring(0, 80)}…`
                            : e.description)
                        : '-'}
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${getBadgeClass(e.status)}`}>
                        {getStatusLabel(e.status)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDateTime(e.createdAt)}</td>
                    <td className="px-4 py-3">
                      <select
                        onClick={(e) => e.stopPropagation()}
                        value={e.status}
                        disabled={updatingId === e.id || updatingId !== null}
                        onChange={(ev) => handleStatusChange(e, ev.target.value)}
                        className="px-2 py-1 border border-gray-300 rounded text-xs focus:ring-2 focus:ring-indigo-500 disabled:opacity-50"
                      >
                        {SAFETY_EVENT_STATUSES.map((s) => (
                          <option key={s} value={s}>{getStatusLabel(s)}</option>
                        ))}
                      </select>
                    </td>
                  </tr>
                ))}
          </tbody>
        </table>
      </div>

      {!loading && events.length > 0 && (
        <p className="mt-4 text-sm text-gray-500">
          {events.length} open event{events.length === 1 ? '' : 's'}
        </p>
      )}
    </div>
  );
}

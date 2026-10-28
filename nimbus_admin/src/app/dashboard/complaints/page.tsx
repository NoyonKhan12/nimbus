'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import {
  FiMessageSquare,
  FiRefreshCw,
  FiFilter,
} from 'react-icons/fi';
import { ComplaintInfo } from '@/types';
import { getComplaints } from '@/services/complaints';
import { COMPLAINT_STATUSES } from '@/lib/constants';
import { truncateId, formatDate, getStatusLabel } from '@/lib/utils';

/**
 * Complaints management page — list all complaints with category/status
 * badges and an optional status filter (server-side, no pagination on API).
 */
export default function ComplaintsPage() {
  const router = useRouter();
  const [complaints, setComplaints] = useState<ComplaintInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [statusFilter, setStatusFilter] = useState<string>('');

  const loadComplaints = async () => {
    try {
      setLoading(true);
      const list: ComplaintInfo[] = await getComplaints(
        statusFilter || undefined,
      );
      setComplaints(list);
      setError(null);
    } catch (err: any) {
      setError(err.response?.data?.message || err.message || 'Failed to load complaints');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadComplaints();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter]);

  const getCategoryBadge = (category: string): string => {
    switch (category) {
      case 'SAFETY':
        return 'bg-rose-100 text-rose-800';
      case 'DRIVER_BEHAVIOR':
        return 'bg-amber-100 text-amber-800';
      case 'OVERCHARGING':
        return 'bg-orange-100 text-orange-800';
      case 'DELAY':
        return 'bg-sky-100 text-sky-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <FiMessageSquare className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Complaints</h1>
        </div>
        <button
          onClick={loadComplaints}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      <div className="mb-4 relative w-48">
        <FiFilter className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 w-full appearance-none"
        >
          <option value="">All Statuses</option>
          {COMPLAINT_STATUSES.map((s) => (
            <option key={s} value={s}>{getStatusLabel(s)}</option>
          ))}
        </select>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">{error}</div>
      )}

      <div className="overflow-x-auto bg-white rounded-xl shadow">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left">
              <th className="px-4 py-2 text-xs font-medium text-gray-500">ID</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Passenger</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Booking</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Category</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Description</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Status</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Resolution</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Created</th>
            </tr>
          </thead>
          <tbody>
            {loading
              ? [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-40"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                  </tr>
                ))
              : complaints.length === 0
              ? (
                  <tr>
                    <td colSpan={8} className="px-4 py-6 text-sm text-gray-500 text-center">
                      No complaints found
                    </td>
                  </tr>
                )
              : complaints.map((c) => (
                  <tr
                    key={c.id}
                    onClick={() => router.push(`/dashboard/complaints/${c.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(c.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {truncateId(c.passengerId ?? c.user?.id ?? undefined)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {truncateId(c.bookingId ?? c.booking?.id ?? undefined)}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`status-badge ${getCategoryBadge(c.category)}`}>
                        {getStatusLabel(c.category)}
                      </span>
                    </td>
                    <td
                      className="px-4 py-3 text-sm text-gray-700 max-w-xs truncate"
                      title={c.description}
                    >
                      {c.description.length > 80
                        ? `${c.description.substring(0, 80)}…`
                        : c.description}
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${
                        c.status === 'RESOLVED' ? 'status-completed' :
                        c.status === 'IN_PROGRESS' ? 'status-pending' :
                        c.status === 'CLOSED' ? 'bg-gray-100 text-gray-800' :
                        'bg-sky-100 text-sky-800'
                      }`}>
                        {getStatusLabel(c.status)}
                      </span>
                    </td>
                    <td
                      className="px-4 py-3 text-sm text-gray-500 max-w-xs truncate"
                      title={c.resolution ?? ''}
                    >
                      {c.resolution ?? '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDate(c.createdAt)}</td>
                  </tr>
                ))}
          </tbody>
        </table>
      </div>

      {!loading && complaints.length > 0 && (
        <p className="mt-4 text-sm text-gray-500">
          {complaints.length} complaint{complaints.length === 1 ? '' : 's'}
          {statusFilter && ` (${getStatusLabel(statusFilter)})`}
        </p>
      )}
    </div>
  );
}

'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import { FiMap, FiSearch, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import { RideInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import { getRides } from '@/services/rides';
import { RIDE_STATUSES } from '@/lib/constants';
import { formatCurrency, formatDate, getBadgeClass, getStatusLabel, truncateId } from '@/lib/utils';

/**
 * Rides management page — list rides with status filter.
 */
export default function RidesPage() {
  const router = useRouter();
  const [rides, setRides] = useState<RideInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [meta, setMeta] = useState<{ page: number; totalPages: number; totalElements: number }>({
    page: 0,
    totalPages: 0,
    totalElements: 0,
  });

  const [statusFilter, setStatusFilter] = useState<string>('');
  const [currentPage, setCurrentPage] = useState(0);

  useEffect(() => {
    loadRides();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter, currentPage]);

  const loadRides = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<RideInfo> = await getRides(
        currentPage,
        20,
        statusFilter || undefined,
      );
      setRides(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load rides');
    } finally {
      setLoading(false);
    }
  };

  const handlePageChange = (page: number) => {
    if (page >= 0 && page < meta.totalPages) {
      setCurrentPage(page);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <FiMap className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Rides</h1>
        </div>
        <button
          onClick={loadRides}
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
          onChange={(e) => { setStatusFilter(e.target.value); setCurrentPage(0); }}
          className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 w-full appearance-none"
        >
          <option value="">All Statuses</option>
          {RIDE_STATUSES.map((s) => (
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
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Pickup</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Dropoff</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Status</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Created</th>
            </tr>
          </thead>
          <tbody>
            {loading
              ? [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                  </tr>
                ))
              : rides.map((ride) => (
                  <tr
                    key={ride.id}
                    onClick={() => router.push(`/dashboard/rides/${ride.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(ride.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{ride.originAddress ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{ride.destinationAddress ?? '-'}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${getBadgeClass(ride.status ?? undefined)}`}>
                        {getStatusLabel(ride.status ?? '')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDate(ride.createdAt)}</td>
                  </tr>
                ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {!loading && (
        <div className="mt-4 flex justify-between items-center">
          <p className="text-sm text-gray-500">
            Page {meta.page + 1} of {meta.totalPages} ({meta.totalElements} total)
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => handlePageChange(meta.page - 1)}
              disabled={meta.page === 0}
              className="px-3 py-1 text-sm border border-gray-300 rounded disabled:opacity-50 flex items-center gap-1"
            >
              <FiChevronLeft className="text-sm" />
              Previous
            </button>
            <button
              onClick={() => handlePageChange(meta.page + 1)}
              disabled={meta.page >= meta.totalPages - 1}
              className="px-3 py-1 text-sm border border-gray-300 rounded disabled:opacity-50 flex items-center gap-1"
            >
              Next
              <FiChevronRight className="text-sm" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
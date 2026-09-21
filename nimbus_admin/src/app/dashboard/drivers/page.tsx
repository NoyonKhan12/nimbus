'use client';

import { useEffect, useState } from 'react';
import { FiUsers, FiSearch, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight, FiCheck, FiX, FiPause, FiPlay } from 'react-icons/fi';
import { DriverInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import {
  getDrivers,
  approveDriver,
  rejectDriver,
  updateDriverStatus,
} from '@/services/drivers';
import { DRIVER_STATUSES } from '@/lib/constants';
import { truncateId, getStatusLabel } from '@/lib/utils';

/**
 * Drivers management page — list, approve, reject, suspend/activate.
 */
export default function DriversPage() {
  const [drivers, setDrivers] = useState<DriverInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [meta, setMeta] = useState<{ page: number; totalPages: number; totalElements: number }>({
    page: 0,
    totalPages: 0,
    totalElements: 0,
  });

  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(0);

  useEffect(() => {
    loadDrivers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, currentPage]);

  const loadDrivers = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<DriverInfo> = await getDrivers(
        currentPage,
        20,
        search || undefined,
      );
      setDrivers(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load drivers');
    } finally {
      setLoading(false);
    }
  };

  const handleAction = async (
    driver: DriverInfo,
    action: 'approve' | 'reject' | 'suspend' | 'activate',
  ) => {
    try {
      switch (action) {
        case 'approve':
          await approveDriver(driver.id);
          break;
        case 'reject':
          await rejectDriver(driver.id);
          break;
        case 'suspend':
          await updateDriverStatus(driver.id, 'SUSPENDED');
          break;
        case 'activate':
          await updateDriverStatus(driver.id, 'ACTIVE');
          break;
      }
      loadDrivers();
    } catch (err) {
      alert(`Failed to ${action} driver`);
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
            <FiUsers className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Drivers</h1>
        </div>
        <button
          onClick={loadDrivers}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      <div className="mb-4 relative w-64">
        <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
        <input
          type="text"
          placeholder="Search drivers..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setCurrentPage(0); }}
          className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 w-full"
        />
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">{error}</div>
      )}

      <div className="overflow-x-auto bg-white rounded-xl shadow">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left">
              <th className="px-4 py-2 text-xs font-medium text-gray-500">ID</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Phone</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">License</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Vehicle</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Rating</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Rides</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Earnings</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Due</th>
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
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-12"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-12"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                  </tr>
                ))
              : drivers.map((driver) => (
                  <tr key={driver.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(driver.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{driver.phone ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{driver.licenseNumber ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">-</td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {driver.rating != null ? driver.rating.toFixed(1) : '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">{driver.totalRides ?? 0}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{driver.totalEarnings ?? 0}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{driver.dueAmount ?? 0}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${
                        driver.approvalStatus === 'PENDING' ? 'status-pending' :
                        driver.driverStatus === 'ACTIVE' ? 'status-active' :
                        driver.driverStatus === 'SUSPENDED' ? 'status-suspended' :
                        ''
                      }`}>
                        {getStatusLabel(driver.approvalStatus ?? driver.driverStatus ?? '')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{driver.createdAt ?? '-'}</td>
                    <td className="px-4 py-3">
                      <div className="flex gap-1">
                        {driver.approvalStatus === 'PENDING' && (
                          <>
                            <button
                              onClick={() => handleAction(driver, 'approve')}
                              className="text-xs px-2 py-1 bg-emerald-100 text-emerald-700 rounded hover:bg-emerald-200 flex items-center gap-1"
                            >
                              <FiCheck className="text-xs" />
                              Approve
                            </button>
                            <button
                              onClick={() => handleAction(driver, 'reject')}
                              className="text-xs px-2 py-1 bg-rose-100 text-rose-700 rounded hover:bg-rose-200 flex items-center gap-1"
                            >
                              <FiX className="text-xs" />
                              Reject
                            </button>
                          </>
                        )}
                        {driver.driverStatus === 'ACTIVE' && (
                          <button
                            onClick={() => handleAction(driver, 'suspend')}
                            className="text-xs px-2 py-1 bg-rose-100 text-rose-700 rounded hover:bg-rose-200 flex items-center gap-1"
                          >
                            <FiPause className="text-xs" />
                            Suspend
                          </button>
                        )}
                        {driver.driverStatus === 'SUSPENDED' && (
                          <button
                            onClick={() => handleAction(driver, 'activate')}
                            className="text-xs px-2 py-1 bg-emerald-100 text-emerald-700 rounded hover:bg-emerald-200 flex items-center gap-1"
                          >
                            <FiPlay className="text-xs" />
                            Activate
                          </button>
                        )}
                      </div>
                    </td>
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
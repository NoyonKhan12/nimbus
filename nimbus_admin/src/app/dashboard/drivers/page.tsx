'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import { FiUserCheck, FiSearch, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight, FiPause, FiPlay } from 'react-icons/fi';
import { DriverInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import {
  getDrivers,
  approveDriver,
  rejectDriver,
  setDriverApproval,
} from '@/services/drivers';
import { DRIVER_STATUSES } from '@/lib/constants';
import { formatDateTime, getBadgeClass, getStatusLabel, truncateId } from '@/lib/utils';
import { useToast, ConfirmDialog } from '@/components/toast';

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

  const router = useRouter();
  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(0);
  const { toast } = useToast();

  // In-flight + confirmation feedback for driver lifecycle actions
  const [busyDriverId, setBusyDriverId] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<{
    driver: DriverInfo;
    action: 'approve' | 'reject' | 'suspend' | 'activate';
  } | null>(null);

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

  const CONFIG: Record<string, { label: string; tone: 'normal' | 'danger'; confirm?: string }> = {
    approve: { label: 'approved', tone: 'normal' },
    reject: { label: 'rejected', tone: 'danger', confirm: 'Reject' },
    suspend: { label: 'suspended', tone: 'danger', confirm: 'Suspend' },
    activate: { label: 'reinstated', tone: 'normal' },
  };

  const handleAction = async (
    driver: DriverInfo,
    action: 'approve' | 'reject' | 'suspend' | 'activate',
  ) => {
    try {
      setBusyDriverId(driver.id);
      switch (action) {
        case 'approve':
          await approveDriver(driver.id);
          break;
        case 'reject':
          await rejectDriver(driver.id);
          break;
        case 'suspend':
          await setDriverApproval(driver.id, 'SUSPENDED');
          break;
        case 'activate':
          await setDriverApproval(driver.id, 'APPROVED');
          break;
      }
      toast('success', `Driver ${CONFIG[action].label}`, `Driver ${truncateId(driver.id)} has been ${CONFIG[action].label}.`);
      loadDrivers();
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const apiMessage = (err as any)?.response?.data?.message;
      toast('error', `${CONFIG[action].confirm ?? action} failed`, apiMessage || `Failed to ${action} driver ${truncateId(driver.id)}`);
    } finally {
      setBusyDriverId(null);
      setPendingAction(null);
    }
  };

  /** Destructive/confirmable actions open the feedback dialog first. */
  const requestAction = (
    driver: DriverInfo,
    action: 'approve' | 'reject' | 'suspend' | 'activate',
  ) => {
    if (CONFIG[action].tone === 'danger') {
      setPendingAction({ driver, action });
    } else {
      handleAction(driver, action);
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
            <FiUserCheck className="text-indigo-600 text-xl" />
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
                  <tr
                    key={driver.id}
                    onClick={() => router.push(`/dashboard/drivers/${driver.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
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
                      <span
                        className={`status-badge ${getBadgeClass(
                          driver.approvalStatus === 'PENDING' ? 'PENDING' : driver.driverStatus,
                        )}`}
                      >
                        {getStatusLabel(driver.approvalStatus ?? driver.driverStatus ?? '')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDateTime(driver.createdAt)}</td>
                    <td className="px-4 py-3">
                      <div className="flex gap-1">
                        {(driver.approvalStatus === 'APPROVED' ||
                          driver.approvalStatus === 'REJECTED') && (
                          <button
                            disabled={busyDriverId === driver.id}
                            onClick={(e) => { e.stopPropagation(); requestAction(driver, "suspend"); }}
                            className="text-xs px-2 py-1 bg-rose-100 text-rose-700 rounded hover:bg-rose-200 flex items-center gap-1"
                          >
                            <FiPause className="text-xs" />
                            Suspend
                          </button>
                        )}
                        {driver.approvalStatus === 'SUSPENDED' && (
                          <button
                            disabled={busyDriverId === driver.id}
                            onClick={(e) => { e.stopPropagation(); requestAction(driver, "activate"); }}
                            className="text-xs px-2 py-1 bg-emerald-100 text-emerald-700 rounded hover:bg-emerald-200 flex items-center gap-1"
                          >
                            <FiPlay className="text-xs" />
                            Reinstate
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

      {/* Confirm dialog for reject/suspend with in-flight "Rejecting…" state */}
      <ConfirmDialog
        open={pendingAction !== null}
        tone={pendingAction ? CONFIG[pendingAction.action].tone : 'normal'}
        title={
          pendingAction
            ? `${CONFIG[pendingAction.action].confirm} driver`
            : ''
        }
        message={
          pendingAction
            ? `Driver ${truncateId(pendingAction.driver.id)} will be ${
                pendingAction.action === 'suspend'
                  ? 'suspended and can no longer accept rides'
                  : pendingAction.action === 'activate'
                    ? 'reinstated and marked APPROVED'
                    : 'rejected'
              }.`
            : ''
        }
        confirmLabel={pendingAction ? CONFIG[pendingAction.action].confirm ?? 'Confirm' : 'Confirm'}
        working={busyDriverId === (pendingAction?.driver.id ?? '')}
        onConfirm={() => pendingAction && handleAction(pendingAction.driver, pendingAction.action)}
        onCancel={() => setPendingAction(null)}
      />
    </div>
  );
}
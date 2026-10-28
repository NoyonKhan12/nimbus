'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import { FiTruck, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight, FiCheck, FiX, FiPause } from 'react-icons/fi';
import { PagedResponse } from '@/types/paged';
import { getVehicles, updateVehicleStatus, VEHICLE_STATUSES, VehicleAdminRow } from '@/services/vehicles';
import { formatDateTime, getBadgeClass, getStatusLabel, truncateId } from '@/lib/utils';
import { useToast, ConfirmDialog } from '@/components/toast';

/**
 * Vehicles management page — list all drivers' vehicles,
 * approve / reject / suspend via PATCH /admin/vehicles/{id}/status.
 */
export default function VehiclesPage() {
  const [vehicles, setVehicles] = useState<VehicleAdminRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [meta, setMeta] = useState<{ page: number; totalPages: number; totalElements: number }>({
    page: 0,
    totalPages: 0,
    totalElements: 0,
  });

  const router = useRouter();
  const [statusFilter, setStatusFilter] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(0);
  const { toast } = useToast();

  // Confirmation + in-flight feedback for status changes
  const [pendingChange, setPendingChange] = useState<{ vehicle: VehicleAdminRow; status: string } | null>(null);

  useEffect(() => {
    loadVehicles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter, currentPage]);

  const loadVehicles = async () => {
    try {
      setLoading(true);
      setError(null);
      const response: { data: VehicleAdminRow[]; meta: { page: number; totalPages: number; totalElements: number } } =
        await getVehicles(currentPage, 20, statusFilter || undefined);
      setVehicles(response.data);
      setMeta(response.meta);
    } catch (err) {
      setError(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (err as any)?.response?.data?.message ||
        (err as Error).message ||
        'Failed to load vehicles',
      );
    } finally {
      setLoading(false);
    }
  };

  const changeStatus = async (id: string, status: string) => {
    try {
      setBusyId(id);
      setError(null);
      await updateVehicleStatus(id, status);
      toast('success', `Vehicle ${getStatusLabel(status).toLowerCase()}`, `Vehicle ${truncateId(id)} is now ${getStatusLabel(status)}.`);
      await loadVehicles();
    } catch (err) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('error', 'Status change failed',
        (err as any)?.response?.data?.message ||
        (err as Error).message ||
        'Failed to update vehicle status');
    } finally {
      setBusyId(null);
      setPendingChange(null);
    }
  };

  const requestChange = (vehicle: VehicleAdminRow, status: string) => {
    if (status === 'APPROVED') {
      // Non-destructive: goes straight through, busy/disable state still shows.
      changeStatus(vehicle.id, status);
    } else {
      setPendingChange({ vehicle, status });
    }
  };

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-semibold text-gray-900 flex items-center gap-2">
          <FiTruck className="text-gray-600" /> Vehicles
        </h1>
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1 text-sm text-gray-500">
            <FiFilter className="text-xs" />
            <select
              value={statusFilter}
              onChange={(e) => {
                setCurrentPage(0);
                setStatusFilter(e.target.value);
              }}
              className="border border-gray-300 rounded-md px-2 py-1.5 text-sm bg-white"
            >
              <option value="">All statuses</option>
              {VEHICLE_STATUSES.map((s) => (
                <option key={s} value={s}>{getStatusLabel(s)}</option>
              ))}
            </select>
          </div>
          <button
            onClick={loadVehicles}
            className="flex items-center gap-1 px-3 py-1.5 text-sm border border-gray-300 rounded-md hover:bg-gray-50"
          >
            <FiRefreshCw className={loading ? 'animate-spin' : ''} /> Refresh
          </button>
        </div>
      </div>

      {error && (
        <div className="mb-4 rounded-md bg-rose-50 px-4 py-2 text-sm text-rose-700">{error}</div>
      )}

      <div className="bg-white rounded-xl shadow overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left text-xs font-medium text-gray-500">
              <th className="px-4 py-2">Registration</th>
              <th className="px-4 py-2">Type</th>
              <th className="px-4 py-2">Model</th>
              <th className="px-4 py-2">Year</th>
              <th className="px-4 py-2">Color</th>
              <th className="px-4 py-2">Seats</th>
              <th className="px-4 py-2">Driver</th>
              <th className="px-4 py-2">Status</th>
              <th className="px-4 py-2">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={9} className="px-4 py-6 text-center text-gray-500">Loading vehicles…</td>
              </tr>
            )}
            {!loading && vehicles.map((v) => (
              <tr
                key={v.id}
                onClick={() => router.push(`/dashboard/vehicles/${v.id}`)}
                className="border-b hover:bg-gray-50 cursor-pointer"
              >
                <td className="px-4 py-3 text-sm text-gray-700">{v.registrationNumber ?? '-'}</td>
                <td className="px-4 py-3 text-sm">
                  <span
                    className={`status-badge capitalize ${getBadgeClass(v.type ?? undefined)}`}
                  >
                    {(v.type ?? '-').toLowerCase()}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm text-gray-700">{v.model ?? '-'}</td>
                <td className="px-4 py-3 text-sm text-gray-700">{v.year ?? '-'}</td>
                <td className="px-4 py-3 text-sm text-gray-700">{v.color ?? '-'}</td>
                <td className="px-4 py-3 text-sm text-gray-700">{v.seatCapacity ?? '-'}</td>
                <td className="px-4 py-3 text-sm text-gray-500">{truncateId(v.driverId)}</td>
                <td className="px-4 py-3 text-sm">
                  <span
                    className={`status-badge ${getBadgeClass(v.status ?? undefined)}`}
                  >
                    {getStatusLabel(v.status)}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">
                  <div className="flex items-center gap-1">
                    {v.status !== 'APPROVED' && (
                      <button
                        title="Approve vehicle"
                        disabled={busyId === v.id}
                        onClick={(e) => { e.stopPropagation(); changeStatus(v.id, 'APPROVED'); }}
                        className="p-1.5 rounded-md text-emerald-600 hover:bg-emerald-50 disabled:opacity-50"
                      >
                        <FiCheck />
                      </button>
                    )}
                    {v.status !== 'REJECTED' && (v.status === 'PENDING' || v.status === 'SUSPENDED') && (
                      <button
                        title="Reject vehicle"
                        disabled={busyId === v.id}
                        onClick={(e) => { e.stopPropagation(); changeStatus(v.id, 'REJECTED'); }}
                        className="p-1.5 rounded-md text-rose-600 hover:bg-rose-50 disabled:opacity-50"
                      >
                        <FiX />
                      </button>
                    )}
                    {v.status !== 'SUSPENDED' && v.status === 'APPROVED' && (
                      <button
                        title="Suspend vehicle"
                        disabled={busyId === v.id}
                        onClick={(e) => { e.stopPropagation(); changeStatus(v.id, 'SUSPENDED'); }}
                        className="p-1.5 rounded-md text-amber-600 hover:bg-amber-50 disabled:opacity-50"
                      >
                        <FiPause />
                      </button>
                    )}
                    {busyId === v.id && <span className="text-xs text-gray-400 mr-1">Updating…</span>}
                  </div>
                </td>
              </tr>
            ))}
            {!loading && vehicles.length === 0 && (
              <tr>
                <td colSpan={9} className="px-4 py-6 text-center text-gray-500">No vehicles found</td>
              </tr>
            )}
          </tbody>
        </table>
        {meta.totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-2 text-sm text-gray-500 border-t">
            <span>{meta.totalElements} vehicle(s) — page {meta.page + 1} of {meta.totalPages}</span>
            <div className="flex gap-1">
              <button
                disabled={currentPage === 0}
                onClick={() => setCurrentPage((p) => Math.max(0, p - 1))}
                className="p-1.5 rounded-md border border-gray-300 disabled:opacity-40 hover:bg-gray-50"
              >
                <FiChevronLeft />
              </button>
              <button
                disabled={currentPage >= meta.totalPages - 1}
                onClick={() => setCurrentPage((p) => p + 1)}
                className="p-1.5 rounded-md border border-gray-300 disabled:opacity-40 hover:bg-gray-50"
              >
                <FiChevronRight />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Confirm dialog for reject/suspend with in-flight state */}
      <ConfirmDialog
        open={pendingChange !== null}
        tone="danger"
        title={pendingChange ? `${getStatusLabel(pendingChange.status).toLowerCase()} vehicle` : ''}
        message={
          pendingChange
            ? `Vehicle ${pendingChange.vehicle.registrationNumber ?? truncateId(pendingChange.vehicle.id)} will be marked ${getStatusLabel(pendingChange.status)}.`
            : ''
        }
        confirmLabel={pendingChange ? getStatusLabel(pendingChange.status) : 'Confirm'}
        working={busyId === (pendingChange?.vehicle.id ?? '')}
        onConfirm={() => pendingChange && changeStatus(pendingChange.vehicle.id, pendingChange.status)}
        onCancel={() => setPendingChange(null)}
      />
    </div>
  );
}

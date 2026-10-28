'use client';

import { useRouter } from 'next/navigation';

import { useEffect, useState } from 'react';
import { FiDollarSign, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight, FiCheckCircle } from 'react-icons/fi';
import { SettlementInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import { getSettlements, settleSettlement } from '@/services/settlements';
import { SETTLEMENT_STATUSES } from '@/lib/constants';
import { formatCurrency, formatDate, getBadgeClass, getStatusLabel, truncateId } from '@/lib/utils';
import { useToast, ConfirmDialog } from '@/components/toast';

/**
 * Settlements management page — list driver settlements with status filter.
 */
export default function SettlementsPage() {
  const router = useRouter();
  const [settlements, setSettlements] = useState<SettlementInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [meta, setMeta] = useState<{ page: number; totalPages: number; totalElements: number }>({
    page: 0,
    totalPages: 0,
    totalElements: 0,
  });

  const [statusFilter, setStatusFilter] = useState<string>('');
  const [currentPage, setCurrentPage] = useState(0);
  const { toast } = useToast();
  const [settleTarget, setSettleTarget] = useState<SettlementInfo | null>(null);
  const [settlingId, setSettlingId] = useState<string | null>(null);

  useEffect(() => {
    loadSettlements();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter, currentPage]);

  const loadSettlements = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<SettlementInfo> = await getSettlements(
        currentPage,
        20,
        undefined,
        statusFilter || undefined,
      );
      setSettlements(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load settlements');
    } finally {
      setLoading(false);
    }
  };

  const handleSettle = (settlement: SettlementInfo) => {
    // Confirmation modal replaces browser confirm(); see <ConfirmDialog> at bottom.
    setSettleTarget(settlement);
  };

  const confirmSettle = async () => {
    if (!settleTarget) return;
    try {
      setSettlingId(settleTarget.id);
      await settleSettlement(settleTarget.id);
      toast('success', 'Settlement paid',
        `${formatCurrency(settleTarget.payable ?? 0)} settled to driver ${truncateId(settleTarget.driverId)}.`);
      setSettleTarget(null);
      loadSettlements();
    } catch (err: any) {
      toast('error', 'Settlement failed',
        err?.response?.data?.message ||
          `Failed to settle settlement ${truncateId(settleTarget.id)}`);
    } finally {
      setSettlingId(null);
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
            <FiDollarSign className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Settlements</h1>
        </div>
        <button
          onClick={loadSettlements}
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
          {SETTLEMENT_STATUSES.map((s) => (
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
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Driver</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Period</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Gross Earnings</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Commission</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Payable</th>
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
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                  </tr>
                ))
              : settlements.map((s) => (
                  <tr
                    key={s.id}
                    onClick={() => router.push(`/dashboard/settlements/${s.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(s.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(s.driverId)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {formatDate(s.periodStart)} → {formatDate(s.periodEnd)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">{formatCurrency(s.grossEarnings ?? 0)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{formatCurrency(s.commission ?? 0)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{formatCurrency(s.payable ?? 0)}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${getBadgeClass(s.status ?? undefined)}`}>
                        {getStatusLabel(s.status ?? '')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDate(s.createdAt)}</td>
                    <td className="px-4 py-3">
                      {s.status === 'PENDING' && (
                        <button
                          onClick={(e) => { e.stopPropagation(); handleSettle(s); }}
                          disabled={settlingId === s.id || settlingId !== null}
                          className="text-xs px-2 py-1 bg-emerald-100 text-emerald-700 rounded hover:bg-emerald-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-1"
                        >
                          <FiCheckCircle className="text-xs" />
                          {settlingId === s.id ? 'Settling…' : 'Settle'}
                        </button>
                      )}
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

      {/* Settlement confirmation + in-flight modal */}
      <ConfirmDialog
        open={settleTarget !== null}
        title="Settle payment"
        message={
          settleTarget
            ? `Pay ${formatCurrency(settleTarget.payable ?? 0)} to driver ${truncateId(settleTarget.driverId)}? The settlement will be marked PAID and cash dues are cleared.`
            : ''
        }
        confirmLabel="Settle"
        working={settlingId === (settleTarget?.id ?? '')}
        onConfirm={confirmSettle}
        onCancel={() => setSettleTarget(null)}
      />
    </div>
  );
}

'use client';

import { useEffect, useState } from 'react';
import { FiCreditCard, FiRefreshCw, FiFilter, FiChevronLeft, FiChevronRight, FiGift } from 'react-icons/fi';
import { PaymentInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import { getPayments, refundPayment } from '@/services/payments';
import { PAYMENT_STATUSES } from '@/lib/constants';
import { truncateId, formatCurrency, formatDate, getStatusLabel } from '@/lib/utils';

/**
 * Payments management page — list payments with status filter and refund action.
 */
export default function PaymentsPage() {
  const [payments, setPayments] = useState<PaymentInfo[]>([]);
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
    loadPayments();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter, currentPage]);

  const loadPayments = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<PaymentInfo> = await getPayments(
        currentPage,
        20,
        statusFilter || undefined,
      );
      setPayments(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load payments');
    } finally {
      setLoading(false);
    }
  };

  const handleRefund = async (payment: PaymentInfo) => {
    const confirmed = confirm(
      `Refund payment of ${formatCurrency(payment.amount ?? 0)}?`,
    );
    if (!confirmed) return;
    try {
      await refundPayment(payment.id, payment.amount ?? 0);
      loadPayments();
    } catch (err) {
      alert('Failed to refund payment');
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
            <FiCreditCard className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Payments</h1>
        </div>
        <button
          onClick={loadPayments}
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
          {PAYMENT_STATUSES.map((s) => (
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
              <th className="px-4 py-2 text-xs font-medium text-gray-500">User</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Ride</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Amount</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Method</th>
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
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                  </tr>
                ))
              : payments.map((payment) => (
                  <tr key={payment.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(payment.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(payment.userId)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(payment.bookingId)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{formatCurrency(payment.amount ?? 0)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{payment.paymentMethod ?? '-'}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${
                        payment.status === 'COMPLETED' ? 'status-completed' :
                        payment.status === 'FAILED' ? 'status-cancelled' :
                        payment.status === 'REFUNDED' ? 'status-cancelled' :
                        'status-pending'
                      }`}>
                        {getStatusLabel(payment.status ?? '')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDate(payment.createdAt)}</td>
                    <td className="px-4 py-3">
                      {payment.status === 'COMPLETED' && payment.paymentMethod === 'CARD' && (
                        <button
                          onClick={() => handleRefund(payment)}
                          className="text-xs px-2 py-1 bg-rose-100 text-rose-700 rounded hover:bg-rose-200 flex items-center gap-1"
                        >
                          <FiGift className="text-xs" />
                          Refund
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
    </div>
  );
}
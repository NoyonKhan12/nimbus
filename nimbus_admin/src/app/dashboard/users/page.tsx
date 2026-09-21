'use client';

import { useEffect, useState } from 'react';
import { FiUsers, FiSearch, FiRefreshCw, FiTrash2, FiFilter, FiChevronLeft, FiChevronRight } from 'react-icons/fi';
import { UserInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import { getUsers, updateUserStatus, deleteUser } from '@/services/users';
import { USER_STATUSES } from '@/lib/constants';
import { truncateId, getStatusLabel } from '@/lib/utils';

/**
 * Users management page — list, search, suspend/activate, and delete users.
 */
export default function UsersPage() {
  const [users, setUsers] = useState<UserInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [meta, setMeta] = useState<{ page: number; totalPages: number; totalElements: number }>({
    page: 0,
    totalPages: 0,
    totalElements: 0,
  });

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [currentPage, setCurrentPage] = useState(0);

  useEffect(() => {
    loadUsers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, statusFilter, currentPage]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<UserInfo> = await getUsers(
        currentPage,
        20,
        search || undefined,
        statusFilter || undefined,
      );
      setUsers(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load users');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id: string, status: string) => {
    try {
      await updateUserStatus(id, status);
      loadUsers();
    } catch (err) {
      alert('Failed to update status');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this user?')) return;
    try {
      await deleteUser(id);
      loadUsers();
    } catch (err) {
      alert('Failed to delete user');
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
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
        </div>
        <button
          onClick={loadUsers}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      <div className="flex gap-4 mb-4">
        <div className="relative w-64">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search users..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setCurrentPage(0); }}
            className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 w-full"
          />
        </div>
        <div className="relative w-48">
          <FiFilter className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <select
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setCurrentPage(0); }}
            className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 w-full appearance-none"
          >
            <option value="">All Statuses</option>
            {USER_STATUSES.map((s) => (
              <option key={s} value={s}>
                {getStatusLabel(s)}
              </option>
            ))}
          </select>
        </div>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">{error}</div>
      )}

      <div className="overflow-x-auto bg-white rounded-xl shadow">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 text-left">
              <th className="px-4 py-2 text-xs font-medium text-gray-500">ID</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Name</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Phone</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Email</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Status</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Role</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Created</th>
              <th className="px-4 py-2 text-xs font-medium text-gray-500">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading
              ? [...Array(5)].map((_, i) => (
                  <tr key={i} className="border-b animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-24"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-32"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-16"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                    <td className="px-4 py-3"><div className="h-4 bg-gray-200 rounded w-20"></div></td>
                  </tr>
                ))
              : users.map((user) => (
                  <tr key={user.id} className="border-b hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(user.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {(user.firstName + ' ' + user.lastName).trim() || '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">{user.phone ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{user.email ?? '-'}</td>
                    <td className="px-4 py-3 text-sm">
                      <select
                        value={user.status ?? ''}
                        onChange={(e) => handleStatusChange(user.id, e.target.value)}
                        className="text-sm border border-gray-300 rounded px-2 py-1"
                      >
                        {USER_STATUSES.map((s) => (
                          <option key={s} value={s}>{getStatusLabel(s)}</option>
                        ))}
                      </select>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">{user.role ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-500">{user.createdAt ?? '-'}</td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => handleDelete(user.id)}
                        className="text-rose-600 hover:text-rose-800 text-sm font-medium flex items-center gap-1"
                      >
                        <FiTrash2 className="text-sm" />
                        Delete
                      </button>
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
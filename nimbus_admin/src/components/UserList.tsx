'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { IconType } from 'react-icons';
import { FiSearch, FiRefreshCw, FiTrash2, FiFilter, FiChevronLeft, FiChevronRight, FiUserPlus } from 'react-icons/fi';
import { UserInfo } from '@/types';
import { PagedResponse } from '@/types/paged';
import { getUsers, updateUserStatus, deleteUser, createUser } from '@/services/users';
import { USER_STATUSES } from '@/lib/constants';
import { formatDateTime, getBadgeClass, getStatusLabel, truncateId, cn } from '@/lib/utils';
import { useToast, ConfirmDialog } from '@/components/toast';

interface UserListProps {
  /** Page title, e.g. "Users", "Passengers", "Admins". */
  title: string;
  /** Page description shown under the title. */
  description?: string;
  /** Lock the listing to one role (backend `role` filter) — used by Passengers/Admins. */
  fixedRole?: string;
  /** Hide the role select in the filter row (when role is fixed). */
  showRoleFilter?: boolean;
  /** Header icon for the page card. */
  headerIcon?: IconType;
  /** Hide destructive actions (e.g. don't allow deleting admin accounts from the Admins page). */
  canDelete?: boolean;
}

/**
 * Shared account list table used by the Users, Passengers and Admins pages:
 * search, status filter, suspend/activate via inline select, delete with
 * confirmation, pagination, and toast feedback for every action.
 */
export default function UserList({
  title,
  description,
  fixedRole,
  showRoleFilter = true,
  headerIcon: HeaderIcon,
  canDelete = true,
}: UserListProps) {
  const router = useRouter();
  const detailBase = fixedRole === 'PASSENGER' ? '/dashboard/passengers' : '/dashboard/users';
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
  const [roleFilter, setRoleFilter] = useState<string>('');
  const [currentPage, setCurrentPage] = useState(0);
  const { toast } = useToast();

  // In-flight feedback for row actions
  const [busyUserId, setBusyUserId] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<UserInfo | null>(null);

  // Create user (Users page only — passengers/drivers have their own flows)
  const canCreate = !fixedRole;
  const emptyCreateForm = { firstName: '', lastName: '', phone: '', email: '', password: '', role: 'SUPPORT' };
  const [createOpen, setCreateOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [createForm, setCreateForm] = useState(emptyCreateForm);

  useEffect(() => {
    loadUsers();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, statusFilter, roleFilter, currentPage, fixedRole]);

  const effectiveRole = fixedRole ?? (showRoleFilter ? roleFilter : undefined);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const response: PagedResponse<UserInfo> = await getUsers(
        currentPage,
        20,
        search || undefined,
        statusFilter || undefined,
        effectiveRole || undefined,
      );
      setUsers(response.data);
      setMeta({
        page: response.meta.page,
        totalPages: response.meta.totalPages,
        totalElements: response.meta.totalElements,
      });
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || (err as Error).message || 'Failed to load users');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (id: string, status: string) => {
    try {
      setBusyUserId(id);
      await updateUserStatus(id, status);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('success', `User ${getStatusLabel(status).toLowerCase()}`,
        `User ${truncateId(id)} is now ${getStatusLabel(status)}.`);
      loadUsers();
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('error', 'Status update failed',
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (err as any)?.response?.data?.message || 'Failed to update status');
    } finally {
      setBusyUserId(null);
    }
  };

  const confirmDelete = async () => {
    if (!deleteTarget) return;
    try {
      setBusyUserId(deleteTarget.id);
      await deleteUser(deleteTarget.id);
      toast('success', 'User deleted', `User ${truncateId(deleteTarget.id)} has been deleted.`);
      setDeleteTarget(null);
      loadUsers();
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('error', 'Delete failed',
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (err as any)?.response?.data?.message || 'Failed to delete user');
    } finally {
      setBusyUserId(null);
    }
  };

  const handlePageChange = (page: number) => {
    if (page >= 0 && page < meta.totalPages) {
      setCurrentPage(page);
    }
  };

  const handleCreateUser = async () => {
    const phone = createForm.phone.trim();
    const password = createForm.password;
    if (!/^\+?[0-9]{10,15}$/.test(phone)) {
      toast('error', 'Invalid phone', 'Phone must be 10-15 digits, optionally starting with +');
      return;
    }
    if (password.length < 8) {
      toast('error', 'Weak password', 'Password must be at least 8 characters');
      return;
    }
    try {
      setCreating(true);
      const created = await createUser({
        phone,
        email: createForm.email.trim() || undefined,
        password,
        role: createForm.role,
        firstName: createForm.firstName.trim() || undefined,
        lastName: createForm.lastName.trim() || undefined,
      });
      toast('success', 'User created',
        `${createForm.role} account ${created.phone} has been created.`);
      setCreateOpen(false);
      setCreateForm(emptyCreateForm);
      setCurrentPage(0);
      loadUsers();
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const e = err as any;
      toast('error', 'Create failed',
        e?.response?.data?.error?.message || e?.response?.data?.message || 'Failed to create user');
    } finally {
      setCreating(false);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          {HeaderIcon && (
            <div className="p-2 bg-indigo-100 rounded-lg">
              <HeaderIcon className="text-indigo-600 text-xl" />
            </div>
          )}
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
            {description && <p className="text-sm text-gray-500 mt-0.5">{description}</p>}
          </div>
        </div>
        <div className="flex items-center gap-2">
          {canCreate && (
            <button
              onClick={() => setCreateOpen(true)}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors flex items-center gap-2"
            >
              <FiUserPlus className="text-sm" />
              Add User
            </button>
          )}
          <button
            onClick={loadUsers}
            className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
          >
            <FiRefreshCw className="text-sm" />
            Refresh
          </button>
        </div>
      </div>

      <div className="flex gap-4 mb-4">
        <div className="relative w-64">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder={`Search ${title.toLowerCase()}...`}
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
        {/* Role filter — hidden when the page is locked to a fixed role. */}
        {fixedRole ? null : (
          <div className="relative w-48">
            <FiFilter className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <select
              value={roleFilter}
              onChange={(e) => { setRoleFilter(e.target.value); setCurrentPage(0); }}
              className={cn('pl-10 pr-4 py-2 border border-gray-300 rounded-lg w-full appearance-none',
                'focus:ring-2 focus:ring-indigo-500')}
            >
              {/* Internal staff roles only — passengers/drivers have their own lists. */}
              <option value="">All staff (internal)</option>
              <option value="ADMIN">Admin</option>
              <option value="OPERATIONS">Operations</option>
              <option value="FINANCE">Finance</option>
              <option value="SUPPORT">Support</option>
              <option value="SAFETY">Safety</option>
            </select>
          </div>
        )}
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
              {canDelete && <th className="px-4 py-2 text-xs font-medium text-gray-500">Actions</th>}
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
                  <tr
                    key={user.id}
                    onClick={() => router.push(`${detailBase}/${user.id}`)}
                    className="border-b hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-4 py-3 text-sm text-gray-700">{truncateId(user.id)}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">
                      {(user.firstName + ' ' + user.lastName).trim() || '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700">{user.phone ?? '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{user.email ?? '-'}</td>
                    <td className="px-4 py-3 text-sm">
                      <select
                        onClick={(e) => e.stopPropagation()}
                        value={user.status ?? ''}
                        onChange={(e) => handleStatusChange(user.id, e.target.value)}
                        disabled={busyUserId === user.id}
                        className="text-sm border border-gray-300 rounded px-2 py-1"
                      >
                        {USER_STATUSES.map((s) => (
                          <option key={s} value={s}>{getStatusLabel(s)}</option>
                        ))}
                      </select>
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`status-badge ${getBadgeClass(user.role)}`}>
                        {getStatusLabel(user.role)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">{formatDateTime(user.createdAt)}</td>
                    {canDelete && (
                      <td className="px-4 py-3">
                        <button
                          onClick={(e) => { e.stopPropagation(); setDeleteTarget(user); }}
                          className="text-rose-600 hover:text-rose-800 text-sm font-medium flex items-center gap-1"
                        >
                          <FiTrash2 className="text-sm" />
                          Delete
                        </button>
                      </td>
                    )}
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
      {/* Delete confirmation + in-flight state */}
      <ConfirmDialog
        open={deleteTarget !== null}
        tone="danger"
        title="Delete user"
        message={
          deleteTarget
            ? `This permanently deletes user ${truncateId(deleteTarget.id)}${
                (deleteTarget.firstName + ' ' + deleteTarget.lastName).trim()
                  ? ` (${deleteTarget.firstName} ${deleteTarget.lastName})`
                  : ''
              }. This action cannot be undone.`
            : ''
        }
        confirmLabel="Delete"
        working={busyUserId === (deleteTarget?.id ?? '')}
        onConfirm={confirmDelete}
        onCancel={() => setDeleteTarget(null)}
      />

      {createOpen && (
        <div
          className="fixed inset-0 z-[70] flex items-center justify-center bg-black/50 p-4"
          onClick={() => !creating && setCreateOpen(false)}
        >
          <div
            className="bg-white rounded-xl shadow-xl w-full max-w-md p-6"
            onClick={(e) => e.stopPropagation()}
            role="dialog"
            aria-modal="true"
          >
            <h2 className="text-lg font-semibold text-gray-900">Add staff user</h2>
            <p className="text-sm text-gray-500 mt-1">
              Internal role accounts only. Passengers and drivers onboard through the mobile apps.
            </p>

            <form
              className="mt-4 space-y-3"
              onSubmit={(e) => { e.preventDefault(); handleCreateUser(); }}
            >
              <div className="grid grid-cols-2 gap-3">
                <label className="block">
                  <span className="text-xs font-medium text-gray-500">First name</span>
                  <input
                    type="text"
                    value={createForm.firstName}
                    onChange={(e) => setCreateForm({ ...createForm, firstName: e.target.value })}
                    className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="e.g. Rahim"
                  />
                </label>
                <label className="block">
                  <span className="text-xs font-medium text-gray-500">Last name</span>
                  <input
                    type="text"
                    value={createForm.lastName}
                    onChange={(e) => setCreateForm({ ...createForm, lastName: e.target.value })}
                    className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="e.g. Karim"
                  />
                </label>
              </div>

              <label className="block">
                <span className="text-xs font-medium text-gray-500">Phone *</span>
                <input
                  type="text"
                  value={createForm.phone}
                  onChange={(e) => setCreateForm({ ...createForm, phone: e.target.value })}
                  className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                  placeholder="+8801XXXXXXXXX"
                  required
                />
              </label>

              <label className="block">
                <span className="text-xs font-medium text-gray-500">Email</span>
                <input
                  type="email"
                  value={createForm.email}
                  onChange={(e) => setCreateForm({ ...createForm, email: e.target.value })}
                  className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                  placeholder="name@nimbus.com (optional)"
                />
              </label>

              <div className="grid grid-cols-2 gap-3">
                <label className="block">
                  <span className="text-xs font-medium text-gray-500">Role *</span>
                  <select
                    value={createForm.role}
                    onChange={(e) => setCreateForm({ ...createForm, role: e.target.value })}
                    className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                  >
                    <option value="ADMIN">Admin</option>
                    <option value="OPERATIONS">Operations</option>
                    <option value="FINANCE">Finance</option>
                    <option value="SUPPORT">Support</option>
                    <option value="SAFETY">Safety</option>
                  </select>
                </label>
                <label className="block">
                  <span className="text-xs font-medium text-gray-500">Password *</span>
                  <input
                    type="password"
                    value={createForm.password}
                    onChange={(e) => setCreateForm({ ...createForm, password: e.target.value })}
                    className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="Min. 8 characters"
                    required
                    minLength={8}
                  />
                </label>
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => !creating && setCreateOpen(false)}
                  disabled={creating}
                  className="px-4 py-2 text-sm rounded-md border border-gray-300 text-gray-700 hover:bg-gray-50 disabled:opacity-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={creating}
                  className="px-4 py-2 text-sm rounded-md text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60 flex items-center gap-2"
                >
                  {creating && (
                    <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                  )}
                  {creating ? 'Creating…' : 'Create user'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

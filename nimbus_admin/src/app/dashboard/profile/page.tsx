'use client';

import { useEffect, useState } from 'react';
import { FiUser, FiLock } from 'react-icons/fi';
import { AdminProfile, getProfile, updateProfile, changePassword } from '@/services/profile';
import { formatDateTime, getBadgeClass, getStatusLabel } from '@/lib/utils';
import { useToast, ConfirmDialog } from '@/components/toast';

/**
 * Admin profile page — view and edit the signed-in administrator's own
 * information (name, email) and change their password.
 */
export default function ProfilePage() {
  const [profile, setProfile] = useState<AdminProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { toast } = useToast();

  // Editable info fields
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [savingInfo, setSavingInfo] = useState(false);

  // Password change
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [savingPassword, setSavingPassword] = useState(false);

  useEffect(() => {
    loadProfile();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadProfile = async () => {
    try {
      setLoading(true);
      const p = await getProfile();
      setProfile(p);
      setFirstName(p.firstName ?? '');
      setLastName(p.lastName ?? '');
      setEmail(p.email ?? '');
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load profile');
    } finally {
      setLoading(false);
    }
  };

  const saveInfo = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setSavingInfo(true);
      const updated = await updateProfile({ firstName, lastName, email });
      setProfile(updated);
      toast('success', 'Profile updated', 'Your information has been saved.');
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('error', 'Update failed', (err as any)?.response?.data?.message || 'Failed to update profile');
    } finally {
      setSavingInfo(false);
    }
  };

  const savePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword.length < 8) {
      toast('warning', 'Weak password', 'The new password must be at least 8 characters.');
      return;
    }
    if (newPassword !== confirmPassword) {
      toast('warning', 'Passwords do not match', 'Re-enter the new password in the confirmation field.');
      return;
    }
    try {
      setSavingPassword(true);
      await changePassword({ currentPassword, newPassword });
      toast('success', 'Password changed', 'Use the new password on your next login.');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      toast('error', 'Change failed', (err as any)?.response?.data?.message || 'Failed to change password');
    } finally {
      setSavingPassword(false);
    }
  };

  const name = profile ? `${profile.firstName ?? ''} ${profile.lastName ?? ''}`.trim() : '';
  const initials = name
    ? name.split(' ').filter(Boolean).map((w) => w[0]).slice(0, 2).join('').toUpperCase()
    : 'NA';

  if (loading) {
    return (
      <div className="p-6 max-w-4xl">
        <div className="animate-pulse space-y-4">
          <div className="h-40 bg-gray-200 rounded-xl" />
          <div className="h-64 bg-gray-200 rounded-xl" />
        </div>
      </div>
    );
  }

  if (error || !profile) {
    return (
      <div className="p-6">
        <div className="bg-rose-50 border border-rose-200 text-rose-700 rounded-lg p-4 text-sm">
          {error || 'Profile not found'}
        </div>
        <button
          onClick={loadProfile}
          className="mt-4 px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-4xl">
      {/* Summary card */}
      <div className="bg-white rounded-xl border border-gray-200 p-6 mb-6 flex items-start gap-5">
        <div className="w-16 h-16 rounded-full bg-indigo-600 text-white flex items-center justify-center text-xl font-bold shrink-0">
          {initials}
        </div>
        <div className="flex-1">
          <div className="flex items-center gap-3 flex-wrap">
            <h1 className="text-xl font-bold text-gray-900">{name || 'Admin'}</h1>
            <span className={`status-badge ${getBadgeClass(profile.role)}`}>
              {getStatusLabel(profile.role)}
            </span>
            <span className={`status-badge ${getBadgeClass(profile.status)}`}>
              {getStatusLabel(profile.status)}
            </span>
          </div>
          <p className="text-sm text-gray-500 mt-1">{profile.email ?? 'No email set'}</p>
          <p className="text-sm text-gray-500">{profile.phone}</p>
          <p className="text-xs text-gray-400 mt-2">Member since {formatDateTime(profile.createdAt)}</p>
        </div>
      </div>

      {/* Editable information */}
      <div className="bg-white rounded-xl border border-gray-200 p-6 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <FiUser className="text-indigo-600" />
          <h2 className="font-semibold text-gray-900">Personal information</h2>
        </div>
        <form onSubmit={saveInfo} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">First name</label>
              <input
                type="text"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                maxLength={60}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Last name</label>
              <input
                type="text"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                maxLength={60}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            <p className="text-xs text-gray-400 mt-1">
              Used to sign in to the admin panel. Phone number cannot be changed.
            </p>
          </div>
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={savingInfo}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700 disabled:opacity-60 flex items-center gap-2"
            >
              {savingInfo && (
                <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
              )}
              {savingInfo ? 'Saving…' : 'Save changes'}
            </button>
          </div>
        </form>
      </div>

      {/* Password change */}
      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <div className="flex items-center gap-2 mb-4">
          <FiLock className="text-indigo-600" />
          <h2 className="font-semibold text-gray-900">Change password</h2>
        </div>
        <form onSubmit={savePassword} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Current password</label>
            <input
              type="password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              required
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">New password</label>
              <input
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
                minLength={8}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Confirm new password</label>
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={savingPassword}
              className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700 disabled:opacity-60 flex items-center gap-2"
            >
              {savingPassword && (
                <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
              )}
              {savingPassword ? 'Updating…' : 'Update password'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

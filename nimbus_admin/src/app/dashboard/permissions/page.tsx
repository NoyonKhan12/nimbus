'use client';

import {
  FiLock,
  FiUsers,
  FiCheckCircle,
  FiUserCheck,
  FiTruck,
  FiMap,
  FiCreditCard,
  FiDollarSign,
  FiMessageSquare,
  FiShield,
  FiSliders,
} from 'react-icons/fi';
import type { IconType } from 'react-icons';
import { cn } from '@/lib/utils';

/**
 * Role → capability matrix for the admin portal.
 *
 * ADMIN currently holds every capability (the backend gates /admin/**
 * behind the ADMIN role); the matrix documents the intended per-role
 * access plan so it can be wired into enforcement as role support lands.
 */
const STAFF_ROLES = ['ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT', 'SAFETY'] as const;
type StaffRole = (typeof STAFF_ROLES)[number];

type Access = 'FULL' | 'VIEW' | 'NONE';

interface Capability {
  key: string;
  label: string;
  icon: IconType;
  href: string;
  description: string;
  access: Record<StaffRole, Access>;
}

const CAPABILITIES: Capability[] = [
  {
    key: 'users',
    label: 'Users & staff accounts',
    icon: FiUsers,
    href: '/dashboard/users',
    description: 'Create staff logins, suspend, reinstate, and delete internal accounts.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'NONE', FINANCE: 'VIEW', SUPPORT: 'VIEW', SAFETY: 'NONE',
    },
  },
  {
    key: 'passengers',
    label: 'Passengers',
    icon: FiUserCheck,
    href: '/dashboard/passengers',
    description: 'View passenger accounts, suspend or ban travelers.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'FULL', FINANCE: 'VIEW', SUPPORT: 'VIEW', SAFETY: 'VIEW',
    },
  },
  {
    key: 'drivers',
    label: 'Drivers',
    icon: FiUserCheck,
    href: '/dashboard/drivers',
    description: 'Approve applications, suspend/reinstate, review ratings and earnings.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'FULL', FINANCE: 'VIEW', SUPPORT: 'VIEW', SAFETY: 'VIEW',
    },
  },
  {
    key: 'vehicles',
    label: 'Vehicles',
    icon: FiTruck,
    href: '/dashboard/vehicles',
    description: 'Register vehicles, edit details, verify registrations.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'FULL', FINANCE: 'NONE', SUPPORT: 'VIEW', SAFETY: 'VIEW',
    },
  },
  {
    key: 'rides',
    label: 'Rides',
    icon: FiMap,
    href: '/dashboard/rides',
    description: 'Monitor live and historical rides, trip and fare details.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'FULL', FINANCE: 'VIEW', SUPPORT: 'VIEW', SAFETY: 'VIEW',
    },
  },
  {
    key: 'payments',
    label: 'Payments',
    icon: FiCreditCard,
    href: '/dashboard/payments',
    description: 'Review transactions and issue refunds for failed or disputed fares.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'VIEW', FINANCE: 'FULL', SUPPORT: 'NONE', SAFETY: 'NONE',
    },
  },
  {
    key: 'settlements',
    label: 'Settlements',
    icon: FiDollarSign,
    href: '/dashboard/settlements',
    description: 'Run daily settlement cycles and pay out driver balances.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'VIEW', FINANCE: 'FULL', SUPPORT: 'NONE', SAFETY: 'NONE',
    },
  },
  {
    key: 'complaints',
    label: 'Complaints',
    icon: FiMessageSquare,
    href: '/dashboard/complaints',
    description: 'Triage, investigate, and resolve passenger complaints.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'VIEW', FINANCE: 'NONE', SUPPORT: 'FULL', SAFETY: 'VIEW',
    },
  },
  {
    key: 'safety',
    label: 'Safety events',
    icon: FiShield,
    href: '/dashboard/safety',
    description: 'Triage SOS and emergency events with location and trip context.',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'VIEW', FINANCE: 'NONE', SUPPORT: 'VIEW', SAFETY: 'FULL',
    },
  },
  {
    key: 'config',
    label: 'System configuration',
    icon: FiSliders,
    href: '/dashboard/config',
    description: 'Operational system-wide configuration keys (pricing, rate limits…).',
    access: {
      ADMIN: 'FULL', OPERATIONS: 'NONE', FINANCE: 'NONE', SUPPORT: 'NONE', SAFETY: 'NONE',
    },
  },
];

const ACCESS_LABEL: Record<Access, string> = {
  FULL: 'Full access',
  VIEW: 'View only',
  NONE: 'No access',
};

// Pill styles per access level
const ACCESS_PILL: Record<Access, string> = {
  FULL: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
  VIEW: 'bg-indigo-50 text-indigo-700 border border-indigo-200',
  NONE: 'bg-gray-100 text-gray-400 border border-gray-200',
};

const ROLE_LABEL: Record<StaffRole, string> = {
  ADMIN: 'Admin',
  OPERATIONS: 'Operations',
  FINANCE: 'Finance',
  SUPPORT: 'Support',
  SAFETY: 'Safety',
};

export default function PermissionsPage() {
  return (
    <div className="p-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex justify-between items-center mb-2">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <FiLock className="text-indigo-600 text-xl" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Permissions</h1>
            <p className="text-sm text-gray-500 mt-0.5">
              What each staff role can do across the admin portal.
            </p>
          </div>
        </div>
      </div>

      {/* Enforcement note */}
      <div className="mt-4 mb-5 flex items-start gap-3 bg-indigo-50 border border-indigo-100 rounded-xl p-4">
        <FiCheckCircle className="text-indigo-600 mt-0.5 shrink-0" />
        <p className="text-sm text-indigo-900">
          <span className="font-semibold">Enforcement:</span> API access is currently gated on
          the <span className="font-medium">Admin</span> role — only active Admin accounts can
          sign in and act on portal data. This matrix documents the intended per-role policy
          for each area; as role-scoped endpoints are introduced, this page defines exactly
          what they get.
        </p>
      </div>

      {/* Role summary chips */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3 mb-6">
        {STAFF_ROLES.map((role) => {
          const fullCount = CAPABILITIES.filter((c) => c.access[role] === 'FULL').length;
          const viewCount = CAPABILITIES.filter((c) => c.access[role] === 'VIEW').length;
          return (
            <div key={role} className="bg-white rounded-xl border border-gray-200 p-4">
              <p className={cn('text-xs font-semibold')} style={{ color: 'inherit' }}>
                <span
                  className={cn(
                    'inline-block px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wide',
                    role === 'ADMIN'
                      ? 'bg-indigo-600 text-white'
                      : 'bg-indigo-50 text-indigo-700',
                  )}
                >
                  {ROLE_LABEL[role]}
                </span>
              </p>
              <p className="text-sm text-gray-700 mt-2">
                <span className="font-bold text-emerald-600">{fullCount}</span> full ·{' '}
                <span className="font-bold text-indigo-600">{viewCount}</span> view
              </p>
            </div>
          );
        })}
      </div>

      {/* Matrix */}
      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-5 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wide w-[38%]">
                  Capability
                </th>
                {STAFF_ROLES.map((role) => (
                  <th
                    key={role}
                    className="px-3 py-3 text-center text-xs font-semibold text-gray-500 uppercase tracking-wide"
                  >
                    {ROLE_LABEL[role]}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {CAPABILITIES.map((cap) => {
                const CapIcon = cap.icon;
                return (
                  <tr key={cap.key} className="hover:bg-gray-50 cursor-pointer"
                      onClick={() => { window.location.href = cap.href; }}>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center shrink-0">
                          <CapIcon className="w-4 h-4" />
                        </div>
                        <div className="min-w-0">
                          <p className="text-sm font-medium text-gray-900">{cap.label}</p>
                          <p className="text-xs text-gray-500 truncate">{cap.description}</p>
                        </div>
                      </div>
                    </td>
                    {STAFF_ROLES.map((role) => {
                      const access = cap.access[role];
                      return (
                        <td key={role} className="px-3 py-3 text-center">
                          <span
                            className={cn(
                              'inline-block px-2.5 py-1 rounded-full text-[11px] font-semibold',
                              ACCESS_PILL[access],
                            )}
                            title={ACCESS_LABEL[access]}
                          >
                            {access === 'FULL' ? 'Full' : access === 'VIEW' ? 'View' : '—'}
                          </span>
                        </td>
                      );
                    })}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Access legend */}
      <div className="mt-4 flex flex-wrap items-center gap-4 text-xs text-gray-500">
        <span className="font-medium text-gray-700">Legend:</span>
        <span className="flex items-center gap-1.5">
          <span className={cn('inline-block px-2 py-0.5 rounded-full text-[10px] font-semibold', ACCESS_PILL.FULL)}>Full</span>
          Full access — manage/create/update
        </span>
        <span className="flex items-center gap-1.5">
          <span className={cn('inline-block px-2 py-0.5 rounded-full text-[10px] font-semibold', ACCESS_PILL.VIEW)}>View</span>
          View only — read and inspect
        </span>
        <span className="flex items-center gap-1.5">
          <span className={cn('inline-block px-2 py-0.5 rounded-full text-[10px] font-semibold', ACCESS_PILL.NONE)}>—</span>
          No access
        </span>
      </div>
    </div>
  );
}

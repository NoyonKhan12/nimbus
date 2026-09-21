'use client';

import { ReactNode, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  FiGrid, FiUsers, FiTruck, FiActivity,
  FiCreditCard, FiDollarSign, FiLogOut, FiMenu,
} from 'react-icons/fi';
import { useAuth } from '@/hooks/useAuth';
import { cn } from '@/lib/utils';

interface NavItem {
  label: string;
  href: string;
  icon: ReactNode;
}

/**
 * Sidebar navigation items for the admin dashboard.
 */
const NAV_ITEMS: NavItem[] = [
  {
    label: 'Dashboard',
    href: '/dashboard',
    icon: <FiGrid className="w-5 h-5" />,
  },
  {
    label: 'Users',
    href: '/dashboard/users',
    icon: <FiUsers className="w-5 h-5" />,
  },
  {
    label: 'Drivers',
    href: '/dashboard/drivers',
    icon: <FiTruck className="w-5 h-5" />,
  },
  {
    label: 'Rides',
    href: '/dashboard/rides',
    icon: <FiActivity className="w-5 h-5" />,
  },
  {
    label: 'Payments',
    href: '/dashboard/payments',
    icon: <FiCreditCard className="w-5 h-5" />,
  },
  {
    label: 'Settlements',
    href: '/dashboard/settlements',
    icon: <FiDollarSign className="w-5 h-5" />,
  },
];

/**
 * Layout wrapping admin dashboard pages with sidebar navigation and header.
 */
export default function AdminLayout({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const pathname = usePathname();
  const { logout, isLoading: isLoggingOut } = useAuth();

  const toggleSidebar = () => setCollapsed(!collapsed);

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside
        className={cn(
          'bg-indigo-900 text-white transition-all duration-300 flex flex-col',
          collapsed ? 'w-16' : 'w-64',
        )}
      >
        {/* Header / Logo */}
        <div className="p-4 flex items-center justify-between border-b border-indigo-800">
          {!collapsed && (
            <h1 className="text-xl font-bold">Nimbus Admin</h1>
          )}
          <button
            onClick={toggleSidebar}
            className="p-2 hover:bg-indigo-800 rounded-lg transition-colors"
            title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            <FiMenu className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 py-2">
          {NAV_ITEMS.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 px-4 py-3 hover:bg-indigo-800 transition-colors',
                  isActive && 'bg-indigo-800 text-white',
                  isActive && !collapsed && 'border-l-4 border-indigo-400',
                  collapsed && 'justify-center',
                )}
              >
                {item.icon}
                {!collapsed && <span>{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Logout */}
        <div className="p-4 border-t border-indigo-800">
          <button
            onClick={logout}
            className={cn(
              'flex items-center gap-3 px-4 py-3 hover:bg-indigo-800 rounded-lg transition-colors w-full',
              collapsed && 'justify-center',
            )}
            disabled={isLoggingOut}
          >
            <FiLogOut className="w-5 h-5" />
            {!collapsed && (
              isLoggingOut ? <span>Logging out...</span> : <span>Logout</span>
            )}
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
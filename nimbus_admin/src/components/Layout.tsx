'use client';

import { ReactNode, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  FiHome, FiUsers, FiTruck, FiMap,
  FiCreditCard, FiDollarSign, FiMessageSquare,
  FiShield, FiSliders, FiLogOut, FiMenu,
  FiUserCheck, FiUser, FiSettings, FiLock,
  FiChevronDown, FiChevronRight,
} from 'react-icons/fi';
import { useAuth } from '@/hooks/useAuth';
import { getProfile } from '@/services/profile';
import { getStoredEmail } from '@/services/auth';
import { cn } from '@/lib/utils';

interface NavItem {
  label: string;
  href: string;
  icon: ReactNode;
  /** Sub-items (renders as an expandable group instead of a plain link). */
  children?: NavItem[];
}

/**
 * Sidebar navigation items for the admin dashboard.
 */
const NAV_ITEMS: NavItem[] = [
  {
    label: 'Dashboard',
    href: '/dashboard',
    icon: <FiHome className="w-5 h-5" />,
  },
  {
    label: 'Passengers',
    href: '/dashboard/passengers',
    icon: <FiUser className="w-5 h-5" />,
  },
  {
    label: 'Drivers',
    href: '/dashboard/drivers',
    icon: <FiUserCheck className="w-5 h-5" />,
  },
  {
    label: 'Vehicles',
    href: '/dashboard/vehicles',
    icon: <FiTruck className="w-5 h-5" />,
  },
  {
    label: 'Rides',
    href: '/dashboard/rides',
    icon: <FiMap className="w-5 h-5" />,
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
  {
    label: 'Complaints',
    href: '/dashboard/complaints',
    icon: <FiMessageSquare className="w-5 h-5" />,
  },
  {
    label: 'Safety',
    href: '/dashboard/safety',
    icon: <FiShield className="w-5 h-5" />,
  },
  {
    label: 'Users',
    href: '/dashboard/users',
    icon: <FiUsers className="w-5 h-5" />,
  },
  {
    label: 'Settings',
    href: '/dashboard/config',
    icon: <FiSettings className="w-5 h-5" />,
    children: [
      {
        label: 'Config',
        href: '/dashboard/config',
        icon: <FiSliders className="w-4 h-4" />,
      },
      {
        label: 'Permissions',
        href: '/dashboard/permissions',
        icon: <FiLock className="w-4 h-4" />,
      },
    ],
  },
];

/**
 * Link styles shared between the main nav and the profile link in the
 * footer bar.
 */
const navLinkClass = (isActive: boolean, collapsed: boolean) =>
  cn(
    'flex items-center gap-2.5 px-3 py-[7px] text-[13px] hover:bg-indigo-800 transition-colors',
    isActive && 'bg-indigo-800 text-white',
    isActive && !collapsed && 'border-l-[3px] border-indigo-400',
    collapsed && 'justify-center',
  );

/**
 * Layout wrapping admin dashboard pages with sidebar navigation and header.
 */
export default function AdminLayout({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const pathname = usePathname();
  const { logout, isLoading: isLoggingOut } = useAuth();
  // Admin's own name for the footer bar ("Profile" until loaded).
  const [adminName, setAdminName] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    getProfile()
      .then((p) => {
        if (cancelled) return;
        const name = `${p.firstName ?? ''} ${p.lastName ?? ''}`.trim();
        setAdminName(name || p.email || 'Admin');
      })
      .catch(() => {
        // Not fatal — footer falls back to "Profile".
      });
    return () => { cancelled = true; };
  }, [pathname]);

  // Expandable groups (e.g. Settings) — active ones default to expanded.
  const [openGroups, setOpenGroups] = useState<string[]>([]);
  useEffect(() => {
    const active = NAV_ITEMS.filter(
      (item) => item.children?.some((c) => pathname.startsWith(c.href)),
    ).map((item) => item.label);
    if (active.length > 0) {
      setOpenGroups((prev) => Array.from(new Set([...prev, ...active])));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pathname]);

  const toggleGroup = (label: string) =>
    setOpenGroups((prev) =>
      prev.includes(label) ? prev.filter((l) => l !== label) : [...prev, label],
    );

  const profileActive = pathname === '/dashboard/profile';
  // Stored login email — used for the footer avatar + account name.
  const adminEmail = typeof window !== 'undefined' ? getStoredEmail() : null;
  const avatarLetter = (adminName?.[0] ?? adminEmail?.[0] ?? 'A').toUpperCase();

  const toggleSidebar = () => setCollapsed(!collapsed);

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside
        className={cn(
          'bg-indigo-900 text-white transition-all duration-300 flex flex-col shrink-0 overflow-hidden',
          collapsed ? 'w-[52px]' : 'w-56',
        )}
      >
        {/* Header / Logo */}
        <div className="p-2.5 flex items-center justify-between border-b border-indigo-800">
          {!collapsed && (
            <div className="flex items-center gap-2">
              {/* Brand mark from the Nimbus exact-fidelity asset kit */}
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/nimbus-mark.svg"
                alt="Nimbus mark"
                className="w-7 h-7 rounded-full bg-white/95 p-[3px]"
              />
              <h1 className="text-[15px] font-bold whitespace-nowrap">Nimbus Admin</h1>
            </div>
          )}
          {collapsed && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src="/nimbus-mark.svg"
              alt="Nimbus mark"
              className="w-7 h-7 rounded-full bg-white/95 p-[3px] mx-auto"
            />
          )}
          <button
            onClick={toggleSidebar}
            className="p-2 hover:bg-indigo-800 rounded-lg transition-colors shrink-0"
            title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            <FiMenu className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation — scrolls when the window is short instead of pushing
            the footer bar out of view */}
        <nav className="flex-1 min-h-0 overflow-y-auto py-1.5">
          {NAV_ITEMS.map((item) => {
            // Group item — expandable submenu (e.g. Settings > Config, Permissions)
            if (item.children) {
              const isActive = item.children.some((c) => pathname === c.href);
              if (collapsed) {
                // Collapsed sidebar: jump straight to the first sub-page
                return (
                  <Link
                    key={item.label}
                    href={item.children[0].href}
                    className={navLinkClass(isActive, true)}
                    title={item.label}
                  >
                    <span className="shrink-0">{item.icon}</span>
                  </Link>
                );
              }
              const isOpen = openGroups.includes(item.label);
              return (
                <div key={item.label}>
                  <button
                    onClick={() => toggleGroup(item.label)}
                    className={cn(navLinkClass(isActive, false), 'w-full')}
                    aria-expanded={isOpen}
                  >
                    <span className="shrink-0">{item.icon}</span>
                    <span className="truncate flex-1 text-left">{item.label}</span>
                    {isOpen
                      ? <FiChevronDown className="w-4 h-4 shrink-0 opacity-70" />
                      : <FiChevronRight className="w-4 h-4 shrink-0 opacity-70" />}
                  </button>
                  {isOpen && (
                    <div>
                      {item.children.map((child) => {
                        const childActive = pathname === child.href;
                        return (
                          <Link
                            key={child.href}
                            href={child.href}
                            className={cn(
                              'flex items-center gap-2.5 pl-10 pr-3 py-[6px] text-xs',
                              'hover:bg-indigo-800 transition-colors text-indigo-200',
                              childActive && 'bg-indigo-800 text-white border-l-[3px] border-indigo-400 pl-[37px]',
                            )}
                          >
                            <span className="shrink-0">{child.icon}</span>
                            <span className="truncate">{child.label}</span>
                          </Link>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            }

            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={navLinkClass(isActive, collapsed)}
                title={collapsed ? item.label : undefined}
              >
                <span className="shrink-0">{item.icon}</span>
                {!collapsed && <span className="truncate">{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Footer bar — account (profile) + logout, pinned to the bottom */}
        <div className="border-t border-indigo-800">
          <Link
            href="/dashboard/profile"
            className={cn('flex items-center gap-2.5 px-3 py-2 hover:bg-indigo-800 transition-colors',
              'text-[13px]', profileActive && 'bg-indigo-800')}
            title={collapsed ? 'Profile' : undefined}
          >
            <span className="w-7 h-7 rounded-full bg-white/95 text-indigo-900 text-sm font-bold flex items-center justify-center shrink-0">
              {avatarLetter}
            </span>
            {!collapsed && (
              <span className="min-w-0 flex-1">
                <span className="block text-sm font-medium truncate">{adminName ?? 'Profile'}</span>
                <span className="block text-xs text-indigo-300 truncate">{adminEmail ?? 'Signed in'}</span>
              </span>
            )}
          </Link>
          <button
            onClick={logout}
            className={cn(
              'flex items-center gap-2.5 px-3 py-2.5 text-[13px] hover:bg-indigo-800 transition-colors w-full',
              collapsed && 'justify-center',
            )}
            disabled={isLoggingOut}
          >
            <FiLogOut className="w-4 h-4 shrink-0" />
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

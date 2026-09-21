'use client';

import { useEffect, useState } from 'react';
import { FiUsers, FiTrendingUp, FiRefreshCw, FiClock, FiCalendar, FiMapPin } from 'react-icons/fi';
import { DashboardStats, RecentRide } from '@/types';
import { getDashboardStats } from '@/services/dashboard';
import { formatCurrency, formatDate } from '@/lib/utils';

/**
 * Dashboard overview page with key statistics.
 */
export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const data = await getDashboardStats();
      setStats(data);
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to load dashboard stats');
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    { label: 'Total Users', value: stats?.totalUsers?.toString() ?? '0', icon: <FiUsers className="text-indigo-600" />, bg: 'bg-indigo-50' },
    { label: 'Total Drivers', value: stats?.totalDrivers?.toString() ?? '0', icon: <FiUsers className="text-purple-600" />, bg: 'bg-purple-50' },
    { label: 'Active Rides', value: stats?.activeRides?.toString() ?? '0', icon: <FiTrendingUp className="text-green-600" />, bg: 'bg-green-50' },
    { label: 'Total Rides', value: stats?.totalRides?.toString() ?? '0', icon: <FiCalendar className="text-blue-600" />, bg: 'bg-blue-50' },
    {
      label: 'Total Revenue',
      value: formatCurrency(stats?.totalRevenue ? parseFloat(stats.totalRevenue) : 0),
      icon: <FiTrendingUp className="text-emerald-600" />,
      bg: 'bg-emerald-50',
    },
    { label: 'Completed Payments', value: stats?.totalPayments?.toString() ?? '0', icon: <FiTrendingUp className="text-amber-600" />, bg: 'bg-amber-50' },
    {
      label: 'Pending Settlements',
      value: stats?.pendingSettlements?.toString() ?? '0',
      icon: <FiClock className="text-rose-600" />,
      bg: 'bg-rose-50',
    },
  ];

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <FiTrendingUp className="text-indigo-600 text-xl" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        </div>
        <button
          onClick={loadData}
          className="px-4 py-2 bg-indigo-100 text-indigo-700 rounded-lg hover:bg-indigo-200 transition-colors flex items-center gap-2"
        >
          <FiRefreshCw className="text-sm" />
          Refresh
        </button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-rose-50 text-rose-700 rounded-lg">
          {error}
        </div>
      )}

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {[...Array(7)].map((_, i) => (
            <div
              key={i}
              className="bg-white rounded-xl shadow p-4 h-24 animate-pulse"
            >
              <div className="h-4 bg-gray-200 rounded w-2/3 mb-2"></div>
              <div className="h-6 bg-gray-200 rounded w-1/3"></div>
            </div>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {statCards.map((card) => (
            <div
              key={card.label}
              className="bg-white rounded-xl shadow p-4 hover:shadow-md transition-shadow"
            >
              <div className="flex items-center gap-3">
                <div className={`p-2 rounded-lg ${card.bg}`}>
                  {card.icon}
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">
                    {card.label}
                  </p>
                  <p className="text-2xl font-bold text-gray-900 mt-1">
                    {card.value}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="bg-white rounded-xl shadow">
        <div className="p-4 border-b flex items-center gap-2">
          <FiClock className="text-gray-600" />
          <h2 className="text-lg font-semibold text-gray-900">
            Recent Rides
          </h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 text-left">
                <th className="px-4 py-2 text-xs font-medium text-gray-500">
                  Ride ID
                </th>
                <th className="px-4 py-2 text-xs font-medium text-gray-500">
                  Pickup
                </th>
                <th className="px-4 py-2 text-xs font-medium text-gray-500">
                  Dropoff
                </th>
                <th className="px-4 py-2 text-xs font-medium text-gray-500">
                  Status
                </th>
                <th className="px-4 py-2 text-xs font-medium text-gray-500">
                  Date
                </th>
              </tr>
            </thead>
            <tbody>
              {(stats?.recentRides ?? []).map((ride: RecentRide) => (
                <tr
                  key={ride.id}
                  className="border-b hover:bg-gray-50"
                >
                  <td className="px-4 py-3 text-sm text-gray-700">
                    {ride.id.slice(0, 8)}
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-700 flex items-center gap-1">
                    <FiMapPin className="text-gray-400 text-xs" />
                    {ride.originAddress ?? '-'}
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-700 flex items-center gap-1">
                    <FiMapPin className="text-gray-400 text-xs" />
                    {ride.destinationAddress ?? '-'}
                  </td>
                  <td className="px-4 py-3 text-sm">
                    <span
                      className={`status-badge ${
                        ride.status === 'COMPLETED'
                          ? 'status-completed'
                          : ride.status === 'CANCELLED'
                            ? 'status-cancelled'
                            : ride.status === 'ACTIVE'
                              ? 'status-active'
                              : 'status-pending'
                      }`}
                    >
                      {ride.status ?? '-'}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-500">
                    {formatDate(ride.createdAt)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {(stats?.recentRides?.length ?? 0) === 0 && !loading && (
            <p className="text-center py-4 text-gray-500">
              No recent rides found
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
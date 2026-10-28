'use client';

import { useEffect, ReactNode, useState } from 'react';
import Link from 'next/link';
import {
  FiArrowLeft, FiAlertCircle, FiRefreshCw, FiCreditCard, FiUser, FiTruck,
  FiMap, FiShield, FiFileText, FiPhone, FiMail, FiHeart, FiClock, FiHome,
  FiDollarSign, FiUsers, FiAlertTriangle, FiCheckCircle, FiBriefcase,
  FiMessageSquare, FiNavigation,
} from 'react-icons/fi';
import {
  UserDetail as UserInfo, getUserDetail,
  DriverDetail as DriverInfo, getDriverDetail,
  VehicleDetail as VehicleInfo, getVehicleDetail,
  RideDetail as RideInfo, getRideDetail, DocumentRow,
  PaymentDetail as PaymentInfo, getPaymentDetail,
  SettlementDetail as SettlementInfo, getSettlementDetail,
  ComplaintDetail as ComplaintInfo, getComplaintDetail,
  SafetyDetail as SafetyInfo, getSafetyDetail,
} from '@/services/details';
import { formatCurrency, formatDate, formatDateTime, getBadgeClass, getStatusLabel } from '@/lib/utils';

// ── Shell primitives ────────────────────────────────────────────────────

function LoadingState() {
  return (
    <div className="p-6 max-w-5xl animate-pulse space-y-4">
      <div className="h-8 bg-gray-200 rounded w-40" />
      <div className="h-28 bg-gray-200 rounded-xl" />
      <div className="h-40 bg-gray-200 rounded-xl" />
      <div className="h-56 bg-gray-200 rounded-xl" />
    </div>
  );
}

function ErrorState({ error, onRetry }: { error: string; onRetry: () => void }) {
  return (
    <div className="p-6 max-w-5xl">
      <div className="bg-rose-50 border border-rose-200 text-rose-700 rounded-lg p-4 text-sm flex items-center gap-2">
        <FiAlertCircle />
        {error}
      </div>
      <button
        onClick={onRetry}
        className="mt-4 px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm hover:bg-indigo-700 flex items-center gap-2"
      >
        <FiRefreshCw />
        Retry
      </button>
    </div>
  );
}

/** Pill (same style as the tables). */
export function Pill({ value, className = '' }: { value: string; className?: string }) {
  if (!value) return null;
  return (
    <span className={`status-badge ${getBadgeClass(value)} ${className}`}>
      {getStatusLabel(value)}
    </span>
  );
}

/** Simple label/value pair. */
export function Field({ label, value, mono = false }: { label: string; value: ReactNode; mono?: boolean }) {
  return (
    <div className="min-w-0">
      <dt className="text-xs font-medium text-gray-400 uppercase tracking-wide">{label}</dt>
      <dd className={`text-sm text-gray-800 mt-0.5 break-words ${mono ? 'font-mono' : ''}`}>{value ?? '-'}</dd>
    </div>
  );
}

/** Carded section with heading. */
export function Section({
  title, icon, children, className = '',
}: { title: string; icon?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <div className={`bg-white rounded-xl border border-gray-200 p-5 ${className}`}>
      <div className="flex items-center gap-2 mb-4">
        {icon && <span className="text-indigo-600">{icon}</span>}
        <h2 className="text-sm font-semibold text-gray-900">{title}</h2>
      </div>
      {children}
    </div>
  );
}

/** Fact grid for Field groups. */
export function FactGrid({ children, cols = 3, className = '' }: { children: ReactNode; cols?: 2 | 3 | 4; className?: string }) {
  const map = { 2: 'sm:grid-cols-2', 3: 'sm:grid-cols-2 lg:grid-cols-3', 4: 'sm:grid-cols-2 lg:grid-cols-4' } as const;
  return <dl className={`grid grid-cols-1 gap-4 ${map[cols]} ${className}`}>{children}</dl>;
}

/**
 * Common page chrome for every detail route: back link, title, status pills
 * and the loading / error / content states.
 */
export function DetailShell({
  title, pills, backHref, backLabel, children, loading, error, onRetry,
}: {
  title: string;
  pills?: string[];
  backHref: string;
  backLabel: string;
  children: ReactNode;
  loading: boolean;
  error: string | null;
  onRetry: () => void;
}) {
  if (loading) return <LoadingState />;
  if (error) return <ErrorState error={error} onRetry={onRetry} />;
  return (
    <div className="p-6 max-w-5xl">
      <div className="flex items-center justify-between mb-5">
        <Link
          href={backHref}
          className="text-sm text-gray-500 hover:text-indigo-600 flex items-center gap-1.5"
        >
          <FiArrowLeft className="w-4 h-4" /> {backLabel}
        </Link>
        {pills && pills.filter(Boolean).length > 0 && (
          <div className="flex gap-2">
            {pills.filter(Boolean).map((p) => <Pill key={p} value={p} />)}
          </div>
        )}
      </div>
      <h1 className="text-xl font-bold text-gray-900 mb-4 truncate">{title}</h1>
      <div className="space-y-5">{children}</div>
    </div>
  );
}

/** Documents table (driver + vehicle). */
export function DocumentsTable({ documents }: { documents: DocumentRow[] }) {
  if (!documents || documents.length === 0) {
    return <p className="text-sm text-gray-500">No documents on file.</p>;
  }
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b text-left text-xs text-gray-500">
            <th className="py-2 pr-4">Type</th>
            <th className="py-2 pr-4">Number</th>
            <th className="py-2 pr-4">Status</th>
            <th className="py-2 pr-4">Verified</th>
            <th className="py-2 pr-4">Expires</th>
            <th className="py-2">File</th>
          </tr>
        </thead>
        <tbody>
          {documents.map((d, i) => (
            <tr key={i} className="border-b last:border-0 text-gray-700">
              <td className="py-2 pr-4"><Pill value={d.documentType} /></td>
              <td className="py-2 pr-4 font-mono text-xs">{d.documentNumber ?? '-'}</td>
              <td className="py-2 pr-4"><Pill value={d.status} /></td>
              <td className="py-2 pr-4">
                {d.verified ? (
                  <FiCheckCircle className="text-emerald-600" title="Verified" />
                ) : (
                  <FiAlertTriangle className="text-amber-500" title="Unverified" />
                )}
              </td>
              <td className="py-2 pr-4 text-gray-500">{d.expiresAt ? formatDateTime(d.expiresAt) : 'No expiry'}</td>
              <td className="py-2">
                {d.documentUrl ? (
                  <a href={d.documentUrl} target="_blank" rel="noreferrer"
                    className="text-indigo-600 hover:text-indigo-800 flex items-center gap-1">
                    <FiFileText className="w-4 h-4" /> View
                  </a>
                ) : '-'}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/** Small reusable "not available" text. */
export function None({ label = 'None recorded' }: { label?: string }) {
  return <p className="text-sm text-gray-500">{label}</p>;
}

// ── User detail (Users & Passengers pages link here) ────────────────────

export function UserDetailView({ id, carrier = 'users' }: { id: string; carrier?: 'users' | 'passengers' }) {
  const [user, setUser] = useState<UserInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setUser(await getUserDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load user');
    } finally {
      setLoading(false);
    }
  };

  const fullName = user
    ? `${user.profile?.firstName ?? ''} ${user.profile?.lastName ?? ''}`.trim()
    : '';
  const initials = fullName
    ? fullName.split(' ').filter(Boolean).map((w) => w[0]).slice(0, 2).join('').toUpperCase()
    : (user?.phone ?? 'NA').slice(-2).toUpperCase();

  return (
    <DetailShell
      title={fullName || 'User'}
      pills={user ? [user.role, user.status] : []}
      backHref={`/dashboard/${carrier}`}
      backLabel={`Back to ${carrier === 'passengers' ? 'passengers' : 'users'}`}
      loading={loading}
      error={error}
      onRetry={load}
    >
      <div className="bg-white rounded-xl border border-gray-200 p-5 flex items-center gap-4">
        <div className="w-14 h-14 rounded-full bg-indigo-600 text-white flex items-center justify-center text-lg font-bold shrink-0">
          {initials}
        </div>
        <div className="min-w-0">
          <p className="text-sm text-gray-800 font-medium truncate">{user?.phone ?? '-'}</p>
          <p className="text-sm text-gray-500 truncate">{user?.email ?? 'No email on file'}</p>
          <p className="text-xs text-gray-400 mt-1">
            Joined {user ? formatDateTime(user.createdAt) : ''}
            {user?.phoneVerified ? ' · phone verified' : ' · phone NOT verified'}
            {user?.deviceCount ? ` · ${user.deviceCount} device${user.deviceCount === 1 ? '' : 's'}` : ''}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Profile" icon={<FiUser />} >
          <FactGrid cols={2}>
            <Field label="First name" value={user?.profile?.firstName ?? '-'} />
            <Field label="Last name" value={user?.profile?.lastName ?? '-'} />
            <Field label="Gender" value={user?.profile?.gender ? getStatusLabel(user.profile.gender) : '-'} />
            <Field
              label="Emergency contact"
              value={
                user?.profile?.emergencyContactName
                  ? `${user.profile.emergencyContactName}${user.profile.emergencyContactPhone ? ` (${user.profile.emergencyContactPhone})` : ''}`
                  : '-'
              }
            />
          </FactGrid>
        </Section>

        <Section title="Wallet" icon={<FiCreditCard />}>
          {user?.wallet ? (
            <FactGrid cols={2}>
              <Field label="Balance" value={
                <span className="text-lg font-semibold text-gray-900">
                  {formatCurrency(user.wallet.balance)} {user.wallet.currency}
                </span>
              } />
              <Field label="Wallet type" value={getStatusLabel(user.wallet.ownerType)} />
            </FactGrid>
          ) : (
            <None label="No wallet has been opened for this user." />
          )}
        </Section>
      </div>

      <Section title="Account" icon={<FiShield />}>
        <FactGrid>
          <Field label="User ID" value={user?.id} mono />
          <Field label="Status" value={<Pill value={user?.status ?? ''} />} />
          <Field label="Role" value={<Pill value={user?.role ?? ''} />} />
          <Field label="Created" value={user ? formatDateTime(user.createdAt) : '-'} />
        </FactGrid>
      </Section>
    </DetailShell>
  );
}

// ── Driver detail ───────────────────────────────────────────────────────

export function DriverDetailView({ id }: { id: string }) {
  const [driver, setDriver] = useState<DriverInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setDriver(await getDriverDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load driver');
    } finally {
      setLoading(false);
    }
  };

  const fullName = driver
    ? `${driver.profile?.firstName ?? ''} ${driver.profile?.lastName ?? ''}`.trim()
    : '';

  return (
    <DetailShell
      title={fullName || `Driver ${id.slice(0, 8)}`}
      pills={driver ? [driver.driverStatus, driver.approvalStatus] : []}
      backHref="/dashboard/drivers"
      backLabel="Back to drivers"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Rating', value: driver?.rating != null ? driver.rating.toFixed(1) : '-', icon: <FiUsers /> },
          { label: 'Total rides', value: driver?.totalRides ?? 0, icon: <FiMap /> },
          { label: 'Earnings', value: formatCurrency(driver?.totalEarnings ?? 0), icon: <FiDollarSign /> },
          { label: 'Cash due', value: formatCurrency(driver?.dueAmount ?? 0), icon: <FiCreditCard /> },
        ].map((s) => (
          <div key={s.label} className="bg-white rounded-xl border border-gray-200 p-4">
            <div className="text-indigo-600 mb-1">{s.icon}</div>
            <p className="text-lg font-bold text-gray-900">{s.value}</p>
            <p className="text-xs text-gray-500">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Contact & profile" icon={<FiUser />}>
          <FactGrid cols={2}>
            <Field label="Phone" value={driver?.phone ?? '-'} />
            <Field label="Email" value={driver?.email ?? '-'} />
            <Field label="Reliability score" value={driver?.reliabilityScore != null ? `${(driver.reliabilityScore * 100).toFixed(0)}%` : '-'} />
            <Field label="Commission rate" value={
              driver?.commissionRate != null
                ? `${(Number(driver.commissionRate) * 100).toFixed(0)}%`
                : 'Default'
            } />
          </FactGrid>
        </Section>

        <Section title="License" icon={<FiShield />}>
          <FactGrid cols={2}>
            <Field label="License number" value={driver?.licenseNumber ?? 'Not provided'} mono />
            <Field
              label="License expiry"
              value={
                driver?.licenseExpiry ? (
                  <span className="flex items-center gap-2">
                    {formatDateTime(driver.licenseExpiry)}
                    <Pill value={new Date(driver.licenseExpiry) > new Date() ? 'COMPLETED' : 'FAILED'} />
                  </span>
                ) : 'No expiry recorded'
              }
            />
          </FactGrid>
          <div className="mt-4">
            <Field
              label="Last known location"
              value={
                driver?.currentLocation
                  ? driver.currentLocation
                  : 'Never shared'
              }
              mono
            />
            {driver?.currentLocationUpdatedAt && (
              <p className="text-xs text-gray-400 mt-1">As of {formatDateTime(driver.currentLocationUpdatedAt)}</p>
            )}
          </div>
        </Section>
      </div>

      <Section title={`Vehicles (${driver?.vehicles?.length ?? 0})`} icon={<FiTruck />}>
        {driver?.vehicles?.length ? (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-xs text-gray-500">
                  <th className="py-2 pr-4">Registration</th>
                  <th className="py-2 pr-4">Type</th>
                  <th className="py-2 pr-4">Model</th>
                  <th className="py-2 pr-4">Year</th>
                  <th className="py-2 pr-4">Seats</th>
                  <th className="py-2">Status</th>
                </tr>
              </thead>
              <tbody>
                {driver.vehicles.map((v) => (
                  <tr key={v.id} className="border-b last:border-0 text-gray-700">
                    <td className="py-2 pr-4 font-medium">
                      <Link href={`/dashboard/vehicles/${v.id}`} className="text-indigo-600 hover:text-indigo-800">
                        {v.registrationNumber}
                      </Link>
                    </td>
                    <td className="py-2 pr-4"><Pill value={v.type} /></td>
                    <td className="py-2 pr-4">{v.model}</td>
                    <td className="py-2 pr-4">{v.year}</td>
                    <td className="py-2 pr-4">{v.seatCapacity}</td>
                    <td className="py-2"><Pill value={v.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <None label="No vehicles registered to this driver." />
        )}
      </Section>

      <Section title="Documents" icon={<FiFileText />}>
        <DocumentsTable documents={driver?.documents ?? []} />
      </Section>
    </DetailShell>
  );
}

// ── Vehicle detail ──────────────────────────────────────────────────────

export function VehicleDetailView({ id }: { id: string }) {
  const [vehicle, setVehicle] = useState<VehicleInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setVehicle(await getVehicleDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load vehicle');
    } finally {
      setLoading(false);
    }
  };

  return (
    <DetailShell
      title={vehicle ? `${vehicle.registrationNumber} · ${vehicle.model ?? ''}` : ''}
      pills={vehicle ? [vehicle.status] : []}
      backHref="/dashboard/vehicles"
      backLabel="Back to vehicles"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-xl bg-indigo-100 text-indigo-700 flex items-center justify-center shrink-0">
            <FiTruck className="w-6 h-6" />
          </div>
          <div className="min-w-0">
            <p className="text-lg font-semibold text-gray-900">{vehicle?.registrationNumber}</p>
            <p className="text-sm text-gray-500">
              {vehicle?.model ?? '-'} {vehicle?.year ?? ''} · {vehicle?.color ?? '-'}
            </p>
            <p className="text-xs text-gray-400 mt-1">Registered {vehicle ? formatDateTime(vehicle.createdAt) : ''}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Specifications" icon={<FiTruck />}>
          <FactGrid cols={2}>
            <Field label="Vehicle type" value={<Pill value={vehicle?.type ?? ''} />} />
            <Field label="Seat capacity" value={vehicle?.seatCapacity ?? '-'} />
            <Field label="Color" value={vehicle?.color ?? '-'} />
            <Field label="Model year" value={vehicle?.year ?? '-'} />
          </FactGrid>
        </Section>

        <Section title="Owner (driver)" icon={<FiUser />}>
          {vehicle?.driverId ? (
            <FactGrid cols={2}>
              <Field label="Driver name" value={vehicle.driverName ?? 'Not available'} />
              <Field label="Driver phone" value={vehicle.driverPhone ?? '-'} />
              <Field label="Driver ID" value={
                <Link href={`/dashboard/drivers/${vehicle.driverId}`}
                  className="text-indigo-600 hover:text-indigo-800 font-mono text-xs">
                  {vehicle.driverId.slice(0, 8)}…
                </Link>
              } mono />
            </FactGrid>
          ) : (
            <None label="Vehicle is not assigned to any driver." />
          )}
        </Section>
      </div>

      <Section title="Documents" icon={<FiFileText />}>
        <DocumentsTable documents={vehicle?.documents ?? []} />
      </Section>
    </DetailShell>
  );
}

// ── Ride detail ─────────────────────────────────────────────────────────

export function RideDetailView({ id, backLabel = 'Back to rides', backHref = '/dashboard/rides' }: {
  id: string;
  backLabel?: string;
  backHref?: string;
}) {
  const [ride, setRide] = useState<RideInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setRide(await getRideDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load ride');
    } finally {
      setLoading(false);
    }
  };

  const timeline = ride ? [
    { label: 'Scheduled', value: ride.scheduledAt ? formatDateTime(ride.scheduledAt) : 'Not scheduled (instant)' },
    { label: 'Started', value: ride.actualStartAt ? formatDateTime(ride.actualStartAt) : '-' },
    { label: 'Ended', value: ride.actualEndAt ? formatDateTime(ride.actualEndAt) : '-' },
  ] : [];

  return (
    <DetailShell
      title={ride ? `${getStatusLabel(ride.type)} ride — ${ride.originAddress ?? ''} → ${ride.destinationAddress ?? ''}` : ''}
      pills={ride ? [ride.type, ride.status] : []}
      backHref={backHref}
      backLabel={backLabel}
      loading={loading}
      error={error}
      onRetry={load}
    >
      {/* Route */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="space-y-4">
          <div className="flex items-start gap-3">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 mt-1.5 shrink-0" />
            <div className="min-w-0">
              <p className="text-xs text-gray-400 uppercase tracking-wide">Pickup</p>
              <p className="text-sm text-gray-800">{ride?.originAddress ?? '-'}</p>
            </div>
          </div>
          <div className="border-l-2 border-dashed border-gray-200 ml-1 h-4" />
          <div className="flex items-start gap-3">
            <span className="w-2.5 h-2.5 rounded-full bg-rose-500 mt-1.5 shrink-0" />
            <div className="min-w-0">
              <p className="text-xs text-gray-400 uppercase tracking-wide">Drop-off</p>
              <p className="text-sm text-gray-800">{ride?.destinationAddress ?? '-'}</p>
            </div>
          </div>
        </div>
        {ride?.notes && (
          <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-3 mt-4">
            <FiFileText className="inline mr-1.5 -mt-0.5" /> {ride.notes}
          </p>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Timing" icon={<FiClock />}>
          <FactGrid cols={3} >{timeline.map((t) => <Field key={t.label} label={t.label} value={t.value} />)}</FactGrid>
        </Section>

        <Section title="People & vehicle" icon={<FiUsers />}>
          <FactGrid cols={2}>
            <Field label="Driver" value={
              ride?.driverId ? (
                <Link href={`/dashboard/drivers/${ride.driverId}`} className="text-indigo-600 hover:text-indigo-800">
                  {ride.driverName ?? 'Driver profile'} {ride.driverPhone ? `· ${ride.driverPhone}` : ''}
                </Link>
              ) : 'Not assigned'
            } />
            <Field label="Created by (ride creator)" value={
              ride?.creatorId ? (
                <Link href={`/dashboard/users/${ride.creatorId}`} className="text-indigo-600 hover:text-indigo-800">
                  {ride.creatorName ?? 'User'} {ride.creatorPhone ? `· ${ride.creatorPhone}` : ''}
                </Link>
              ) : '-'
            } />
            <Field label="Vehicle" value={ride?.vehicleRegistration ?? 'Not assigned'} />
            <Field label="Seats offered" value={ride?.availableSeats ?? '-'} />
          </FactGrid>
        </Section>
      </div>

      {/* Bookings */}
      <Section title={`Bookings (${ride?.bookings?.length ?? 0})`} icon={<FiCheckCircle />}>
        {ride?.bookings?.length ? (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-xs text-gray-500">
                  <th className="py-2 pr-4">Pickup</th>
                  <th className="py-2 pr-4">Drop-off</th>
                  <th className="py-2 pr-4">Seats</th>
                  <th className="py-2 pr-4">Status</th>
                  <th className="py-2">Fare</th>
                </tr>
              </thead>
              <tbody>
                {ride.bookings.map((b) => (
                  <tr key={b.id} className="border-b last:border-0 text-gray-700">
                    <td className="py-2 pr-4 max-w-[180px] truncate" title={b.pickupAddress}>{b.pickupAddress ?? '-'}</td>
                    <td className="py-2 pr-4 max-w-[180px] truncate" title={b.dropoffAddress}>{b.dropoffAddress ?? '-'}</td>
                    <td className="py-2 pr-4">{b.seats}</td>
                    <td className="py-2 pr-4"><Pill value={b.status} /></td>
                    <td className="py-2 font-medium">{b.finalPayable != null ? formatCurrency(b.finalPayable) : '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <None label="No bookings on this ride yet." />
        )}
      </Section>

      {/* Passengers + payment */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title={`Passengers on board (${ride?.passengers?.length ?? 0})`} icon={<FiUsers />}>
          {ride?.passengers?.length ? (
            <ul className="space-y-3">
              {ride.passengers.map((p) => (
                <li key={p.id} className="flex items-center gap-3 text-sm border-b last:border-0 pb-3 last:pb-0">
                  <div className="w-8 h-8 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center text-xs font-bold shrink-0">
                    {(p.passengerName ?? '??').slice(0, 2).toUpperCase()}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-gray-800 truncate">
                      {p.passengerId ? (
                        <Link href={`/dashboard/users/${p.passengerId}`} className="text-indigo-600 hover:text-indigo-800">
                          {p.passengerName ?? 'Passenger'}
                        </Link>
                      ) : (
                        p.passengerName ?? 'Passenger'
                      )}
                    </p>
                    <p className="text-xs text-gray-500">{p.passengerPhone ?? '-'} · {p.seats} seat(s)</p>
                  </div>
                  <Pill value={p.journeyStatus} />
                </li>
              ))}
            </ul>
          ) : (
            <None label="No live passenger records (bookings only)." />
          )}
        </Section>

        <Section title="Payment" icon={<FiCreditCard />}>
          {ride?.payment ? (
            <FactGrid cols={2}>
              <Field label="Amount" value={
                <span className="text-lg font-semibold text-gray-900">{formatCurrency(ride.payment.amount)}</span>
              } />
              <Field label="Method" value={<Pill value={ride.payment.method} />} />
              <Field label="Status" value={<Pill value={ride.payment.status} />} />
              <Field label="Provider ref." value={ride.payment.providerReference ?? '-'} mono />
              <Field label="Paid at" value={formatDateTime(ride.payment.createdAt)} />
            </FactGrid>
          ) : (
            <None label="No payment recorded for this ride." />
          )}
        </Section>
      </div>
    </DetailShell>
  );
}

// ── Payment detail ──────────────────────────────────────────────────────

export function PaymentDetailView({ id }: { id: string }) {
  const [payment, setPayment] = useState<PaymentInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setPayment(await getPaymentDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load payment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <DetailShell
      title={payment ? `Payment ${payment.id.slice(0, 8)} — ${formatCurrency(payment.amount)}` : ''}
      pills={payment ? [payment.method, payment.status] : []}
      backHref="/dashboard/payments"
      backLabel="Back to payments"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <div className="bg-white rounded-xl border border-gray-200 p-5 flex items-center gap-4">
        <div className="w-14 h-14 rounded-xl bg-indigo-100 text-indigo-700 flex items-center justify-center shrink-0">
          <FiCreditCard className="w-6 h-6" />
        </div>
        <div>
          <p className="text-2xl font-bold text-gray-900">{formatCurrency(payment?.amount ?? 0)}</p>
          <p className="text-sm text-gray-500">
            {getStatusLabel(payment?.method ?? '')} · {payment ? formatDateTime(payment.createdAt) : ''}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Payer" icon={<FiUser />}>
          <FactGrid cols={2}>
            <Field label="Passenger" value={
              payment?.payerId ? (
                <Link href={`/dashboard/users/${payment.payerId}`} className="text-indigo-600 hover:text-indigo-800">
                  {payment.payerName ?? 'User'}{payment.payerPhone ? ` · ${payment.payerPhone}` : ''}
                </Link>
              ) : 'Payer profile unavailable'
            } />
            <Field label="Payment status" value={<Pill value={payment?.status ?? ''} />} />
            <Field label="Method" value={<Pill value={payment?.method ?? ''} />} />
            <Field label="Updated" value={payment ? formatDateTime(payment.updatedAt) : '-'} />
          </FactGrid>
        </Section>

        <Section title="Trip context" icon={<FiMap />}>
          <FactGrid cols={2}>
            <Field label="Booking" value={payment?.bookingId ? (
              payment.rideId ? (
                <Link href={`/dashboard/rides/${payment.rideId}`} className="text-indigo-600 hover:text-indigo-800 font-mono text-xs">
                  {payment.bookingId.slice(0, 8)}… (ride)
                </Link>
              ) : payment.bookingId.slice(0, 8) + '…'
            ) : '-'} mono />
            <Field label="Pickup" value={payment?.pickupAddress ?? '-'} />
            <Field label="Drop-off" value={payment?.dropoffAddress ?? '-'} />
          </FactGrid>
        </Section>
      </div>

      <Section title="Provider data" icon={<FiBriefcase />}>
        <FactGrid cols={2}>
          <Field label="Provider reference" value={payment?.providerReference ?? '-'} mono />
          <Field label="Idempotency key" value={payment?.idempotencyKey ?? '-'} mono />
        </FactGrid>
      </Section>
    </DetailShell>
  );
}

// ── Settlement detail ───────────────────────────────────────────────────

export function SettlementDetailView({ id }: { id: string }) {
  const [settlement, setSettlement] = useState<SettlementInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setSettlement(await getSettlementDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load settlement');
    } finally {
      setLoading(false);
    }
  };

  if (settlement) {
    const rows = [
      { label: 'Gross earnings', value: settlement.grossEarnings, emphasis: false },
      { label: 'Platform commission', value: -settlement.commission, emphasis: false },
      { label: 'Adjustments', value: settlement.adjustments, emphasis: false },
      { label: 'Refunds', value: -settlement.refunds, emphasis: false },
      { label: 'Driver credits', value: settlement.driverCredits, emphasis: false },
    ];
    const payable = (
      <div className="mt-3 pt-3 border-t flex items-center justify-between">
        <span className="text-sm font-semibold text-gray-900">Net payable</span>
        <span className="text-lg font-bold text-indigo-700">{formatCurrency(settlement.payable)}</span>
      </div>
    );
    return (
      <DetailShell
        title={`Settlement ${settlement.periodStart ? formatDate(settlement.periodStart) : ''} → ${settlement.periodEnd ? formatDate(settlement.periodEnd) : ''}`}
        pills={[settlement.status]}
        backHref="/dashboard/settlements"
        backLabel="Back to settlements"
        loading={loading}
        error={error}
        onRetry={load}
      >
        <div className="bg-white rounded-xl border border-gray-200 p-5 flex items-center gap-4">
          <div className="w-14 h-14 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
            <FiDollarSign className="w-6 h-6" />
          </div>
          <div className="min-w-0">
            <p className="text-lg font-semibold text-gray-900">{formatCurrency(settlement.payable)}</p>
            <p className="text-sm text-gray-500 truncate">
              Driver:{' '}
              {settlement.driverId ? (
                <Link href={`/dashboard/drivers/${settlement.driverId}`} className="text-indigo-600 hover:text-indigo-800">
                  {settlement.driverName ?? 'Driver profile'}
                </Link>
              ) : 'unassigned'}
              {settlement.driverPhone ? ` · ${settlement.driverPhone}` : ''}
            </p>
            <p className="text-xs text-gray-400 mt-0.5">
              Ref {settlement.paymentReference ?? '—'} · Created {formatDateTime(settlement.createdAt)}
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <Section title="Period breakdown" icon={<FiBriefcase />}>
            <dl className="text-sm">
              {rows.map((r) => (
                <div key={r.label} className="flex items-center justify-between py-1.5 border-b last:border-0 border-gray-100">
                  <dt className="text-gray-600">{r.label}</dt>
                  <dd className={r.value < 0 ? 'text-rose-600 font-medium' : 'text-gray-800 font-medium'}>
                    {r.value < 0 ? `-${formatCurrency(Math.abs(r.value))}` : formatCurrency(r.value)}
                  </dd>
                </div>
              ))}
              {payable}
            </dl>
          </Section>

          <Section title="Timing" icon={<FiClock />}>
            <FactGrid cols={2}>
              <Field label="Period start" value={formatDate(settlement.periodStart)} />
              <Field label="Period end" value={formatDate(settlement.periodEnd)} />
              <Field label="Created" value={formatDateTime(settlement.createdAt)} />
              <Field label="Payment reference" value={settlement.paymentReference ?? '-'} mono />
            </FactGrid>
          </Section>
        </div>
      </DetailShell>
    );
  }

  return (
    <DetailShell
      title="Settlement"
      pills={[]}
      backHref="/dashboard/settlements"
      backLabel="Back to settlements"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <Section title="Period breakdown" icon={<FiBriefcase />}><None /></Section>
    </DetailShell>
  );
}

// ── Complaint detail ────────────────────────────────────────────────────

export function ComplaintDetailView({ id }: { id: string }) {
  const [complaint, setComplaint] = useState<ComplaintInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setComplaint(await getComplaintDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load complaint');
    } finally {
      setLoading(false);
    }
  };

  return (
    <DetailShell
      title={`Complaint — ${getStatusLabel(complaint?.category ?? '')}`}
      pills={complaint ? [complaint.category, complaint.status] : []}
      backHref="/dashboard/complaints"
      backLabel="Back to complaints"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <Section title="Reported by" icon={<FiUser />}>
        {complaint?.passengerId ? (
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center text-sm font-bold shrink-0">
              {(complaint.passengerName ?? complaint.passengerPhone ?? '??').slice(0, 2).toUpperCase()}
            </div>
            <div className="min-w-0">
              <Link href={`/dashboard/users/${complaint.passengerId}`} className="text-sm text-indigo-600 hover:text-indigo-800 font-medium">
                {complaint.passengerName ?? 'User'}
              </Link>
              <p className="text-xs text-gray-500">{complaint.passengerPhone ?? '-'}</p>
            </div>
          </div>
        ) : (
          <None label="Reporter profile unavailable." />
        )}
      </Section>

      <Section title="Complaint" icon={<FiMessageSquare />}>
        <p className="text-sm text-gray-800 whitespace-pre-line">{complaint?.description ?? '-'}</p>
        {complaint?.resolution && (
          <div className="mt-4 border-t pt-3">
            <p className="text-xs font-medium text-gray-400 uppercase tracking-wide mb-1">Resolution</p>
            <div className="flex items-start gap-2 text-sm text-emerald-700 bg-emerald-50 rounded-lg p-3">
              <FiCheckCircle className="mt-0.5 shrink-0" />
              <span className="whitespace-pre-line">{complaint.resolution}</span>
            </div>
          </div>
        )}
        <FactGrid cols={2} className="mt-4">
          <Field label="Status" value={<Pill value={complaint?.status ?? ''} />} />
          <Field label="Last updated" value={complaint ? formatDateTime(complaint.updatedAt) : '-'} />
        </FactGrid>
      </Section>

      <Section title="Trip context" icon={<FiMap />}>
        <FactGrid cols={2}>
          <Field label="Booking ID" value={complaint?.bookingId ? complaint.bookingId.slice(0, 8) + '…' : '-'} mono />
          <Field label="Ride" value={
            complaint?.rideId ? (
              <Link href={`/dashboard/rides/${complaint.rideId}`} className="text-indigo-600 hover:text-indigo-800 font-mono text-xs">
                {complaint.rideId.slice(0, 8)}… view ride
              </Link>
            ) : '-'
          } mono />
          <Field label="Filed at" value={complaint ? formatDateTime(complaint.createdAt) : '-'} />
        </FactGrid>
      </Section>
    </DetailShell>
  );
}

// ── Safety event detail ─────────────────────────────────────────────────

export function SafetyDetailView({ id }: { id: string }) {
  const [event, setEvent] = useState<SafetyInfo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const load = async () => {
    try {
      setLoading(true);
      setEvent(await getSafetyDetail(id));
      setError(null);
    } catch (err: unknown) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setError((err as any)?.response?.data?.message || 'Failed to load safety event');
    } finally {
      setLoading(false);
    }
  };

  const coords = event?.latitude != null && event?.longitude != null
    ? `${Number(event.latitude).toFixed(5)}, ${Number(event.longitude).toFixed(5)}`
    : null;

  return (
    <DetailShell
      title={`Safety event — ${getStatusLabel(event?.eventType ?? '')}`}
      pills={event ? [event.eventType, event.status] : []}
      backHref="/dashboard/safety"
      backLabel="Back to safety events"
      loading={loading}
      error={error}
      onRetry={load}
    >
      <div className="bg-white rounded-xl border border-gray-200 p-5 flex items-start gap-4">
        <div className={`w-14 h-14 rounded-xl flex items-center justify-center shrink-0 ${
          event?.eventType === 'SOS'
            ? 'bg-rose-100 text-rose-700'
            : 'bg-indigo-100 text-indigo-700'
        }`}>
          <FiAlertTriangle className="w-6 h-6" />
        </div>
        <div className="min-w-0">
          <p className="text-lg font-semibold text-gray-900">{getStatusLabel(event?.eventType ?? '')}</p>
          <p className="text-sm text-gray-600">{event?.description ?? 'No description recorded'}</p>
          <p className="text-xs text-gray-400 mt-1">
            Triggered {event ? formatDateTime(event.createdAt) : ''} · status {getStatusLabel(event?.status ?? '')}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Section title="Reported by" icon={<FiUser />}>
          {event?.userId ? (
            <FactGrid cols={2}>
              <Field label="Passenger" value={
                <Link href={`/dashboard/users/${event.userId}`} className="text-indigo-600 hover:text-indigo-800">
                  {event.userName ?? 'User'}{event.userPhone ? ` · ${event.userPhone}` : ''}
                </Link>
              } />
              <Field label="Initiated" value={formatDateTime(event.createdAt)} />
            </FactGrid>
          ) : <None label="Reporter profile unavailable." />}
        </Section>

        <Section title="Participants" icon={<FiUsers />}>
          <FactGrid cols={2}>
            <Field label="Driver" value={
              event?.driverId ? (
                <Link href={`/dashboard/drivers/${event.driverId}`} className="text-indigo-600 hover:text-indigo-800">
                  {event.driverName ?? 'Driver profile'}{event.driverPhone ? ` · ${event.driverPhone}` : ''}
                </Link>
              ) : 'Not involved'
            } />
            <Field label="Vehicle" value={event?.vehicleRegistration ?? '-'} />
            <Field label="Ride" value={
              event?.rideId ? (
                <Link href={`/dashboard/rides/${event.rideId}`} className="text-indigo-600 hover:text-indigo-800 font-mono text-xs">
                  {event.rideId.slice(0, 8)}… view ride
                </Link>
              ) : '-'
            } mono />
            <Field label="Event ID" value={event?.id} mono />
          </FactGrid>
        </Section>
      </div>

      <Section title="Location" icon={<FiNavigation />}>
        {coords ? (
          <FactGrid cols={2}>
            <Field label="Coordinates" value={coords} mono />
            <Field label="Map" value={
              <a
                href={`https://www.google.com/maps?q=${event!.latitude},${event!.longitude}`}
                target="_blank" rel="noreferrer"
                className="text-indigo-600 hover:text-indigo-800"
              >
                Open in Google Maps
              </a>
            } />
          </FactGrid>
        ) : (
          <None label="No GPS location attached to this event." />
        )}
      </Section>
    </DetailShell>
  );
}

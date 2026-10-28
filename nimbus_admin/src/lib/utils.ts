/**
 * Format a date string to a localized date string.
 */
export const formatDate = (dateStr: string | undefined): string => {
  if (!dateStr) return '-';
  try {
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  } catch {
    return dateStr;
  }
};

/**
 * Format a date string to include both date and time.
 */
export const formatDateTime = (dateStr: string | undefined): string => {
  if (!dateStr) return '-';
  try {
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return dateStr;
  }
};

/**
 * Format a number as a Bangladeshi Taka currency string.
 */
export const formatCurrency = (amount: number | undefined): string => {
  if (amount == null) return '-';
  return `৳${amount.toLocaleString('en-BD', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
};

/**
 * Format a ride pickup/drop-off: prefer the address; when missing, fall back
 * to readable coordinates extracted from the WKT POINT string.
 */
export const formatPlace = (address: string | null | undefined, wkt?: string | null): string => {
  if (address) return address;
  if (!wkt) return '-';
  // "POINT(90.4126 23.8104)" -> "(23.8104, 90.4126)" (lat, lng order for humans)
  const m = wkt.match(/POINT\s*\(\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s*\)/i);
  if (m) return `(${m[2]}, ${m[1]})`;
  return wkt;
};

/**
 * Truncate an ID string to a shorter display length.
 */
export const truncateId = (id: string | undefined, length: number = 8): string => {
  if (!id) return '-';
  return id.length > length ? id.substring(0, length) : id;
};

/**
 * Capitalize the first letter of a string.
 */
export const capitalize = (str: string | undefined): string => {
  if (!str) return '-';
  return str.charAt(0).toUpperCase() + str.slice(1);
};

/**
 * Get a human-readable status label.
 */
export const getStatusLabel = (status: string | undefined): string => {
  if (!status) return 'Unknown';
  return status
      .split('_')
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
      .join(' ');
};

/**
 * Map an enum-ish table value (status / role / category / method) to the
 * shared pill-badge CSS class used in every dashboard table
 * (same pill style as the Rides table status column).
 */
export const getBadgeClass = (value: string | undefined | null): string => {
  const v = (value ?? '').toUpperCase();

  // Roles
  if (v === 'ADMIN') return 'status-info';

  // Positive / happy states
  if (v === 'ACTIVE' || v === 'COMPLETED' || v === 'APPROVED' || v === 'PAID' ||
      v === 'RESOLVED' || v === 'SUCCEEDED' || v === 'DRIVER') {
    return 'status-active';
  }

  // In-flight / attention states
  if (v === 'PENDING' || v === 'IN_PROGRESS' || v === 'PROCESSING' ||
      v === 'REQUESTED' || v === 'INCOMING' || v === 'EN_ROUTE' ||
      v === 'DISPATCHING' || v === 'ARRIVED' || v === 'OPEN' ||
      v === 'DRIVER_BEHAVIOR' || v === 'DELAY' || v === 'ONLINE' ||
      v === 'AWAY') {
    return 'status-pending';
  }
  if (v === 'DRIVING') return 'status-active';

  // Negative states
  if (v === 'CANCELLED' || v === 'CANCELED' || v === 'FAILED' ||
      v === 'REJECTED' || v === 'ESCALATED' || v === 'SAFETY' ||
      v === 'OVERCHARGING') {
    return 'status-cancelled';
  }

  if (v === 'SUSPENDED' || v === 'SOS') return 'status-suspended';

  // Everything else (roles like PASSENGER, methods like CASH, vehicle types)
  return 'status-neutral';
};

/**
 * Get CSS class for a status type (used in admin UI).
 */
export const getStatusColorClass = (
  status: string | undefined,
): string => {
  if (!status) return 'bg-gray-100 text-gray-800';

  const s = status.toLowerCase();
  if (s.includes('active') || s.includes('completed') || s.includes('approved')) {
    return 'bg-emerald-100 text-emerald-800';
  }
  if (s.includes('pending')) {
    return 'bg-amber-100 text-amber-800';
  }
  if (
    s.includes('cancel') ||
    s.includes('failed') ||
    s.includes('rejected') ||
    s.includes('suspended')
  ) {
    return 'bg-rose-100 text-rose-800';
  }
  return 'bg-gray-100 text-gray-800';
};

/**
 * Combine class names (simple utility).
 */
export const cn = (...classes: (string | undefined | false)[]) => {
  return classes.filter(Boolean).join(' ');
};

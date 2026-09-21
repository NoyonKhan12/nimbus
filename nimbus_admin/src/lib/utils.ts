/**
 * Format a date string to a localized date string.
 */
export const formatDate = (dateStr: string | undefined): string => {
  if (!dateStr) return '-';
  try {
    return new Date(dateStr).toLocaleDateString('en-US', {
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
    return new Date(dateStr).toLocaleString('en-US', {
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

import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formatting helpers for money, distance, duration and dates.
///
/// Business time is presented in Asia/Dhaka regardless of device locale
/// (guide §5: timestamps are stored UTC, displayed in business time).
class AppFormatters {
  AppFormatters._();

  /// `DateTime.now()` shifted into Asia/Dhaka (+06:00, no DST).
  static DateTime dhaka(DateTime utc) =>
      utc.toUtc().add(const Duration(hours: 6));

  /// `৳1,250.00`
  static String money(double amount, {String? currency}) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final symbol = (currency == null || currency.isEmpty)
        ? AppConstants.currencySymbol
        : currency;
    return '$symbol${fmt.format(amount)}';
  }

  /// `1,250.00` without the currency symbol.
  static String amount(double amount) =>
      NumberFormat('#,##0.00', 'en_US').format(amount);

  /// `850 m` / `12.4 km`
  static String distance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// `8 min` / `1 h 20 min`
  static String duration(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// `5 Oct, 8:15 AM` in Asia/Dhaka.
  static String dateTime(DateTime? utc) {
    if (utc == null) return '';
    final local = dhaka(utc);
    return DateFormat('d MMM, h:mm a', 'en_US').format(local);
  }

  /// `8:15 AM` in Asia/Dhaka.
  static String time(DateTime? utc) {
    if (utc == null) return '';
    return DateFormat('h:mm a', 'en_US').format(dhaka(utc));
  }

  /// `5 Oct 2026` in Asia/Dhaka.
  static String date(DateTime? utc) {
    if (utc == null) return '';
    return DateFormat('d MMM yyyy', 'en_US').format(dhaka(utc));
  }

  /// Countdown `4:32` from a duration.
  static String countdown(Duration remaining) {
    if (remaining.isNegative) return '0:00';
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Relative label for ledger entries: `Today`, `Yesterday`, `5 Oct`.
  static String relativeDate(DateTime? utc) {
    if (utc == null) return '';
    final now = DateTime.now().toUtc();
    final localNow = DateTime.utc(
        now.year, now.month, now.day);
    final localThen = DateTime.utc(
        utc.year, utc.month, utc.day);
    final diff = localNow.difference(localThen).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return date(utc);
  }
}

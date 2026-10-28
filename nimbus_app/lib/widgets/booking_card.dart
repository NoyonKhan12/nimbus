import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../dto/location_dto.dart';
import '../dto/ride_booking_dtos.dart';
import 'state_views.dart';

/// A booking summary card for the "My Rides" list.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingCard({super.key, required this.booking, this.onTap});

  String get _routeLabel {
    String short(LocationDto l) =>
        l.address?.isNotEmpty == true
            ? l.address!
            : '${l.latitude.toStringAsFixed(3)}, ${l.longitude.toStringAsFixed(3)}';
    return '${short(booking.pickupLocation)}  →  ${short(booking.dropoffLocation)}';
  }

  @override
  Widget build(BuildContext context) {
    final fare = booking.fareQuote?.finalPayable;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #${booking.id.substring(0, 8)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  StatusChip.of(_statusName),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _routeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_seat,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${booking.seats} seat(s)',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                  const Spacer(),
                  if (fare != null)
                    Text(
                      AppFormatters.money(fare),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                ],
              ),
              if (booking.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  AppFormatters.dateTime(booking.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _statusName {
    switch (booking.status) {
      case BookingStatus.held:
        return 'HELD';
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.pickedUp:
        return 'PICKED_UP';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
      case BookingStatus.expired:
        return 'EXPIRED';
      case BookingStatus.refundPending:
        return 'REFUND_PENDING';
      case BookingStatus.refunded:
        return 'REFUNDED';
    }
  }
}

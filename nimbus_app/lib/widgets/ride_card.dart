import 'package:flutter/material.dart';
import '../dto/ride_booking_dtos.dart';
import '../core/theme/app_theme.dart';

/// A card widget representing a ride in the list.
class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;

  const RideCard({super.key, required this.ride, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ride.status);
    final statusText = _getStatusText(ride.status);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ride #${ride.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.origin.address ??
                          '${ride.origin.latitude}, ${ride.origin.longitude}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppTheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.destination.address ??
                          '${ride.destination.latitude}, ${ride.destination.longitude}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ride.availableSeats}/${ride.totalSeats} seats',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (ride.scheduledAt != null)
                    Text(
                      '${ride.scheduledAt!.hour.toString().padLeft(2, '0')}:${ride.scheduledAt!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.published:
        return AppTheme.secondary;
      case RideStatus.inProgress:
        return AppTheme.primary;
      case RideStatus.completed:
        return AppTheme.success;
      case RideStatus.cancelled:
        return AppTheme.error;
      case RideStatus.draft:
      case RideStatus.routeLocked:
      case RideStatus.driverArriving:
      case RideStatus.interrupted:
        return Colors.orange;
    }
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.draft:
        return 'Draft';
      case RideStatus.published:
        return 'Published';
      case RideStatus.routeLocked:
        return 'Route Locked';
      case RideStatus.driverArriving:
        return 'Driver Arriving';
      case RideStatus.inProgress:
        return 'In Progress';
      case RideStatus.interrupted:
        return 'Interrupted';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/booking/booking_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../dto/location_dto.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/state_views.dart';
import '../booking/booking_checkout_page.dart';

/// Ride detail — reviews the ride and picks segment + seats before
/// requesting a fare quote (first step of the booking pipeline).
class RideDetailPage extends StatefulWidget {
  final Ride ride;

  /// The passenger's chosen search segment. Falls back to the ride's own
  /// endpoints when the ride was opened outside search.
  final LocationDto? pickup;
  final LocationDto? dropoff;

  const RideDetailPage({
    super.key,
    required this.ride,
    this.pickup,
    this.dropoff,
  });

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  int _seats = 1;

  bool get _bookable =>
      widget.ride.status == RideStatus.published &&
      widget.ride.availableSeats > 0;

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    return Scaffold(
      appBar: AppBar(title: const Text('Ride details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Route card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _address(ride.origin),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        Container(
                          width: 2,
                          height: 26,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.more_vert,
                            size: 16, color: Colors.grey.shade400),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _address(ride.destination),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.pickup != null && widget.dropoff != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your segment',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.muted(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _segmentRow(
                      Icons.trip_origin,
                      AppTheme.primary,
                      widget.pickup!,
                    ),
                    const SizedBox(height: 8),
                    _segmentRow(
                      Icons.location_on,
                      AppTheme.secondary,
                      widget.dropoff!,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Meta card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _metaRow(Icons.schedule, 'Departure',
                      AppFormatters.dateTime(ride.scheduledAt)),
                  _metaRow(Icons.event_seat, 'Seats available',
                      '${ride.availableSeats}'),
                  _metaRow(Icons.loop, 'Ride type',
                      _rideTypeLabel(ride.rideType)),
                  _metaRow(Icons.verified_outlined, 'Status',
                      _statusLabel(ride.status)),
                  if (ride.notes != null && ride.notes!.isNotEmpty)
                    _metaRow(Icons.notes, 'Notes', ride.notes!),
                ],
              ),
            ),
          ),
          if (!_bookable) ...[
            const SizedBox(height: 16),
            ErrorState(
              message: ride.status == RideStatus.published
                  ? 'This ride is full.'
                  : 'This ride is no longer bookable '
                      '(${_statusLabel(ride.status)}).',
            ),
          ],
        ],
      ),
      bottomNavigationBar: _bookable ? _bookingBar(context) : null,
    );
  }

  Widget _bookingBar(BuildContext context) {
    final maxSeats = widget.ride.availableSeats;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('Seats', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: _seats > 1
                  ? () => setState(() => _seats--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$_seats',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton.outlined(
              onPressed: _seats < maxSeats
                  ? () => setState(() => _seats++)
                  : null,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openCheckout(context),
                child: const Text('Get fare quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context) async {
    // A fresh BookingBloc per flow keeps hold/payment state isolated.
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (ctx) => BookingBloc(
            bookingService: ctx.read<BookingService>(),
            paymentService: ctx.read<PaymentService>(),
          ),
          child: BookingCheckoutPage(
            ride: widget.ride,
            seats: _seats,
            pickup: widget.pickup ?? widget.ride.origin,
            dropoff: widget.dropoff ?? widget.ride.destination,
          ),
        ),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _segmentRow(IconData icon, Color color, LocationDto location) {
    final address = location.address;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            (address != null && address.isNotEmpty)
                ? address
                : '${location.latitude.toStringAsFixed(5)}, '
                    '${location.longitude.toStringAsFixed(5)}',
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _address(dynamic location) {
    final address = location.address as String?;
    if (address != null && address.isNotEmpty) return address;
    final lat = location.latitude as double;
    final lng = location.longitude as double;
    return '$lat, $lng';
  }

  String _rideTypeLabel(RideType type) {
    switch (type) {
      case RideType.scheduled:
        return 'Scheduled';
      case RideType.instant:
        return 'Instant';
      case RideType.recurring:
        return 'Recurring';
    }
  }

  String _statusLabel(RideStatus status) {
    switch (status) {
      case RideStatus.draft:
        return 'Draft';
      case RideStatus.published:
        return 'Open for booking';
      case RideStatus.routeLocked:
        return 'Route locked';
      case RideStatus.driverArriving:
        return 'Driver arriving';
      case RideStatus.inProgress:
        return 'In progress';
      case RideStatus.interrupted:
        return 'Interrupted';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

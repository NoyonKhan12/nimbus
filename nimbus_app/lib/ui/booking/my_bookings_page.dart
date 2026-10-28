import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/ride_booking_dtos.dart';
import '../../services/booking_service.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/state_views.dart';
import '../ride/trip_tracking_page.dart';

/// "My Rides" tab — active bookings on top, past trips below.
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<BookingService>().listBookings();
  }

  void _reload() {
    setState(() {
      _future = context.read<BookingService>().listBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My rides')),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    ),
                  ),
                ],
              );
            }
            final bookings = snapshot.data ?? const <Booking>[];
            if (bookings.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(
                    height: 480,
                    child: EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No rides yet',
                      subtitle: 'Search for a ride to book your first '
                          'pooled commute.',
                    ),
                  ),
                ],
              );
            }
            final active = bookings
                .where((b) =>
                    b.status == BookingStatus.held ||
                    b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.pickedUp)
                .toList();
            final past = bookings
                .where((b) =>
                    b.status != BookingStatus.held &&
                    b.status != BookingStatus.confirmed &&
                    b.status != BookingStatus.pickedUp)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isNotEmpty) ...[
                  const _SectionHeader('Active'),
                  ...active.map((b) => BookingCard(
                        booking: b,
                        onTap: () => _open(b),
                      )),
                ],
                if (past.isNotEmpty) ...[
                  const _SectionHeader('History'),
                  ...past.map((b) => BookingCard(
                        booking: b,
                        onTap: () => _open(b),
                      )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _open(Booking booking) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TripTrackingPage(
          rideId: booking.rideId,
          bookingId: booking.id,
        ),
      ),
    );
    if (changed == true && mounted) _reload();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

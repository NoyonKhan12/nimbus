import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/ride_control/ride_control_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../network/backend_mapper.dart';
import '../../widgets/state_views.dart';

/// Live ride control: lifecycle actions, passenger manifest with
/// pickup/dropoff, and GPS sharing during the trip.
class RideControlPage extends StatefulWidget {
  final String rideId;

  const RideControlPage({super.key, required this.rideId});

  @override
  State<RideControlPage> createState() => _RideControlPageState();
}

class _RideControlPageState extends State<RideControlPage> {
  @override
  void initState() {
    super.initState();
    context.read<RideControlBloc>().add(RideControlStarted(widget.rideId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride control')),
      body: BlocConsumer<RideControlBloc, RideControlState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.error,
              ),
            );
            context
                .read<RideControlBloc>()
                .add(const RideControlErrorCleared());
          }
        },
        builder: (context, state) {
          if (state.loading && state.ride == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final ride = state.ride;
          if (ride == null) {
            return const EmptyState(
                icon: Icons.route_outlined, title: 'Ride not found');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statusHeader(context, state, ride),
              const SizedBox(height: 12),
              _routeCard(ride),
              const SizedBox(height: 12),
              _passengersCard(context, state),
              const SizedBox(height: 12),
              if (ride.status.isLive) _gpsCard(context, state),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<RideControlBloc, RideControlState>(
        builder: (context, state) {
          final ride = state.ride;
          if (ride == null) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _primaryAction(context, state, ride),
            ),
          );
        },
      ),
    );
  }

  Widget _statusHeader(
      BuildContext context, RideControlState state, Ride ride) {
    final (label, color) = _statusVisual(ride.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.radar, color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: color)),
                Text(
                  'Created ${_date(ride)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (state.busyAction != null)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  String _date(Ride ride) {
    final d = ride.scheduledAt;
    if (d == null) return 'just now';
    return '${d.day}/${d.month} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  (String, Color) _statusVisual(RideStatus status) {
    return switch (status) {
      RideStatus.draft => ('Draft — not visible to passengers',
          AppTheme.warning),
      RideStatus.published => ('Published — accepting bookings',
          AppTheme.primary),
      RideStatus.routeLocked => ('Route locked — ready to start',
          AppTheme.primary),
      RideStatus.driverArriving => ('Driver arriving', AppTheme.secondary),
      RideStatus.inProgress => ('Trip in progress', AppTheme.secondary),
      RideStatus.interrupted => ('Interrupted', AppTheme.warning),
      RideStatus.completed => ('Completed', AppTheme.success),
      RideStatus.cancelled => ('Cancelled', AppTheme.error),
    };
  }

  Widget _routeCard(Ride ride) {
    String point(dynamic l) =>
        (l.address as String?)?.isNotEmpty == true
            ? l.address as String
            : '${l.latitude}, ${l.longitude}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trip_origin,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(point(ride.origin))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: AppTheme.secondary),
                const SizedBox(width: 10),
                Expanded(child: Text(point(ride.destination))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _passengersCard(BuildContext context, RideControlState state) {
    final passengers = state.passengers;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                'Passengers (${passengers.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            if (passengers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No bookings yet. Passengers appear here as they book.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              )
            else
              ...passengers.map((p) => _passengerTile(context, state, p)),
          ],
        ),
      ),
    );
  }

  Widget _passengerTile(
      BuildContext context, RideControlState state, PassengerBooking p) {
    final busyKey = 'pickup:${p.id}';
    final busyDrop = 'dropoff:${p.id}';
    final busy = state.busyAction == busyKey || state.busyAction == busyDrop;

    final (statusLabel, statusColor) = switch (p.status) {
      BookingStatus.held => ('Held', AppTheme.warning),
      BookingStatus.confirmed => ('Confirmed', AppTheme.primary),
      BookingStatus.pickedUp => ('On board', AppTheme.secondary),
      BookingStatus.completed => ('Dropped off', AppTheme.success),
      BookingStatus.cancelled => ('Cancelled', AppTheme.error),
      BookingStatus.expired => ('Expired', AppTheme.error),
      BookingStatus.refundPending => ('Refund pending', AppTheme.warning),
      BookingStatus.refunded => ('Refunded', AppTheme.success),
    };

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: statusColor.withOpacity(0.12),
        child: Text(
          '${p.seats}',
          style: TextStyle(
              color: statusColor, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        'Passenger ${p.passengerId.substring(0, 8)}',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        'Pickup: ${p.pickup.address ?? _coords(p.pickup)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : switch (p.status) {
              BookingStatus.confirmed => FilledButton(
                  onPressed: () => context
                      .read<RideControlBloc>()
                      .add(PassengerPickupRequested(p.id)),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14)),
                  child: const Text('Pickup'),
                ),
              BookingStatus.pickedUp => FilledButton(
                  onPressed: () => context
                      .read<RideControlBloc>()
                      .add(PassengerDropoffRequested(p.id)),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(horizontal: 14)),
                  child: const Text('Drop'),
                ),
              _ => Chip(
                  label: Text(statusLabel,
                      style:
                          TextStyle(fontSize: 11, color: statusColor)),
                  backgroundColor: statusColor.withOpacity(0.1),
                ),
            },
    );
  }

  Widget _gpsCard(BuildContext context, RideControlState state) {
    return Card(
      color: state.sharingLocation
          ? AppTheme.secondary.withOpacity(0.08)
          : null,
      child: SwitchListTile(
        secondary: Icon(
          state.sharingLocation ? Icons.gps_fixed : Icons.gps_off,
          color: state.sharingLocation ? AppTheme.secondary : Colors.grey,
        ),
        title: const Text('Share live GPS position',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          state.sharingLocation
              ? (state.lastSentPosition == null
                  ? 'Streaming…'
                  : 'Last sent: ${state.lastSentPosition}')
              : 'Send your position every ~8 s during the trip',
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600),
        ),
        value: state.sharingLocation,
        onChanged: (_) =>
            context.read<RideControlBloc>().add(const LocationSharingToggled()),
      ),
    );
  }

  Widget _primaryAction(
      BuildContext context, RideControlState state, Ride ride) {
    if (state.busyAction != null &&
        state.busyAction != '__clear__' &&
        !state.busyAction!.contains(':')) {
      return const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (ride.status == RideStatus.draft) {
      return ElevatedButton.icon(
        onPressed: () => context
            .read<RideControlBloc>()
            .add(const RideControlAction('publish')),
        icon: const Icon(Icons.publish),
        label: const Text('Publish ride'),
      );
    }
    if (state.canStart) {
      return ElevatedButton.icon(
        onPressed: () => context
            .read<RideControlBloc>()
            .add(const RideControlAction('start')),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start ride (locks route)'),
      );
    }
    if (state.canComplete) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
        onPressed: () => _confirmComplete(context),
        icon: const Icon(Icons.flag),
        label: const Text('Complete ride'),
      );
    }
    if (ride.status == RideStatus.published) {
      return TextButton(
        onPressed: () => _confirmCancel(context),
        child:
            const Text('Cancel ride', style: TextStyle(color: AppTheme.error)),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmComplete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete ride?'),
        content: const Text(
            'All passengers should be dropped off. The ride moves to '
            'history and earnings settle.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Back')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Complete',
                  style: TextStyle(color: AppTheme.success))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<RideControlBloc>()
          .add(const RideControlAction('complete'));
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel ride?'),
        content: const Text('Held and confirmed bookings will be affected.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep ride')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel ride',
                  style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<RideControlBloc>()
          .add(const RideControlAction('cancel'));
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  String _coords(dynamic location) =>
      '${location.latitude}, ${location.longitude}';
}

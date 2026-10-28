import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/rides/rides_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../network/backend_mapper.dart';
import '../../widgets/state_views.dart';
import '../ride_control/ride_control_page.dart';
import 'create_ride_page.dart';

/// Driver's created rides: live, upcoming and history.
class MyRidesPage extends StatefulWidget {
  const MyRidesPage({super.key});

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RidesBloc>().add(const RidesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My rides')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_ride',
        onPressed: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateRidePage()));
          if (context.mounted) {
            context.read<RidesBloc>().add(const RidesLoadRequested());
          }
        },
        icon: const Icon(Icons.add_road),
        label: const Text('New ride'),
      ),
      body: BlocConsumer<RidesBloc, RidesState>(
        listener: (context, state) {
          if (state is RidesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RidesLoading || state is RidesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RidesFailure) {
            return ErrorState(
              message: state.message,
              onRetry: () => context
                  .read<RidesBloc>()
                  .add(const RidesLoadRequested()),
            );
          }
          if (state is RidesLoaded) {
            if (state.rides.isEmpty) {
              return const EmptyState(
                icon: Icons.route_outlined,
                title: 'No rides yet',
                subtitle: 'Create and publish your first pooled ride.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<RidesBloc>()
                    .add(const RidesLoadRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.live.isNotEmpty) ...[
                    const _SectionHeader('Live now'),
                    ...state.live.map((r) => _RideCard(
                          ride: r,
                          busy: state.busyRideId == r.id,
                        )),
                  ],
                  if (state.draftOrPublished.isNotEmpty) ...[
                    const _SectionHeader('Open for booking'),
                    ...state.draftOrPublished
                        .map((r) => _RideCard(
                              ride: r,
                              busy: state.busyRideId == r.id,
                            )),
                  ],
                  if (state.history.isNotEmpty) ...[
                    const _SectionHeader('History'),
                    ...state.history
                        .map((r) => _RideCard(
                              ride: r,
                              busy: state.busyRideId == r.id,
                            )),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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

class _RideCard extends StatelessWidget {
  final Ride ride;
  final bool busy;

  const _RideCard({required this.ride, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: ride.status == RideStatus.completed ||
                ride.status == RideStatus.cancelled
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RideControlPage(rideId: ride.id),
                )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ride.destination.address ?? 'Ride ${ride.id.substring(0, 8)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  _statusChip(ride.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.trip_origin,
                      size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.origin.address ?? _coords(ride.origin),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.destination.address ?? _coords(ride.destination),
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
                      size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${ride.availableSeats} seats open',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700)),
                  const Spacer(),
                  Text(
                    ride.scheduledAt == null
                        ? 'Instant'
                        : AppFormatters.dateTime(ride.scheduledAt),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  if (busy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _coords(dynamic location) =>
      '${location.latitude}, ${location.longitude}';

  Widget _statusChip(RideStatus status) {
    final (label, color) = switch (status) {
      RideStatus.draft => ('Draft', AppTheme.warning),
      RideStatus.published => ('Published', AppTheme.primary),
      RideStatus.routeLocked => ('Route locked', AppTheme.primary),
      RideStatus.driverArriving => ('Arriving', AppTheme.secondary),
      RideStatus.inProgress => ('In progress', AppTheme.secondary),
      RideStatus.interrupted => ('Interrupted', AppTheme.warning),
      RideStatus.completed => ('Completed', AppTheme.success),
      RideStatus.cancelled => ('Cancelled', AppTheme.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver/driver_bloc.dart';
import '../../bloc/rides/rides_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../network/backend_mapper.dart';
import '../../widgets/state_views.dart';
import '../onboarding/apply_page.dart';
import '../ride_control/ride_control_page.dart';
import '../rides/create_ride_page.dart';

/// Dashboard — driver status, eligibility, stats and live rides.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const DriverDashboardLoadRequested());
    context.read<RidesBloc>().add(const RidesLoadRequested());
  }

  void _reload() {
    context.read<DriverBloc>().add(const DriverDashboardLoadRequested());
    context.read<RidesBloc>().add(const RidesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver dashboard')),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: BlocBuilder<DriverBloc, DriverState>(
          builder: (context, state) {
            if (state is DriverLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DriverFailure && state.data == null) {
              return ErrorState(
                message: state.message,
                onRetry: _reload,
              );
            }
            final data = state is DriverLoaded
                ? state.data
                : state is DriverApplying
                    ? (state as DriverApplying).data
                    : state is DriverFailure
                        ? (state as DriverFailure).data!
                        : null;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Account status
                if (!data.hasApplied) ...[
                  _notAppliedCard(context),
                ] else ...[
                  _statusCard(context, data, state is DriverApplying),
                  const SizedBox(height: 16),
                  _statsRow(data),
                  const SizedBox(height: 16),
                ],

                // Live rides
                if (data.hasApplied &&
                    data.profile!.isApproved &&
                    data.eligible) ...[
                  BlocBuilder<RidesBloc, RidesState>(
                    builder: (context, ridesState) {
                      if (ridesState is! RidesLoaded) {
                        return const SizedBox(
                          height: 80,
                          child: Center(
                              child: CircularProgressIndicator()),
                        );
                      }
                      final live = ridesState.live;
                      if (live.isEmpty) {
                        return _newRideCard(context);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live rides',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...live.map((r) => _liveRideCard(context, r)),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notAppliedCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_car_filled,
                size: 48, color: AppTheme.primary),
            const SizedBox(height: 12),
            const Text(
              'Become a Nimbus driver',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Submit your license and vehicle details. '
              'Once operations approves your application you can '
              'publish rides and start earning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ApplyPage()));
                _reload();
              },
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Apply now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(
      BuildContext context, DriverDashboardData data, bool applying) {
    final profile = data.profile!;
    Color color;
    IconData icon;
    String headline;
    if (!profile.isApproved) {
      color = AppTheme.warning;
      icon = Icons.hourglass_top;
      headline = 'Application ${statusLabel(profile.approvalStatus)}';
    } else if (!data.eligible) {
      color = AppTheme.error;
      icon = Icons.block;
      headline = 'Not eligible to publish rides';
    } else if (data.vehicles.isEmpty) {
      color = AppTheme.warning;
      icon = Icons.directions_car_outlined;
      headline = 'No vehicle on file';
    } else {
      color = AppTheme.success;
      icon = Icons.verified;
      headline = 'Eligible — ready to drive';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                if (!profile.isApproved)
                  const Text(
                    'Operations reviews applications. You will be '
                    'notified once approved.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (applying)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _statsRow(DriverDashboardData data) {
    final profile = data.profile!;
    return Row(
      children: [
        _statCard(Icons.star, profile.rating.toStringAsFixed(1), 'Rating',
            AppTheme.warning),
        _statCard(Icons.route, '${profile.totalRides}', 'Total rides',
            AppTheme.primary),
        _statCard(
            Icons.payments,
            '৳${profile.totalEarnings.toStringAsFixed(0)}',
            'Earned',
            AppTheme.success),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newRideCard(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CreateRidePage()));
          _reload();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_road,
                    color: AppTheme.secondary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Publish a new ride',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveRideCard(BuildContext context, Ride ride) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RideControlPage(rideId: ride.id),
          ));
          _reload();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.radar, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.destination.address ?? 'Ride ${ride.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${statusLabel(ride.status.name)} · ${ride.availableSeats} seats open',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

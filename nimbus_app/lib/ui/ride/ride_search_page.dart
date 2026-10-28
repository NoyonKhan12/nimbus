import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/ride_search/ride_search_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../dto/location_dto.dart';
import '../../widgets/location_entry_sheet.dart';
import '../../widgets/ride_card.dart';
import '../../widgets/state_views.dart';
import 'ride_detail_page.dart';

/// Ride search — pick origin/destination (+ optional time), see matching
/// published rides, and open one to book.
class RideSearchPage extends StatefulWidget {
  const RideSearchPage({super.key});

  @override
  State<RideSearchPage> createState() => _RideSearchPageState();
}

class _RideSearchPageState extends State<RideSearchPage> {
  LocationDto? _origin;
  LocationDto? _destination;
  DateTime? _time;

  Future<void> _pick(bool isOrigin) async {
    final picked = await LocationEntrySheet.show(
      context,
      isOrigin ? 'Where from?' : 'Where to?',
    );
    if (picked != null) {
      setState(() {
        if (isOrigin) {
          _origin = picked;
        } else {
          _destination = picked;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _time ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_time ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() {
      _time = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _search() {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both pickup and drop-off')),
      );
      return;
    }
    context.read<RideSearchBloc>().add(RideSearchRequested(
          origin: _origin!,
          destination: _destination!,
          time: _time?.toUtc(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a ride')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _locationTile(
                      icon: Icons.trip_origin,
                      color: AppTheme.primary,
                      label: 'Pickup',
                      value: _origin,
                      onTap: () => _pick(true),
                    ),
                    const Divider(height: 16),
                    _locationTile(
                      icon: Icons.location_on,
                      color: AppTheme.secondary,
                      label: 'Drop-off',
                      value: _destination,
                      onTap: () => _pick(false),
                    ),
                    const Divider(height: 16),
                    InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _time == null
                                    ? 'Departing anytime (now)'
                                    : 'Departing ${AppFormatters.dateTime(_time)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _time == null ? Colors.grey : null,
                                ),
                              ),
                            ),
                            if (_time != null)
                              GestureDetector(
                                onTap: () => setState(() => _time = null),
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('Search rides'),
            ),
          ),
          Expanded(
            child: BlocBuilder<RideSearchBloc, RideSearchState>(
              builder: (context, state) {
                if (state is RideSearchInitial) {
                  return const EmptyState(
                    icon: Icons.directions_car_outlined,
                    title: 'Find your commute',
                    subtitle:
                        'Enter pickup and drop-off to see available '
                        'pooled rides.',
                  );
                }
                if (state is RideSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RideSearchFailure) {
                  return ErrorState(
                    message: state.message,
                    onRetry: _search,
                  );
                }
                if (state is RideSearchSuccess) {
                  if (state.rides.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No rides found',
                      subtitle:
                          'Try a nearby pickup point or a different time.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.rides.length,
                    itemBuilder: (context, index) {
                      final ride = state.rides[index];
                      return RideCard(
                        ride: ride,
                        onTap: () async {
                          final booked = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => RideDetailPage(
                                ride: ride,
                                pickup: _origin,
                                dropoff: _destination,
                              ),
                            ),
                          );
                          if (booked == true && context.mounted) {
                            // Refresh seat availability after a booking.
                            _search();
                          }
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationTile({
    required IconData icon,
    required Color color,
    required String label,
    required LocationDto? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : (value.address ??
                        '${value.latitude.toStringAsFixed(5)}, '
                            '${value.longitude.toStringAsFixed(5)}'),
                style: TextStyle(
                  fontSize: 14,
                  color: value == null ? Colors.grey : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

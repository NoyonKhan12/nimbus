import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../dto/location_dto.dart';
import '../../network/backend_mapper.dart';
import '../../services/driver_service.dart';
import '../../services/ride_service.dart';
import '../../widgets/location_entry_sheet.dart';
import '../../widgets/state_views.dart';

/// Create ride — instant or scheduled, with map-picked endpoints.
class CreateRidePage extends StatefulWidget {
  const CreateRidePage({super.key});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  bool _instant = true;
  DateTime? _scheduledAt;
  int _seats = 3;
  LocationDto? _origin;
  LocationDto? _destination;
  List<Vehicle> _vehicles = [];
  String? _vehicleId;
  bool _loadingVehicles = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles =
          await context.read<DriverService>().getVehicles();
      setState(() {
        _vehicles = vehicles;
        if (vehicles.isNotEmpty) _vehicleId = vehicles.first.id;
        _loadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _loadingVehicles = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickOrigin() async {
    final picked = await LocationEntrySheet.show(context, 'Where from?');
    if (picked != null) setState(() => _origin = picked);
  }

  Future<void> _pickDestination() async {
    final picked = await LocationEntrySheet.show(context, 'Where to?');
    if (picked != null) setState(() => _destination = picked);
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _scheduledAt ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_vehicleId == null) {
      setState(() => _error = 'You need an approved vehicle to create rides.');
      return;
    }
    if (_origin == null || _destination == null) {
      setState(() => _error = 'Select both pickup and drop-off on the map.');
      return;
    }
    if (!_instant && _scheduledAt == null) {
      setState(() => _error = 'Pick a departure time for scheduled rides.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final ride = await context.read<RideService>().create(
            rideType: _instant ? 'INSTANT' : 'SCHEDULED',
            scheduledAt: _instant ? DateTime.now().toUtc() : _scheduledAt,
            vehicleId: _vehicleId!,
            originLat: _origin!.latitude,
            originLng: _origin!.longitude,
            originAddress: _origin!.address,
            destLat: _destination!.latitude,
            destLng: _destination!.longitude,
            destAddress: _destination!.address,
            availableSeats: _seats,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Ride created — publish it so passengers can book. (${ride.id.substring(0, 8)})')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a ride')),
      body: _loadingVehicles
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? const EmptyState(
                  icon: Icons.directions_car_outlined,
                  title: 'No vehicle on file',
                  subtitle: 'Your vehicle is registered with your driver '
                      'application. Contact operations if it is missing.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Ride type toggle
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                            value: true,
                            icon: Icon(Icons.bolt),
                            label: Text('Instant')),
                        ButtonSegment(
                            value: false,
                            icon: Icon(Icons.schedule),
                            label: Text('Scheduled')),
                      ],
                      selected: {_instant},
                      onSelectionChanged: (s) =>
                          setState(() => _instant = s.first),
                    ),
                    if (!_instant) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Departure time',
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          child: Text(
                            _scheduledAt == null
                                ? 'Not set'
                                : '${_scheduledAt!.day}/${_scheduledAt!.month} '
                                    '${_scheduledAt!.hour.toString().padLeft(2, '0')}:'
                                    '${_scheduledAt!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: _scheduledAt == null
                                    ? Colors.grey
                                    : null),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Route
                    Card(
                      child: Column(
                        children: [
                          _locationTile(
                            icon: Icons.trip_origin,
                            color: AppTheme.primary,
                            label: 'Where from?',
                            value: _origin,
                            onTap: _pickOrigin,
                          ),
                          const Divider(height: 1, indent: 16),
                          _locationTile(
                            icon: Icons.location_on,
                            color: AppTheme.secondary,
                            label: 'Where to?',
                            value: _destination,
                            onTap: _pickDestination,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seats
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Text('Seats offered',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton.outlined(
                              onPressed: _seats > 1
                                  ? () => setState(() => _seats--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('$_seats',
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                            ),
                            IconButton.outlined(
                              onPressed: _seats < 8
                                  ? () => setState(() => _seats++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create ride (draft)'),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Drafts are private — publish when you are ready '
                        'to take bookings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    fontSize: 14, color: value == null ? Colors.grey : null),
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

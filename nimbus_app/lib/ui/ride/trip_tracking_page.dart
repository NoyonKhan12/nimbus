import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../bloc/trip/trip_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../dto/location_dto.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../services/booking_service.dart';
import '../../services/safety_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/state_views.dart';
import '../rating/rating_page.dart';
import '../safety/sos_sheet.dart';

/// Live trip view for the passenger: status timeline, driver position,
/// ETA, SOS and trip sharing — driven by WebSocket events with polling
/// fallback.
class TripTrackingPage extends StatefulWidget {
  final String rideId;
  final String? bookingId;

  const TripTrackingPage({
    super.key,
    required this.rideId,
    this.bookingId,
  });

  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<TripBloc>().add(TripStarted(
          rideId: widget.rideId,
          bookingId: widget.bookingId,
        ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause polling in the background, catch up + resume on return.
    final bloc = context.read<TripBloc>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        bloc.add(const TripBackgrounded());
        break;
      case AppLifecycleState.resumed:
        bloc.add(const TripResumed());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your trip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_location),
            tooltip: 'Share live trip',
            onPressed: _shareTrip,
          ),
        ],
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TripFailure) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<TripBloc>().add(TripStarted(
                    rideId: widget.rideId,
                    bookingId: widget.bookingId,
                  )),
            );
          }
          if (state is TripActive) {
            return _activeView(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          final active = state is TripActive && !state.isCompleted;
          if (!active) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _openSos,
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.emergency),
            label: const Text('SOS'),
          );
        },
      ),
    );
  }

  Widget _activeView(BuildContext context, TripActive state) {
    final ride = state.ride;
    final booking = state.booking;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TripBloc>().add(const TripRefreshRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status header
          Card(
            color: AppTheme.primary.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.radar, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Live trip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _headline(state),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Updated ${AppFormatters.time(state.lastUpdatedAt)}'
                    '${_socketBadge()}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Live route map (OpenStreetMap via flutter_map — no API key).
          // Shows the ride corridor, pickup/drop-off pins and the driver's
          // live position; the timeline/details below are untouched.
          if (ride != null) ...[
            _RouteMapCard(
              origin: ride.origin,
              destination: ride.destination,
              driverLocation: state.driverLocation,
            ),
            const SizedBox(height: 12),
          ],

          // Journey timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _timelineStep(
                    icon: Icons.check_circle,
                    done: true,
                    title: 'Booking confirmed',
                    subtitle: booking == null
                        ? null
                        : 'Booking #${booking.id.substring(0, 8)} · '
                            '${booking.seats} seat(s)',
                  ),
                  _timelineStep(
                    icon: Icons.directions_car,
                    done: _stepDone(state, RideStatus.driverArriving),
                    title: 'Driver on the way',
                    subtitle: state.driverLocation == null
                        ? null
                        : 'Last position ${state.driverLocation!.latitude.toStringAsFixed(4)}, '
                            '${state.driverLocation!.longitude.toStringAsFixed(4)}',
                  ),
                  _timelineStep(
                    icon: Icons.airline_seat_recline_normal,
                    done: booking?.status == BookingStatus.pickedUp ||
                        state.isCompleted,
                    title: 'On board',
                  ),
                  _timelineStep(
                    icon: Icons.flag,
                    done: state.isCompleted,
                    isLast: true,
                    title: state.isCompleted
                        ? 'Trip completed'
                        : 'Drop-off',
                    subtitle: state.etaSeconds != null && !state.isCompleted
                        ? 'ETA ${AppFormatters.duration(state.etaSeconds!)}'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Route summary (renders without a maps API key)
          if (ride != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.trip_origin,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ride.origin.address ?? _coords(ride.origin),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: AppTheme.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ride.destination.address ??
                                _coords(ride.destination),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Post-trip rating
          if (state.isCompleted && ride?.driverId != null && widget.bookingId != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'How was your trip?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: ride == null
                          ? null
                          : () => _rateDriver(context, ride),
                      icon: const Icon(Icons.star),
                      label: const Text('Rate your driver'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Cancel while pre-pickup
          if (!state.isCompleted &&
              booking != null &&
              (booking.status == BookingStatus.held ||
                  booking.status == BookingStatus.confirmed)) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _cancelBooking(context),
                child: const Text(
                  'Cancel booking',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ),
          ],
          const SizedBox(height: 80), // room for the SOS FAB
        ],
      ),
    );
  }

  String _headline(TripActive state) {
    if (state.isCompleted) return 'Trip completed — thanks for pooling!';
    switch (state.rideStatus) {
      case RideStatus.driverArriving:
        return 'Your driver is arriving';
      case RideStatus.inProgress:
        return 'Trip in progress';
      case RideStatus.routeLocked:
        return 'Route locked — driver preparing to start';
      default:
        return 'Waiting for the driver to start';
    }
  }

  Widget _timelineStep({
    required IconData icon,
    required bool done,
    required String title,
    String? subtitle,
    bool isLast = false,
  }) {
    final color = done ? AppTheme.success : Colors.grey.shade400;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: done
                      ? AppTheme.success.withOpacity(0.12)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade200),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          done ? FontWeight.w600 : FontWeight.w500,
                      color: done ? null : Colors.grey.shade600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _socketBadge() {
    final connected = WebsocketService().isConnected;
    return connected ? ' · live' : ' · polling';
  }

  bool _stepDone(TripActive state, RideStatus target) {
    final current = state.rideStatus;
    if (current == null || state.isCompleted) return true;
    return RideStatus.values.indexOf(current) >=
        RideStatus.values.indexOf(target);
  }

  String _coords(dynamic location) =>
      '${location.latitude}, ${location.longitude}';

  Future<void> _shareTrip() async {
    final safety = context.read<SafetyService>();
    try {
      final ok = await safety.startTripShare(rideId: widget.rideId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Live trip shared for the next 2 hours.'
              : 'Could not start trip sharing.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip sharing failed: $e')),
      );
    }
  }

  Future<void> _openSos() async {
    await SosSheet.show(context, rideId: widget.rideId);
  }

  Future<void> _rateDriver(BuildContext context, Ride ride) async {
    await RatingSheet.show(
      context,
      bookingId: widget.bookingId!,
      toUserId: ride.driverId!,
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    if (widget.bookingId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content:
            const Text('Cancellation charges may apply per policy.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final bookingService = context.read<BookingService>();
      final tripBloc = context.read<TripBloc>();
      final messenger = ScaffoldMessenger.of(context);
      try {
        await bookingService.cancelBooking(widget.bookingId!);
        if (!context.mounted) return;
        tripBloc.add(const TripRefreshRequested());
        messenger.showSnackBar(
          const SnackBar(content: Text('Booking cancelled.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Cancellation failed: $e')),
        );
      }
    }
  }
}

/// Live tracking map card: the ride corridor as a polyline between the ride
/// origin/destination, labelled pickup/drop-off markers, and the driver's
/// live position streamed from TripBloc (`RIDE_LOCATION_UPDATED`).
///
/// The camera fits the current route on first layout (and whenever the route
/// toggles) and keeps following the driver until the user takes control of
/// the map with a gesture. Bounded to 300 px height inside the scroll view.
class _RouteMapCard extends StatefulWidget {
  final LocationDto origin;
  final LocationDto destination;
  final LocationDto? driverLocation;

  const _RouteMapCard({
    required this.origin,
    required this.destination,
    this.driverLocation,
  });

  @override
  State<_RouteMapCard> createState() => _RouteMapCardState();
}

class _RouteMapCardState extends State<_RouteMapCard> {
  static const _dhakaCenter = LatLng(23.8103, 90.4125);
  static const _cameraPadding = EdgeInsets.all(36);

  final MapController _mapController = MapController();

  LocationDto? _lastSeenDriver;

  /// Camera stays centred on the route/driver until the user manually
  /// pans or zooms (then we stop auto-positioning).
  bool _followCamera = true;

  List<LatLng> get _routePoints => [
        LatLng(widget.origin.latitude, widget.origin.longitude),
        LatLng(widget.destination.latitude, widget.destination.longitude),
      ];

  /// Bounds covering the route plus the driver, or null when a route is
  /// somehow unavailable (keeps the map from crashing on bad data).
  LatLngBounds? get _fitBounds {
    final points = [..._routePoints];
    final driver = widget.driverLocation;
    if (driver != null) {
      points.add(LatLng(driver.latitude, driver.longitude));
    }
    if (points.length < 2) return null;
    return LatLngBounds.fromPoints(points);
  }

  void _fitRoute() {
    final bounds = _fitBounds;
    if (bounds == null) return;
    try {
      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: _cameraPadding,
        maxZoom: 16,
      ));
    } catch (_) {
      // Controller not attached yet (or map already disposed) — the
      // initialCameraFit covers the first frame, so this is harmless.
    }
  }

  @override
  void initState() {
    super.initState();
    // The map sits inside a scrollable: fit once real constraints exist.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
  }

  @override
  void didUpdateWidget(_RouteMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final routeChanged =
        oldWidget.origin != widget.origin ||
            oldWidget.destination != widget.destination;
    if (routeChanged) {
      _followCamera = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRoute());
      return;
    }
    _followDriver();
  }

  /// Nudges the camera to keep the driver in frame while auto-following.
  void _followDriver() {
    final driver = widget.driverLocation;
    if (driver == null || !_followCamera) return;
    if (driver == _lastSeenDriver) return;
    _lastSeenDriver = driver;
    try {
      final driverPoint = LatLng(driver.latitude, driver.longitude);
      final camera = _mapController.camera;
      if (!camera.visibleBounds.contains(driverPoint)) {
        // The map may not be ready yet (or is being disposed) — ignore.
        _mapController.move(driverPoint, camera.zoom);
      }
    } catch (_) {
      // Degrade gracefully: the position still renders on next rebuild.
    }
  }

  void _onMapEvent(MapEvent event) {
    switch (event.source) {
      case MapEventSource.onDrag:
      case MapEventSource.dragStart:
      case MapEventSource.dragEnd:
      case MapEventSource.onMultiFinger:
      case MapEventSource.multiFingerGestureStart:
      case MapEventSource.multiFingerEnd:
      case MapEventSource.scrollWheel:
        // User took over the camera.
        _followCamera = false;
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driverLocation;
    final bounds = _fitBounds;
    final route = _routePoints;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                // A precise fit on first build; a sane Dhaka-centred
                // fallback when the route coordinates are unavailable.
                initialCameraFit: bounds == null
                    ? null
                    : CameraFit.bounds(
                        bounds: bounds,
                        padding: _cameraPadding,
                        maxZoom: 16,
                      ),
                initialCenter: route.isEmpty ? _dhakaCenter : route.first,
                initialZoom: 13,
                onMapEvent: _onMapEvent,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nimbus.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route,
                      strokeWidth: 4,
                      color: AppTheme.primary.withOpacity(0.9),
                      borderStrokeWidth: 7,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    _labelledPin(
                      point: route.first,
                      label: _label(widget.origin, 'Pickup'),
                      icon: Icons.trip_origin,
                      color: AppTheme.primary,
                    ),
                    if (route.length > 1)
                      _labelledPin(
                        point: route.last,
                        label: _label(widget.destination, 'Drop-off'),
                        icon: Icons.location_on,
                        color: AppTheme.secondary,
                      ),
                    if (driver != null) _driverMarker(driver),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            // Graceful degradation when no driver position has arrived yet.
            if (driver == null)
              const Positioned(
                left: 12,
                top: 12,
                child: IgnorePointer(
                  child: _MapStatusBadge(
                    icon: Icons.gps_not_fixed,
                    label: 'Locating the driver…',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _label(LocationDto location, String fallback) =>
      location.address?.trim().isNotEmpty == true
          ? location.address!.trim()
          : fallback;

  Marker _labelledPin({
    required LatLng point,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Marker(
      point: point,
      width: 170,
      height: 58,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(icon, size: 30, color: color),
        ],
      ),
    );
  }

  Marker _driverMarker(LocationDto driver) {
    return Marker(
      point: LatLng(driver.latitude, driver.longitude),
      width: 36,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: const Icon(
          Icons.directions_car,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Small floating status pill overlaid on the map corner.
class _MapStatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MapStatusBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../network/backend_mapper.dart';
import '../../services/booking_service.dart';
import '../../services/ride_service.dart';
import '../../services/websocket_service.dart';

/// RideControlBloc — the driver's live control surface for one ride:
/// lifecycle actions, the passenger manifest with pickup/dropoff, and
/// GPS position streaming (5–10 s target per guide §5, throttled here
/// to one POST every 8 s).
abstract class RideControlEvent extends Equatable {
  const RideControlEvent();

  @override
  List<Object?> get props => [];
}

class RideControlStarted extends RideControlEvent {
  final String rideId;

  const RideControlStarted(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class RideControlAction extends RideControlEvent {
  final String action; // publish | start | complete | cancel

  const RideControlAction(this.action);

  @override
  List<Object?> get props => [action];
}

class PassengerPickupRequested extends RideControlEvent {
  final String bookingId;

  const PassengerPickupRequested(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class PassengerDropoffRequested extends RideControlEvent {
  final String bookingId;

  const PassengerDropoffRequested(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class LocationSharingToggled extends RideControlEvent {
  const LocationSharingToggled();
}

/// A real-time event arrived for the currently loaded ride
/// (`/topic/ride/{rideId}` — status/manifest changes pushed by the
/// backend instead of manual-only refresh).
class RideControlSocketEventReceived extends RideControlEvent {
  final WsEvent event;

  const RideControlSocketEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

/// Clears a surfaced transient error (UI acknowledges it).
class RideControlErrorCleared extends RideControlEvent {
  const RideControlErrorCleared();
}

class _PositionReceived extends RideControlEvent {
  final double lat;
  final double lng;

  const _PositionReceived(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}

class RideControlState extends Equatable {
  final String? rideId;
  final Ride? ride;
  final List<PassengerBooking> passengers;
  final bool loading;
  final bool sharingLocation;
  final String? busyAction;
  final String? lastSentPosition;
  final String? error; // transient, surfaced once by the UI

  const RideControlState({
    this.rideId,
    this.ride,
    this.passengers = const [],
    this.loading = false,
    this.sharingLocation = false,
    this.busyAction,
    this.lastSentPosition,
    this.error,
  });

  bool get canStart =>
      ride != null &&
      (ride!.status == RideStatus.published ||
          ride!.status == RideStatus.routeLocked);

  bool get canComplete => ride?.status == RideStatus.inProgress;

  RideControlState copyWith({
    Ride? ride,
    List<PassengerBooking>? passengers,
    bool? loading,
    bool? sharingLocation,
    String? busyAction,
    String? lastSentPosition,
    String? error,
    bool clearError = false,
  }) {
    return RideControlState(
      rideId: rideId,
      ride: ride ?? this.ride,
      passengers: passengers ?? this.passengers,
      loading: loading ?? this.loading,
      sharingLocation: sharingLocation ?? this.sharingLocation,
      busyAction: busyAction,
      lastSentPosition: lastSentPosition ?? this.lastSentPosition,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        rideId, ride, passengers, loading, sharingLocation,
        busyAction, lastSentPosition, error,
      ];
}

class RideControlBloc extends Bloc<RideControlEvent, RideControlState> {
  final RideService _rideService;
  final BookingService _bookingService;
  final WebsocketService _socket;

  StreamSubscription<Position>? _positionSub;
  DateTime? _lastPostAt;
  static const _minPostInterval = Duration(seconds: 8);

  /// Live event stream subscription for the currently loaded ride.
  StreamSubscription<WsEvent>? _socketSub;
  Timer? _socketRefreshDebounce;
  String? _subscribedRideId;

  RideControlBloc({
    required RideService rideService,
    required BookingService bookingService,
    WebsocketService? socket,
  })  : _rideService = rideService,
        _bookingService = bookingService,
        _socket = socket ?? WebsocketService(),
        super(const RideControlState()) {
    on<RideControlStarted>(_onStarted);
    on<RideControlAction>(_onAction);
    on<PassengerPickupRequested>(_onPickup);
    on<PassengerDropoffRequested>(_onDropoff);
    on<LocationSharingToggled>(_onSharingToggled);
    on<RideControlErrorCleared>(_onErrorCleared);
    on<RideControlSocketEventReceived>(_onSocketEvent);
    on<_SocketRefresh>(_onSocketRefresh);
    on<_PositionReceived>(_onPosition);
  }

  Future<void> _onStarted(
    RideControlStarted event,
    Emitter<RideControlState> emit,
  ) async {
    emit(RideControlState(rideId: event.rideId, loading: true));
    await _refresh(emit);
    // Stop any previous stream when switching rides.
    await _stopStream();
    // Real-time updates for this ride (silent fallback: REST refresh on
    // failure is already in place above).
    _setupSocket(event.rideId);
  }

  Future<void> _onAction(
    RideControlAction event,
    Emitter<RideControlState> emit,
  ) async {
    final rideId = state.rideId;
    if (rideId == null) return;
    emit(state.copyWith(busyAction: event.action, clearError: true));
    try {
      switch (event.action) {
        case 'publish':
          await _rideService.publish(rideId);
          break;
        case 'start':
          await _rideService.start(rideId);
          break;
        case 'complete':
          await _rideService.complete(rideId);
          await _stopStream();
          break;
        case 'cancel':
          await _rideService.cancel(rideId);
          await _stopStream();
          break;
      }
      await _refresh(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), busyAction: null));
    }
  }

  Future<void> _onPickup(
    PassengerPickupRequested event,
    Emitter<RideControlState> emit,
  ) async {
    emit(state.copyWith(busyAction: 'pickup:${event.bookingId}',
        clearError: true));
    try {
      await _bookingService.pickup(event.bookingId);
      await _refresh(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), busyAction: null));
    }
  }

  Future<void> _onDropoff(
    PassengerDropoffRequested event,
    Emitter<RideControlState> emit,
  ) async {
    emit(state.copyWith(busyAction: 'dropoff:${event.bookingId}',
        clearError: true));
    try {
      await _bookingService.dropoff(event.bookingId);
      await _refresh(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), busyAction: null));
    }
  }

  void _onErrorCleared(
    RideControlErrorCleared event,
    Emitter<RideControlState> emit,
  ) {
    emit(state.copyWith(clearError: true, busyAction: null));
  }

  Future<void> _onSharingToggled(
    LocationSharingToggled event,
    Emitter<RideControlState> emit,
  ) async {
    final rideId = state.rideId;
    if (rideId == null) return;
    if (state.sharingLocation) {
      await _stopStream();
      emit(state.copyWith(sharingLocation: false));
      return;
    }

    // Permission first — no stream without it.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
          error: 'Location permission is required to share GPS.'));
      return;
    }
    if (permission != LocationPermission.always) {
      emit(state.copyWith(
        error: 'Open system settings and choose "Allow all the time" so '
            'passengers can see your location while the app is backgrounded.',
      ));
      return;
    }

    emit(state.copyWith(sharingLocation: true, clearError: true));
    await _positionSub?.cancel();
    // Android needs a foreground service while the app is backgrounded during
    // a trip; iOS uses the location background mode declared in Info.plist.
    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 25,
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Nimbus Driver is sharing your location',
              notificationText:
                  'Live location is being shared for your active trip.',
              notificationChannelName: 'Trip location',
              enableWakeLock: true,
              setOngoing: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 25,
            activityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          );
    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (pos) => add(_PositionReceived(pos.latitude, pos.longitude)),
      onError: (e) {
        if (kDebugMode) debugPrint('RideControlBloc: GPS stream error: $e');
      },
      cancelOnError: false,
    );
  }

  Future<void> _onPosition(
    _PositionReceived event,
    Emitter<RideControlState> emit,
  ) async {
    final rideId = state.rideId;
    if (rideId == null || !state.sharingLocation) return;
    // Throttle to the 5–10 s window from the guide.
    final now = DateTime.now();
    if (_lastPostAt != null && now.difference(_lastPostAt!) < _minPostInterval) {
      return;
    }
    _lastPostAt = now;
    try {
      await _rideService.updateLocation(rideId, lat: event.lat, lng: event.lng);
      emit(state.copyWith(
        lastSentPosition:
            '${event.lat.toStringAsFixed(5)}, ${event.lng.toStringAsFixed(5)}',
      ));
    } catch (e) {
      // GPS loss must degrade gracefully — keep streaming, surface once.
      emit(state.copyWith(error: 'Position update failed: $e'));
    }
  }

  Future<void> _refresh(Emitter<RideControlState> emit) async {
    final rideId = state.rideId;
    if (rideId == null) return;
    try {
      final results = await Future.wait([
        _rideService.get(rideId),
        _rideService.rideBookings(rideId),
      ]);
      emit(state.copyWith(
        ride: results[0] as Ride,
        passengers: results[1] as List<PassengerBooking>,
        loading: false,
        busyAction: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false,
          busyAction: null));
    }
  }

  Future<void> _stopStream() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _lastPostAt = null;
  }

  // ------------------------------------------------------------------
  // Real-time (STOMP /topic/ride/{rideId})
  // ------------------------------------------------------------------

  /// Subscribes the bloc to the ride topic. Never throws: a broken socket
  /// silently falls back to the REST refresh already run on every action.
  void _setupSocket(String rideId) {
    try {
      if (_subscribedRideId != null && _subscribedRideId != rideId) {
        _socket.unsubscribeFromRide(_subscribedRideId!);
        _subscribedRideId = null;
      }
      awaitSubscription() {
        _socketSub?.cancel();
        _socketSub = _socket.events.listen(
          (event) => add(RideControlSocketEventReceived(event)),
          onError: (e) {
            if (kDebugMode) debugPrint('RideControlBloc: socket error: $e');
          },
        );
        _socket.subscribeToRide(rideId);
        _subscribedRideId = rideId;
      }

      if (!_socket.isConnected) {
        _socket.connect().catchError((e) {
          if (kDebugMode) debugPrint('RideControlBloc: socket connect failed: $e');
        });
      }
      awaitSubscription();
    } catch (e) {
      if (kDebugMode) debugPrint('RideControlBloc: subscribe failed: $e');
    }
  }

  Future<void> _teardownSocket() async {
    await _socketSub?.cancel();
    _socketSub = null;
    if (_subscribedRideId != null) {
      try {
        _socket.unsubscribeFromRide(_subscribedRideId!);
      } catch (_) {}
      _subscribedRideId = null;
    }
    _socketRefreshDebounce?.cancel();
    _socketRefreshDebounce = null;
  }

  void _onSocketEvent(
    RideControlSocketEventReceived event,
    Emitter<RideControlState> emit,
  ) {
    final active = state;
    if (active.rideId == null || active.ride == null) return;
    // Ignore events for rides other than the one loaded.
    final eventRideId = event.event.data['rideId']?.toString();
    if (eventRideId != null && eventRideId != active.rideId) return;
    final data = event.event.data;

    switch (event.event.type) {
      case 'RIDE_STATUS_CHANGED':
        final status = data['newStatus']?.toString();
        if (status != null) {
          emit(active.copyWith(
            ride: _rideWithStatus(active.ride!, status),
          ));
          _scheduleRefresh();
        }
        break;
      case 'BOOKING_STATUS_CHANGED':
        _scheduleRefresh();
        break;
      case 'SEAT_AVAILABILITY_CHANGED':
      case 'PASSENGER_PICKED_UP':
      case 'PASSENGER_DROPPED_OFF':
      case 'DRIVER_ARRIVED':
        // Manifest/seat counts are merged the same way; a short debounce
        // coalesces bursts into a single authoritative REST refresh.
        _scheduleRefresh();
        break;
      case 'RIDE_LOCATION_UPDATED':
        // The driver is the source of location — nothing to merge.
        break;
      default:
        break;
    }
  }

  /// Coalesced authoritative refresh after a real-time event.
  void _scheduleRefresh() {
    _socketRefreshDebounce ??= Timer(const Duration(milliseconds: 800), () {
      _socketRefreshDebounce = null;
      add(const _SocketRefresh());
    });
  }

  Future<void> _onSocketRefresh(
    _SocketRefresh event,
    Emitter<RideControlState> emit,
  ) async {
    if (state.rideId == null) return;
    await _refresh(emit);
  }

  /// Rebuilds the ride with the backend's live status.
  Ride _rideWithStatus(Ride ride, String backendStatus) {
    return Ride(
      id: ride.id,
      driverId: ride.driverId,
      creatorId: ride.creatorId,
      vehicleId: ride.vehicleId,
      type: ride.type,
      status: parseRideStatus(backendStatus),
      scheduledAt: ride.scheduledAt,
      origin: ride.origin,
      destination: ride.destination,
      availableSeats: ride.availableSeats,
      notes: ride.notes,
    );
  }

  @override
  Future<void> close() {
    _teardownSocket();
    _stopStream();
    return super.close();
  }
}

/// Internal: debounced refresh triggered by socket events.
class _SocketRefresh extends RideControlEvent {
  const _SocketRefresh();
}

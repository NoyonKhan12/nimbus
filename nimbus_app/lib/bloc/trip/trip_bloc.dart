import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/ride_booking_dtos.dart';
import '../../dto/location_dto.dart';
import '../../network/backend_mapper.dart';
import '../../services/booking_service.dart';
import '../../services/ride_service.dart';
import '../../services/websocket_service.dart';

/// TripBloc — the passenger's live view of an active trip.
///
/// Subscribes to `/topic/ride/{rideId}` over the WebSocket and mirrors
/// ride/booking status, driver position and ETA. A slow polling loop runs
/// alongside as graceful degradation when the socket drops (guide §19).
abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class TripStarted extends TripEvent {
  final String rideId;
  final String? bookingId;

  const TripStarted({required this.rideId, this.bookingId});

  @override
  List<Object?> get props => [rideId, bookingId];
}

class TripRefreshRequested extends TripEvent {
  const TripRefreshRequested();
}

class TripSocketEventReceived extends TripEvent {
  final WsEvent event;

  const TripSocketEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class TripStopped extends TripEvent {
  const TripStopped();
}

/// App went to the background — pause the polling loop.
class TripBackgrounded extends TripEvent {
  const TripBackgrounded();
}

/// App returned to the foreground — refresh immediately and resume polling.
class TripResumed extends TripEvent {
  const TripResumed();
}

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

/// Full live state of the tracked trip. All fields are nullable because
/// different events carry different slices; the UI merges onto what it has.
class TripActive extends TripState {
  final String rideId;
  final String? bookingId;
  final Ride? ride;
  final Booking? booking;
  final LocationDto? driverLocation;
  final int? etaSeconds;
  final int? etaDistanceMeters;
  final DateTime lastUpdatedAt;

  const TripActive({
    required this.rideId,
    this.bookingId,
    this.ride,
    this.booking,
    this.driverLocation,
    this.etaSeconds,
    this.etaDistanceMeters,
    required this.lastUpdatedAt,
  });

  RideStatus? get rideStatus => ride?.status;
  BookingStatus? get bookingStatus => booking?.status;

  bool get isCompleted =>
      rideStatus == RideStatus.completed ||
      bookingStatus == BookingStatus.completed;

  TripActive copyWith({
    Ride? ride,
    Booking? booking,
    LocationDto? driverLocation,
    int? etaSeconds,
    int? etaDistanceMeters,
    DateTime? lastUpdatedAt,
  }) {
    return TripActive(
      rideId: rideId,
      bookingId: bookingId,
      ride: ride ?? this.ride,
      booking: booking ?? this.booking,
      driverLocation: driverLocation ?? this.driverLocation,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      etaDistanceMeters: etaDistanceMeters ?? this.etaDistanceMeters,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now().toUtc(),
    );
  }

  @override
  List<Object?> get props => [
        rideId, bookingId, ride, booking, driverLocation,
        etaSeconds, etaDistanceMeters, lastUpdatedAt,
      ];
}

class TripFailure extends TripState {
  final String message;

  const TripFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TripBloc extends Bloc<TripEvent, TripState> {
  final RideService _rideService;
  final BookingService _bookingService;
  final WebsocketService _socket;

  StreamSubscription<WsEvent>? _socketSub;
  Timer? _pollTimer;

  TripBloc({
    required RideService rideService,
    required BookingService bookingService,
    required WebsocketService socket,
  })  : _rideService = rideService,
        _bookingService = bookingService,
        _socket = socket,
        super(TripInitial()) {
    on<TripStarted>(_onStarted);
    on<TripRefreshRequested>(_onRefresh);
    on<TripSocketEventReceived>(_onSocketEvent);
    on<TripStopped>(_onStopped);
    on<TripBackgrounded>(_onBackgrounded);
    on<TripResumed>(_onResumed);
  }

  Future<void> _onStarted(
    TripStarted event,
    Emitter<TripState> emit,
  ) async {
    emit(TripLoading());
    await _teardown();

    // Initial authoritative snapshot from the REST API.
    try {
      final ride = await _rideService.getRide(event.rideId);
      Booking? booking;
      if (event.bookingId != null) {
        booking = await _bookingService.getBooking(event.bookingId!);
      }
      emit(TripActive(
        rideId: event.rideId,
        bookingId: event.bookingId,
        ride: ride,
        booking: booking,
        lastUpdatedAt: DateTime.now().toUtc(),
      ));
    } catch (e) {
      emit(TripFailure(e.toString()));
      return;
    }

    // Real-time updates.
    _subscribeSocket(event.rideId);
    // Graceful degradation: poll every 15 s regardless of socket health.
    _startPolling();
  }

  Future<void> _onRefresh(
    TripRefreshRequested event,
    Emitter<TripState> emit,
  ) async {
    final active = state;
    if (active is! TripActive) return;
    try {
      final ride = await _rideService.getRide(active.rideId);
      Booking? booking = active.booking;
      if (active.bookingId != null) {
        booking = await _bookingService.getBooking(active.bookingId!);
      }
      emit(active.copyWith(
        ride: ride,
        booking: booking,
        lastUpdatedAt: DateTime.now().toUtc(),
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('TripBloc: refresh failed: $e');
      // Keep last known state — GPS/network loss must degrade gracefully.
    }
  }

  void _onSocketEvent(
    TripSocketEventReceived event,
    Emitter<TripState> emit,
  ) {
    final active = state;
    if (active is! TripActive) return;
    final data = event.event.data;

    switch (event.event.type) {
      case 'RIDE_STATUS_CHANGED':
        final status = data['newStatus']?.toString();
        if (active.ride != null && status != null) {
          emit(active.copyWith(
            ride: _withStatus(active.ride!, status),
            lastUpdatedAt: event.event.timestamp,
          ));
        }
        break;
      case 'BOOKING_STATUS_CHANGED':
        final status = data['newStatus']?.toString();
        if (active.booking != null && status != null) {
          emit(active.copyWith(
            booking: _withBookingStatus(active.booking!, status),
            lastUpdatedAt: event.event.timestamp,
          ));
        }
        break;
      case 'RIDE_LOCATION_UPDATED':
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          emit(active.copyWith(
            driverLocation: LocationDto(latitude: lat, longitude: lng),
            lastUpdatedAt: event.event.timestamp,
          ));
        }
        break;
      case 'ETA_UPDATED':
        final eta = data['eta'];
        emit(active.copyWith(
          etaSeconds: eta is num ? eta.toInt() : active.etaSeconds,
          lastUpdatedAt: event.event.timestamp,
        ));
        break;
      case 'DRIVER_ARRIVED':
      case 'PASSENGER_PICKED_UP':
      case 'PASSENGER_DROPPED_OFF':
      case 'SEAT_AVAILABILITY_CHANGED':
        // Status-level changes are reconciled by the poll loop / refresh.
        emit(active.copyWith(lastUpdatedAt: event.event.timestamp));
        add(const TripRefreshRequested());
        break;
      default:
        break;
    }
  }

  Future<void> _onStopped(
    TripStopped event,
    Emitter<TripState> emit,
  ) async {
    await _teardown();
    emit(TripInitial());
  }

  void _onBackgrounded(
    TripBackgrounded event,
    Emitter<TripState> emit,
  ) {
    // Stop burning battery/data while backgrounded; the WebSocket (and the
    // OS) will suspend on their own.
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _onResumed(
    TripResumed event,
    Emitter<TripState> emit,
  ) async {
    if (state is! TripActive) return;
    // Catch up on anything missed in the background, then resume polling.
    add(const TripRefreshRequested());
    _startPolling();
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => add(const TripRefreshRequested()),
    );
  }

  void _subscribeSocket(String rideId) {
    try {
      if (!_socket.isConnected) {
        _socket.connect().catchError((e) {
          if (kDebugMode) debugPrint('TripBloc: socket connect failed: $e');
        });
      }
      _socketSub?.cancel();
      _socketSub = _socket.events.listen(
        (event) => add(TripSocketEventReceived(event)),
        onError: (e) {
          if (kDebugMode) debugPrint('TripBloc: socket error: $e');
        },
      );
      _socket.subscribeToRide(rideId);
    } catch (e) {
      if (kDebugMode) debugPrint('TripBloc: subscribe failed: $e');
    }
  }

  Ride _withStatus(Ride ride, String backendStatus) {
    // Re-map through the shared enum parser by rebuilding minimal JSON.
    final json = <String, dynamic>{
      'id': ride.id,
      'type': ride.rideType.name.toUpperCase(),
      'status': backendStatus,
      'originLatitude': ride.origin.latitude,
      'originLongitude': ride.origin.longitude,
      'originAddress': ride.origin.address,
      'destinationLatitude': ride.destination.latitude,
      'destinationLongitude': ride.destination.longitude,
      'destinationAddress': ride.destination.address,
      'availableSeats': ride.availableSeats,
      'scheduledAt': ride.scheduledAt?.toIso8601String(),
    };
    return rideFromJson(json);
  }

  Booking _withBookingStatus(Booking booking, String backendStatus) {
    return Booking(
      id: booking.id,
      rideId: booking.rideId,
      passengerId: booking.passengerId,
      seats: booking.seats,
      fareQuote: booking.fareQuote,
      pickupLocation: booking.pickupLocation,
      dropoffLocation: booking.dropoffLocation,
      pickupAddress: booking.pickupAddress,
      dropoffAddress: booking.dropoffAddress,
      status: parseBookingStatus(backendStatus),
      pickupStopSequence: booking.pickupStopSequence,
      dropoffStopSequence: booking.dropoffStopSequence,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }

  Future<void> _teardown() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _socketSub?.cancel();
    _socketSub = null;
  }

  @override
  Future<void> close() {
    _teardown();
    return super.close();
  }
}

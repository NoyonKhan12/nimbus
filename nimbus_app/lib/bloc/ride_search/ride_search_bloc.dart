import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/location_dto.dart';
import '../../dto/ride_booking_dtos.dart';
import '../../services/ride_service.dart';

/// RideSearchBloc — searches published rides for an origin/destination pair.
abstract class RideSearchEvent extends Equatable {
  const RideSearchEvent();

  @override
  List<Object?> get props => [];
}

class RideSearchRequested extends RideSearchEvent {
  final LocationDto origin;
  final LocationDto destination;
  final DateTime? time;

  const RideSearchRequested({
    required this.origin,
    required this.destination,
    this.time,
  });

  @override
  List<Object?> get props => [origin, destination, time];
}

abstract class RideSearchState extends Equatable {
  const RideSearchState();

  @override
  List<Object?> get props => [];
}

class RideSearchInitial extends RideSearchState {}

class RideSearchLoading extends RideSearchState {}

class RideSearchSuccess extends RideSearchState {
  final List<Ride> rides;
  final LocationDto origin;
  final LocationDto destination;

  const RideSearchSuccess({
    required this.rides,
    required this.origin,
    required this.destination,
  });

  @override
  List<Object?> get props => [rides, origin, destination];
}

class RideSearchFailure extends RideSearchState {
  final String message;

  const RideSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RideSearchBloc extends Bloc<RideSearchEvent, RideSearchState> {
  final RideService _rideService;

  RideSearchBloc({required RideService rideService})
      : _rideService = rideService,
        super(RideSearchInitial()) {
    on<RideSearchRequested>(_onSearch);
  }

  Future<void> _onSearch(
    RideSearchRequested event,
    Emitter<RideSearchState> emit,
  ) async {
    emit(RideSearchLoading());
    try {
      final rides = await _rideService.searchRides(
        originLat: event.origin.latitude,
        originLng: event.origin.longitude,
        destLat: event.destination.latitude,
        destLng: event.destination.longitude,
        time: event.time,
      );
      emit(RideSearchSuccess(
        rides: rides,
        origin: event.origin,
        destination: event.destination,
      ));
    } catch (e) {
      emit(RideSearchFailure(e.toString()));
    }
  }
}

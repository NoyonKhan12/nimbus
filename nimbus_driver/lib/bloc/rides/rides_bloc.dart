import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/backend_mapper.dart';
import '../../services/ride_service.dart';

/// RidesBloc — the driver's created rides and lifecycle actions.
abstract class RidesEvent extends Equatable {
  const RidesEvent();

  @override
  List<Object?> get props => [];
}

class RidesLoadRequested extends RidesEvent {
  const RidesLoadRequested();
}

/// Lifecycle action on a ride: publish / start / complete / cancel.
class RideActionRequested extends RidesEvent {
  final String rideId;
  final String action; // publish | start | complete | cancel

  const RideActionRequested({required this.rideId, required this.action});

  @override
  List<Object?> get props => [rideId, action];
}

abstract class RidesState extends Equatable {
  const RidesState();

  @override
  List<Object?> get props => [];
}

class RidesInitial extends RidesState {}

class RidesLoading extends RidesState {}

class RidesLoaded extends RidesState {
  final List<Ride> rides;
  final String? busyRideId; // ride with an in-flight lifecycle action

  const RidesLoaded({required this.rides, this.busyRideId});

  List<Ride> get live =>
      rides.where((r) => r.status.isLive).toList();
  List<Ride> get draftOrPublished => rides
      .where((r) => r.status == RideStatus.draft ||
          r.status == RideStatus.published)
      .toList();
  List<Ride> get history => rides
      .where((r) => r.status == RideStatus.completed ||
          r.status == RideStatus.cancelled)
      .toList();

  @override
  List<Object?> get props => [rides, busyRideId];
}

class RidesFailure extends RidesState {
  final String message;

  const RidesFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RidesBloc extends Bloc<RidesEvent, RidesState> {
  final RideService _rideService;

  RidesBloc({required RideService rideService})
      : _rideService = rideService,
        super(RidesInitial()) {
    on<RidesLoadRequested>(_onLoad);
    on<RideActionRequested>(_onAction);
  }

  Future<void> _onLoad(
    RidesLoadRequested event,
    Emitter<RidesState> emit,
  ) async {
    final current = state;
    emit(current is RidesLoaded
        ? RidesLoaded(rides: current.rides, busyRideId: current.busyRideId)
        : RidesLoading());
    try {
      final rides = await _rideService.listMine();
      final busy = current is RidesLoaded ? current.busyRideId : null;
      emit(RidesLoaded(rides: rides, busyRideId: busy));
    } catch (e) {
      emit(RidesFailure(e.toString()));
    }
  }

  Future<void> _onAction(
    RideActionRequested event,
    Emitter<RidesState> emit,
  ) async {
    final current = state;
    if (current is! RidesLoaded) return;
    emit(RidesLoaded(rides: current.rides, busyRideId: event.rideId));
    try {
      switch (event.action) {
        case 'publish':
          await _rideService.publish(event.rideId);
          break;
        case 'start':
          await _rideService.start(event.rideId);
          break;
        case 'complete':
          await _rideService.complete(event.rideId);
          break;
        case 'cancel':
          await _rideService.cancel(event.rideId);
          break;
      }
      final rides = await _rideService.listMine();
      emit(RidesLoaded(rides: rides));
    } catch (e) {
      emit(RidesFailure(e.toString()));
      // Restore the list view after surfacing the failure.
      emit(RidesLoaded(rides: current.rides));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/backend_mapper.dart';
import '../../services/driver_service.dart';
import '../../services/user_service.dart';

/// DriverBloc — the driver's dashboard data: account, profile
/// (null until applied), eligibility and vehicles.
abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class DriverDashboardLoadRequested extends DriverEvent {
  const DriverDashboardLoadRequested();
}

class DriverApplyRequested extends DriverEvent {
  final String licenseNumber;
  final DateTime? licenseExpiry;
  final String vehicleRegistrationNumber;
  final String vehicleType;
  final String vehicleModel;
  final int? vehicleYear;
  final String? vehicleColor;
  final int seatCapacity;

  const DriverApplyRequested({
    required this.licenseNumber,
    this.licenseExpiry,
    required this.vehicleRegistrationNumber,
    required this.vehicleType,
    required this.vehicleModel,
    this.vehicleYear,
    this.vehicleColor,
    required this.seatCapacity,
  });

  @override
  List<Object?> get props => [
        licenseNumber, licenseExpiry, vehicleRegistrationNumber,
        vehicleType, vehicleModel, vehicleYear, vehicleColor, seatCapacity,
      ];
}

class DriverDashboardData extends Equatable {
  final DriverUser user;
  final DriverProfile? profile;
  final bool eligible;
  final List<Vehicle> vehicles;

  const DriverDashboardData({
    required this.user,
    this.profile,
    required this.eligible,
    required this.vehicles,
  });

  bool get hasApplied => profile != null;
  bool get canGoOnline =>
      hasApplied && (profile!.isApproved) && eligible && vehicles.isNotEmpty;

  @override
  List<Object?> get props => [user, profile, eligible, vehicles];
}

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final DriverDashboardData data;

  const DriverLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DriverApplying extends DriverState {
  final DriverDashboardData data;

  const DriverApplying(this.data);

  @override
  List<Object?> get props => [data];
}

class DriverFailure extends DriverState {
  final String message;
  final DriverDashboardData? data;

  const DriverFailure(this.message, [this.data]);

  @override
  List<Object?> get props => [message, data];
}

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverService _driverService;
  final UserService _userService;

  DriverBloc({
    required DriverService driverService,
    required UserService userService,
  })  : _driverService = driverService,
        _userService = userService,
        super(DriverInitial()) {
    on<DriverDashboardLoadRequested>(_onLoad);
    on<DriverApplyRequested>(_onApply);
  }

  Future<void> _onLoad(
    DriverDashboardLoadRequested event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    try {
      final user = await _userService.getCurrentUser();
      final profile = await _driverService.getProfile();
      var eligible = false;
      var vehicles = <Vehicle>[];
      if (profile != null) {
        try {
          eligible = await _driverService.isEligible();
        } catch (_) {
          eligible = false;
        }
        try {
          vehicles = await _driverService.getVehicles();
        } catch (_) {
          vehicles = [];
        }
      }
      emit(DriverLoaded(DriverDashboardData(
        user: user,
        profile: profile,
        eligible: eligible,
        vehicles: vehicles,
      )));
    } catch (e) {
      emit(DriverFailure(e.toString()));
    }
  }

  Future<void> _onApply(
    DriverApplyRequested event,
    Emitter<DriverState> emit,
  ) async {
    final current = state;
    final data = current is DriverLoaded
        ? current.data
        : current is DriverApplying
            ? current.data
            : null;
    if (data != null) emit(DriverApplying(data));
    try {
      final profile = await _driverService.apply(
        licenseNumber: event.licenseNumber,
        licenseExpiry: event.licenseExpiry,
        vehicleRegistrationNumber: event.vehicleRegistrationNumber,
        vehicleType: event.vehicleType,
        vehicleModel: event.vehicleModel,
        vehicleYear: event.vehicleYear,
        vehicleColor: event.vehicleColor,
        seatCapacity: event.seatCapacity,
      );
      // Refresh eligibility + vehicles after applying.
      var eligible = false;
      var vehicles = <Vehicle>[];
      try {
        eligible = await _driverService.isEligible();
        vehicles = await _driverService.getVehicles();
      } catch (_) {}
      emit(DriverLoaded(DriverDashboardData(
        user: data?.user ??
            DriverUser(id: profile.userId, phone: null, email: null),
        profile: profile,
        eligible: eligible,
        vehicles: vehicles,
      )));
    } catch (e) {
      if (data != null) {
        emit(DriverFailure(e.toString(), data));
      } else {
        emit(DriverFailure(e.toString()));
      }
    }
  }
}

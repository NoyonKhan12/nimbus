import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/user_dtos.dart';
import '../../services/user_service.dart';

/// ProfileBloc — current user profile and saved locations.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.email,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  @override
  List<Object?> get props => [
        firstName, lastName, email, emergencyContactName,
        emergencyContactPhone,
      ];
}

class ProfileSavedLocationAdded extends ProfileEvent {
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  const ProfileSavedLocationAdded({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [label, address, latitude, longitude];
}

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<SavedLocation> savedLocations;

  const ProfileLoaded({
    required this.profile,
    required this.savedLocations,
  });

  @override
  List<Object?> get props => [profile, savedLocations];
}

class ProfileSaving extends ProfileState {
  final UserProfile profile;
  final List<SavedLocation> savedLocations;

  const ProfileSaving({
    required this.profile,
    required this.savedLocations,
  });

  @override
  List<Object?> get props => [profile, savedLocations];
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserService _userService;

  ProfileBloc({required UserService userService})
      : _userService = userService,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileSavedLocationAdded>(_onAddSavedLocation);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _userService.getCurrentUser();
      List<SavedLocation> locations = [];
      try {
        locations = await _userService.getSavedLocations();
      } catch (_) {
        // Saved locations are auxiliary — profile still renders without them.
      }
      emit(ProfileLoaded(profile: profile, savedLocations: locations));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded && current is! ProfileSaving) return;
    final UserProfile profile;
    final List<SavedLocation> locations;
    if (current is ProfileLoaded) {
      profile = current.profile;
      locations = current.savedLocations;
    } else {
      profile = (current as ProfileSaving).profile;
      locations = (current as ProfileSaving).savedLocations;
    }
    emit(ProfileSaving(profile: profile, savedLocations: locations));
    try {
      final updated = await _userService.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        emergencyContactName: event.emergencyContactName,
        emergencyContactPhone: event.emergencyContactPhone,
      );
      emit(ProfileLoaded(profile: updated, savedLocations: locations));
    } catch (e) {
      emit(ProfileLoaded(profile: profile, savedLocations: locations));
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onAddSavedLocation(
    ProfileSavedLocationAdded event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(ProfileSaving(
      profile: current.profile,
      savedLocations: current.savedLocations,
    ));
    try {
      await _userService.saveLocation(
        label: event.label,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final locations = await _userService.getSavedLocations();
      emit(ProfileLoaded(profile: current.profile, savedLocations: locations));
    } catch (e) {
      emit(ProfileLoaded(
        profile: current.profile,
        savedLocations: current.savedLocations,
      ));
      emit(ProfileFailure(e.toString()));
    }
  }
}

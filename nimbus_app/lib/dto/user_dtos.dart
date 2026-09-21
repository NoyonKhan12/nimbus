import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';

part 'user_dtos.freezed.dart';
part 'user_dtos.g.dart';

/// User profile from /me.
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? dialCode,
    String? photoUrl,
    String? nationalId,
    DateTime? dateOfBirth,
    String? gender,
    LocationDto? homeLocation,
    LocationDto? workLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Request to update user profile.
@freezed
class UpdateUserProfileRequest with _$UpdateUserProfileRequest {
  const factory UpdateUserProfileRequest({
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? nationalId,
  }) = _UpdateUserProfileRequest;

  factory UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserProfileRequestFromJson(json);
}

/// Saved location.
@freezed
class SavedLocation with _$SavedLocation {
  const factory SavedLocation({
    required String id,
    required String label,
    required String address,
    required LocationDto location,
    bool? isFavorite,
  }) = _SavedLocation;

  factory SavedLocation.fromJson(Map<String, dynamic> json) =>
      _$SavedLocationFromJson(json);
}

/// Request to save a location.
@freezed
class SaveLocationRequest with _$SaveLocationRequest {
  const factory SaveLocationRequest({
    required String label,
    required String address,
    required LocationDto location,
    bool? isFavorite,
  }) = _SaveLocationRequest;

  factory SaveLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveLocationRequestFromJson(json);
}

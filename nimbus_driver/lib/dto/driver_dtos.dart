import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';

part 'driver_dtos.freezed.dart';
part 'driver_dtos.g.dart';

@freezed
class DriverProfile with _$DriverProfile {
  const factory DriverProfile({
    required String id,
    String? name,
    String? phone,
    double? rating,
    int? totalRides,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DriverProfile;

  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);
}

@freezed
class DriverEligibility with _$DriverEligibility {
  const factory DriverEligibility({
    required bool eligible,
    required List<String> missingRequirements,
    String? reason,
  }) = _DriverEligibility;

  factory DriverEligibility.fromJson(Map<String, dynamic> json) =>
      _$DriverEligibilityFromJson(json);
}

@freezed
class DriverDocument with _$DriverDocument {
  const factory DriverDocument({
    required String id,
    required String type,
    required String number,
    required String status,
    DateTime? expiresAt,
    String? photoUrl,
    DateTime? uploadedAt,
  }) = _DriverDocument;

  factory DriverDocument.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentFromJson(json);
}

@freezed
class DriverDocumentRequest with _$DriverDocumentRequest {
  const factory DriverDocumentRequest({
    required String type,
    required String number,
    required String photoUrl,
    DateTime? expiresAt,
  }) = _DriverDocumentRequest;

  factory DriverDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentRequestFromJson(json);
}

@freezed
class DriverEarnings with _$DriverEarnings {
  const factory DriverEarnings({
    required double totalEarnings,
    required double pendingSettlement,
    required double availableBalance,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) = _DriverEarnings;

  factory DriverEarnings.fromJson(Map<String, dynamic> json) =>
      _$DriverEarningsFromJson(json);
}

@freezed
class DriverSettlement with _$DriverSettlement {
  const factory DriverSettlement({
    required String id,
    required String driverId,
    required double grossAmount,
    required double commission,
    required double adjustments,
    required double payable,
    required String status,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? processedAt,
  }) = _DriverSettlement;

  factory DriverSettlement.fromJson(Map<String, dynamic> json) =>
      _$DriverSettlementFromJson(json);
}

@freezed
class DriverLocationUpdate with _$DriverLocationUpdate {
  const factory DriverLocationUpdate({
    required String rideId,
    required LocationDto location,
    double? heading,
    double? speed,
  }) = _DriverLocationUpdate;

  factory DriverLocationUpdate.fromJson(Map<String, dynamic> json) =>
      _$DriverLocationUpdateFromJson(json);
}

enum DriverAvailability { online, offline, away }

@freezed
class DriverStatusResponse with _$DriverStatusResponse {
  const factory DriverStatusResponse({
    required String driverId,
    required DriverAvailability availability,
    bool? isAcceptingRides,
  }) = _DriverStatusResponse;

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$DriverStatusResponseFromJson(json);
}

@freezed
class UpdateDriverStatusRequest with _$UpdateDriverStatusRequest {
  const factory UpdateDriverStatusRequest({
    required DriverAvailability availability,
    bool? isAcceptingRides,
  }) = _UpdateDriverStatusRequest;

  factory UpdateDriverStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDriverStatusRequestFromJson(json);
}

enum DriverVerificationLevel { basic, verified, premium }

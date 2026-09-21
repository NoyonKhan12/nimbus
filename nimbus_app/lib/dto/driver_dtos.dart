import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';

part 'driver_dtos.freezed.dart';
part 'driver_dtos.g.dart';

@freezed
class DriverApplicationRequest with _$DriverApplicationRequest {
  const factory DriverApplicationRequest({
    required String licenseNumber,
    required String nationalId,
    required String vehicleId,
    required String drivingLicensePhoto,
    required String nationalIdPhoto,
    String? vehicleRegistrationPhoto,
  }) = _DriverApplicationRequest;

  factory DriverApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverApplicationRequestFromJson(json);
}

@freezed
class DriverApplication with _$DriverApplication {
  const factory DriverApplication({
    required String id,
    required String userId,
    required String status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) = _DriverApplication;

  factory DriverApplication.fromJson(Map<String, dynamic> json) =>
      _$DriverApplicationFromJson(json);
}

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

enum DriverStatus { active, suspended, banned }
enum ApprovalStatus { pending, approved, rejected }

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
class Settlement with _$Settlement {
  const factory Settlement({
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
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
}

@freezed
class SettlementActionRequest with _$SettlementActionRequest {
  const factory SettlementActionRequest({
    required String action, // pay_out, hold, release
    String? reason,
  }) = _SettlementActionRequest;

  factory SettlementActionRequest.fromJson(Map<String, dynamic> json) =>
      _$SettlementActionRequestFromJson(json);
}

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    required String make,
    required String model,
    required int year,
    required String color,
    required String licensePlate,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}

@freezed
class CreateVehicleRequest with _$CreateVehicleRequest {
  const factory CreateVehicleRequest({
    required String make,
    required String model,
    required int year,
    required String color,
    required String licensePlate,
    String? photoUrl,
  }) = _CreateVehicleRequest;

  factory CreateVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVehicleRequestFromJson(json);
}

@freezed
class UpdateVehicleRequest with _$UpdateVehicleRequest {
  const factory UpdateVehicleRequest({
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? photoUrl,
    bool? isActive,
  }) = _UpdateVehicleRequest;

  factory UpdateVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateVehicleRequestFromJson(json);
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

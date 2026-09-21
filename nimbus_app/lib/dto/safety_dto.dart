import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_dto.freezed.dart';
part 'safety_dto.g.dart';

@freezed
class SafetyEvent with _$SafetyEvent {
  const factory SafetyEvent({
    required String id,
    required String userId,
    String? rideId,
    required String type,
    required String status,
    List<double>? location,
    String? note,
    DateTime? respondedAt,
    DateTime? createdAt,
  }) = _SafetyEvent;

  factory SafetyEvent.fromJson(Map<String, dynamic> json) =>
      _$SafetyEventFromJson(json);
}

@freezed
class SosRequest with _$SosRequest {
  const factory SosRequest({
    required String rideId,
    List<double>? location,
    String? note,
  }) = _SosRequest;

  factory SosRequest.fromJson(Map<String, dynamic> json) =>
      _$SosRequestFromJson(json);
}

@freezed
class TripShareResponse with _$TripShareResponse {
  const factory TripShareResponse({
    required bool shared,
    String? shareUrl,
    String? expiresAt,
  }) = _TripShareResponse;

  factory TripShareResponse.fromJson(Map<String, dynamic> json) =>
      _$TripShareResponseFromJson(json);
}

@freezed
class TripShareRequest with _$TripShareRequest {
  const factory TripShareRequest({
    required String rideId,
    int? durationMinutes,
  }) = _TripShareRequest;

  factory TripShareRequest.fromJson(Map<String, dynamic> json) =>
      _$TripShareRequestFromJson(json);
}

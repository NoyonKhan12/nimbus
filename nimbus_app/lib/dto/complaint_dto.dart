import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_dto.freezed.dart';
part 'complaint_dto.g.dart';

@freezed
class Complaint with _$Complaint {
  const factory Complaint({
    required String id,
    required String userId,
    required String? rideId,
    required String subject,
    required String description,
    String? status,
    String? response,
    DateTime? respondedAt,
    DateTime? createdAt,
  }) = _Complaint;

  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
}

@freezed
class CreateComplaintRequest with _$CreateComplaintRequest {
  const factory CreateComplaintRequest({
    required String subject,
    required String description,
    String? rideId,
  }) = _CreateComplaintRequest;

  factory CreateComplaintRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateComplaintRequestFromJson(json);
}

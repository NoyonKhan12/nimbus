import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_dto.freezed.dart';
part 'rating_dto.g.dart';

@freezed
class Rating with _$Rating {
  const factory Rating({
    required String id,
    required String rideId,
    required String fromUserId,
    required String toUserId,
    required double score,
    String? comment,
    DateTime? createdAt,
  }) = _Rating;

  factory Rating.fromJson(Map<String, dynamic> json) =>
      _$RatingFromJson(json);
}

@freezed
class CreateRatingRequest with _$CreateRatingRequest {
  const factory CreateRatingRequest({
    required String rideId,
    required String toUserId,
    required double score,
    String? comment,
  }) = _CreateRatingRequest;

  factory CreateRatingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRatingRequestFromJson(json);
}

import '../dto/complaint_dto.dart';
import '../dto/rating_dto.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for post-trip feedback: ratings and complaints.
class FeedbackService {
  final BackendApi _api;

  FeedbackService(this._api);

  /// Rates the driver after a completed journey.
  /// Backend `RatingRequest`: `{bookingId, ratedId, score, comment?}`.
  Future<Rating> createRating({
    required String bookingId,
    required String ratedUserId,
    required double score,
    String? comment,
  }) async {
    final body = await _api.post('/ratings', body: {
      'bookingId': bookingId,
      'ratedId': ratedUserId,
      'score': score,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    final data = body.dataMap;
    return Rating(
      id: data['id']?.toString() ?? '',
      rideId: data['rideId']?.toString() ?? '',
      fromUserId: data['raterId']?.toString() ?? '',
      toUserId: data['ratedId']?.toString() ?? ratedUserId,
      score: toDouble(data['score'], score),
      comment: data['comment']?.toString(),
      createdAt: toDateOrNull(data['createdAt']),
    );
  }

  /// Files a complaint, optionally tied to a booking.
  ///
  /// Backend contract: `{category, description, bookingId?}`. The category
  /// must be one of the values in [complaintCategories].
  Future<void> createComplaint({
    required String category,
    required String description,
    String? bookingId,
  }) async {
    await _api.post('/complaints', body: {
      'category': category,
      'description': description,
      if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
    });
  }

  /// Fetches a complaint with its operational status/resolution.
  Future<Complaint> getComplaint(String complaintId) async {
    final body = await _api.get('/complaints/$complaintId');
    return complaintFromJson(body.dataMap);
  }
}

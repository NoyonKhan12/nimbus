import '../dto/safety_dto.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for safety features: SOS and live trip sharing.
class SafetyService {
  final BackendApi _api;

  SafetyService(this._api);

  /// Triggers an SOS for an active ride with the current GPS position.
  Future<SafetyEvent> triggerSos({
    required String rideId,
    double? latitude,
    double? longitude,
    String? note,
  }) async {
    final body = await _api.post('/safety/sos', body: {
      'rideId': rideId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return safetyEventFromJson(body.dataMap);
  }

  /// Starts (or refreshes) a shareable live-trip link.
  /// The backend currently acknowledges without returning a URL.
  Future<bool> startTripShare({
    required String rideId,
    int durationMinutes = 120,
  }) async {
    final body = await _api.post('/safety/trip-share', body: {
      'rideId': rideId,
      'durationMinutes': durationMinutes,
    });
    return body['success'] == true;
  }

  /// Lists safety events recorded for a ride.
  Future<List<SafetyEvent>> getRideSafetyEvents(String rideId) async {
    final body = await _api.get('/safety/events/rides/$rideId');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(safetyEventFromJson)
        .toList();
  }
}

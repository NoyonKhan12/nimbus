import '../dto/ride_booking_dtos.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for ride discovery: search, details and seat availability.
class RideService {
  final BackendApi _api;

  RideService(this._api);

  /// Searches published rides matching origin/destination/time.
  ///
  /// Mirrors `GET /rides/search?originLat&originLng&destLat&destLng[&time]`.
  Future<List<Ride>> searchRides({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    DateTime? time,
  }) async {
    final body = await _api.get('/rides/search', query: {
      'originLat': originLat,
      'originLng': originLng,
      'destLat': destLat,
      'destLng': destLng,
      if (time != null) 'time': time.toUtc().toIso8601String(),
    });
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(rideFromJson)
        .toList();
  }

  /// Lists rides known to the current user (creations, past trips).
  Future<List<Ride>> listRides() async {
    final body = await _api.get('/rides');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(rideFromJson)
        .toList();
  }

  /// Fetches a single ride.
  Future<Ride> getRide(String rideId) async {
    final body = await _api.get('/rides/$rideId');
    return rideFromJson(body.dataMap);
  }
}

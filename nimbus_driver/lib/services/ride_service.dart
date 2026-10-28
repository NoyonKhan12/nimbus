import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Ride lifecycle for drivers: create, publish, start, complete, cancel,
/// plus GPS position streaming during an active trip.
class RideService {
  final BackendApi _api;

  RideService(this._api);

  /// Creates a ride. [origin]/[destination] are sent as `[lng, lat]`
  /// (backend `CreateRideRequest` GeoJSON order).
  Future<Ride> create({
    required String rideType, // SCHEDULED | INSTANT
    DateTime? scheduledAt,
    required String vehicleId,
    required double originLat,
    required double originLng,
    String? originAddress,
    required double destLat,
    required double destLng,
    String? destAddress,
    required int availableSeats,
    int? maxDetourMeters,
    int? maxWaitSeconds,
    String? notes,
  }) async {
    final body = await _api.post('/rides', body: {
      'rideType': rideType,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'vehicleId': vehicleId,
      'origin': [originLng, originLat],
      if (originAddress != null) 'originAddress': originAddress,
      'destination': [destLng, destLat],
      if (destAddress != null) 'destinationAddress': destAddress,
      'availableSeats': availableSeats,
      'maxDetourMeters': maxDetourMeters ?? 2000,
      'maxWaitSeconds': maxWaitSeconds ?? 300,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Ride.fromJson(body.dataMap);
  }

  /// Lists rides created by the current driver.
  Future<List<Ride>> listMine() async {
    final body = await _api.get('/rides');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(Ride.fromJson)
        .toList();
  }

  Future<Ride> get(String rideId) async {
    final body = await _api.get('/rides/$rideId');
    return Ride.fromJson(body.dataMap);
  }

  Future<Ride> publish(String rideId) =>
      _action(rideId, 'publish', 'Ride published');

  /// Locks the route (required before start; makes the execution route
  /// the authoritative version).
  Future<Ride> routeLock(String rideId) =>
      _action(rideId, 'route-lock', 'Route locked');

  /// Starts the ride. The backend requires the route to be locked first,
  /// so this locks the route and then starts.
  Future<Ride> start(String rideId) async {
    await routeLock(rideId);
    return _action(rideId, 'start', 'Ride started');
  }

  Future<Ride> complete(String rideId) =>
      _action(rideId, 'complete', 'Ride completed');

  Future<Ride> cancel(String rideId) =>
      _action(rideId, 'cancel', 'Ride cancelled');

  Future<Ride> _action(String rideId, String action, String ok) async {
    final body = await _api.post('/rides/$rideId/$action');
    return Ride.fromJson(body.dataMap);
  }

  /// Streams the driver's GPS position during an active trip
  /// (`POST /rides/{rideId}/driver-location?lat=&lng=`).
  Future<void> updateLocation(
    String rideId, {
    required double lat,
    required double lng,
  }) async {
    await _api.post('/rides/$rideId/driver-location', query: {
      'lat': lat,
      'lng': lng,
    });
  }

  /// Bookings (passengers) on this ride — driver only
  /// (`GET /bookings/ride/{rideId}`).
  Future<List<PassengerBooking>> rideBookings(String rideId) async {
    final body = await _api.get('/bookings/ride/$rideId');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(PassengerBooking.fromJson)
        .toList();
  }
}

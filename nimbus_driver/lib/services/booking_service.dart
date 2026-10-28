import '../network/backend_api.dart';

/// Driver-side booking actions: mark passengers picked up / dropped off.
/// The backend authorizes these to the ride creator only, and enforces
/// CONFIRMED → PICKED_UP → dropoff ordering.
class BookingService {
  final BackendApi _api;

  BookingService(this._api);

  /// Marks the passenger as picked up.
  Future<void> pickup(String bookingId) async {
    await _api.post('/bookings/$bookingId/pickup');
  }

  /// Marks the passenger as dropped off.
  Future<void> dropoff(String bookingId) async {
    await _api.post('/bookings/$bookingId/dropoff');
  }
}

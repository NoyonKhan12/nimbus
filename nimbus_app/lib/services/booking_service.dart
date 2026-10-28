import 'package:uuid/uuid.dart';

import '../dto/fare_quote_dto.dart';
import '../dto/ride_booking_dtos.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for the booking lifecycle: fare quotes, seat holds and bookings.
class BookingService {
  final BackendApi _api;

  BookingService(this._api);

  /// Requests a versioned fare quote for [seats] on a ride, optionally
  /// applying a voucher code. The quote expires — book with its id in time.
  Future<FareQuoteDto> getFareQuote({
    required String rideId,
    required int seats,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String? voucherCode,
  }) async {
    final body = await _api.post('/fare/quote', body: {
      'rideId': rideId,
      'seats': seats,
      // [longitude, latitude] — same GeoJSON order as the booking payload.
      'pickupLocation': [pickupLng, pickupLat],
      'dropoffLocation': [dropoffLng, dropoffLat],
      if (voucherCode != null && voucherCode.isNotEmpty)
        'voucherCode': voucherCode,
    });
    return fareQuoteFromJson(body.dataMap);
  }

  /// Creates a booking, transactionally holding seats on the ride.
  ///
  /// Pickup/drop-off are sent as `[longitude, latitude]` pairs (GeoJSON
  /// order), matching the backend's `CreateBookingRequest`.
  Future<Booking> createBooking({
    required String rideId,
    required int seats,
    required double pickupLat,
    required double pickupLng,
    String? pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    String? dropoffAddress,
    required String fareQuoteId,
  }) async {
    final body = await _api.post('/bookings', body: {
      'rideId': rideId,
      'seats': seats,
      'pickupLocation': [pickupLng, pickupLat],
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      'dropoffLocation': [dropoffLng, dropoffLat],
      if (dropoffAddress != null) 'dropoffAddress': dropoffAddress,
      if (fareQuoteId.isNotEmpty) 'fareQuoteId': fareQuoteId,
    });
    return bookingFromJson(body.dataMap);
  }

  /// Lists the current user's bookings (active + past).
  Future<List<Booking>> listBookings() async {
    final body = await _api.get('/bookings');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(bookingFromJson)
        .toList();
  }

  /// Fetches the current state of a booking.
  Future<Booking> getBooking(String bookingId) async {
    final body = await _api.get('/bookings/$bookingId');
    return bookingFromJson(body.dataMap);
  }

  /// Confirms a HELD booking (converts the 5-minute hold into a seat).
  Future<Booking> confirmBooking(String bookingId) async {
    final body = await _api.post('/bookings/$bookingId/confirm');
    return bookingFromJson(body.dataMap);
  }

  /// Cancels a booking and releases the seat.
  Future<void> cancelBooking(String bookingId) async {
    await _api.post('/bookings/$bookingId/cancel');
  }

  /// Builds a fresh idempotency key for payment submissions.
  String newIdempotencyKey() => const Uuid().v4();
}

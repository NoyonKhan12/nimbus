import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';

part 'create_ride_dto.freezed.dart';
part 'create_ride_dto.g.dart';

/// Request DTO for creating a ride.
@freezed
class CreateRideRequest with _$CreateRideRequest {
  const factory CreateRideRequest({
    required String rideType, // SCHEDULED, INSTANT
    DateTime? scheduledAt,
    required String vehicleId,
    required LocationDto origin,
    required LocationDto destination,
    required int availableSeats,
    int? maxDetourMeters,
    int? maxWaitSeconds,
    String? notes,
  }) = _CreateRideRequest;

  factory CreateRideRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRideRequestFromJson(json);
}

/// Request DTO for creating a booking.
@freezed
class CreateBookingRequest with _$CreateBookingRequest {
  const factory CreateBookingRequest({
    required int seatCount,
    required LocationDto pickupLocation,
    String? pickupAddress,
    required LocationDto dropoffLocation,
    String? dropoffAddress,
    required String fareQuoteId,
  }) = _CreateBookingRequest;

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestFromJson(json);
}

/// Request DTO for creating a payment.
@freezed
class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String bookingId,
    required double amount,
    required String method, // bkash, nagad, card, etc.
    String? returnUrl,
    required String idempotencyKey,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
}

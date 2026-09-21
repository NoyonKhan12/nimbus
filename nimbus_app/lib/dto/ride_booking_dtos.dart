import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';
import 'fare_quote_dto.dart';

part 'ride_booking_dtos.freezed.dart';
part 'ride_booking_dtos.g.dart';

enum RideType { scheduled, instant, recurring }
enum RideStatus { draft, published, routeLocked, driverArriving, inProgress, interrupted, completed, cancelled }
enum BookingStatus { held, confirmed, pickedUp, completed, cancelled, expired, refundPending, refunded }

@freezed
class Ride with _$Ride {
  const factory Ride({
    required String id,
    String? driverId,
    String? creatorId,
    String? vehicleId,
    required RideType rideType,
    required RideStatus status,
    DateTime? scheduledAt,
    required LocationDto origin,
    required LocationDto destination,
    required int totalSeats,
    required int availableSeats,
    int? maxDetourMeters,
    int? maxWaitSeconds,
    String? notes,
    String? routeVersion,
    String? fareRuleVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Ride;

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
}

@freezed
class UpdateRideRequest with _$UpdateRideRequest {
  const factory UpdateRideRequest({
    DateTime? scheduledAt,
    LocationDto? origin,
    LocationDto? destination,
    int? availableSeats,
    int? maxDetourMeters,
    int? maxWaitSeconds,
    String? notes,
  }) = _UpdateRideRequest;

  factory UpdateRideRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRideRequestFromJson(json);
}

@freezed
class CancelRideRequest with _$CancelRideRequest {
  const factory CancelRideRequest({
    String? reason,
  }) = _CancelRideRequest;

  factory CancelRideRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelRideRequestFromJson(json);
}

@freezed
class EtaResponse with _$EtaResponse {
  const factory EtaResponse({
    required int durationSeconds,
    required int distanceMeters,
    String? polyline,
  }) = _EtaResponse;

  factory EtaResponse.fromJson(Map<String, dynamic> json) =>
      _$EtaResponseFromJson(json);
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String rideId,
    required String passengerId,
    required int seats,
    required FareQuoteDto? fareQuote,
    required LocationDto pickupLocation,
    required LocationDto dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    required BookingStatus status,
    int? pickupStopSequence,
    int? dropoffStopSequence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

@freezed
class CancelBookingRequest with _$CancelBookingRequest {
  const factory CancelBookingRequest({
    String? reason,
  }) = _CancelBookingRequest;

  factory CancelBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingRequestFromJson(json);
}

@freezed
class FareQuoteRequest with _$FareQuoteRequest {
  const factory FareQuoteRequest({
    required String rideId,
    required LocationDto pickup,
    required LocationDto dropoff,
  }) = _FareQuoteRequest;

  factory FareQuoteRequest.fromJson(Map<String, dynamic> json) =>
      _$FareQuoteRequestFromJson(json);
}

@freezed
class RideHistoryItem with _$RideHistoryItem {
  const factory RideHistoryItem({
    required String id,
    required String driverName,
    required LocationDto origin,
    required LocationDto destination,
    required double fare,
    required DateTime scheduledAt,
    String? status,
  }) = _RideHistoryItem;

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$RideHistoryItemFromJson(json);
}

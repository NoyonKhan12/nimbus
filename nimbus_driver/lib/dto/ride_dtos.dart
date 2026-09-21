import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_dto.dart';
import 'fare_quote_dto.dart';
import 'driver_dtos.dart';

part 'ride_dtos.freezed.dart';
part 'ride_dtos.g.dart';

enum RideType { scheduled, instant, recurring }
enum RideStatus {
  draft,
  published,
  routeLocked,
  driverArriving,
  inProgress,
  interrupted,
  completed,
  cancelled
}

enum BookingStatus {
  held,
  confirmed,
  pickedUp,
  completed,
  cancelled,
  expired,
  refundPending,
  refunded
}

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
    List<StopInfo>? stops,
    DriverProfile? driver,
  }) = _Ride;

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
}

@freezed
class StopInfo with _$StopInfo {
  const factory StopInfo({
    required String id,
    required int sequence,
    required LocationDto location,
    DateTime? plannedPickupTime,
    DateTime? actualPickupTime,
    DateTime? plannedDropoffTime,
    DateTime? actualDropoffTime,
    String? bookingId,
    BookingStatus? status,
  }) = _StopInfo;

  factory StopInfo.fromJson(Map<String, dynamic> json) =>
      _$StopInfoFromJson(json);
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

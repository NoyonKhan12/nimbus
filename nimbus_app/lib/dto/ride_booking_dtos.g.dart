// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_booking_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RideImpl _$$RideImplFromJson(Map<String, dynamic> json) => _$RideImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String?,
      creatorId: json['creatorId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      rideType: $enumDecode(_$RideTypeEnumMap, json['rideType']),
      status: $enumDecode(_$RideStatusEnumMap, json['status']),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
      destination:
          LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
      totalSeats: (json['totalSeats'] as num).toInt(),
      availableSeats: (json['availableSeats'] as num).toInt(),
      maxDetourMeters: (json['maxDetourMeters'] as num?)?.toInt(),
      maxWaitSeconds: (json['maxWaitSeconds'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      routeVersion: json['routeVersion'] as String?,
      fareRuleVersion: json['fareRuleVersion'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RideImplToJson(_$RideImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'creatorId': instance.creatorId,
      'vehicleId': instance.vehicleId,
      'rideType': _$RideTypeEnumMap[instance.rideType]!,
      'status': _$RideStatusEnumMap[instance.status]!,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'origin': instance.origin,
      'destination': instance.destination,
      'totalSeats': instance.totalSeats,
      'availableSeats': instance.availableSeats,
      'maxDetourMeters': instance.maxDetourMeters,
      'maxWaitSeconds': instance.maxWaitSeconds,
      'notes': instance.notes,
      'routeVersion': instance.routeVersion,
      'fareRuleVersion': instance.fareRuleVersion,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$RideTypeEnumMap = {
  RideType.scheduled: 'scheduled',
  RideType.instant: 'instant',
  RideType.recurring: 'recurring',
};

const _$RideStatusEnumMap = {
  RideStatus.draft: 'draft',
  RideStatus.published: 'published',
  RideStatus.routeLocked: 'routeLocked',
  RideStatus.driverArriving: 'driverArriving',
  RideStatus.inProgress: 'inProgress',
  RideStatus.interrupted: 'interrupted',
  RideStatus.completed: 'completed',
  RideStatus.cancelled: 'cancelled',
};

_$UpdateRideRequestImpl _$$UpdateRideRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateRideRequestImpl(
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      origin: json['origin'] == null
          ? null
          : LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
      destination: json['destination'] == null
          ? null
          : LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
      availableSeats: (json['availableSeats'] as num?)?.toInt(),
      maxDetourMeters: (json['maxDetourMeters'] as num?)?.toInt(),
      maxWaitSeconds: (json['maxWaitSeconds'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$UpdateRideRequestImplToJson(
        _$UpdateRideRequestImpl instance) =>
    <String, dynamic>{
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'origin': instance.origin,
      'destination': instance.destination,
      'availableSeats': instance.availableSeats,
      'maxDetourMeters': instance.maxDetourMeters,
      'maxWaitSeconds': instance.maxWaitSeconds,
      'notes': instance.notes,
    };

_$CancelRideRequestImpl _$$CancelRideRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CancelRideRequestImpl(
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$CancelRideRequestImplToJson(
        _$CancelRideRequestImpl instance) =>
    <String, dynamic>{
      'reason': instance.reason,
    };

_$EtaResponseImpl _$$EtaResponseImplFromJson(Map<String, dynamic> json) =>
    _$EtaResponseImpl(
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      polyline: json['polyline'] as String?,
    );

Map<String, dynamic> _$$EtaResponseImplToJson(_$EtaResponseImpl instance) =>
    <String, dynamic>{
      'durationSeconds': instance.durationSeconds,
      'distanceMeters': instance.distanceMeters,
      'polyline': instance.polyline,
    };

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      passengerId: json['passengerId'] as String,
      seats: (json['seats'] as num).toInt(),
      fareQuote: json['fareQuote'] == null
          ? null
          : FareQuoteDto.fromJson(json['fareQuote'] as Map<String, dynamic>),
      pickupLocation:
          LocationDto.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation:
          LocationDto.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      pickupAddress: json['pickupAddress'] as String?,
      dropoffAddress: json['dropoffAddress'] as String?,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      pickupStopSequence: (json['pickupStopSequence'] as num?)?.toInt(),
      dropoffStopSequence: (json['dropoffStopSequence'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rideId': instance.rideId,
      'passengerId': instance.passengerId,
      'seats': instance.seats,
      'fareQuote': instance.fareQuote,
      'pickupLocation': instance.pickupLocation,
      'dropoffLocation': instance.dropoffLocation,
      'pickupAddress': instance.pickupAddress,
      'dropoffAddress': instance.dropoffAddress,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'pickupStopSequence': instance.pickupStopSequence,
      'dropoffStopSequence': instance.dropoffStopSequence,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.held: 'held',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.pickedUp: 'pickedUp',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.expired: 'expired',
  BookingStatus.refundPending: 'refundPending',
  BookingStatus.refunded: 'refunded',
};

_$CancelBookingRequestImpl _$$CancelBookingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CancelBookingRequestImpl(
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$CancelBookingRequestImplToJson(
        _$CancelBookingRequestImpl instance) =>
    <String, dynamic>{
      'reason': instance.reason,
    };

_$FareQuoteRequestImpl _$$FareQuoteRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$FareQuoteRequestImpl(
      rideId: json['rideId'] as String,
      pickup: LocationDto.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: LocationDto.fromJson(json['dropoff'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FareQuoteRequestImplToJson(
        _$FareQuoteRequestImpl instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'pickup': instance.pickup,
      'dropoff': instance.dropoff,
    };

_$RideHistoryItemImpl _$$RideHistoryItemImplFromJson(
        Map<String, dynamic> json) =>
    _$RideHistoryItemImpl(
      id: json['id'] as String,
      driverName: json['driverName'] as String,
      origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
      destination:
          LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toDouble(),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$RideHistoryItemImplToJson(
        _$RideHistoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverName': instance.driverName,
      'origin': instance.origin,
      'destination': instance.destination,
      'fare': instance.fare,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'status': instance.status,
    };

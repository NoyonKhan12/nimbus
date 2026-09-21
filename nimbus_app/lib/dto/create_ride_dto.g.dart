// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ride_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateRideRequestImpl _$$CreateRideRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateRideRequestImpl(
      rideType: json['rideType'] as String,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      vehicleId: json['vehicleId'] as String,
      origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
      destination:
          LocationDto.fromJson(json['destination'] as Map<String, dynamic>),
      availableSeats: (json['availableSeats'] as num).toInt(),
      maxDetourMeters: (json['maxDetourMeters'] as num?)?.toInt(),
      maxWaitSeconds: (json['maxWaitSeconds'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CreateRideRequestImplToJson(
        _$CreateRideRequestImpl instance) =>
    <String, dynamic>{
      'rideType': instance.rideType,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'vehicleId': instance.vehicleId,
      'origin': instance.origin,
      'destination': instance.destination,
      'availableSeats': instance.availableSeats,
      'maxDetourMeters': instance.maxDetourMeters,
      'maxWaitSeconds': instance.maxWaitSeconds,
      'notes': instance.notes,
    };

_$CreateBookingRequestImpl _$$CreateBookingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateBookingRequestImpl(
      seatCount: (json['seatCount'] as num).toInt(),
      pickupLocation:
          LocationDto.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      pickupAddress: json['pickupAddress'] as String?,
      dropoffLocation:
          LocationDto.fromJson(json['dropoffLocation'] as Map<String, dynamic>),
      dropoffAddress: json['dropoffAddress'] as String?,
      fareQuoteId: json['fareQuoteId'] as String,
    );

Map<String, dynamic> _$$CreateBookingRequestImplToJson(
        _$CreateBookingRequestImpl instance) =>
    <String, dynamic>{
      'seatCount': instance.seatCount,
      'pickupLocation': instance.pickupLocation,
      'pickupAddress': instance.pickupAddress,
      'dropoffLocation': instance.dropoffLocation,
      'dropoffAddress': instance.dropoffAddress,
      'fareQuoteId': instance.fareQuoteId,
    };

_$PaymentRequestImpl _$$PaymentRequestImplFromJson(Map<String, dynamic> json) =>
    _$PaymentRequestImpl(
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      returnUrl: json['returnUrl'] as String?,
      idempotencyKey: json['idempotencyKey'] as String,
    );

Map<String, dynamic> _$$PaymentRequestImplToJson(
        _$PaymentRequestImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'amount': instance.amount,
      'method': instance.method,
      'returnUrl': instance.returnUrl,
      'idempotencyKey': instance.idempotencyKey,
    };

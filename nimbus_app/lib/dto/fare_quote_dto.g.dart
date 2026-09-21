// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_quote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FareQuoteDtoImpl _$$FareQuoteDtoImplFromJson(Map<String, dynamic> json) =>
    _$FareQuoteDtoImpl(
      quoteId: json['quoteId'] as String,
      bookingId: json['bookingId'] as String?,
      fareRuleVersion: json['fareRuleVersion'] as String,
      routeVersion: json['routeVersion'] as String,
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      baseFare: (json['baseFare'] as num).toDouble(),
      distanceCharge: (json['distanceCharge'] as num).toDouble(),
      timeCharge: (json['timeCharge'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      grossFare: (json['grossFare'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      finalPayable: (json['finalPayable'] as num).toDouble(),
      currency: json['currency'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$FareQuoteDtoImplToJson(_$FareQuoteDtoImpl instance) =>
    <String, dynamic>{
      'quoteId': instance.quoteId,
      'bookingId': instance.bookingId,
      'fareRuleVersion': instance.fareRuleVersion,
      'routeVersion': instance.routeVersion,
      'distanceMeters': instance.distanceMeters,
      'durationSeconds': instance.durationSeconds,
      'baseFare': instance.baseFare,
      'distanceCharge': instance.distanceCharge,
      'timeCharge': instance.timeCharge,
      'serviceFee': instance.serviceFee,
      'tax': instance.tax,
      'grossFare': instance.grossFare,
      'discount': instance.discount,
      'finalPayable': instance.finalPayable,
      'currency': instance.currency,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

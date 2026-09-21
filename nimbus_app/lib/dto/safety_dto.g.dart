// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SafetyEventImpl _$$SafetyEventImplFromJson(Map<String, dynamic> json) =>
    _$SafetyEventImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rideId: json['rideId'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      location: (json['location'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      note: json['note'] as String?,
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SafetyEventImplToJson(_$SafetyEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'rideId': instance.rideId,
      'type': instance.type,
      'status': instance.status,
      'location': instance.location,
      'note': instance.note,
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$SosRequestImpl _$$SosRequestImplFromJson(Map<String, dynamic> json) =>
    _$SosRequestImpl(
      rideId: json['rideId'] as String,
      location: (json['location'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$SosRequestImplToJson(_$SosRequestImpl instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'location': instance.location,
      'note': instance.note,
    };

_$TripShareResponseImpl _$$TripShareResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TripShareResponseImpl(
      shared: json['shared'] as bool,
      shareUrl: json['shareUrl'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );

Map<String, dynamic> _$$TripShareResponseImplToJson(
        _$TripShareResponseImpl instance) =>
    <String, dynamic>{
      'shared': instance.shared,
      'shareUrl': instance.shareUrl,
      'expiresAt': instance.expiresAt,
    };

_$TripShareRequestImpl _$$TripShareRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$TripShareRequestImpl(
      rideId: json['rideId'] as String,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TripShareRequestImplToJson(
        _$TripShareRequestImpl instance) =>
    <String, dynamic>{
      'rideId': instance.rideId,
      'durationMinutes': instance.durationMinutes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintImpl _$$ComplaintImplFromJson(Map<String, dynamic> json) =>
    _$ComplaintImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rideId: json['rideId'] as String?,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String?,
      response: json['response'] as String?,
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ComplaintImplToJson(_$ComplaintImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'rideId': instance.rideId,
      'subject': instance.subject,
      'description': instance.description,
      'status': instance.status,
      'response': instance.response,
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CreateComplaintRequestImpl _$$CreateComplaintRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateComplaintRequestImpl(
      subject: json['subject'] as String,
      description: json['description'] as String,
      rideId: json['rideId'] as String?,
    );

Map<String, dynamic> _$$CreateComplaintRequestImplToJson(
        _$CreateComplaintRequestImpl instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'description': instance.description,
      'rideId': instance.rideId,
    };

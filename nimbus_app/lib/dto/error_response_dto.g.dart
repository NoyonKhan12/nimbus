// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ErrorResponseImpl _$$ErrorResponseImplFromJson(Map<String, dynamic> json) =>
    _$ErrorResponseImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: (json['status'] as num).toInt(),
      code: json['code'] as String,
      message: json['message'] as String,
      path: json['path'] as String?,
      traceId: json['traceId'] as String?,
      fieldErrors: (json['fieldErrors'] as List<dynamic>?)
          ?.map((e) => FieldError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ErrorResponseImplToJson(_$ErrorResponseImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'code': instance.code,
      'message': instance.message,
      'path': instance.path,
      'traceId': instance.traceId,
      'fieldErrors': instance.fieldErrors,
    };

_$FieldErrorImpl _$$FieldErrorImplFromJson(Map<String, dynamic> json) =>
    _$FieldErrorImpl(
      field: json['field'] as String,
      rejectedValue: json['rejectedValue'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$FieldErrorImplToJson(_$FieldErrorImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'rejectedValue': instance.rejectedValue,
      'message': instance.message,
    };

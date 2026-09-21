// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagedResponse<T> _$PagedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PagedResponse<T>(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$PagedResponseToJson<T>(
  PagedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map(toJsonT).toList(),
      'meta': instance.meta,
      'timestamp': instance.timestamp,
    };

PageMeta _$PageMetaFromJson(Map<String, dynamic> json) => PageMeta(
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PageMetaToJson(PageMeta instance) => <String, dynamic>{
      'page': instance.page,
      'size': instance.size,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
    };

import 'package:json_annotation/json_annotation.dart';

part 'paged_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResponse<T> {
  final bool success;
  final List<T> data;
  final PageMeta meta;
  final String timestamp;

  PagedResponse({
    required this.success,
    required this.data,
    required this.meta,
    required this.timestamp,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PagedResponseFromJson(json, fromJsonT);
}

@JsonSerializable()
class PageMeta {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  PageMeta({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) =>
      _$PageMetaFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
      'totalElements': totalElements,
      'totalPages': totalPages,
    };
  }
}

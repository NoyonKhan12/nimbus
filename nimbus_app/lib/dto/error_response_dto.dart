import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response_dto.freezed.dart';
part 'error_response_dto.g.dart';

/// Standard API error response matching the backend ErrorResponse.
@freezed
class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required DateTime timestamp,
    required int status,
    required String code,
    required String message,
    String? path,
    String? traceId,
    List<FieldError>? fieldErrors,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}

@freezed
class FieldError with _$FieldError {
  const factory FieldError({
    required String field,
    required String rejectedValue,
    required String message,
  }) = _FieldError;

  factory FieldError.fromJson(Map<String, dynamic> json) =>
      _$FieldErrorFromJson(json);
}

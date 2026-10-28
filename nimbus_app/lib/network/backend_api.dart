import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Exception carrying the backend's structured error payload
/// (`ErrorResponse{error: {code, message, details, traceId}}`).
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromBody(Map<String, dynamic> body, int? statusCode) {
    final error = body['error'];
    String code = 'UNKNOWN';
    String message = body['message']?.toString() ?? 'Something went wrong';
    if (error is Map<String, dynamic>) {
      code = error['code']?.toString() ?? code;
      message = error['message']?.toString() ?? message;
    }
    return ApiException(
      code: code,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiException.fromDio(DioException e) {
    final resp = e.response;
    final data = resp?.data;
    if (data is Map<String, dynamic>) {
      return ApiException.fromBody(data, resp?.statusCode);
    }
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = 'Network error. Please try again.';
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: message,
      statusCode: resp?.statusCode,
    );
  }

  @override
  String toString() => message;
}

/// Thin data-access layer over Dio that speaks the backend's envelope
/// contract: every response is `{success, data, message, timestamp}` and
/// every error is `{success: false, error: {code, message, ...}}`.
///
/// Methods return the raw envelope so callers can read `data` and, for
/// paged endpoints, `meta`.
class BackendApi {
  final Dio _dio;

  BackendApi(this._dio);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async =>
      _run(() => _dio.get(path, queryParameters: query));

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async =>
      _run(() => _dio.post(path, data: body, queryParameters: query));

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
  }) async =>
      _run(() => _dio.put(path, data: body));

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
  }) async =>
      _run(() => _dio.patch(path, data: body));

  Future<Map<String, dynamic>> delete(String path) async =>
      _run(() => _dio.delete(path));

  Future<Map<String, dynamic>> _run(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final success = body['success'];
        if (success == false) {
          throw ApiException.fromBody(body, response.statusCode);
        }
        return body;
      }
      // Non-envelope payloads pass through as-is.
      return {'data': body};
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('BackendApi: ${e.requestOptions.method} '
            '${e.requestOptions.path} failed: ${e.response?.data ?? e.message}');
      }
      throw ApiException.fromDio(e);
    }
  }
}

/// Helpers for extracting envelope contents.
extension EnvelopeX on Map<String, dynamic> {
  /// The `data` field of the standard `ApiResponse` envelope.
  dynamic get data => this['data'];

  /// The `data` field cast to a JSON object.
  Map<String, dynamic> get dataMap =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : {};

  /// The `data` field cast to a JSON array.
  List<dynamic> get dataList => data is List<dynamic> ? data as List<dynamic> : [];

  /// The `meta` field of a paged envelope, if present.
  Map<String, dynamic>? get metaMap =>
      this['meta'] is Map<String, dynamic> ? this['meta'] as Map<String, dynamic> : null;
}

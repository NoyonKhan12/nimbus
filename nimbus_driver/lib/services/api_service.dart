import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import '../network/backend_api.dart';

/// Centralized API service using Dio with JWT authentication.
/// Handles token storage, single-flight refresh, and interceptor logic.
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const _dioTimeout = 30000;
  static const _receiveTimeout = 30000;
  static const _connectTimeout = 15000;

  ApiService._(this._dio, this._secureStorage);

  static ApiService? _instance;

  factory ApiService() {
    if (_instance == null) {
      throw StateError(
          'ApiService not initialized. Call ApiService.init() first.');
    }
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) return;
    _instance = await _create();
  }

  static Future<ApiService> _create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiService._connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiService._receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiService._dioTimeout),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final service = ApiService._(dio, const FlutterSecureStorage());
    service._setupInterceptors();
    return service;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: StorageKeys.accessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;
          // The backend's JWT filter silently skips bad tokens, so Spring
          // Security rejects expired/missing auth with 403 (empty body) —
          // treat both 401 and 403 as "try to refresh and retry".
          final isAuthFailure = status == 401 || status == 403;
          if (isAuthFailure) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final request = error.requestOptions;
              final newToken =
                  await _secureStorage.read(key: StorageKeys.accessToken);
              if (newToken != null) {
                request.headers['Authorization'] = 'Bearer $newToken';
                return handler.resolve(await _dio.fetch(request));
              }
            }
            await _clearTokens();
          }
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  Future<bool>? _refreshInFlight;

  /// Single-flight refresh — concurrent 401/403 handlers share one call.
  Future<bool> _refreshToken() {
    return _refreshInFlight ??= _doRefreshToken().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _doRefreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) return false;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return false;
      final access = data['accessToken']?.toString();
      final refresh = data['refreshToken']?.toString();
      if (access == null || access.isEmpty) return false;
      await _secureStorage.write(key: StorageKeys.accessToken, value: access);
      if (refresh != null && refresh.isNotEmpty) {
        await _secureStorage.write(key: StorageKeys.refreshToken, value: refresh);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Stores auth tokens after successful OTP verification.
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await _secureStorage.write(
        key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() =>
      _secureStorage.read(key: StorageKeys.accessToken);

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logs out — best-effort server call, then clears local tokens.
  Future<void> logout() async {
    try {
      await BackendApi(_dio).post('/auth/logout');
    } catch (_) {
      // JWTs are stateless; local clearing is what matters.
    }
    await _clearTokens();
  }

  Dio get dio => _dio;
}

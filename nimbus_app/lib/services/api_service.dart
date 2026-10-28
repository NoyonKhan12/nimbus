import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import '../dto/auth_dtos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized API service using Dio with JWT authentication.
/// Handles token storage, refresh, and interceptor logic.
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const _dioTimeout = 30000;
  static const _receiveTimeout = 30000;
  static const _connectTimeout = 15000;

  ApiService._(this._dio, this._secureStorage);

  static ApiService? _instance;

  /// Factory constructor to provide singleton access.
  factory ApiService() {
    if (_instance == null) {
      throw StateError(
          'ApiService not initialized. Call ApiService.init() first.');
    }
    return _instance!;
  }

  /// Initialize the ApiService singleton.
  static Future<void> init() async {
    if (_instance != null) return;
    _instance = await _create();
  }

  /// Internal initialization that builds the Dio client.
  static Future<ApiService> _create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiService._connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiService._receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiService._dioTimeout),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final secureStorage = const FlutterSecureStorage();
    final service = ApiService._(dio, secureStorage);
    service._setupInterceptors();
    return service;
  }

  void _setupInterceptors() {
    // Auth interceptor — injects JWT token from storage.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: StorageKeys.accessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Inject Idempotency-Key for non-GET requests if not already set.
          if (options.method != 'GET' &&
              options.headers['Idempotency-Key'] == null) {
            // Idempotency key is set per-request by the caller if needed.
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
            // Refresh failed — force logout.
            await _clearTokens();
            // Signal logout via callback or event (handled by UI layer).
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor in debug mode.
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// In-flight refresh future — shared by concurrent 401 handlers so only
  /// ONE `/auth/refresh` call happens at a time (with refresh-token
  /// rotation, parallel refreshes would revoke each other's tokens).
  Future<bool>? _refreshInFlight;

  /// Refreshes the JWT access token using the stored refresh token.
  ///
  /// Single-flight: concurrent callers await the same future.
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

      if (response.statusCode == 200) {
        // The backend wraps tokens in the ApiResponse envelope:
        // `{success, data: {accessToken, refreshToken, expiresIn}, ...}`.
        final body = response.data;
        if (body is! Map<String, dynamic>) return false;
        final data = body['data'];
        if (data is! Map<String, dynamic>) return false;
        final access = data['accessToken']?.toString();
        final refresh = data['refreshToken']?.toString();
        if (access == null || access.isEmpty) return false;
        await _secureStorage.write(key: StorageKeys.accessToken, value: access);
        if (refresh != null && refresh.isNotEmpty) {
          await _secureStorage.write(
            key: StorageKeys.refreshToken,
            value: refresh,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);

    // Also clear SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Stores auth tokens after successful OTP verification.
  Future<void> storeTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: tokens.refreshToken,
    );
    if (tokens.sessionId != null) {
      await _secureStorage.write(
        key: StorageKeys.sessionId,
        value: tokens.sessionId,
      );
    }
  }

  /// Retrieves the current JWT access token.
  Future<String?> getAccessToken() =>
      _secureStorage.read(key: StorageKeys.accessToken);

  /// Checks if the user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logs out — clears all stored tokens and user data.
  Future<void> logout() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (e) {
      // Best-effort logout; we still clear local tokens.
    }
    await _clearTokens();
  }

  Dio get dio => _dio;
}

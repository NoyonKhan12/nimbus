import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import '../dto/auth_dtos.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized API service using Dio with JWT authentication.
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static ApiService? _instance;

  ApiService._(this._dio, this._secureStorage);

  factory ApiService() {
    _instance ??= _init();
    return _instance!;
  }

  static Future<ApiService> _init() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 30000),
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
          if (error.response?.statusCode == 401) {
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
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  Future<bool> _refreshToken() async {
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
        final tokens = RefreshTokenResponse.fromJson(response.data);
        await _secureStorage.write(
            key: StorageKeys.accessToken, value: tokens.accessToken);
        await _secureStorage.write(
            key: StorageKeys.refreshToken, value: tokens.refreshToken);
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
    await _secureStorage.delete(key: StorageKeys.sessionId);
  }

  Future<void> storeTokens(AuthTokens tokens) async {
    await _secureStorage.write(
        key: StorageKeys.accessToken, value: tokens.accessToken);
    await _secureStorage.write(
        key: StorageKeys.refreshToken, value: tokens.refreshToken);
    if (tokens.sessionId != null) {
      await _secureStorage.write(
          key: StorageKeys.sessionId, value: tokens.sessionId);
    }
  }

  Future<String?> getAccessToken() =>
      _secureStorage.read(key: StorageKeys.accessToken);

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (e) {
      // Best-effort.
    }
    await _clearTokens();
  }

  Dio get dio => _dio;
}

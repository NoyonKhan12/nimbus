import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../dto/auth_dtos.dart';
import '../network/backend_api.dart';
import 'api_service.dart';
import 'push_notification_service.dart';

/// Auth service that orchestrates OTP send/verify, token storage and logout
/// against the backend contract:
///  - `POST /auth/send-otp`   `{phone}`
///  - `POST /auth/verify-otp`
///    `{phone, otp, deviceId?, platform?, appVersion?, pushToken?}` →
///    `AuthResponse{accessToken, refreshToken, expiresIn, user}`
///  - `POST /auth/logout`
class AuthService {
  final BackendApi _api;
  final ApiService _apiService;

  AuthService(ApiService apiService)
      : _api = BackendApi(apiService.dio),
        _apiService = apiService;

  /// Sends an OTP to the given Bangladesh phone number.
  ///
  /// [phone] must be in the backend's required `+8801[3-9]XXXXXXXX`
  /// format. `purpose` is mandatory on `SendOtpRequest`.
  Future<void> sendOtp({required String phone}) async {
    await _api.post('/auth/send-otp', body: {
      'phone': phone,
      'purpose': 'LOGIN',
    });
  }

  /// Verifies the OTP and stores the resulting tokens.
  /// Returns [true] if verification succeeds, [false] otherwise.
  Future<bool> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final body = await _api.post('/auth/verify-otp', body: {
        'phone': phone,
        'otp': code,
        // Stable per-install device identifier (see [_stableDeviceId]) —
        // lets the backend track push registration per real device instead
        // of the previous hard-coded 'mobile-app' placeholder.
        'deviceId': await _stableDeviceId(),
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'IOS'
            : 'ANDROID',
        'appVersion': AppConstants.appVersion,
        // FCM token when Firebase is configured; null otherwise (the
        // PushNotificationService guards unconfigured projects).
        'pushToken': PushNotificationService.instance.currentToken,
      });

      final data = body.dataMap;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      if (accessToken == null || accessToken.isEmpty) return false;

      final expiresInSeconds =
          (data['expiresIn'] as num?)?.toInt() ?? 900;
      final tokens = AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
        accessTokenExpiresAt:
            DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds)),
        refreshTokenExpiresAt:
            DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      await _apiService.storeTokens(tokens);
      return true;
    } on ApiException {
      // Structured backend error (validation, expired OTP, server error…) —
      // rethrow so the UI can show the real reason instead of a generic
      // "invalid OTP".
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: OTP verification failed: $e');
      }
      return false;
    }
  }

  /// Checks if the user is currently authenticated.
  Future<bool> isAuthenticated() => _apiService.isAuthenticated();

  /// Logs the user out (server call is best-effort; tokens always cleared).
  Future<void> logout() => _apiService.logout();

  /// Stable per-install device identifier.
  ///
  /// A UUID is generated locally the first time it is needed and persisted
  /// in SharedPreferences, so the same device reports the same `deviceId`
  /// across logins and app restarts (reinstalling resets it, which is the
  /// correct semantic for "new device"). No Firebase/native setup is
  /// required for this part.
  Future<String> _stableDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(AppConstants.deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'nimbus-${const Uuid().v4()}';
    await prefs.setString(AppConstants.deviceIdKey, id);
    return id;
  }
}

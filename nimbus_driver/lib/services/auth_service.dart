import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/storage_keys.dart';
import '../network/backend_api.dart';
import 'api_service.dart';
import 'websocket_service.dart';
import 'push_notification_service.dart';

/// Auth service for the driver app: OTP send/verify, token storage, logout,
/// and device/push registration.
///
/// Backend contract:
///  - `POST /auth/send-otp`   `{phone, purpose}`
///  - `POST /auth/verify-otp`
///    `{phone, otp, deviceId?, platform?, pushToken?, appVersion?}` →
///    `AuthResponse{accessToken, refreshToken, expiresIn, user}`
class AuthService {
  final BackendApi _api;
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService(ApiService apiService)
      : _api = BackendApi(apiService.dio),
        _apiService = apiService;

  /// Sends an OTP. [phone] must match the backend's `+8801[3-9]XXXXXXXX`.
  Future<void> sendOtp({required String phone}) async {
    await _api.post('/auth/send-otp', body: {'phone': phone, 'purpose': 'LOGIN'});
  }

  /// Verifies the OTP and stores tokens. Returns true on success; throws
  /// [ApiException] with the backend's real message on structured errors.
  Future<bool> verifyOtp({required String phone, required String code}) async {
    try {
      final body = await _api.post('/auth/verify-otp', body: {
        'phone': phone,
        'otp': code,
        // Device push registration. The token is null when Firebase is not
        // configured; the backend handles that safely.
        'deviceId': await _deviceId(),
        'platform': _platformName(),
        'appVersion': _appVersion,
        'pushToken': await pushToken(),
      });

      final data = body.dataMap;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString() ?? '';
      if (accessToken == null || accessToken.isEmpty) return false;

      await _apiService.storeTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Persist the user id — /topic/driver/{userId} is keyed on it.
      final user = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null;
      final userId = user?['id']?.toString();
      if (userId != null && userId.isNotEmpty) {
        await _secureStorage.write(key: StorageKeys.userId, value: userId);
      }
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthService: OTP verification failed: $e');
      return false;
    }
  }

  /// FCM device token when Firebase is configured (native config files
  /// present), else null — the PushNotificationService guards unconfigured
  /// projects, so this never throws.
  Future<String?> pushToken() async =>
      PushNotificationService.instance.currentToken;

  /// Locally-generated, persistent device id (survives reinstalls of the
  /// app only as long as app data; stable per install, which matches the
  /// refresh-session device tracking use case).
  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(StorageKeys.deviceId);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(StorageKeys.deviceId, id);
    }
    return id;
  }

  String _platformName() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      case TargetPlatform.macOS:
        return 'MACOS';
      case TargetPlatform.windows:
        return 'WINDOWS';
      case TargetPlatform.linux:
        return 'LINUX';
      default:
        return 'ANDROID';
    }
  }

  static const _appVersion = '1.0.0';

  /// The stored user id (set at verify-otp from AuthResponse.user.id).
  Future<String?> getUserId() =>
      _secureStorage.read(key: StorageKeys.userId);

  Future<bool> isAuthenticated() => _apiService.isAuthenticated();

  Future<void> logout() async {
    // Drop the real-time session first so no push arrives mid-teardown.
    try {
      WebsocketService().disconnect();
    } catch (_) {}
    await _apiService.logout();
  }
}

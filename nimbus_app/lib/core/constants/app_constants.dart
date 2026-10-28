import 'package:flutter/foundation.dart';

/// Application-wide constants for the Nimbus passenger app.
///
/// API endpoints are supplied at build time:
///
/// ```sh
/// flutter build appbundle --release \
///   --dart-define=API_BASE_URL=https://api.example.com/api/v1 \
///   --dart-define=WS_BASE_URL=wss://api.example.com/api/v1/ws
/// ```
///
/// Release builds refuse plain HTTP unless `ALLOW_INSECURE_HTTP=true` is
/// explicitly supplied for a local verification build. Debug builds default
/// to the host loopback for the current platform.
class AppConstants {
  static const String _configuredApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');
  static const String _configuredWsBaseUrl =
      String.fromEnvironment('WS_BASE_URL');
  static const bool _allowInsecureHttp = bool.fromEnvironment(
    'ALLOW_INSECURE_HTTP',
    defaultValue: false,
  );

  /// Base URL used by Dio and the WebSocket service.
  static String get apiBaseUrl {
    final configured = _configuredApiBaseUrl.trim();
    if (configured.isNotEmpty) return _withoutTrailingSlash(configured);

    // Android emulators reach the host through 10.0.2.2. iOS simulators and
    // desktop use the loopback interface. Physical devices must be built
    // with an explicit API_BASE_URL.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:9090/api/v1';
    }
    return 'http://127.0.0.1:9090/api/v1';
  }

  /// WebSocket endpoint. Derived from [apiBaseUrl] when not supplied.
  static String get wsBaseUrl {
    final configured = _configuredWsBaseUrl.trim();
    if (configured.isNotEmpty) return _withoutTrailingSlash(configured);
    return '${apiBaseUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws';
  }

  /// Fails fast when a release build would send traffic over plain HTTP.
  ///
  /// This is called before the widget tree starts so a misconfigured build
  /// cannot silently ship credentials or trip data over the network in
  /// cleartext.
  static void validate() {
    final api = Uri.tryParse(apiBaseUrl);
    final ws = Uri.tryParse(wsBaseUrl);
    if (api == null || !api.hasScheme || api.host.isEmpty) {
      throw StateError('Invalid API_BASE_URL: $apiBaseUrl');
    }
    if (ws == null || !ws.hasScheme || ws.host.isEmpty) {
      throw StateError('Invalid WS_BASE_URL: $wsBaseUrl');
    }

    if (kReleaseMode && !_allowInsecureHttp) {
      if (api.scheme != 'https') {
        throw StateError(
          'Release builds require an HTTPS API_BASE_URL. '
          'Refusing to start with $apiBaseUrl.',
        );
      }
      if (ws.scheme != 'wss') {
        throw StateError(
          'Release builds require a WSS WS_BASE_URL. '
          'Refusing to start with $wsBaseUrl.',
        );
      }
    }
  }

  static String _withoutTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  // Auth
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  /// Stable locally-generated device identifier (persisted in
  /// SharedPreferences, generated on first use of verify-otp).
  static const String deviceIdKey = 'app_device_id';

  /// App version reported to the backend on verify-otp. Kept in sync with
  /// `version` in pubspec.yaml (package info endpoint not used here).
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0+1',
  );

  // OTP
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 30;

  // Storage
  //
  // Fallback avatar URL for users without a photo. Initials-based avatar
  // (ui-avatars.com), matching the app's own avatar fallback pattern of
  // showing the user's initial over the primary colour (see
  // profile_page.dart). Never hardcode this URL into a NetworkImage
  // without a loading-error fallback.
  static const String defaultPhotoUrl =
      'https://ui-avatars.com/api/?name=N&size=150&background=1565C0&color=fff';

  // Seat limits
  static const int maxSeats = 4;

  // Map
  static const double defaultZoom = 14.0;
  static const double pickupZoom = 16.0;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Seat hold
  static const int seatHoldMinutes = 5;

  // Currency
  static const String currency = 'BDT';
  static const String currencySymbol = '৳';
}

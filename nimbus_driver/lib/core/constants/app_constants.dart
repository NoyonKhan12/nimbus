import 'package:flutter/foundation.dart';

/// Application-wide constants for the Nimbus Driver app.
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
/// explicitly supplied for a local verification build.
class AppConstants {
  static const String _configuredApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');
  static const String _configuredWsBaseUrl =
      String.fromEnvironment('WS_BASE_URL');
  static const bool _allowInsecureHttp = bool.fromEnvironment(
    'ALLOW_INSECURE_HTTP',
    defaultValue: false,
  );

  static String get apiBaseUrl {
    final configured = _configuredApiBaseUrl.trim();
    if (configured.isNotEmpty) return _withoutTrailingSlash(configured);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:9090/api/v1';
    }
    return 'http://127.0.0.1:9090/api/v1';
  }

  static String get wsBaseUrl {
    final configured = _configuredWsBaseUrl.trim();
    if (configured.isNotEmpty) return _withoutTrailingSlash(configured);
    return '${apiBaseUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws';
  }

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
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // OTP
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 30;

  // Map
  static const double defaultZoom = 14.0;

  // Currency
  static const String currencySymbol = '৳';

  // GPS sharing cadence during active trips (guide §5: 5–10 s)
  static const int gpsShareSeconds = 8;
}

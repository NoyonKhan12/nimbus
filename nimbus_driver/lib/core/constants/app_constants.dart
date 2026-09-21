/// Application-wide constants for the Nimbus Driver app.
class AppConstants {
  // API - use 10.0.2.2 for Android emulator access to host
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:9090/api/v1',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://10.0.2.2:9090/ws',
  );

  // Auth
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // OTP
  static const int otpLength = 6;

  // Map
  static const double defaultZoom = 14.0;
}

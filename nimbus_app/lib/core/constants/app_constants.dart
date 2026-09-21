/// Application-wide constants for the Nimbus client app.
class AppConstants {
  // API - use host.docker.internal for Android emulator access
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:9090/api/v1',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://10.0.2.2:9090/ws',
  );

  // Auth
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // OTP
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 30;

  // Storage
  static const String defaultPhotoUrl =
      'https://via.placeholder.com.com/150';

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

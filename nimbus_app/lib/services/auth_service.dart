import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../dto/auth_dtos.dart';
import 'api_service.dart';

/// Auth service that orchestrates OTP send/verify, token management, and logout.
class AuthService {
  final ApiClient _apiClient;
  final ApiService _apiService;

  AuthService(this._apiClient, this._apiService);

  /// Sends an OTP to the given phone number.
  Future<void> sendOtp({
    required String phone,
    required String dialCode,
  }) async {
    try {
      await _apiClient.sendOtp(
        SendOtpRequest(phone: phone, dialCode: dialCode),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verifies the OTP and stores the resulting tokens.
  /// Returns [true] if verification succeeds, [false] otherwise.
  Future<bool> verifyOtp({
    required String phone,
    required String dialCode,
    required String code,
    required bool termsAccepted,
  }) async {
    try {
      final tokens = await _apiClient.verifyOtp(
        VerifyOtpRequest(
          phone: phone,
          dialCode: dialCode,
          code: code,
          termsAccepted: termsAccepted,
        ),
      );

      await _apiService.storeTokens(tokens);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: OTP verification failed: $e');
      }
      return false;
    }
  }

  /// Checks if the user is currently authenticated.
  Future<bool> isAuthenticated() => _apiService.isAuthenticated();

  /// Retrieves the list of active sessions.
  Future<List<UserSession>> getSessions() async {
    return await _apiClient.getSessions();
  }

  /// Revokes a specific session by ID.
  Future<void> revokeSession(String sessionId) async {
    await _apiClient.revokeSession(sessionId);
  }

  /// Logs the user out and clears all stored tokens.
  Future<void> logout() async {
    await _apiService.logout();
  }
}

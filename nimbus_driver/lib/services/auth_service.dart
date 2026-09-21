import '../api/api_client.dart';
import '../dto/auth_dtos.dart';
import 'api_service.dart';

/// Service for authentication operations.
class AuthService {
  final ApiClient _apiClient;
  final ApiService _apiService;

  AuthService(this._apiClient, this._apiService);

  Future<void> sendOtp({
    required String phone,
    required String dialCode,
  }) async {
    await _apiClient.sendOtp(SendOtpRequest(phone: phone, dialCode: dialCode));
  }

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
      return false;
    }
  }

  Future<bool> isAuthenticated() => _apiService.isAuthenticated();

  Future<void> logout() => _apiService.logout();
}

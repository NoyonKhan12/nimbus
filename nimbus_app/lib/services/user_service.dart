import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../dto/user_dtos.dart';
import '../dto/ride_booking_dtos.dart';

/// Service for user profile management.
class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Fetches the current user's profile.
  Future<UserProfile> getCurrentUser() async {
    return await _apiClient.getCurrentUser();
  }

  /// Updates the current user's profile.
  Future<UserProfile> updateProfile(UpdateUserProfileRequest request) async {
    return await _apiClient.updateProfile(request);
  }

  /// Fetches the current user's ride history.
  Future<List<RideHistoryItem>> getHistory() async {
    return await _apiClient.getHistory();
  }
}

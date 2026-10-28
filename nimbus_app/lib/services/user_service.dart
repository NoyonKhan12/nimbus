import '../dto/user_dtos.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for the current user's profile and saved locations
/// (`GET/PUT /me`, `GET/POST /me/locations`).
class UserService {
  final BackendApi _api;

  UserService(this._api);

  /// Fetches the current user's profile.
  Future<UserProfile> getCurrentUser() async {
    final body = await _api.get('/me');
    return userProfileFromJson(body.dataMap);
  }

  /// Updates profile fields accepted by the backend
  /// (`UpdateUserRequest{firstName, lastName, email, emergencyContactName,
  /// emergencyContactPhone}`).
  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final body = await _api.put('/me', body: {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
      if (emergencyContactName != null)
        'emergencyContactName': emergencyContactName,
      if (emergencyContactPhone != null)
        'emergencyContactPhone': emergencyContactPhone,
    });
    return userProfileFromJson(body.dataMap);
  }

  /// Lists the user's saved locations.
  Future<List<SavedLocation>> getSavedLocations() async {
    final body = await _api.get('/me/locations');
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(savedLocationFromJson)
        .toList();
  }

  /// Saves a named location (home, work, ...).
  Future<SavedLocation> saveLocation({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final body = await _api.post('/me/locations', body: {
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    });
    return savedLocationFromJson(body.dataMap);
  }
}

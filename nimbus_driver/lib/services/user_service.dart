import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Current user (driver account) profile.
class UserService {
  final BackendApi _api;

  UserService(this._api);

  Future<DriverUser> getCurrentUser() async {
    final body = await _api.get('/me');
    return DriverUser.fromJson(body.dataMap);
  }

  Future<DriverUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final body = await _api.put('/me', body: {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
    });
    return DriverUser.fromJson(body.dataMap);
  }
}

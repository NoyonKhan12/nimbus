import '../dto/notification_dto.dart';
import '../network/backend_api.dart';
import '../network/backend_mapper.dart';

/// Service for in-app notifications.
class NotificationService {
  final BackendApi _api;

  NotificationService(this._api);

  /// Fetches the user's notifications, newest first.
  Future<List<Notification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final body = await _api.get(
      '/notifications',
      query: {'page': page, 'size': size},
    );
    return body.dataList
        .whereType<Map<String, dynamic>>()
        .map(notificationFromJson)
        .toList();
  }

  /// Marks a single notification as read.
  Future<void> markRead(String notificationId) async {
    await _api.post('/notifications/$notificationId/read');
  }
}

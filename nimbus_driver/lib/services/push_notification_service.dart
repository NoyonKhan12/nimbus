import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/config/firebase_config.dart';

/// Top-level handler required by FCM for data messages received while the
/// app is terminated/backgrounded. Notification payloads are rendered by the
/// OS; this handler is deliberately side-effect free beyond Firebase setup.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: FirebaseConfig.options);
}

/// A push message normalised for the app layer.
class PushNotification {
  const PushNotification({
    required this.title,
    required this.body,
    required this.data,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;

  String? get rideId => data['rideId']?.toString();
  String? get bookingId => data['bookingId']?.toString();
  String? get type => data['type']?.toString() ?? data['event']?.toString();
}

/// Push registration and message routing for the driver app.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final _messages = StreamController<PushNotification>.broadcast();
  final _taps = StreamController<PushNotification>.broadcast();
  final _tokenChanges = StreamController<String>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  String? _token;
  bool _initialized = false;

  String? get currentToken => _token;
  Stream<PushNotification> get messages => _messages.stream;
  Stream<PushNotification> get taps => _taps.stream;
  Stream<String> get tokenChanges => _tokenChanges.stream;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final options = FirebaseConfig.options;
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _token = await FirebaseMessaging.instance.getToken();
      if (_token != null) _tokenChanges.add(_token!);

      _subscriptions.add(
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          _token = token;
          _tokenChanges.add(token);
          if (kDebugMode) debugPrint('[Push] FCM token refreshed');
        }),
      );
      _subscriptions.add(
        FirebaseMessaging.onMessage.listen((message) {
          _messages.add(_normalise(message));
        }),
      );
      _subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          _taps.add(_normalise(message));
        }),
      );

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _taps.add(_normalise(initial));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push] Firebase not configured, push disabled: $e');
      }
      _token = null;
    }
  }

  PushNotification _normalise(RemoteMessage message) {
    final notification = message.notification;
    return PushNotification(
      title: notification?.title ?? 'Nimbus Driver',
      body: notification?.body ?? '',
      data: Map<String, dynamic>.from(message.data),
    );
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _messages.close();
    await _taps.close();
    await _tokenChanges.close();
  }
}

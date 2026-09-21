import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// WebSocket service for real-time ride event updates.
class WebsocketService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  final _eventController = StreamController<WsEvent>.broadcast();
  bool _connected = false;

  static WebsocketService? _instance;

  WebsocketService._();

  factory WebsocketService() {
    _instance ??= WebsocketService._();
    return _instance!;
  }

  Stream<WsEvent> get events => _eventController.stream;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected) return;

    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      throw StateError('No JWT token found.');
    }

    final uri = Uri.parse(AppConstants.wsBaseUrl);
    final wsUrl = uri.replace(queryParameters: {'token': token});

    try {
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );

      _connected = true;
      if (kDebugMode) {
        debugPrint('WebsocketService: connected');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebsocketService: error: $e');
      }
      _connected = false;
      rethrow;
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(ws_status.goingAway);
      _channel = null;
    }
    _connected = false;
  }

  void subscribeToRide(String rideId) {
    if (!_connected) return;
    _channel?.sink.add(_buildSubscribeFrame('/topic/ride/$rideId'));
  }

  void subscribeToDriver(String driverId) {
    if (!_connected) return;
    _channel?.sink.add(_buildSubscribeFrame('/topic/driver/$driverId'));
  }

  void _onMessage(dynamic data) {
    try {
      final message = data is String ? data : utf8.decode(data);
      final event = WsEvent.fromJsonString(message);
      if (event != null) {
        _eventController.add(event);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebsocketService: parse error: $e');
      }
    }
  }

  void _onError(error) {
    _connected = false;
    _reconnect();
  }

  void _onDone() {
    _connected = false;
    _reconnect();
  }

  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 5));
    try {
      await connect();
    } catch (e) {
      _reconnect();
    }
  }

  String _buildSubscribeFrame(String topic) {
    final headers = 'destination:$topic\nid:${DateTime.now().millisecondsSinceEpoch}';
    return 'SUBSCRIBE\n$headers\n\n\x00';
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _instance = null;
  }
}

/// WebSocket event from the server.
class WsEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WsEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  static WsEvent? fromJsonString(String json) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(json);
      final type = parsed['type'] as String? ?? 'UNKNOWN';
      final data = parsed['data'] as Map<String, dynamic>? ?? {};
      final ts = parsed['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(parsed['timestamp'].toString()))
          : DateTime.now();
      return WsEvent(type: type, data: data, timestamp: ts);
    } catch (_) {
      return null;
    }
  }
}

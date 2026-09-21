import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// WebSocket service for real-time ride and booking event updates.
///
/// Connects to `/ws` endpoint over STOMP and subscribes to ride-specific
/// and driver-specific topics. Events are broadcast to listeners.
class WebsocketService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  WebSocketChannel? _channel;
  final _eventController = StreamController<WsEvent>.broadcast();
  bool _connected = false;
  bool _connecting = false;

  static WebsocketService? _instance;

  WebsocketService._();

  factory WebsocketService() {
    _instance ??= WebsocketService._();
    return _instance!;
  }

  /// Stream of incoming WebSocket events.
  Stream<WsEvent> get events => _eventController.stream;

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _connected;

  /// Connects to the WebSocket endpoint.
  /// Requires a valid JWT token in storage.
  Future<void> connect() async {
    if (_connected || _connecting) return;

    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      throw StateError('No JWT token found. User must be authenticated.');
    }

    _connecting = true;

    try {
      // Build the WebSocket URL with token as a query parameter.
      // The backend /ws endpoint expects either a query param or a
      // Sec-WebSocket-Protocol header for JWT authentication.
      final uri = Uri.parse(AppConstants.wsBaseUrl);
      final wsUrl = uri.replace(
        queryParameters: {'token': token},
      );

      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true,
      );

      _connected = true;
      _connecting = false;

      if (kDebugMode) {
        debugPrint('WebsocketService: connected to ${wsUrl.toString()}');
      }
    } catch (e) {
      _connecting = false;
      _connected = false;
      if (kDebugMode) {
        debugPrint('WebsocketService: connection error: $e');
      }
      rethrow;
    }
  }

  /// Disconnects and closes the WebSocket connection.
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(ws_status.goingAway);
      _channel = null;
    }
    _connected = false;
    _connecting = false;
  }

  /// Subscribes to a ride topic: `/topic/ride/{rideId}`
  void subscribeToRide(String rideId) {
    if (!_connected) return;
    _send(StompFrame.subscribe('/topic/ride/$rideId'));
  }

  /// Subscribes to a driver topic: `/topic/driver/{driverId}`
  void subscribeToDriver(String driverId) {
    if (!_connected) return;
    _send(StompFrame.subscribe('/topic/driver/$driverId'));
  }

  /// Unsubscribes from a ride topic.
  void unsubscribeFromRide(String rideId) {
    if (!_connected) return;
    _send(StompFrame.unsubscribe('/topic/ride/$rideId'));
  }

  /// Sends a message to the server (e.g., driver location updates).
  void sendMessage(String destination, Map<String, dynamic> payload) {
    if (!_connected) return;
    _send(StompFrame.send(destination, payload));
  }

  void _send(String frame) {
    try {
      _channel?.sink.add(frame);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebsocketService: failed to send: $e');
      }
    }
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
        debugPrint('WebsocketService: failed to parse message: $e');
      }
    }
  }

  void _onError(error) {
    _connected = false;
    if (kDebugMode) {
      debugPrint('WebsocketService: error: $error');
    }
    // Attempt reconnection on error.
    _reconnect();
  }

  void _onDone() {
    _connected = false;
    if (kDebugMode) {
      debugPrint('WebsocketService: connection closed');
    }
    // Attempt reconnection on disconnect.
    _reconnect();
  }

  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 5));
    try {
      await connect();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WebsocketService: reconnect failed: $e');
      }
      // Retry again.
      _reconnect();
    }
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _instance = null;
  }
}

/// Represents a WebSocket event received from the backend.
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
              int.parse(parsed['timestamp'].toString()),
            )
          : DateTime.now();
      return WsEvent(type: type, data: data, timestamp: ts);
    } catch (e) {
      return null;
    }
  }
}

/// Minimal STOMP frame builder for subscription and message sending.
class StompFrame {
  StompFrame._();

  static String subscribe(String topic) {
    return 'SUBSCRIBE\ndestination:$topic\nid:${_generateId()}\n\n\x00';
  }

  static String unsubscribe(String topic) {
    return 'UNSUBSCRIBE\ndestination:$topic\nid:${_generateId()}\n\n\x00';
  }

  static String send(String destination, Map<String, dynamic> payload) {
    final body = jsonEncode(payload);
    return 'SEND\ndestination:$destination\ncontent-type:application/json\n\n$body\x00';
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

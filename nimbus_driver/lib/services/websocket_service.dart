import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../core/constants/app_constants.dart';
import '../core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// WebSocket service speaking the subset of STOMP 1.2 the Nimbus backend
/// uses (Spring `@EnableWebSocketMessageBroker` with a simple broker).
///
/// Backend specifics encoded here:
///  - The endpoint `/ws` is registered with SockJS, so the raw WebSocket
///    transport lives at `{WS_BASE_URL}/websocket`.
///  - The JWT is sent as the CONNECT native STOMP header
///    `authorization: Bearer <token>`. WebSocketChannelInterceptor rejects
///    CONNECT frames missing a valid token ("Authentication required"),
///    so this header is mandatory.
///  - MESSAGE bodies are `{event: "RIDE_STATUS_CHANGED", rideId?, data:
///    {...}, timestamp: "ISO-8601"}`; timestamps are ISO strings, not
///    epoch-millis.
///
/// Driver topics:
///  - `/topic/driver/{driverUserId}` — NEW_BOOKING (bookingId, seats).
///  - `/topic/ride/{rideId}` — RIDE_STATUS_CHANGED, BOOKING_STATUS_CHANGED,
///    SEAT_AVAILABILITY_CHANGED, RIDE_LOCATION_UPDATED, PASSENGER_PICKED_UP,
///    PASSENGER_DROPPED_OFF, DRIVER_ARRIVED, ETA_UPDATED.
///
/// Reliability model: subscriptions are registered before the session is
/// up and replayed after every reconnect; reconnects use capped exponential
/// backoff with jitter and are cancelled by [disconnect]/[dispose].
class WebsocketService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSub;
  Timer? _heartbeatTimer;
  Timer? _connectGuard;
  Timer? _reconnectTimer;

  final _eventController = StreamController<WsEvent>.broadcast();
  final _parser = StompFrameParser();

  /// Active subscriptions: destination → STOMP subscription id.
  /// Kept across reconnects so they can be replayed on CONNECTED.
  final Map<String, String> _subscriptions = {};

  bool _connected = false; // STOMP session established (CONNECTED received)
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;
  int _subSeq = 0;

  static WebsocketService? _instance;

  WebsocketService._();

  factory WebsocketService() {
    _instance ??= WebsocketService._();
    return _instance!;
  }

  /// Stream of incoming WebSocket events.
  Stream<WsEvent> get events => _eventController.stream;

  /// Whether a STOMP session is established.
  bool get isConnected => _connected;

  /// Exponential backoff with jitter: 1s, 2s, 4s … capped at 16s + ≤500ms.
  Duration get _backoff {
    final shift = _reconnectAttempt > 4 ? 4 : _reconnectAttempt;
    final base = 1000 * (1 << shift);
    final jitter = DateTime.now().microsecondsSinceEpoch % 500;
    return Duration(milliseconds: base + jitter);
  }

  /// Opens the socket and starts the STOMP CONNECT handshake with the
  /// authorization header taken from secure storage.
  ///
  /// Safe to call repeatedly: subscriptions requested before CONNECTED are
  /// flushed automatically once the session is established.
  Future<void> connect() async {
    if (_disposed || _connected || _connecting || _channel != null) return;
    // Flag set synchronously — before the first await — so concurrent
    // calls can't open two sockets.
    _connecting = true;

    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      _connecting = false;
      throw StateError('WebsocketService: no access token stored');
    }

    final base = AppConstants.wsBaseUrl.replaceAll(RegExp(r'/+$'), '');
    // SockJS raw WebSocket transport endpoint.
    final uri = Uri.parse('$base/websocket');

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    try {
      await channel.ready;
    } catch (e) {
      _connecting = false;
      _teardownSocket();
      if (kDebugMode) {
        debugPrint('WebsocketService: connect failed: $e');
      }
      _scheduleReconnect();
      rethrow;
    }

    _socketSub = channel.stream.listen(
      _onData,
      onError: (Object e) {
        if (kDebugMode) debugPrint('WebsocketService: error: $e');
        _handleLoss();
      },
      onDone: () {
        if (kDebugMode) debugPrint('WebsocketService: connection closed');
        _handleLoss();
      },
      cancelOnError: true,
    );

    _send(StompFrames.connect(token: token));
    _connecting = false; // TCP + WS handshake done; awaiting CONNECTED.

    // If the server never answers the CONNECT (e.g. rejected token),
    // treat it as a loss.
    _connectGuard = Timer(const Duration(seconds: 10), () {
      if (!_connected) {
        if (kDebugMode) {
          debugPrint('WebsocketService: CONNECT timed out');
        }
        _handleLoss();
      }
    });
  }

  /// Closes the session and stops all timers. Reconnects stop until
  /// [connect] is called again.
  void disconnect() {
    if (_connected) _send(StompFrames.disconnect());
    _connected = false;
    _teardownSocket();
  }

  /// Permanently stops the service and closes the event stream.
  void dispose() {
    disconnect();
    _disposed = true;
    _eventController.close();
    _instance = null;
  }

  /// Subscribes to a ride topic: `/topic/ride/{rideId}`.
  void subscribeToRide(String rideId) => _subscribe('/topic/ride/$rideId');

  /// Subscribes to the driver's private topic: `/topic/driver/{driverId}`
  /// (the driver **user** id, as used by the backend's broadcasts).
  void subscribeToDriver(String driverId) =>
      _subscribe('/topic/driver/$driverId');

  /// Unsubscribes from a ride topic.
  void unsubscribeFromRide(String rideId) =>
      _unsubscribe('/topic/ride/$rideId');

  /// Unsubscribes from a driver topic.
  void unsubscribeFromDriver(String driverId) =>
      _unsubscribe('/topic/driver/$driverId');

  /// Sends a JSON message to an application destination (`/app/...`).
  void sendMessage(String destination, Map<String, dynamic> payload) {
    if (!_connected) return;
    _send(StompFrames.send(destination, payload));
  }

  // ------------------------------------------------------------------
  // Internals
  // ------------------------------------------------------------------

  void _subscribe(String destination) {
    if (_disposed || _subscriptions.containsKey(destination)) return;
    final id = 'sub-${_subSeq++}';
    _subscriptions[destination] = id;
    if (_connected) _send(StompFrames.subscribe(destination, id));
  }

  void _unsubscribe(String destination) {
    final id = _subscriptions.remove(destination);
    if (id != null && _connected) _send(StompFrames.unsubscribe(id));
  }

  /// Replays every active subscription after (re)connecting.
  void _flushSubscriptions() {
    _subscriptions.forEach((destination, id) {
      _send(StompFrames.subscribe(destination, id));
    });
  }

  void _onData(dynamic data) {
    final text = data is String
        ? data
        : utf8.decode(data as List<int>, allowMalformed: true);
    for (final frame in _parser.add(text)) {
      switch (frame.command) {
        case 'CONNECTED':
          _connected = true;
          _reconnectAttempt = 0;
          _connectGuard?.cancel();
          _connectGuard = null;
          _startHeartbeat(frame.headers['heart-beat']);
          _flushSubscriptions();
          if (kDebugMode) {
            debugPrint('WebsocketService: STOMP session established');
          }
          break;
        case 'MESSAGE':
          final event = WsEvent.fromStompBody(frame.body);
          if (event != null) _eventController.add(event);
          break;
        case 'ERROR':
          // Server rejected something (e.g. an unauthorized subscription).
          // The session may still be usable; log and continue.
          if (kDebugMode) {
            debugPrint('WebsocketService: server ERROR frame: ${frame.body}');
          }
          break;
        default:
          break;
      }
    }
  }

  /// Negotiates client→server heart-beats from the CONNECTED header
  /// (`sx,sy`: client sends at max(our cx, server's sy)).
  void _startHeartbeat(String? headerBeat) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    var serverAccepts = 0;
    if (headerBeat != null) {
      final parts = headerBeat.split(',');
      if (parts.length == 2) serverAccepts = int.tryParse(parts[1]) ?? 0;
    }
    if (serverAccepts > 0) {
      final interval = max(10000, serverAccepts);
      _heartbeatTimer = Timer.periodic(
        Duration(milliseconds: interval),
        (_) => _send(StompFrames.heartbeat),
      );
    }
  }

  void _handleLoss() {
    final wasConnected = _connected;
    _connected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _connectGuard?.cancel();
    _connectGuard = null;
    _teardownSocket();
    if (_disposed) return;
    // Reset the backoff only when a session had actually been working, so
    // cold-start failures keep backing off instead of hot-looping.
    if (wasConnected) _reconnectAttempt = 0;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    final delay = _backoff;
    _reconnectAttempt += 1;
    if (kDebugMode) {
      debugPrint('WebsocketService: reconnecting in ${delay.inMilliseconds}ms '
          '(attempt $_reconnectAttempt)');
    }
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      connect().catchError((_) {
        // connect() already scheduled the next retry.
      });
    });
  }

  void _teardownSocket() {
    _connecting = false;
    _socketSub?.cancel();
    _socketSub = null;
    try {
      _channel?.sink.close(ws_status.goingAway);
    } catch (_) {
      // Sink may already be closed.
    }
    _channel = null;
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
}

/// A parsed STOMP frame.
class StompFrame {
  final String command;
  final Map<String, String> headers;
  final String body;

  const StompFrame(this.command, this.headers, this.body);
}

/// Incremental STOMP frame parser.
///
/// Feed raw socket chunks to [add]; complete frames (terminated by NUL) are
/// returned. Lone `\n` / `\r\n` bytes (heart-beats) are ignored.
class StompFrameParser {
  String _pending = '';

  List<StompFrame> add(String chunk) {
    _pending += chunk;
    final frames = <StompFrame>[];
    while (true) {
      // Strip heart-beat bytes between frames.
      var start = 0;
      while (start < _pending.length &&
          (_pending[start] == '\n' || _pending[start] == '\r')) {
        start++;
      }
      if (start > 0) _pending = _pending.substring(start);

      final nul = _pending.indexOf('\x00');
      if (nul < 0) break;
      final raw = _pending.substring(0, nul);
      _pending = _pending.substring(nul + 1);
      final frame = _parse(raw);
      if (frame != null) frames.add(frame);
    }
    return frames;
  }

  StompFrame? _parse(String raw) {
    final sep = raw.indexOf('\n\n');
    final headerPart = sep >= 0 ? raw.substring(0, sep) : raw;
    final body = sep >= 0 ? raw.substring(sep + 2) : '';
    final lines = headerPart.split('\n');
    final command = lines.first.trim();
    if (command.isEmpty) return null;
    final headers = <String, String>{};
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      final colon = line.indexOf(':');
      if (colon <= 0) continue;
      headers[line.substring(0, colon)] = line.substring(colon + 1);
    }
    return StompFrame(command, headers, body);
  }
}

/// STOMP frame encoder for the client-side commands Nimbus uses.
class StompFrames {
  StompFrames._();

  static const String heartbeat = '\n';

  static String encode(
    String command,
    Map<String, String> headers, [
    String body = '',
  ]) {
    final sb = StringBuffer(command);
    headers.forEach((key, value) => sb..write('\n')..write(key)..write(':')..write(value));
    sb..write('\n\n')..write(body)..write('\x00');
    return sb.toString();
  }

  /// The backend's WebSocketChannelInterceptor reads the native STOMP
  /// header `authorization` (lowercase) and requires the `Bearer ` prefix.
  static String connect({String? token}) {
    return encode('CONNECT', {
      'accept-version': '1.2',
      'heart-beat': '10000,10000',
      'host': 'nimbus',
      if (token != null && token.isNotEmpty)
        'authorization': 'Bearer $token',
    });
  }

  static String subscribe(String destination, String id) {
    return encode('SUBSCRIBE', {
      'destination': destination,
      'id': id,
      'ack': 'auto',
    });
  }

  static String unsubscribe(String id) {
    return encode('UNSUBSCRIBE', {'id': id});
  }

  static String send(String destination, Map<String, dynamic> payload) {
    return encode(
      'SEND',
      {
        'destination': destination,
        'content-type': 'application/json',
      },
      jsonEncode(payload),
    );
  }

  static String disconnect() => encode('DISCONNECT', const {});
}

/// Represents a real-time event received from the backend.
///
/// Bodies look like `{event: "RIDE_STATUS_CHANGED", rideId: "...",
/// data: {...}, timestamp: "2026-10-05T10:00:00Z"}`. Driver-topic events
/// (e.g. NEW_BOOKING) carry a top-level `bookingId` instead of `rideId`;
/// both are surfaced inside [data] for consumers.
class WsEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WsEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Parses a MESSAGE body, tolerating both the backend's `event` key and
  /// the documented `type` key, and ISO or epoch timestamps.
  static WsEvent? fromStompBody(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final type =
          (decoded['event'] ?? decoded['type'])?.toString() ?? 'UNKNOWN';
      final data = decoded['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded['data'] as Map<String, dynamic>)
          : <String, dynamic>{};
      if (decoded['rideId'] != null && !data.containsKey('rideId')) {
        data['rideId'] = decoded['rideId'];
      }
      if (decoded['bookingId'] != null && !data.containsKey('bookingId')) {
        data['bookingId'] = decoded['bookingId'];
      }
      return WsEvent(
        type: type,
        data: data,
        timestamp: _parseTimestamp(decoded['timestamp']),
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc() ?? DateTime.now().toUtc();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    return DateTime.now().toUtc();
  }
}

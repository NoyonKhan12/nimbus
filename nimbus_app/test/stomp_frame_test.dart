// Tests for the minimal STOMP client used for real-time ride events:
// frame encoding (client commands) and incremental parsing (server frames
// incl. heart-beats and chunked delivery).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus_app/services/websocket_service.dart';

void main() {
  group('StompFrames encoder', () {
    test('connect frame carries version, heart-beat and auth headers', () {
      final frame = StompFrames.connect(token: 'jwt-token');
      expect(frame, startsWith('CONNECT\n'));
      expect(frame, contains('accept-version:1.2'));
      expect(frame, contains('heart-beat:10000,10000'));
      expect(frame, contains('authorization:Bearer jwt-token'));
      expect(frame, endsWith('\n\n\x00'));
    });

    test('connect frame omits auth header when no token', () {
      expect(StompFrames.connect(), isNot(contains('authorization')));
    });

    test('subscribe frame has destination, id and auto ack', () {
      final frame = StompFrames.subscribe('/topic/ride/abc', 'sub-0');
      expect(frame, startsWith('SUBSCRIBE\n'));
      expect(frame, contains('destination:/topic/ride/abc'));
      expect(frame, contains('id:sub-0'));
      expect(frame, contains('ack:auto'));
    });

    test('send frame JSON-encodes the body', () {
      final frame = StompFrames.send('/app/location', {'lat': 23.8});
      expect(frame, contains('content-type:application/json'));
      expect(frame, contains(jsonEncode({'lat': 23.8})));
    });
  });

  group('StompFrameParser', () {
    test('parses a single complete frame', () {
      final parser = StompFrameParser();
      final frames = parser.add('CONNECTED\nversion:1.2\n\n\x00');
      expect(frames, hasLength(1));
      expect(frames.first.command, 'CONNECTED');
      expect(frames.first.headers['version'], '1.2');
      expect(frames.first.body, '');
    });

    test('parses a frame delivered in chunks', () {
      final parser = StompFrameParser();
      expect(parser.add('MESSAG'), isEmpty);
      expect(parser.add('E\ndestination:/topic/ride/1\n\n{"event":"X"}'), isEmpty);
      final frames = parser.add('\x00');
      expect(frames, hasLength(1));
      expect(frames.first.command, 'MESSAGE');
      expect(frames.first.headers['destination'], '/topic/ride/1');
      expect(frames.first.body, '{"event":"X"}');
    });

    test('parses multiple frames in one chunk', () {
      final parser = StompFrameParser();
      final frames = parser.add(
        'CONNECTED\nversion:1.2\n\n\x00'
        'MESSAGE\ndestination:/topic/a\n\none\x00'
        'MESSAGE\ndestination:/topic/b\n\ntwo\x00',
      );
      expect(frames, hasLength(3));
      expect(frames[1].body, 'one');
      expect(frames[2].body, 'two');
      expect(frames[2].headers['destination'], '/topic/b');
    });

    test('ignores heart-beat bytes between frames', () {
      final parser = StompFrameParser();
      expect(parser.add('\n'), isEmpty);
      expect(parser.add('\n\n'), isEmpty);
      final frames =
          parser.add('CONNECTED\nversion:1.2\n\n\x00\n\n\x00');
      // The trailing "\n\n\x00" after the frame is a heart-beat followed by
      // an empty frame start; the NUL with no command must not crash and
      // should not yield a frame.
      expect(frames, hasLength(1));
      expect(frames.first.command, 'CONNECTED');
    });

    test('header values may contain colons', () {
      final parser = StompFrameParser();
      final frames = parser.add('ERROR\nmessage:bad:input\n\n\x00');
      expect(frames.single.headers['message'], 'bad:input');
    });
  });

  group('WsEvent.fromStompBody', () {
    test('maps the backend payload {event, rideId, data, timestamp}', () {
      final event = WsEvent.fromStompBody(jsonEncode({
        'event': 'RIDE_LOCATION_UPDATED',
        'rideId': 'ride-1',
        'data': {'latitude': 23.81, 'longitude': 90.41},
        'timestamp': '2026-10-05T10:00:00Z',
      }));
      expect(event, isNotNull);
      expect(event!.type, 'RIDE_LOCATION_UPDATED');
      expect(event.data['latitude'], 23.81);
      expect(event.data['rideId'], 'ride-1'); // surfaced from top level
      expect(event.timestamp.year, 2026);
    });

    test('accepts the documented {type, ...} shape and epoch timestamps', () {
      final event = WsEvent.fromStompBody(jsonEncode({
        'type': 'ETA_UPDATED',
        'data': {'eta': 420},
        'timestamp': 1791571200000,
      }));
      expect(event!.type, 'ETA_UPDATED');
      expect(event.data['eta'], 420);
      expect(event.timestamp.isUtc, isTrue);
    });

    test('returns null for non-JSON bodies', () {
      expect(WsEvent.fromStompBody('not json'), isNull);
      expect(WsEvent.fromStompBody('[1,2,3]'), isNull);
    });
  });
}

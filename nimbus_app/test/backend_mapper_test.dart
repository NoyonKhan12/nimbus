// Tests for the hand-written backend → DTO mapping layer.
//
// These fixtures mirror the actual nimbus_api JSON contract: flat response
// DTOs, UPPER_SNAKE enums, ApiResponse envelope already unwrapped, and
// BigDecimal values that may arrive as strings.

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus_app/dto/ride_booking_dtos.dart';
import 'package:nimbus_app/network/backend_mapper.dart';

void main() {
  group('primitive coercion', () {
    test('toDouble accepts num, numeric string, and junk', () {
      expect(toDouble(12.5), 12.5);
      expect(toDouble('1250.75'), 1250.75);
      expect(toDouble('not-a-number', 9), 9);
      expect(toDouble(null, 3), 3);
    });

    test('toInt accepts num and string', () {
      expect(toInt(7), 7);
      expect(toInt('42'), 42);
      expect(toInt(null, 5), 5);
    });

    test('toDateOrNull parses ISO instants and epoch millis', () {
      final iso = toDateOrNull('2026-10-05T04:30:00Z');
      expect(iso, isNotNull);
      expect(iso!.toUtc().year, 2026);
      expect(iso.month, 10);
      expect(iso.day, 5);

      final epoch = toDateOrNull(1791571200000);
      expect(epoch, isNotNull);
      expect(epoch!.isUtc, isTrue);

      expect(toDateOrNull(null), isNull);
      expect(toDateOrNull('garbage'), isNull);
    });
  });

  group('enum parsing', () {
    test('maps UPPER_SNAKE backend values to client enums', () {
      expect(parseRideStatus('ROUTE_LOCKED'), RideStatus.routeLocked);
      expect(parseRideStatus('IN_PROGRESS'), RideStatus.inProgress);
      expect(parseRideStatus('PUBLISHED'), RideStatus.published);
      expect(parseBookingStatus('PICKED_UP'), BookingStatus.pickedUp);
      expect(parseBookingStatus('REFUND_PENDING'), BookingStatus.refundPending);
      expect(parseRideType('SCHEDULED'), RideType.scheduled);
      expect(parseRideType('INSTANT'), RideType.instant);
    });

    test('falls back to safe defaults for unknown values', () {
      expect(parseRideStatus('SOMETHING_NEW'), RideStatus.draft);
      expect(parseBookingStatus(null), BookingStatus.held);
      expect(parseRideType('TELEPORT'), RideType.scheduled);
    });
  });

  group('rideFromJson', () {
    test('maps the flat RideResponse shape', () {
      final ride = rideFromJson({
        'id': '7a4f6d1e-1111-2222-3333-444455556666',
        'driverId': 'aaaa-1111',
        'creatorId': 'bbbb-2222',
        'vehicleId': 'cccc-3333',
        'type': 'SCHEDULED',
        'status': 'PUBLISHED',
        'scheduledAt': '2026-10-06T02:00:00Z',
        'originLatitude': 23.8103,
        'originLongitude': 90.4125,
        'originAddress': 'Dhanmondi 27, Dhaka',
        'destinationLatitude': 23.7509,
        'destinationLongitude': 90.3934,
        'destinationAddress': 'Banani, Dhaka',
        'availableSeats': 3,
        'maxDetourMeters': 2000,
        'maxWaitSeconds': 300,
        'notes': 'Office commute',
        'routeVersion': 4,
        'fareRuleVersion': 'v7',
        'createdAt': '2026-10-05T10:00:00Z',
      });

      expect(ride.id, '7a4f6d1e-1111-2222-3333-444455556666');
      expect(ride.rideType, RideType.scheduled);
      expect(ride.status, RideStatus.published);
      expect(ride.origin.latitude, 23.8103);
      expect(ride.origin.address, 'Dhanmondi 27, Dhaka');
      expect(ride.destination.address, 'Banani, Dhaka');
      expect(ride.availableSeats, 3);
      expect(ride.routeVersion, '4');
      expect(ride.fareRuleVersion, 'v7');
      expect(ride.scheduledAt, isNotNull);
    });

    test('survives missing optionals', () {
      final ride = rideFromJson({
        'id': 'x',
        'status': 'PUBLISHED',
        'originLatitude': 1.0,
        'originLongitude': 2.0,
        'destinationLatitude': 3.0,
        'destinationLongitude': 4.0,
        'availableSeats': 1,
      });
      expect(ride.notes, isNull);
      expect(ride.scheduledAt, isNull);
      expect(ride.origin.address, isNull);
    });
  });

  group('fareQuoteFromJson', () {
    test('maps int routeVersion and numeric money', () {
      final quote = fareQuoteFromJson({
        'quoteId': 'q-1',
        'fareRuleVersion': 'v7',
        'routeVersion': 3,
        'distanceMeters': 12500,
        'durationSeconds': 2400,
        'baseFare': 50,
        'distanceCharge': 187.5,
        'timeCharge': 0,
        'serviceFee': 10,
        'tax': 5,
        'grossFare': 252.5,
        'discount': 25,
        'finalPayable': '227.50', // BigDecimal can arrive as a string
        'currency': 'BDT',
        'expiresAt': '2026-10-05T10:05:00Z',
      });

      expect(quote.quoteId, 'q-1');
      expect(quote.routeVersion, '3');
      expect(quote.finalPayable, 227.50);
      expect(quote.discount, 25);
      expect(quote.currency, 'BDT');
      expect(quote.expiresAt, isNotNull);
    });

    test('defaults missing money fields to zero', () {
      final quote = fareQuoteFromJson({
        'quoteId': 'q-2',
        'expiresAt': '2026-10-05T10:05:00Z',
      });
      expect(quote.baseFare, 0);
      expect(quote.finalPayable, 0);
      expect(quote.currency, 'BDT');
    });
  });

  group('bookingFromJson', () {
    test('maps flat pickup/dropoff coordinates into LocationDto', () {
      final booking = bookingFromJson({
        'id': 'bk-1',
        'rideId': 'r-1',
        'passengerId': 'p-1',
        'seats': 2,
        'status': 'HELD',
        'pickupLatitude': 23.81,
        'pickupLongitude': 90.41,
        'pickupAddress': 'Mirpur 10',
        'dropoffLatitude': 23.75,
        'dropoffLongitude': 90.39,
        'dropoffAddress': 'Mohakhali',
        'finalPayable': '350.00',
        'createdAt': '2026-10-05T11:00:00Z',
      });

      expect(booking.status, BookingStatus.held);
      expect(booking.seats, 2);
      expect(booking.pickupLocation.address, 'Mirpur 10');
      expect(booking.dropoffLocation.latitude, 23.75);
      expect(booking.fareQuote, isNull);
    });
  });

  group('wallet & notification mapping', () {
    test('walletFromJson reads ownerId into userId', () {
      final wallet = walletFromJson({
        'id': 'w-1',
        'ownerId': 'u-1',
        'ownerType': 'USER',
        'balance': '1250.25',
        'currency': 'BDT',
      });
      expect(wallet.userId, 'u-1');
      expect(wallet.balance, 1250.25);
      expect(wallet.currency, 'BDT');
    });

    test('walletTransactionFromJson maps accountId and defaults status', () {
      final tx = walletTransactionFromJson({
        'id': 't-1',
        'accountId': 'a-1',
        'type': 'RIDE_PAYMENT',
        'amount': -120.5,
        'referenceType': 'BOOKING',
        'description': 'Fare for booking bk-9',
        'createdAt': '2026-10-05T12:00:00Z',
      });
      expect(tx.walletId, 'a-1');
      expect(tx.status, 'COMPLETED'); // ledger entries are immutable
      expect(tx.amount, -120.5);
    });

    test('notificationFromJson maps content→body and isRead→read', () {
      final n = notificationFromJson({
        'id': 'n-1',
        'userId': 'u-1',
        'type': 'RIDE',
        'title': 'Driver arriving',
        'content': 'Your driver is 2 minutes away.',
        'isRead': true,
        'createdAt': '2026-10-05T12:30:00Z',
      });
      expect(n.body, 'Your driver is 2 minutes away.');
      expect(n.read, isTrue);
      expect(n.title, 'Driver arriving');
    });
  });

  group('userProfileFromJson', () {
    test('joins nested profile names and photo', () {
      final user = userProfileFromJson({
        'id': 'u-9',
        'phone': '+8801712345678',
        'email': 'user@example.com',
        'status': 'ACTIVE',
        'profile': {
          'firstName': 'Nusrat',
          'lastName': 'Jahan',
          'profilePhotoUrl': 'https://cdn.example.com/p.jpg',
        },
      });
      expect(user.id, 'u-9');
      expect(user.name, 'Nusrat Jahan');
      expect(user.photoUrl, 'https://cdn.example.com/p.jpg');
      expect(user.phone, '+8801712345678');
    });

    test('handles missing profile block', () {
      final user = userProfileFromJson({'id': 'u-1', 'phone': '017'});
      expect(user.name, isNull);
      expect(user.id, 'u-1');
    });
  });

  group('safetyEventFromJson', () {
    test('reads nested ride/user entities into ids', () {
      final ev = safetyEventFromJson({
        'id': 'se-1',
        'ride': {'id': 'r-77'},
        'user': {'id': 'u-5'},
        'eventType': 'SOS',
        'status': 'OPEN',
        'latitude': 23.79,
        'longitude': 90.40,
        'description': 'SOS triggered',
        'createdAt': '2026-10-05T13:00:00Z',
      });
      expect(ev.rideId, 'r-77');
      expect(ev.userId, 'u-5');
      expect(ev.type, 'SOS');
      expect(ev.status, 'OPEN');
      expect(ev.location, [23.79, 90.40]);
    });
  });
}

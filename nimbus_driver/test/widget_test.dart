// Smoke tests for the Nimbus Driver app.
//
// The app root needs an initialized ApiService (platform channels), so
// these cover standalone units: mappers and formatters.

import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus_driver/core/utils/formatters.dart';
import 'package:nimbus_driver/network/backend_mapper.dart';

void main() {
  group('AppFormatters', () {
    test('formats BDT money', () {
      expect(AppFormatters.money(1250), '৳1,250.00');
    });

    test('formats durations', () {
      expect(AppFormatters.duration(480), '8 min');
      expect(AppFormatters.duration(4800), '1 h 20 min');
    });
  });

  group('backend mapper', () {
    test('parses flat RideResponse with UPPER_SNAKE enums', () {
      final ride = Ride.fromJson({
        'id': 'r-1',
        'type': 'INSTANT',
        'status': 'IN_PROGRESS',
        'originLatitude': 23.81,
        'originLongitude': 90.41,
        'originAddress': 'Dhanmondi',
        'destinationLatitude': 23.75,
        'destinationLongitude': 90.39,
        'destinationAddress': 'Banani',
        'availableSeats': 3,
      });
      expect(ride.status, RideStatus.inProgress);
      expect(ride.status.isLive, isTrue);
      expect(ride.origin.address, 'Dhanmondi');
      expect(ride.availableSeats, 3);
    });

    test('parses driver profile with defaults', () {
      final p = DriverProfile.fromJson({
        'id': 'p-1',
        'userId': 'u-1',
        'driverStatus': 'ONLINE',
        'approvalStatus': 'APPROVED',
        'rating': '4.8',
        'totalEarnings': '15000',
      });
      expect(p.isApproved, isTrue);
      expect(p.isOnline, isTrue);
      expect(p.rating, 4.8);
      expect(p.totalEarnings, 15000);
    });

    test('parses passenger booking status', () {
      final b = PassengerBooking.fromJson({
        'id': 'b-1',
        'rideId': 'r-1',
        'passengerId': 'p-1',
        'seats': 2,
        'status': 'PICKED_UP',
        'pickupLatitude': 23.8,
        'pickupLongitude': 90.4,
      });
      expect(b.status, BookingStatus.pickedUp);
      expect(b.seats, 2);
    });
  });
}

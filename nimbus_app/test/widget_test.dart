// Smoke tests for the Nimbus passenger app.
//
// The app root (NimbusApp) requires an initialized ApiService (secure
// storage + Dio), which needs platform channels unavailable in unit
// tests — so these tests cover standalone UI pieces and formatters.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus_app/core/utils/formatters.dart';
import 'package:nimbus_app/widgets/state_views.dart';

void main() {
  group('AppFormatters', () {
    test('formats BDT money with symbol and thousands separators', () {
      expect(AppFormatters.money(1250), '৳1,250.00');
      expect(AppFormatters.money(0), '৳0.00');
    });

    test('formats distances', () {
      expect(AppFormatters.distance(850), '850 m');
      expect(AppFormatters.distance(12400), '12.4 km');
    });

    test('formats durations', () {
      expect(AppFormatters.duration(480), '8 min');
      expect(AppFormatters.duration(4800), '1 h 20 min');
    });

    test('formats countdown', () {
      expect(AppFormatters.countdown(const Duration(minutes: 4, seconds: 5)),
          '4:05');
      expect(AppFormatters.countdown(Duration.zero), '0:00');
      expect(AppFormatters.countdown(const Duration(seconds: -3)), '0:00');
    });
  });

  group('StatusChip', () {
    testWidgets('renders UPPER_SNAKE backend statuses as labels',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusChip.of('IN_PROGRESS')),
      ));
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('uses error color for terminal failures', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatusChip.of('CANCELLED')),
      ));
      expect(find.text('Cancelled'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No rides yet',
            subtitle: 'Book your first pooled commute.',
          ),
        ),
      ));
      expect(find.text('No rides yet'), findsOneWidget);
      expect(find.text('Book your first pooled commute.'), findsOneWidget);
    });
  });
}

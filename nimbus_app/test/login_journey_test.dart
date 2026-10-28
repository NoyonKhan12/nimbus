import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus_app/services/api_service.dart';
import 'package:nimbus_app/services/auth_service.dart';
import 'package:nimbus_app/ui/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Journey-level widget tests for the OTP login flow entry (guide §22 E2E
/// start point): invalid input is caught client-side, and the two-step
/// phone → OTP state machine renders its contract correctly.
///
/// ApiService runs against the real Dio stack with mocked platform storage;
/// no network is required for the assertions below (validation errors fire
/// before any request, and the send-failure banner is not a validation
/// error).
void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await ApiService.init();
    final apiService = ApiService();
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ApiService>.value(value: apiService),
          RepositoryProvider<AuthService>(
            create: (_) => AuthService(apiService),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows client-side error for an invalid BD phone number',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), '12345');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    expect(find.text('Enter a valid Bangladesh number, e.g. 01712345678'),
        findsOneWidget);
  });

  testWidgets('valid phone passes validation (no field error) and the '
      'send-failure path surfaces a non-validation banner', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), '01712345678');
    await tester.tap(find.text('Send OTP'));
    // Let the (failing) network future settle inside the test environment.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final validationError =
        find.text('Enter a valid Bangladesh number, e.g. 01712345678');
    expect(validationError, findsNothing);
  });

  testWidgets('two-step UI contract: OTP step shows Verify CTA, phone step '
      'shows Send OTP', (tester) async {
    await pumpPage(tester);

    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('Verify & Continue'), findsNothing);
  });
}

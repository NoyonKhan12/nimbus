import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'services/api_service.dart';
import 'services/push_notification_service.dart';

/// Nimbus Driver App entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppConstants.validate();
  } catch (error) {
    runApp(_ConfigurationErrorApp(message: error.toString()));
    return;
  }

  // Push registration: no-op until Firebase native config exists.
  await PushNotificationService.instance.ensureInitialized();

  // Initialize the API service singleton before launching the app.
  await ApiService.init();

  // Driver apps are portrait-primary.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const NimbusDriverApp());
  });
}

/// Shown instead of a blank screen when a release build is misconfigured.
class _ConfigurationErrorApp extends StatelessWidget {
  const _ConfigurationErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_ethernet, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Nimbus Driver is not configured',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

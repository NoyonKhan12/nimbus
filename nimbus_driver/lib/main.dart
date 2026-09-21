import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/// Nimbus Driver App Entry Point
/// For drivers to accept rides, manage earnings, and update status.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const NimbusDriverApp());
  });
}

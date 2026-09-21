import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'services/api_service.dart';

/// Nimbus App Entry Point
/// Bangladesh Commuter Ride-Pooling Platform
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the API service singleton before launching the app.
  await ApiService.init();
  final apiService = ApiService();

  // Force portrait mode (driver/passenger apps are portrait-primary).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(NimbusApp(apiService: apiService));
  });
}

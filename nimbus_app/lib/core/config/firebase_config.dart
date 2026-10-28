import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration supplied at build time.
///
/// Native `google-services.json` / `GoogleService-Info.plist` remains the
/// preferred production path. These compile-time values are a fallback for
/// CI or managed builds where secrets are injected as `--dart-define`
/// values instead of checked-in files.
class FirebaseConfig {
  FirebaseConfig._();

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _measurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static bool get hasExplicitOptions =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static FirebaseOptions? get options {
    if (!hasExplicitOptions) return null;
    return FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
      authDomain: _authDomain.isEmpty ? null : _authDomain,
      measurementId: _measurementId.isEmpty ? null : _measurementId,
      iosBundleId: defaultTargetPlatform == TargetPlatform.iOS &&
              _iosBundleId.isNotEmpty
          ? _iosBundleId
          : null,
    );
  }
}

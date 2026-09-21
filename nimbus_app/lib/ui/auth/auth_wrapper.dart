import 'package:flutter/material.dart';
import 'login_page.dart';

/// AuthWrapper — wraps the authentication flow.
/// Shows LoginPage (with OTP) if unauthenticated.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

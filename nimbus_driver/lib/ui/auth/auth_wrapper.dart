import 'package:flutter/material.dart';
import 'login_page.dart';

/// Wraps the authentication flow.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

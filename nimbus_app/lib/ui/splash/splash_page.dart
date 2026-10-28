import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/brand.dart';

/// SplashPage — checks auth state and redirects accordingly.
/// Shows the Nimbus logo while determining if the user is authenticated.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check immediately.
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BrandGradients.hero),
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/auth');
          }
        },
          child: Center(
            child: _SplashContent(),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo — glass ring with brand glow.
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: BrandGradients.glow,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4DB6AC).withOpacity(0.45),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(10),
            child: ClipOval(
              child: Image.asset(
                'assets/images/nimbus_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Nimbus',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share the ride. Split the fare.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.75),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 40),
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
      ],
    );
  }
}

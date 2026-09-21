import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../services/auth_service.dart';

/// LoginPage — OTP-based phone login for the driver app.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String _errorMessage = '';

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number');
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[\+\s\-]'), '');
    final phoneDigits = cleanPhone.replaceAll('880', '');

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.sendOtp(phone: phoneDigits, dialCode: '+880');
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit code');
      return;
    }

    final phone = _phoneController.text.trim();
    final phoneDigits = phone.replaceAll(RegExp(r'[\+\s\-]'), '').replaceAll('880', '');

    setState(() => _isLoading = true);

    try {
      final success = await _authService.verifyOtp(
        phone: phoneDigits,
        dialCode: '+880',
        code: code,
        termsAccepted: true,
      );

      if (success) {
        context.read<AuthBloc>().add(const AuthLoggedIn());
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP code. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.directions_car, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Nimbus Driver',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login with your driver phone number',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Phone (0XXXXXXXX)',
                    prefixText: '+880 ',
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '6-digit OTP',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                ),
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_errorMessage,
                    style: const TextStyle(color: Colors.red.shade200)),
              ],
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white70)
                  : ElevatedButton(
                      onPressed: _otpSent ? _verifyOtp : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                      ),
                      child: Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
                    ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _otpController.clear();
                  }),
                  child: const Text('Change phone',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// LoginPage — OTP-based phone login flow.
/// Users enter their Bangladesh phone number, receive an OTP, and verify it.
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

    // Strip +880 prefix if present; we'll send with dialCode +880.
    final cleanPhone = phone.replaceAll('+880', '').replaceAll('0', '');
    if (cleanPhone.isEmpty) {
      setState(() => _errorMessage = 'Invalid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.sendOtp(
        phone: cleanPhone,
        dialCode: '+880',
      );
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
    final cleanPhone = phone.replaceAll('+880', '').replaceAll('0', '');

    setState(() => _isLoading = true);

    try {
      final success = await _authService.verifyOtp(
        phone: cleanPhone,
        dialCode: '+880',
        code: code,
        termsAccepted: true,
      );

      if (success) {
        if (mounted) {
          context.read<AuthBloc>().add(const AuthLoggedIn());
          Navigator.of(context).pushReplacementNamed('/home');
        }
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

  void _resendOtp() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _errorMessage = '';
    });
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
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.electric_rickshaw,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nimbus',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login with your Bangladesh number',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Phone (0XXXXXXXX)',
                    prefixText: '+880 ',
                    prefixIcon:
                        const Icon(Icons.phone, color: AppTheme.primary),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '6-digit OTP',
                    prefixIcon:
                        const Icon(Icons.lock, color: AppTheme.primary),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                  ),
                ),
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade200),
                ),
              ],
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white70)
                  : ElevatedButton(
                      onPressed: _otpSent ? _verifyOtp : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _otpSent ? 'Verify OTP' : 'Send OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(color: Colors.white70),
                  ),
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

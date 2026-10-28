import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../network/backend_api.dart';
import '../../services/auth_service.dart';
import '../../widgets/brand.dart';

/// Driver login — OTP-based phone verification.
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
  Timer? _resendTimer;
  int _resendRemaining = 0;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Normalizes any common BD input (`01712345678`, `+8801712345678`,
  /// `8801712345678`, `1712345678`) to the backend's required
  /// `+8801[3-9]XXXXXXXX` format, or returns null.
  String? _normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+880')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('880')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    final valid = RegExp(r'^1[3-9]\d{8}$').hasMatch(digits);
    return valid ? '+880$digits' : null;
  }

  Future<void> _sendOtp() async {
    final normalized = _normalizePhone(_phoneController.text);
    if (normalized == null) {
      setState(() {
        _errorMessage =
            'Enter a valid Bangladesh number, e.g. 01712345678';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.sendOtp(phone: normalized);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      _startResendCooldown();
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

    final phone = _normalizePhone(_phoneController.text);
    if (phone == null) {
      setState(() => _errorMessage = 'Invalid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.verifyOtp(phone: phone, code: code);

      if (success) {
        if (mounted) {
          context.read<AuthBloc>().add(const AuthLoggedIn());
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP code. Please try again.';
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendRemaining = AppConstants.otpResendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendRemaining <= 1) {
        timer.cancel();
        setState(() => _resendRemaining = 0);
      } else {
        setState(() => _resendRemaining--);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resendRemaining > 0 || _isLoading) return;
    _otpController.clear();
    setState(() {
      _errorMessage = '';
      _otpSent = true;
    });
    await _sendOtp();
  }

  void _changeNumber() {
    _resendTimer?.cancel();
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _errorMessage = '';
      _resendRemaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final glassField = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
      prefixStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BrandGradients.hero),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  AnimatedEntrance(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                            colors: BrandGradients.glow),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DB6AC).withOpacity(0.4),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/nimbus_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 80),
                    child: Column(
                      children: [
                        const Text(
                          'Nimbus Driver',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Drive with Nimbus — sign in to go online',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 160),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_otpSent)
                            Semantics(
                              label: 'Bangladesh mobile number',
                              textField: true,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber
                                ],
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _sendOtp(),
                                style: const TextStyle(color: Colors.white),
                                decoration: glassField.copyWith(
                                  hintText: '01XXXXXXXXX',
                                  prefixIcon: Icon(Icons.local_taxi_rounded,
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                            )
                          else
                            Semantics(
                              label: 'Six digit one time passcode',
                              textField: true,
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                maxLength: AppConstants.otpLength,
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _verifyOtp(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 10,
                                ),
                                decoration: glassField.copyWith(
                                  hintText: '••••••',
                                  counterText: '',
                                  prefixIcon: null,
                                ),
                              ),
                            ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFFFB4AB), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                        color: Color(0xFFFFB4AB),
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),
                          GradientButton(
                            label: _otpSent ? 'Verify & Go Online' : 'Send OTP',
                            icon: _otpSent
                                ? Icons.verified_rounded
                                : Icons.sms_outlined,
                            loading: _isLoading,
                            onPressed: _otpSent ? _verifyOtp : _sendOtp,
                          ),
                          if (_otpSent) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _resendRemaining == 0
                                      ? _resendOtp
                                      : null,
                                  child: Text(
                                    _resendRemaining == 0
                                        ? 'Resend code'
                                        : 'Resend in ${_resendRemaining}s',
                                    style: TextStyle(
                                      color: _resendRemaining == 0
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _changeNumber,
                                  child: Text(
                                    'Change number',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 240),
                    child: Text(
                      'Drive. Earn. Repeat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

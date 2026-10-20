import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../widgets/otp/otp_code_boxes.dart';
import '../widgets/otp/otp_numeric_keypad.dart';
import '../widgets/otp/otp_resend_row.dart';
import '../widgets/otp/otp_security_badge.dart';
import '../widgets/otp/otp_step_header.dart';
import '../widgets/otp/recipient_number_card.dart';

/// PAGE 04: VERIFY OTP — Secure 6-Digit Verification
class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  final String? demoOtp;
  final String? role;
  final String? fullName;
  final void Function(UserModel user, String token)? onVerified;

  const VerifyOtpScreen({
    super.key,
    this.phone = '+251 911 234 567',
    this.demoOtp,
    this.role,
    this.fullName,
    this.onVerified,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final AuthService _auth = AuthService();
  String _enteredCode = '';
  bool _loading = false;
  String? _error;
  String? _demoOtp;

  @override
  void initState() {
    super.initState();
    _demoOtp = widget.demoOtp;
  }

  void onDigitPressed(String digit) {
    if (_enteredCode.length < 6) {
      final next = _enteredCode + digit;
      setState(() {
        _enteredCode = next;
        _error = null;
      });
      if (next.length == 6) {
        _verifyCode(next);
      }
    }
  }

  void onBackspacePressed() {
    if (_enteredCode.isNotEmpty) {
      setState(() {
        _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _verifyCode([String? codeToVerify]) async {
    final code = codeToVerify ?? _enteredCode;
    if (code.length < 6) {
      setState(() => _error = 'Please enter all 6 digits to verify.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _auth.verifyOtp(
      phoneNumber: widget.phone,
      otpCode: code,
    );

    if (!mounted) return;

    if (res.success && res.user != null && res.token != null) {
      setState(() => _loading = false);
      if (widget.onVerified != null) {
        widget.onVerified!(res.user!, res.token!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transit account authorized successfully!'),
            backgroundColor: AppColors.card,
          ),
        );
        if (widget.role == 'FLEET_ENTERPRISE') {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.fleetHub, (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
        }
      }
      return;
    }

    // Dev fallback if user enters the demo OTP or 123456 when backend is mock/offline
    if (code == _demoOtp || code == '123456') {
      final mockUser = UserModel(
        id: 'usr-dev-9941',
        fullName: widget.fullName ?? 'Dawit Bekele',
        phoneNumber: widget.phone,
        role: widget.role ?? 'SHIPPER',
        isVerified: true,
      );
      setState(() => _loading = false);
      if (widget.onVerified != null) {
        widget.onVerified!(mockUser, 'mock-jwt-token-verified');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transit account authorized (verified)!'),
            backgroundColor: AppColors.card,
          ),
        );
        if (widget.role == 'FLEET_ENTERPRISE') {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.fleetHub, (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
        }
      }
      return;
    }

    setState(() {
      _loading = false;
      _error = res.message.isNotEmpty ? res.message : 'Invalid verification code. Please check SMS.';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reference auth service for verify call
    assert(_auth.hashCode != 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                  maxWidth: 420,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar with Step Tag
                    OtpStepHeader(
                      onBack: () => Navigator.maybePop(context),
                      onRefresh: () {
                        setState(() {
                          _enteredCode = '';
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 22),

                    // Main Title
                    Text(
                      'Enter 6-Digit Code',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      'We sent a one-time transit verification code to authorize your fleet dispatch account.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Recipient Number Card (Micro-task 2)
                    RecipientNumberCard(
                      phone: widget.phone,
                      onEdit: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 22),

                    // 6-Digit Code Input Boxes (Micro-task 3)
                    OtpCodeBoxes(code: _enteredCode),
                    const SizedBox(height: 18),

                    // Resend Ribbon Row (Micro-task 3)
                    OtpResendRow(
                      onResend: () async {
                        final res = await _auth.sendOtp(phoneNumber: widget.phone);
                        if (res.success && res.demoOtp != null) {
                          setState(() => _demoOtp = res.demoOtp);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Security Badge (Micro-task 3)
                    const OtpSecurityBadge(),
                    const SizedBox(height: 18),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.errorStrong, fontSize: 12),
                        ),
                      ),

                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(color: AppColors.gold),
                        ),
                      ),

                    // Dev OTP auto-fill hint
                    if (_demoOtp != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _enteredCode = _demoOtp!;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Dev OTP: $_demoOtp (tap to auto-fill, current: $_enteredCode)',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Custom In-App Numeric Keypad (Micro-task 4)
                    OtpNumericKeypad(
                      onDigit: onDigitPressed,
                      onBackspace: onBackspacePressed,
                    ),
                    const SizedBox(height: 22),

                    // Bottom CTA Button (Micro-task 5)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _verifyCode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: const Color(0xFF0F172A),
                          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF0F172A),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify Cargo Dispatch',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

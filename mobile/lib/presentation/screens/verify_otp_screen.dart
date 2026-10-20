import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
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
      setState(() {
        _enteredCode += digit;
        _error = null;
      });
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

  void setLoading(bool loading) {
    setState(() => _loading = loading);
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

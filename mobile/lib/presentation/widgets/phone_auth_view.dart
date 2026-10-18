import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ethiopian_flag.dart';
import '../../data/models/user_model.dart';
import 'otp_verification_sheet.dart';

class PhoneAuthView extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;

  const PhoneAuthView({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  // Pre-fill with a valid seeded driver number for convenient testing
  final TextEditingController _phoneController =
      TextEditingController(text: '92 265 4321');
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _formattedFullPhone {
    final raw = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.startsWith('+251')) return raw;
    if (raw.startsWith('09') || raw.startsWith('07')) {
      return '+251${raw.substring(1)}';
    }
    if (raw.startsWith('9') || raw.startsWith('7')) {
      return '+251$raw';
    }
    return '+251$raw';
  }

  Future<void> _handleRequestOtp() async {
    final rawNumber = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (rawNumber.length < 8) {
      setState(() => _errorMessage = 'Please enter a valid Ethiopian mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = _formattedFullPhone;
    final response = await widget.authService.sendOtp(phoneNumber: fullPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OtpVerificationSheet(
          phoneNumber: fullPhone,
          initialDemoOtp: response.demoOtp,
          authService: widget.authService,
          onVerified: widget.onAuthenticated,
        ),
      );
    } else {
      setState(() {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to request OTP code. Please check your number.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Mobile Number',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Phone Input Container
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorMessage != null
                  ? AppColors.error
                  : (_isFocused ? AppColors.gold : AppColors.cardBorder),
              width: _isFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Ethiopian Flag
              const EthiopianFlag(width: 26, height: 17),
              const SizedBox(width: 10),

              // Country Code (+251)
              Text(
                '+251',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),

              // Vertical Divider Line
              Container(
                width: 1,
                height: 22,
                color: const Color(0xFF263756),
              ),
              const SizedBox(width: 12),

              // Phone Number Input Field
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '91 234 5678',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onFieldSubmitted: (_) => _handleRequestOtp(),
                ),
              ),
            ],
          ),
        ),

        // Error message if any
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        // Primary Action: Request OTP Code Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRequestOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textDark,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Request OTP Code',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

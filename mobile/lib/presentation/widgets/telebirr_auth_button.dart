import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';

class TelebirrAuthButton extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;
  final String? initialPhone;

  const TelebirrAuthButton({
    super.key,
    required this.authService,
    required this.onAuthenticated,
    this.initialPhone,
  });

  @override
  State<TelebirrAuthButton> createState() => _TelebirrAuthButtonState();
}

class _TelebirrAuthButtonState extends State<TelebirrAuthButton> {
  bool _isLoading = false;

  Future<void> _handleTelebirrAuth() async {
    // If phone number is available, use it; otherwise prompt quick phone input
    String phoneNumber = widget.initialPhone?.trim() ?? '';
    if (phoneNumber.isEmpty) {
      final inputPhone = await _promptPhoneModal(context);
      if (inputPhone == null || inputPhone.isEmpty) return;
      phoneNumber = inputPhone;
    }

    setState(() => _isLoading = true);

    final response = await widget.authService.telebirrLogin(
      phoneNumber: phoneNumber,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success && response.user != null && response.token != null) {
      widget.onAuthenticated(response.user!, response.token!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Telebirr authentication failed. Please try again.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _promptPhoneModal(BuildContext context) async {
    final controller = TextEditingController(text: '+251911234567');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.telebirrBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.telebirrBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Telebirr Fast-Sign',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered Telebirr mobile number for instant carrier authentication:',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '+251 91 123 4567',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.telebirrBlue,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Authenticate',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider: OR CONTINUE WITH
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.cardBorder, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.cardBorder, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Telebirr Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleTelebirrAuth,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.telebirrBlue.withValues(alpha: 0.1),
            highlightColor: AppColors.telebirrBlue.withValues(alpha: 0.05),
            child: Ink(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.telebirrButton,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.telebirrBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Telebirr Logo Icon Badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.telebirrBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: AppColors.telebirrBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Label & Subtext
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Auth with Telebirr',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Instant SuperApp verification',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Icon or Spinner
                    if (_isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.telebirrBlue,
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

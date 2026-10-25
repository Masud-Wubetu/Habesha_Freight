import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PasswordAuthView extends StatelessWidget {
  final TextEditingController? emailController;
  final TextEditingController? idController;
  final TextEditingController passController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const PasswordAuthView({
    super.key,
    this.emailController,
    this.idController,
    required this.passController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  }) : assert(emailController != null || idController != null,
            'Must provide either emailController or idController');

  TextEditingController get _resolvedEmailController =>
      emailController ?? idController!;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _box(
          controller: _resolvedEmailController,
          hint: 'name@example.com',
          icon: Icons.mail_outline_rounded,
          obscure: false,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        _box(
          controller: passController,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscure: obscurePassword,
          toggle: onToggleObscure,
        ),
      ],
    );
  }

  Widget _box({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? toggle,
  }) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                keyboardType: keyboardType,
                autocorrect: false,
                enableSuggestions: false,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            if (toggle != null)
              IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                onPressed: toggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: obscure ? 'Show password' : 'Hide password',
              ),
          ],
        ),
      );
}

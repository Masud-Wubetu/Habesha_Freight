import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PasswordAuthView extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController passController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const PasswordAuthView({
    super.key,
    required this.idController,
    required this.passController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Mobile / Email', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      _box(idController, 'user@domain.com or +251...', Icons.person_outline_rounded, false),
      const SizedBox(height: 12),
      Text('Password', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      _box(passController, '••••••••', Icons.lock_outline_rounded, obscurePassword, toggle: onToggleObscure),
    ]);
  }

  Widget _box(TextEditingController c, String hint, IconData icon, bool obs, {VoidCallback? toggle}) => Container(
    height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
    child: Row(children: [
      Icon(icon, color: AppColors.textMuted, size: 18),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: c, obscureText: obs,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: hint, hintStyle: const TextStyle(color: AppColors.textMuted)),
        onSubmitted: (_) => onSubmit(),
      )),
      if (toggle != null)
        IconButton(
          icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
          onPressed: toggle, padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

enum AuthTab { phone, password }

class AuthTabSwitcher extends StatelessWidget {
  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;

  const AuthTabSwitcher({super.key, required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D48)),
      ),
      child: Row(children: [
        _tabItem('Phone OTP', Icons.phone_android_rounded, activeTab == AuthTab.phone, () => onTabChanged(AuthTab.phone)),
        const SizedBox(width: 4),
        _tabItem('Password', Icons.lock_outline_rounded, activeTab == AuthTab.password, () => onTabChanged(AuthTab.password)),
      ]),
    );
  }

  Widget _tabItem(String t, IconData i, bool sel, VoidCallback tap) => Expanded(
    child: GestureDetector(
      onTap: tap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1E2D48) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: sel ? Border.all(color: const Color(0xFF2E4369), width: 1) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 16, color: sel ? AppColors.gold : AppColors.textMuted),
          const SizedBox(width: 8),
          Text(t, style: GoogleFonts.inter(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? Colors.white : AppColors.textMuted)),
        ]),
      ),
    ),
  );
}

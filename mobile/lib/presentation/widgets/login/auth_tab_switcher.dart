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
      height: 40, padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFF0C1322), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1E2D48))),
      child: Row(children: [
        _tabItem('Phone OTP', Icons.phone_android_rounded, activeTab == AuthTab.phone, () => onTabChanged(AuthTab.phone)),
        _tabItem('Password', Icons.lock_outline_rounded, activeTab == AuthTab.password, () => onTabChanged(AuthTab.password)),
      ]),
    );
  }

  Widget _tabItem(String t, IconData i, bool sel, VoidCallback tap) => Expanded(
    child: GestureDetector(
      onTap: tap,
      child: Container(
        decoration: BoxDecoration(color: sel ? const Color(0xFF1E2D48) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 14, color: sel ? AppColors.gold : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? Colors.white : AppColors.textMuted)),
        ]),
      ),
    ),
  );
}

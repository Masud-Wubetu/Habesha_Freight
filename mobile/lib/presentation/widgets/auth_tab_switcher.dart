import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum AuthTab { phone, password }

class AuthTabSwitcher extends StatelessWidget {
  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;

  const AuthTabSwitcher({
    super.key,
    this.activeTab = AuthTab.phone,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Phone Number',
              tab: AuthTab.phone,
              isSelected: activeTab == AuthTab.phone,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabItem(
              title: 'Password Login',
              tab: AuthTab.password,
              isSelected: activeTab == AuthTab.password,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required AuthTab tab,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onTabChanged(tab),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF19243C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF28395A), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

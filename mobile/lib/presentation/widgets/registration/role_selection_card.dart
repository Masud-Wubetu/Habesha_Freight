import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

enum UserRegistrationRole {
  shipper('SHIPPER'),
  driver('DRIVER'),
  fleetEnterprise('FLEET_OWNER');

  final String backendRole;
  const UserRegistrationRole(this.backendRole);
}

class RoleCardData {
  final UserRegistrationRole role;
  final String title;
  final IconData icon;

  const RoleCardData({
    required this.role,
    required this.title,
    required this.icon,
  });
}

class RoleSelectionCard extends StatelessWidget {
  final RoleCardData data;
  final bool isSelected;
  final VoidCallback onSelect;

  const RoleSelectionCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132035) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.7)
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon in rounded square
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1726),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.35)
                      : const Color(0xFF1E2D48),
                ),
              ),
              child: Icon(
                data.icon,
                size: 20,
                color: isSelected ? AppColors.gold : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 14),

            // Role Title
            Expanded(
              child: Text(
                data.title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Radio Button selection indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : const Color(0xFF334155),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

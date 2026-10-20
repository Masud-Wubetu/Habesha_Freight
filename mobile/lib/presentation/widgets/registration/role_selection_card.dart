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
  final String badgeText;
  final Color badgeTextColor;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final IconData icon;
  final String description;

  const RoleCardData({
    required this.role,
    required this.title,
    required this.badgeText,
    required this.badgeTextColor,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.icon,
    required this.description,
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
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF132035)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.6)
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon, Title, Badge, Radio Indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon in dark square container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1726),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold.withValues(alpha: 0.3)
                          : const Color(0xFF1E2D48),
                    ),
                  ),
                  child: Icon(
                    data.icon,
                    size: 22,
                    color: isSelected ? AppColors.gold : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              data.title,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: data.badgeBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: data.badgeBorderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              data.badgeText,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: data.badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Radio Button selection indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : const Color(0xFF334155),
                      width: 2.5,
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
            const SizedBox(height: 10),

            // Description text
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                data.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

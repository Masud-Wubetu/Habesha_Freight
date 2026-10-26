import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../navigation/corridor_navigation_sheet.dart';

class HomeHeader extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onProfileTap;
  final String userName;

  const HomeHeader({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onProfileTap,
    this.userName = 'Shipper',
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.trim().isNotEmpty ? userName.trim() : 'Shipper';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo & Title
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Habesha ',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Freight',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ETHIOPIAN CORRIDORS',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right Actions (Compact, responsive, no overflow)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // All Modules shortcut
            IconButton(
              onPressed: () => CorridorNavigationSheet.show(context),
              tooltip: 'Corridor Modules',
              icon: const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: AppColors.gold,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.card,
                padding: const EdgeInsets.all(8),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),

            const SizedBox(width: 8),

            // Profile Avatar Button
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.gold,
                      child: Text(
                        initial,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(
                        displayName.split(' ').first,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

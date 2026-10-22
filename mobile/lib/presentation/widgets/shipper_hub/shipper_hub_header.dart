import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../navigation/corridor_navigation_sheet.dart';

class ShipperHubHeader extends StatelessWidget {
  final String language;
  final ValueChanged<String>? onLanguageChanged;
  final VoidCallback? onProfileTap;

  const ShipperHubHeader({
    super.key,
    this.language = 'EN',
    this.onLanguageChanged,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top App Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Logo & Subtitle
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1A2D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF223554), width: 1.2),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        children: const [
                          TextSpan(text: 'Habesha', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Freight', style: TextStyle(color: AppColors.gold)),
                        ],
                      ),
                    ),
                    Text(
                      'LOGISTICS EXCHANGE',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Actions: Modules, Language, Avatar
            Row(
              children: [
                // Modules Hub
                IconButton(
                  onPressed: () => CorridorNavigationSheet.show(context),
                  icon: const Icon(Icons.grid_view_rounded, size: 19),
                  color: AppColors.gold,
                  tooltip: 'All Corridor Modules',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1A2D),
                    padding: const EdgeInsets.all(7),
                  ),
                ),
                const SizedBox(width: 8),

                // Language Chip
                InkWell(
                  onTap: () {
                    final next = language == 'EN' ? 'AM' : 'EN';
                    onLanguageChanged?.call(next);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1A2D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF223554)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.translate, size: 13, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Profile Avatar
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      border: Border.all(color: const Color(0xFFFEF3C7), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // PAGE 06 Ribbon Header matching screenshot
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1324),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E2E4A), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PAGE 06: SHIPPER DASHBOARD • ACTIVE HUB & OP...',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: const Color(0xFFCBD5E1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE HUB',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

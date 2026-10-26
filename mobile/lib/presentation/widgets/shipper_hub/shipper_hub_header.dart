import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

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
                      'OPERATIONS HUB',
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

            // Actions: Language, Avatar
            Row(
              children: [
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
      ],
    );
  }
}

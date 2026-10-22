import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ReviewBidsHeader extends StatelessWidget {
  final String language;
  final ValueChanged<String>? onLanguageChanged;
  final VoidCallback? onProfileTap;
  final int activeBidsCount;

  const ReviewBidsHeader({
    super.key,
    this.language = 'EN',
    this.onLanguageChanged,
    this.onProfileTap,
    this.activeBidsCount = 3,
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
            // Brand Logo & Title
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
                          letterSpacing: 0.2,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Habesha',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Freight',
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'ETHIOPIA NATIONAL LOGISTICS',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Language Switcher & Profile Avatar
            Row(
              children: [
                InkWell(
                  onTap: () {
                    final nextLang = language == 'EN' ? 'AM' : 'EN';
                    onLanguageChanged?.call(nextLang);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1A2D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF223554), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.translate_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF241C10),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Sub-Header Ribbon: PAGE 08: REVIEW CARGO BIDS & 3 Bids Active • Live Auction
        Row(
          children: [
            // Left Pill: PAGE 08
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1708),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5A4010), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'PAGE 09: REVIEW CARGO BIDS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Right Pill: Live Auction
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF072418),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF14532D), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$activeBidsCount Bids Active • Live Auction',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: const Color(0xFF4EDEA3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

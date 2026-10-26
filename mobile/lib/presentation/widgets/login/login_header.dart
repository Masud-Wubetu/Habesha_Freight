import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF162137),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF263756)),
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: AppColors.gold,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(text: 'Habesha ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Freight', style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Text(
        'HabeshaFreight Mobile',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.badgeGreenBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.badgeGreenBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.badgeGreenText,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'National Freight Network',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.badgeGreenText,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        // Brand Logo Row (Squircle Truck + "Habesha Freight")
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF162137),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF263756),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.gold,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                children: const [
                  TextSpan(
                    text: 'Habesha ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Freight',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // National Freight Network Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.badgeGreenBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.badgeGreenBorder,
              width: 1,
            ),
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
              const SizedBox(width: 8),
              Text(
                'National Freight Network',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeGreenText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

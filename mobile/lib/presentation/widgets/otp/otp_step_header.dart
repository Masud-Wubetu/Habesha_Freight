import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class OtpStepHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;

  const OtpStepHeader({
    super.key,
    this.onBack,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Circular Back Button
        InkWell(
          onTap: onBack ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF131D31),
              border: Border.all(color: const Color(0xFF223554), width: 1.2),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        // Step Ribbon Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF223554), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PAGE 04: VERIFY OTP',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Secure 6-Digit Verification',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),

        // Circular Refresh / Action Button
        InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF131D31),
              border: Border.all(color: const Color(0xFF223554), width: 1.2),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

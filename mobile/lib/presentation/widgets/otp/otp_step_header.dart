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
        // Back Button
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            padding: const EdgeInsets.all(8),
          ),
        ),

        // Center Title
        Text(
          'Phone Verification',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // Clear / Reset Button
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
          tooltip: 'Reset Code',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class RegistrationStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final String heading;
  final String subheading;

  const RegistrationStepHeader({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 3,
    this.stepTitle = 'Account Setup',
    this.heading = 'Choose your role',
    this.subheading =
        'Connect to the HabeshaFreight logistics network across prime East African corridors.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Page tag & Step indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  'PAGE 03: MULTI-ROLE REGISTRATION',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.goldLight,
                  ),
                ),
              ],
            ),
            Text(
              'Step $currentStep of $totalSteps: $stepTitle',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Step progress track
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompletedOrActive = index < currentStep;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isCompletedOrActive
                      ? AppColors.gold
                      : AppColors.cardBorder.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Headline & Subtitle
        Text(
          heading,
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subheading,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

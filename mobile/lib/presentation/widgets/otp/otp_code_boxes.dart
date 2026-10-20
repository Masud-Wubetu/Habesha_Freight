import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class OtpCodeBoxes extends StatelessWidget {
  final String code;
  final int length;

  const OtpCodeBoxes({
    super.key,
    required this.code,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        final isFilled = index < code.length;
        final isActive = index == code.length;
        final digit = isFilled ? code[index] : '';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 54,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF16243D)
                : const Color(0xFF0F1A2D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColors.gold
                  : (isFilled
                      ? const Color(0xFF334B75)
                      : const Color(0xFF1E2E4A)),
              width: isActive ? 1.8 : 1.2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isFilled)
                Text(
                  digit,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                )
              else if (isActive)
                // Glowing Cursor Underscore matching mockup
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 16,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Muted Placeholder Dot
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF334155),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

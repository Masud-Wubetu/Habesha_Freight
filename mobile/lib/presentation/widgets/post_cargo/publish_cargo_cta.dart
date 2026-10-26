import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class PublishCargoCta extends StatelessWidget {
  final VoidCallback onPublish;
  final int availableTrucksCount;
  final bool isLoading;

  const PublishCargoCta({
    super.key,
    required this.onPublish,
    this.availableTrucksCount = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 4,
              shadowColor: AppColors.gold.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Publish Cargo Request',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          availableTrucksCount > 0
              ? 'Request will be broadcasted to $availableTrucksCount active vehicles on the corridor.'
              : 'Request will be broadcasted live to active transport carriers.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

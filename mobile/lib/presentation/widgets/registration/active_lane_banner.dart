import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ActiveLaneBanner extends StatelessWidget {
  final String laneName;
  final String statusText;
  final String onTimeRate;

  const ActiveLaneBanner({
    super.key,
    this.laneName = 'Active Lane: Addis Ababa – Djibouti',
    this.statusText = 'Fast dispatch telemetry enabled',
    this.onTimeRate = '98.4% On-Time',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Route/Fork icon in dark badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF162338),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Lane info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laneName,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Green on-time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.badgeGreenBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.badgeGreenBorder),
            ),
            child: Text(
              onTimeRate,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.badgeGreenText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

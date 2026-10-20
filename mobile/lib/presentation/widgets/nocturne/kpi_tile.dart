import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';

/// Metric label + big number + optional trend row.
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendIcon,
    this.trendColor = AppColors.secondary,
    this.trailingIcon,
    this.iconColor = AppColors.primary,
    this.valueColor = AppColors.onSurface,
    this.onTap,
  });

  final String label;
  final String value;
  final String? trend;
  final IconData? trendIcon;
  final Color trendColor;
  final IconData? trailingIcon;
  final Color iconColor;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.24,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 20, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (trendIcon != null) ...[
                  Icon(trendIcon, size: 14, color: trendColor),
                  const SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: trendColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

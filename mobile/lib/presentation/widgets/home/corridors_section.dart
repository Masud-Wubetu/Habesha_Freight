import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_model.dart';

class CorridorsSection extends StatelessWidget {
  final List<EthiopianCorridor> corridors;
  final EthiopianCorridor selectedCorridor;
  final ValueChanged<EthiopianCorridor> onSelect;

  const CorridorsSection({
    super.key,
    required this.corridors,
    required this.selectedCorridor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Ethiopian Corridors',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                '${corridors.length} Strategic Corridors',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeGreenText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...corridors.take(3).map((c) => _card(c)),
      ],
    );
  }

  Widget _card(EthiopianCorridor c) {
    final sel = c.id == selectedCorridor.id;
    final isDjibouti = c.destinationCity == 'Djibouti';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onSelect(c),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: AppColors.cardBorder.withValues(alpha: 0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? AppColors.gold : AppColors.cardBorder,
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: sel ? AppColors.gold : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                c.originCity,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isDjibouti
                      ? Icons.sync_alt_rounded
                      : Icons.arrow_forward_rounded,
                  size: 13,
                  color: sel ? AppColors.gold : AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  c.destinationCity,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                sel ? 'Selected' : '${c.distanceKm.toInt()} km',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sel ? AppColors.gold : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: sel ? AppColors.gold : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

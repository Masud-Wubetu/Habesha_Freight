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
        // Section Header Row
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
                '${corridors.length} Active',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeGreenText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Corridors List
        ...corridors.take(3).map((c) => _corridorCard(c)),
      ],
    );
  }

  Widget _corridorCard(EthiopianCorridor c) {
    final isSelected = c.id == selectedCorridor.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onSelect(c),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Origin & Destination
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.textMuted,
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
                        c.destinationCity == 'Djibouti'
                            ? Icons.sync_alt_rounded
                            : Icons.arrow_forward_rounded,
                        size: 13,
                        color: isSelected ? AppColors.gold : AppColors.textMuted,
                      ),
                    ),
                    Flexible(
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
                  ],
                ),
              ),

              // Status / Distance badge
              Text(
                c.id == selectedCorridor.id ? 'Active' : '${c.distanceKm.toInt()} km',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.gold : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isSelected ? AppColors.gold : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

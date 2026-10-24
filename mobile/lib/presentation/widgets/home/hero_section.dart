import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final int loadCount;
  final bool isLoadingLoads;
  final VoidCallback onFindLoad;
  final VoidCallback onFindTrucks;
  final String userName;

  const HeroSection({
    super.key,
    required this.loadCount,
    required this.isLoadingLoads,
    required this.onFindLoad,
    required this.onFindTrucks,
    this.userName = 'Shipper',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.badgeAmberBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.badgeAmberBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'SHIPPER CARGO PORTAL',
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.badgeAmberText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          userName != 'Shipper' && userName.isNotEmpty
              ? 'Welcome, $userName\nMove Your Cargo Across Ethiopia'
              : 'Move Your Cargo.\nFind the Right Truck.',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Instant direct matching, verified carrier telemetry, and transparent corridor rates across Ethiopia.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onFindLoad,
                icon: const Icon(Icons.add_box_rounded, size: 16),
                label: Text(
                  'Post Cargo Load',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFindTrucks,
                icon: const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'My Shipments',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.cardBorder),
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

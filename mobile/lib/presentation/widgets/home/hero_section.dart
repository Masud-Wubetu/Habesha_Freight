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
    final firstName = userName.trim().isNotEmpty
        ? userName.trim().split(' ').first
        : 'Shipper';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clean Title
        Text(
          'Welcome, $firstName',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Book verified carriers and track your corridor cargo in real time.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onFindLoad,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Post Cargo Load',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFindTrucks,
                icon: const Icon(
                  Icons.inventory_2_outlined,
                  size: 17,
                  color: Colors.white,
                ),
                label: Text(
                  'My Shipments',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.cardBorder),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

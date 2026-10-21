import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class BidsView extends StatelessWidget {
  final int activeLoadsCount;
  final VoidCallback onPostLoad;

  const BidsView({super.key, required this.activeLoadsCount, required this.onPostLoad});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Carrier Bids & Offers', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Live market rates from Ethiopian transporters', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
          child: Text('Live Bidding', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.badgeGreenText)),
        ),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 24),
          ),
          const SizedBox(height: 12),
          Text('Direct Transporter Matching', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            activeLoadsCount > 0
                ? '$activeLoadsCount loads are broadcasted to registered carriers. When transporters submit bids below corridor tariffs, they will appear here.'
                : 'Post a cargo load on a corridor to receive competitive bids from verified truck drivers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPostLoad,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Post Load for Bids'),
          ),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

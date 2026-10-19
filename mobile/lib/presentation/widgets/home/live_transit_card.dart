import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_model.dart';

class LiveTransitCard extends StatelessWidget {
  final ActiveTransit transit;
  const LiveTransitCard({super.key, required this.transit});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.badgeGreenText, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('Live GPS Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.badgeGreenText)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
          child: Text('${transit.speedKmH.toInt()} km/h / ${transit.etaMinutes} min', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_shipping_rounded, color: AppColors.gold, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Current Transit: ${transit.transitNumber}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
              Text(transit.carrierName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.badgeGreenBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.badgeGreenBorder)),
              child: Text(transit.status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.badgeGreenText)),
            ),
          ]),
          const SizedBox(height: 14),
          Stack(alignment: Alignment.centerLeft, children: [
            Container(height: 3, decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(2))),
            FractionallySizedBox(widthFactor: transit.progressPercent, child: Container(height: 3, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)))),
            Align(
              alignment: Alignment(transit.progressPercent * 2 - 1, 0),
              child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, size: 8, color: AppColors.textDark)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${transit.originCity}, ${transit.originTime}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
            Text(transit.destinationCity, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ]),
      ),
    ]);
  }
}

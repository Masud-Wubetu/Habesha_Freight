import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_model.dart';

class TelemetrySection extends StatelessWidget {
  final RegionalTelemetry telemetry;
  const TelemetrySection({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Regional Logistics Telemetry', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statCard('ACTIVE TRUCKS', Icons.local_shipping_outlined, AppColors.badgeGreenText, '${telemetry.activeTrucks}', '+${telemetry.trucksOnHighway} on highway', AppColors.badgeGreenText)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('DISPATCH LATENCY', Icons.timer_outlined, AppColors.telebirrBlue, '${telemetry.dispatchLatencyMinutes} min', telemetry.corridorGate, AppColors.textSecondary)),
      ]),
      const SizedBox(height: 12),
      _trustBanner(),
    ]);
  }

  Widget _statCard(String label, IconData icon, Color iconColor, String val, String sub, Color subColor) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted)),
        Icon(icon, size: 16, color: iconColor),
      ]),
      const SizedBox(height: 8),
      Text(val, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(sub, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: subColor)),
    ]),
  );

  Widget _trustBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
    child: Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('100% Transit Protection', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        Text('Direct coverage backed by Ethiopian national transit guarantees.', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
      ])),
    ]),
  );
}

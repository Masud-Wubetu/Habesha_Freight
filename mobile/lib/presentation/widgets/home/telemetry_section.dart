import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class TelemetrySection extends StatelessWidget {
  final int verifiedVehicles;
  final int activeLoadsCount;

  const TelemetrySection({
    super.key,
    required this.verifiedVehicles,
    required this.activeLoadsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Real-Time Logistics Telemetry', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: _statCard(
            context,
            'VERIFIED TRUCKS',
            Icons.local_shipping_outlined,
            AppColors.badgeGreenText,
            '$verifiedVehicles',
            'Active fleet · Tap roster',
            AppColors.badgeGreenText,
            AppRoutes.page29DriverRoster,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            context,
            'LIVE FREIGHT LOADS',
            Icons.inventory_2_outlined,
            AppColors.telebirrBlue,
            '$activeLoadsCount',
            'Open loads · Tap dispatch',
            AppColors.textSecondary,
            AppRoutes.page30DispatchMatrix,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      _trustBanner(context),
    ]);
  }

  Widget _statCard(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    String val,
    String sub,
    Color subColor,
    String route,
  ) => InkWell(
    onTap: () => Navigator.pushNamed(context, route),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted)),
          Icon(icon, size: 16, color: iconColor),
        ]),
        const SizedBox(height: 8),
        Text(val, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(sub, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: subColor), overflow: TextOverflow.ellipsis)),
            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textMuted),
          ],
        ),
      ]),
    ),
  );

  Widget _trustBanner(BuildContext context) => InkWell(
    onTap: () => Navigator.pushNamed(context, AppRoutes.page38Compliance),
    borderRadius: BorderRadius.circular(14),
    child: Container(
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
          Row(
            children: [
              Text('100% Transit Protection', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('View Audits →', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.gold)),
            ],
          ),
          Text('Direct coverage backed by Ethiopian national transit guarantees.', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
        ])),
      ]),
    ),
  );
}

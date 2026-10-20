import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TrackingView extends StatelessWidget {
  final Map<String, dynamic>? activeShipment;
  final int verifiedVehicles;

  const TrackingView({super.key, required this.activeShipment, required this.verifiedVehicles});

  @override
  Widget build(BuildContext context) {
    final hasShipment = activeShipment != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fleet & Shipment Tracking', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Ethiopian corridor telematics & checkpoint telemetry', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
          child: Text(hasShipment ? 'Live GPS' : 'Fleet Standby', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: hasShipment ? AppColors.badgeGreenText : AppColors.gold)),
        ),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.badgeGreenText.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.satellite_alt_rounded, color: AppColors.badgeGreenText, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hasShipment ? 'Active Corridor Telemetry' : 'National Telemetry Grid', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('$verifiedVehicles verified trucks monitored via GPS telemetry', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          _checkpoint('Addis Ababa Central Terminal', 'Dispatched / Cleared', true),
          const Padding(padding: EdgeInsets.only(left: 14), child: SizedBox(height: 16, child: VerticalDivider(color: AppColors.gold, thickness: 2))),
          _checkpoint('Modjo Dry Port Transit Gate', hasShipment ? 'In Transit • 75 km/h' : 'Awaiting Cargo Convoy', hasShipment),
          const Padding(padding: EdgeInsets.only(left: 14), child: SizedBox(height: 16, child: VerticalDivider(color: AppColors.cardBorder, thickness: 1.5))),
          _checkpoint('Djibouti Port Customs Bay', 'Destination Clearance Bay', false),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _checkpoint(String title, String subtitle, bool done) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: done ? AppColors.gold : AppColors.textMuted, shape: BoxShape.circle)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: done ? AppColors.badgeGreenText : AppColors.textSecondary)),
    ])),
  ]);
}

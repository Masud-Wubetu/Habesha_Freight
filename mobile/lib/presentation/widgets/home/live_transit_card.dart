import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class LiveTransitCard extends StatelessWidget {
  final Map<String, dynamic>? activeShipment;
  const LiveTransitCard({super.key, this.activeShipment});

  @override
  Widget build(BuildContext context) {
    final hasShipment = activeShipment != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: hasShipment ? AppColors.badgeGreenText : AppColors.textMuted, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(hasShipment ? 'Live GPS Active' : 'Corridor GPS Standby', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: hasShipment ? AppColors.badgeGreenText : AppColors.textMuted)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
          child: Text(hasShipment ? '${activeShipment!['status'] ?? 'IN_TRANSIT'}' : 'Idle', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
      ]),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.page28RigTelemetry),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasShipment
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : AppColors.cardBorder,
            ),
          ),
          child: Column(
            children: [
              hasShipment ? _shipmentDetails(activeShipment!) : _emptyState(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Open Full Telemetry & CAN-bus',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _emptyState() => Row(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.satellite_alt_outlined, color: AppColors.textMuted, size: 20),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('No Active In-Transit Shipment', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      Text('Real-time GPS telemetry activates when a carrier begins load transit.', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
    ])),
  ]);

  Widget _shipmentDetails(Map<String, dynamic> s) => Column(children: [
    Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_shipping_rounded, color: AppColors.gold, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Shipment: ${s['id']?.toString().substring(0, 8) ?? 'Active'}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        Text(s['carrier_name']?.toString() ?? 'Assigned Carrier', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: AppColors.badgeGreenBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.badgeGreenBorder)),
        child: Text(s['status']?.toString() ?? 'MOVING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.badgeGreenText)),
      ),
    ]),
    const SizedBox(height: 12),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(s['origin_city']?.toString() ?? 'Origin', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.gold),
      Text(s['destination_city']?.toString() ?? 'Destination', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  ]);
}

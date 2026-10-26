import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TrackingView extends StatelessWidget {
  final Map<String, dynamic>? activeShipment;
  final int verifiedVehicles;

  const TrackingView({
    super.key,
    required this.activeShipment,
    required this.verifiedVehicles,
  });

  @override
  Widget build(BuildContext context) {
    final hasShipment = activeShipment != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipment Tracking',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Live GPS corridor tracking and milestone status',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                hasShipment ? 'In Transit' : 'Standby',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: hasShipment ? AppColors.badgeGreenText : AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasShipment)
          _shipmentTrackingCard(context, activeShipment!)
        else
          _emptyTrackingState(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _emptyTrackingState() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      children: [
        const Icon(Icons.satellite_alt_outlined, size: 42, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(
          'No Active Shipments to Track',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'When a carrier accepts your load and begins transit, real-time GPS corridor telemetry and milestones will activate here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Widget _shipmentTrackingCard(BuildContext context, Map<String, dynamic> s) {
    final origin = s['origin_city']?.toString() ?? 'Origin';
    final dest = s['destination_city']?.toString() ?? 'Destination';
    final carrier = s['carrier_name']?.toString() ?? 'Assigned Carrier';
    final cargo = s['cargo_description']?.toString() ?? 'Freight';
    final rawId = s['id']?.toString() ?? '';
    final shortId = rawId.length >= 8 ? rawId.substring(0, 8) : rawId;
    final status = (s['status'] ?? 'IN_TRANSIT').toString().toUpperCase();
    final isDelivered = status == 'DELIVERED';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waybill: #$shortId • $cargo',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Driver: $carrier',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDelivered ? AppColors.badgeGreenBg : const Color(0xFF132035),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDelivered ? AppColors.badgeGreenBorder : AppColors.gold,
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDelivered ? AppColors.badgeGreenText : AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _milestone('Origin Depot: $origin', 'Cargo loaded and manifest cleared', true),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: SizedBox(height: 16, child: VerticalDivider(color: AppColors.gold, thickness: 2)),
          ),
          _milestone(
            'Corridor Transit',
            isDelivered ? 'Corridor segment completed' : 'In transit on national logistics route',
            true,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: SizedBox(height: 16, child: VerticalDivider(color: AppColors.cardBorder, thickness: 1.5)),
          ),
          _milestone(
            'Destination: $dest',
            isDelivered ? 'Delivery confirmed & completed' : 'En route to terminal gate',
            isDelivered,
          ),
        ],
      ),
    );
  }

  Widget _milestone(String title, String subtitle, bool done) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: done ? AppColors.gold : AppColors.textMuted,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: done ? AppColors.badgeGreenText : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

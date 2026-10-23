import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class LiveTransitCard extends StatelessWidget {
  final Map<String, dynamic>? activeShipment;
  const LiveTransitCard({super.key, this.activeShipment});

  @override
  Widget build(BuildContext context) {
    final s = activeShipment;
    final hasShipment = s != null;
    final status = (s?['status'] ?? 'IN_TRANSIT').toString().toUpperCase();
    final isDelivered = status == 'DELIVERED';
    final isInTransit = status == 'IN_TRANSIT' || status == 'MOVING' || status == 'PICKED_UP';

    final Color statusColor = isInTransit
        ? AppColors.badgeGreenText
        : (isDelivered ? const Color(0xFF38BDF8) : AppColors.gold);
    final Color badgeBg = isInTransit
        ? AppColors.badgeGreenBg
        : (isDelivered ? const Color(0xFF0C2A4A) : AppColors.badgeAmberBg);
    final Color badgeBorder = isInTransit
        ? AppColors.badgeGreenBorder
        : (isDelivered ? const Color(0xFF1E4976) : AppColors.badgeAmberBorder);

    final String statusLabel = isInTransit
        ? 'Live GPS Active'
        : (isDelivered
            ? 'Completed Delivery'
            : (hasShipment ? 'Carrier Assigned' : 'Corridor GPS Standby'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                hasShipment ? status : 'Standby',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.page10LiveTracking),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasShipment
                    ? AppColors.gold.withValues(alpha: 0.4)
                    : AppColors.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hasShipment
                    ? _shipmentDetails(s, statusColor, badgeBg, badgeBorder)
                    : _emptyState(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Open Full Telemetry & GPS Corridor Tracking',
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
      ],
    );
  }

  Widget _emptyState() => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.satellite_alt_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active In-Transit Shipment',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Post a cargo load to dispatch a carrier and track real-time telemetry.',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _shipmentDetails(
    Map<String, dynamic> s,
    Color statusColor,
    Color badgeBg,
    Color badgeBorder,
  ) {
    final carrierName = s['carrier_name']?.toString() ?? 'Assigned Carrier';
    final cargoDesc = s['cargo_description']?.toString() ?? 'General Freight';
    final shipmentId = s['id']?.toString() ?? '';
    final shortId = shipmentId.length >= 8 ? shipmentId.substring(0, 8) : shipmentId;
    final status = (s['status'] ?? 'IN_TRANSIT').toString().toUpperCase();

    return Column(
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waybill: #$shortId • $cargoDesc',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Assigned Driver: ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        carrierName,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeBorder),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.badgeGreenText),
                const SizedBox(width: 4),
                Text(
                  s['origin_city']?.toString() ?? 'Origin',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 12,
              color: AppColors.gold,
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.gold),
                const SizedBox(width: 2),
                Text(
                  s['destination_city']?.toString() ?? 'Destination',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

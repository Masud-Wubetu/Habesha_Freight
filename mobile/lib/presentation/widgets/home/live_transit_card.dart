import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class LiveTransitCard extends StatelessWidget {
  final Map<String, dynamic>? activeShipment;
  final VoidCallback? onPostLoad;

  const LiveTransitCard({
    super.key,
    this.activeShipment,
    this.onPostLoad,
  });

  @override
  Widget build(BuildContext context) {
    final s = activeShipment;
    final status = (s?['status'] ?? '').toString().toUpperCase();
    final bool isActuallyActive = s != null &&
        (status == 'IN_TRANSIT' ||
            status == 'DISPATCHED' ||
            status == 'PICKED_UP' ||
            status == 'ASSIGNED');

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
                    color: isActuallyActive
                        ? AppColors.badgeGreenText
                        : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isActuallyActive ? 'Active Cargo Transit' : 'Corridor Transit Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActuallyActive
                        ? AppColors.badgeGreenText
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isActuallyActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeGreenBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.badgeGreenBorder),
                ),
                child: Text(
                  status.replaceAll('_', ' '),
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.badgeGreenText,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        isActuallyActive
            ? _buildActiveCard(context, s)
            : _buildEmptyCard(context),
      ],
    );
  }

  Widget _buildActiveCard(BuildContext context, Map<String, dynamic> s) {
    final carrierName = s['carrier_name']?.toString() ?? 'Assigned Carrier';
    final cargoDesc = s['cargo_description']?.toString() ?? 'General Freight';
    final shipmentId = s['id']?.toString() ?? '';
    final shortId = shipmentId.length >= 8 ? shipmentId.substring(0, 8) : shipmentId;
    final origin = s['origin_city']?.toString() ?? 'Origin';
    final destination = s['destination_city']?.toString() ?? 'Destination';

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.page10LiveTracking),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waybill: #$shortId • $cargoDesc',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Driver: $carrierName',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.badgeGreenText),
                  const SizedBox(width: 6),
                  Text(
                    origin,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                  ),
                  const Icon(Icons.location_on, size: 12, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    destination,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Live Telemetry & Tracking',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.gold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Shipments in Transit',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your posted cargo will display live GPS tracking once a carrier is dispatched.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

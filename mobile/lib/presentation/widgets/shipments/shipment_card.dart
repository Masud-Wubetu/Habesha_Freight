import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_shipment_item.dart';

class ShipmentCard extends StatelessWidget {
  final CorridorShipmentItem item;
  final VoidCallback? onLiveRadarTap;
  final VoidCallback? onCallDriverTap;
  final VoidCallback? onReviewBidsTap;
  final VoidCallback? onManifestPassTap;
  final VoidCallback? onPodReceiptTap;
  final VoidCallback? onTap;

  const ShipmentCard({
    super.key,
    required this.item,
    this.onLiveRadarTap,
    this.onCallDriverTap,
    this.onReviewBidsTap,
    this.onManifestPassTap,
    this.onPodReceiptTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Manifest ID & Real Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      item.id,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 12),

            // Route: Origin ➔ Destination
            Row(
              children: [
                const Icon(Icons.route_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.origin,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.gold),
                      ),
                      Flexible(
                        child: Text(
                          item.destination,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Cargo Description & Rate Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.cargoType,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.lowestOfferEtb != null && item.lowestOfferEtb! > 0)
                  Text(
                    '${item.lowestOfferEtb} ETB',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
              ],
            ),
            const Divider(color: AppColors.cardBorder, height: 20),

            // Bottom Context & Action Row
            _buildBottomActionRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.inTransit:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.badgeGreenBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.badgeGreenBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('IN TRANSIT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.badgeGreenText)),
            ],
          ),
        );
      case ShipmentStatus.bidding:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x661E3A8A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x993B82F6)),
          ),
          child: Text('POSTED • OPEN FOR BIDS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF93C5FD))),
        );
      case ShipmentStatus.awaitingDispatch:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x664C1D95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x998B5CF6)),
          ),
          child: Text('ASSIGNED • AWAITING DISPATCH', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFC4B5FD))),
        );
      case ShipmentStatus.delivered:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.badgeGreenBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.badgeGreenBorder),
          ),
          child: Text('DELIVERED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.badgeGreenText)),
        );
    }
  }

  Widget _buildBottomActionRow(BuildContext context) {
    if (item.status == ShipmentStatus.inTransit) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.driverName ?? item.carrierAssigned ?? 'Assigned Carrier',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCallDriverTap != null)
                  IconButton(
                    onPressed: onCallDriverTap,
                    icon: const Icon(Icons.phone_rounded, size: 16, color: AppColors.gold),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Call Driver',
                  ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onLiveRadarTap,
            icon: const Icon(Icons.location_on_rounded, size: 14),
            label: const Text('Track Live GPS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      );
    }

    if (item.status == ShipmentStatus.bidding) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Broadcasting on corridor',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onReviewBidsTap,
            icon: const Icon(Icons.gavel_rounded, size: 14),
            label: const Text('Review Bids'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      );
    }

    if (item.status == ShipmentStatus.awaitingDispatch) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Carrier: ${item.carrierAssigned ?? "Assigned"}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          OutlinedButton.icon(
            onPressed: onManifestPassTap,
            icon: const Icon(Icons.qr_code_rounded, size: 14, color: Colors.white),
            label: const Text('Manifest Pass', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      );
    }

    // Delivered
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.deliveredDate != null ? 'Delivered: ${item.deliveredDate}' : 'Delivery Completed',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.badgeGreenText),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onPodReceiptTap,
          icon: const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.gold),
          label: const Text('POD Receipt', style: TextStyle(color: AppColors.gold, fontSize: 12)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
        ),
      ],
    );
  }
}

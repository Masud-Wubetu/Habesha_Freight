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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: ID + Cargo Type Pill + Status Badge
            Row(
              children: [
                Text(
                  item.id,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: item.status == ShipmentStatus.inTransit ? AppColors.gold : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070D18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Text(
                    item.cargoType,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 14),

            // Route Schematic: Origin ➔ Destination
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Origin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origin',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.origin,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.originDetail,
                        style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow & Corridor Route
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Text(
                        '${item.distanceKm} km',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.gold, size: 16),
                      Text(
                        item.viaRoute,
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),

                // Destination
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Destination',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.destination,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.destinationDetail,
                        style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Card Specific Section
            if (item.status == ShipmentStatus.inTransit) ...[
              _buildInTransitSection(),
            ] else if (item.status == ShipmentStatus.bidding) ...[
              _buildBiddingSection(),
            ] else if (item.status == ShipmentStatus.awaitingDispatch) ...[
              _buildAwaitingDispatchSection(),
            ] else if (item.status == ShipmentStatus.delivered) ...[
              _buildDeliveredSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.inTransit:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF052E16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF166534)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('In Transit', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF4ADE80))),
            ],
          ),
        );
      case ShipmentStatus.bidding:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF451A03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF92400E)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 12),
              const SizedBox(width: 4),
              Text('${item.bidsCount ?? 5} Bids Active', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.gold)),
            ],
          ),
        );
      case ShipmentStatus.awaitingDispatch:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2E1065),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF581C87)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFFA855F7), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Awaiting Dispatch', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFFD8B4FE))),
            ],
          ),
        );
      case ShipmentStatus.delivered:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF047857)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xFF34D399), size: 12),
              const SizedBox(width: 4),
              Text('Delivered', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF6EE7B7))),
            ],
          ),
        );
    }
  }

  // 1. In Transit Section (#HF-9012)
  Widget _buildInTransitSection() {
    return Column(
      children: [
        // 3-Metric Boxes Row
        Row(
          children: [
            Expanded(
              child: _metricBox(
                label: 'Fleet & Rig',
                val1: item.fleetRig ?? 'Sino 30T Heavy',
                val2: item.plateNumber ?? 'ET-3-89412',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricBox(
                label: 'Telemetry',
                val1: item.telemetrySpeed ?? '68 km/h',
                val2: item.gpsLock ?? 'GPS Lock 100%',
                val1Color: const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricBox(
                label: 'Estimated ETA',
                val1: item.eta ?? '3h 15m',
                val2: item.etaStatus ?? 'On Schedule',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Driver Row & Live Radar CTA
        Row(
          children: [
            // Driver Avatar Circle
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E293B),
              ),
              alignment: Alignment.center,
              child: Text(
                item.driverInitials ?? 'TK',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.driverName ?? 'Tewodros Kassaye',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        'Verified Carrier',
                        style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                      Text(
                        ' ${item.driverRating ?? 4.9}',
                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.gold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Call driver button
            InkWell(
              onTap: onCallDriverTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_rounded, color: Color(0xFF94A3B8), size: 16),
              ),
            ),
            const SizedBox(width: 8),
            // Live Radar button
            ElevatedButton.icon(
              onPressed: onLiveRadarTap,
              icon: const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF0F172A)),
              label: Text(
                'Live Radar',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 36),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Bidding Section (#HF-8841)
  Widget _buildBiddingSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF070D18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lowest Offer', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '18,500',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF22C55E)),
                      ),
                      const SizedBox(width: 4),
                      Text('ETB', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF22C55E))),
                    ],
                  ),
                  Text('Avg. market: 21,000 ETB', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Auction Ends In', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        item.auctionEndsIn ?? '01h 42m',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold),
                      ),
                    ],
                  ),
                  Text('Fees: 1,500 ETB', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _avatarCircle('DA', const Color(0xFF38BDF8)),
                Transform.translate(offset: const Offset(-8, 0), child: _avatarCircle('DG', AppColors.gold)),
                Transform.translate(offset: const Offset(-16, 0), child: _avatarCircle('+3', const Color(0xFF10B981))),
                Transform.translate(
                  offset: const Offset(-10, 0),
                  child: Text('Certified drivers', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onReviewBidsTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 36),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Review Bids', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Awaiting Dispatch Section (#HF-7720)
  Widget _buildAwaitingDispatchSection() {
    final progress = item.loadingProgress ?? 0.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Carrier Assigned:', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text(
                    item.carrierAssigned ?? 'Selam Logistics PLC',
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.gatePassStatus ?? 'Gate Pass Generated',
                    style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Target Departure:', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                Text(
                  item.targetDeparture ?? 'Today @ 16:30',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  'Loading in Progress (${(progress * 100).toInt()}%)',
                  style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.gold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.gold),
                const SizedBox(width: 5),
                Text('Cargo Insured (NIC)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gold)),
              ],
            ),
            OutlinedButton.icon(
              onPressed: onManifestPassTap,
              icon: const Icon(Icons.qr_code_rounded, size: 14, color: Colors.white),
              label: Text('Manifest Pass', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E293B)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Delivered Section (#HF-6504)
  Widget _buildDeliveredSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signed by: ${item.signedBy ?? "Girma Worku (Yard B)"} • ${item.deliveredDate ?? "Yesterday"}',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onPodReceiptTap,
          icon: const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.gold),
          label: Text('POD Receipt', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1E293B)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(0, 32),
          ),
        ),
      ],
    );
  }

  Widget _metricBox({
    required String label,
    required String val1,
    required String val2,
    Color? val1Color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF070D18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            val1,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: val1Color ?? Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            val2,
            style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF94A3B8)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle(String text, Color borderColor) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_bid_item.dart';

class StandardBidCard extends StatelessWidget {
  final CorridorBidItem item;
  final ValueChanged<double>? onCounterOfferSubmitted;
  final VoidCallback? onAcceptTap;

  const StandardBidCard({
    super.key,
    required this.item,
    this.onCounterOfferSubmitted,
    this.onAcceptTap,
  });

  void _showCounterOfferModal(BuildContext context) {
    double currentBid = item.bidAmountEtb;
    final counterController = TextEditingController(
      text: (currentBid * 0.95).round().toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1E05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold, width: 1.2),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Counter Offer to ${item.driverName}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Original Bid: ${item.bidAmountEtb.toStringAsFixed(0)} ETB',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Discount Chips (-5%, -10%, -15%)
                  Text(
                    'Quick Presets',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _presetChip('-5% (${(currentBid * 0.95).round()} ETB)', () {
                        setModalState(() {
                          counterController.text = (currentBid * 0.95).round().toString();
                        });
                      }),
                      const SizedBox(width: 8),
                      _presetChip('-10% (${(currentBid * 0.90).round()} ETB)', () {
                        setModalState(() {
                          counterController.text = (currentBid * 0.90).round().toString();
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Counter Amount Input
                  Text(
                    'Proposed Counter Amount (ETB)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: counterController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.gold),
                      suffixText: 'ETB',
                      suffixStyle: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final val = double.tryParse(counterController.text.trim()) ?? (currentBid * 0.95);
                        Navigator.pop(ctx);
                        onCounterOfferSubmitted?.call(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF042F2E),
                            content: Text(
                              'Counter offer of ${val.toStringAsFixed(0)} ETB submitted to ${item.driverName}.',
                              style: GoogleFonts.inter(color: const Color(0xFF34D399)),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        'Submit Counter Offer',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showAcceptConfirmationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF042F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0D9488)),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accept Driver Bid',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Lock Escrow: ${item.bidAmountEtb.toStringAsFixed(0)} ETB',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1320),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2C44)),
                ),
                child: Column(
                  children: [
                    _confirmRow('Carrier / Driver', item.driverName),
                    const SizedBox(height: 8),
                    _confirmRow('Truck Spec', item.truckSpec),
                    const SizedBox(height: 8),
                    _confirmRow('Pickup Proximity', item.locationText),
                    const SizedBox(height: 8),
                    _confirmRow('Target Ready Time', item.availabilityText),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onAcceptTap?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF042F2E),
                            content: Text(
                              'Accepted ${item.driverName}’s bid! Waybill and escrow pass issued.',
                              style: GoogleFonts.inter(color: const Color(0xFF34D399)),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Confirm & Accept',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLowestFare = item.badgeLabel.contains('Lowest');
    final badgeBg = isLowestFare ? const Color(0xFF042F2E) : const Color(0xFF0C253D);
    final badgeBorder = isLowestFare ? const Color(0xFF0D9488) : const Color(0xFF0284C7);
    final badgeText = isLowestFare ? const Color(0xFF34D399) : const Color(0xFF38BDF8);
    final badgeIcon = isLowestFare ? Icons.local_offer_outlined : Icons.local_shipping_outlined;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E2C44),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges Row: Badge Pill & Submitted Time
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, color: badgeText, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        item.badgeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Submitted Time
                if (item.submittedAgo != null)
                  Text(
                    item.submittedAgo!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Driver Profile Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Live Dot
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155), width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: const Color(0xFF1E293B),
                          child: Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: AppColors.gold.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0D1726), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name, Rating, Rig, Location, Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.driverName,
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          // Rating Pill
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${item.rating}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' (${item.reviewsCount})',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Truck Spec
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.truckSpec,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.locationText,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Ready Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.availabilityText,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Total Price & Actions (Counter Offer & Accept)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DRIVER\'S BID',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item.bidAmountEtb.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                          style: GoogleFonts.outfit(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ETB',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Buttons: Counter Offer and Accept
                Row(
                  children: [
                    // Counter Offer button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showCounterOfferModal(context);
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.gold),
                      label: Text(
                        item.counterOfferEtb != null
                            ? 'Countered'
                            : 'Counter Offer',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Accept button
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAcceptConfirmationModal(context);
                      },
                      icon: Icon(
                        item.isAccepted ? Icons.check_circle_rounded : Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: Text(
                        item.isAccepted ? 'Accepted' : 'Accept',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.isAccepted ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: item.isAccepted ? const Color(0xFF10B981) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/bid_service.dart';
import '../../../core/theme/app_colors.dart';

class BidsView extends StatefulWidget {
  final int activeLoadsCount;
  final VoidCallback onPostLoad;

  const BidsView({super.key, required this.activeLoadsCount, required this.onPostLoad});

  @override
  State<BidsView> createState() => _BidsViewState();
}

class _BidsViewState extends State<BidsView> {
  final BidService _bidService = BidService();
  List<Map<String, dynamic>> _bids = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    setState(() => _loading = true);
    final bids = await _bidService.fetchShipperBids();
    if (!mounted) return;
    setState(() {
      _bids = bids;
      _loading = false;
    });
  }

  Future<void> _handleAccept(Map<String, dynamic> bid) async {
    final loadId = bid['load_id']?.toString() ?? '';
    final bidId = bid['id']?.toString() ?? '';
    final ok = await _bidService.acceptBid(loadId: loadId, bidId: bidId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid accepted! Transporter assigned for delivery.')),
      );
      _loadBids();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not accept bid. Please try again.')),
      );
    }
  }

  Future<void> _handleDecline(Map<String, dynamic> bid) async {
    final loadId = bid['load_id']?.toString() ?? '';
    final bidId = bid['id']?.toString() ?? '';
    final ok = await _bidService.rejectBid(loadId: loadId, bidId: bidId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid declined.')),
      );
      _loadBids();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Carrier Bids & Quotes',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  'Transporter offers on your broadcasted cargo loads',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
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
                '${_bids.length} Offers',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          )
        else if (_bids.isEmpty)
          _emptyState()
        else
          ..._bids.map((b) => _bidTile(b)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'No Active Bids Yet',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            widget.activeLoadsCount > 0
                ? 'Your ${widget.activeLoadsCount} loads are live on the Transporter Load Board. When verified drivers submit quotes, they will appear here.'
                : 'Broadcast a cargo load on an Ethiopian corridor to receive competitive carrier quotes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onPostLoad,
            icon: const Icon(Icons.add_box_rounded, size: 16),
            label: const Text('Post Load for Bids'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bidTile(Map<String, dynamic> bid) {
    final driverName = bid['driver_name']?.toString() ?? 'Transporter';
    final origin = bid['origin_city']?.toString() ?? 'Origin';
    final dest = bid['destination_city']?.toString() ?? 'Destination';
    final cargo = bid['cargo_description']?.toString() ?? 'Cargo';
    final amount = bid['bid_amount_etb']?.toString() ?? '0';
    final vehicle = bid['vehicle_type']?.toString() ?? 'Truck';
    final status = (bid['status'] ?? 'PENDING').toString().toUpperCase();
    final isPending = status == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppColors.gold),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        vehicle,
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$amount ETB',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                '$origin ➔ $dest',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            cargo,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: AppColors.cardBorder, height: 20),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAccept(bid),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept Bid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.badgeGreenText,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _handleDecline(bid),
                  child: const Text('Decline', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            )
          else
            Text(
              'Status: $status',
              style: TextStyle(
                color: status == 'ACCEPTED' ? AppColors.badgeGreenText : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/bid_service.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_bid_item.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/review_bids/active_tender_summary_card.dart';
import '../../widgets/review_bids/review_bids_header.dart';
import '../../widgets/review_bids/standard_bid_card.dart';
import '../../widgets/review_bids/top_match_bid_card.dart';

class ReviewBidsScreen extends StatefulWidget {
  final String initialLanguage;
  final List<CorridorBidItem>? initialBids;

  const ReviewBidsScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.initialBids,
  });

  @override
  State<ReviewBidsScreen> createState() => _ReviewBidsScreenState();
}

class _ReviewBidsScreenState extends State<ReviewBidsScreen> {
  final BidService _bidService = BidService();
  final CorridorService _corridorService = CorridorService();
  late String _language;
  List<CorridorBidItem> _bids = [];
  bool _loading = false;
  String _userName = 'Shipper';

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    if (widget.initialBids != null) {
      _bids = List.from(widget.initialBids!);
    } else {
      _loadBids();
    }
  }

  Future<void> _loadBids() async {
    setState(() => _loading = true);
    final user = await StorageService.getUserName();
    final realBids = await _bidService.fetchShipperBids();

    if (!mounted) return;
    setState(() {
      _userName = user ?? 'Shipper';
      if (realBids.isNotEmpty) {
        _bids = realBids.map((b) => CorridorBidItem.fromMap(b)).toList();
      } else {
        _bids = [];
      }
      _loading = false;
    });
  }

  void _handleLanguageTap(String newLang) {
    setState(() => _language = newLang);
  }

  void _openPostLoadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostLoadSheet(
        corridorService: _corridorService,
        onPosted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Load posted successfully!'),
              backgroundColor: AppColors.card,
            ),
          );
          _loadBids();
        },
      ),
    );
  }

  void _handleProfileTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF0F172A), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Habesha Freight Logistics',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                title: Text('Shipper Dashboard', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined, color: AppColors.gold),
                title: Text('My Shipments', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page08MyShipments);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text('Sign Out', style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.clearAuthData();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (r) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadBids,
          color: AppColors.gold,
          backgroundColor: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewBidsHeader(
                  language: _language,
                  onLanguageChanged: _handleLanguageTap,
                  onProfileTap: _handleProfileTap,
                  activeBidsCount: _bids.length,
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else if (_bids.isEmpty)
                  _buildEmptyState()
                else
                  _buildBidsContent(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 3, // Bids Tab active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page08MyShipments);
          } else if (idx == 2) {
            _openPostLoadSheet();
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.badgeAmberBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.badgeAmberBorder),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Active Bids Yet',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transporter bids on your cargo requests will appear here in real-time. Post a load to start receiving competitive carrier bids.',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openPostLoadSheet,
            icon: const Icon(Icons.add_box_rounded, size: 16),
            label: const Text('Post Cargo Load'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAcceptBid(CorridorBidItem bid) async {
    setState(() {
      _bids = _bids.map((b) => b.id == bid.id ? b.copyWith(isAccepted: true, status: 'ACCEPTED') : b).toList();
    });

    if (bid.loadId != null) {
      final ok = await _bidService.acceptBid(loadId: bid.loadId!, bidId: bid.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bid of ${bid.bidAmountEtb.toStringAsFixed(0)} ETB accepted! Escrow locked & contract awarded to ${bid.driverName}.'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  void _handleCounterOffer(CorridorBidItem bid, double counterAmt) {
    setState(() {
      _bids = _bids.map((b) => b.id == bid.id ? b.copyWith(counterOfferEtb: counterAmt) : b).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Counter offer of ${counterAmt.toStringAsFixed(0)} ETB submitted to ${bid.driverName}.'),
        backgroundColor: AppColors.card,
      ),
    );
  }

  Widget _buildBidsContent() {
    final firstBid = _bids.isNotEmpty ? _bids.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActiveTenderSummaryCard(
          origin: firstBid?.originCity ?? 'Addis Ababa',
          destination: firstBid?.destinationCity ?? 'Dire Dawa',
          cargoSpec: firstBid?.cargoDescription ?? '28 MT Dry Bulk (Teff & Grain)',
          distanceKm: 452,
          bidsCount: _bids.length,
        ),
        const SizedBox(height: 16),

        // Top Match Verified Pro Bid Card
        if (_bids.any((b) => b.isTopMatch))
          TopMatchBidCard(
            item: _bids.firstWhere((b) => b.isTopMatch),
            onAcceptTap: () {
              final top = _bids.firstWhere((b) => b.isTopMatch);
              _handleAcceptBid(top);
            },
          ),
        const SizedBox(height: 16),

        // Standard Bid Cards
        ..._bids.where((b) => !b.isTopMatch).map(
              (bid) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StandardBidCard(
                  item: bid,
                  onCounterOfferSubmitted: (counterAmt) => _handleCounterOffer(bid, counterAmt),
                  onAcceptTap: () => _handleAcceptBid(bid),
                ),
              ),
            ),
      ],
    );
  }
}

// Aliases for page 09 semantic naming
typedef Page09Screen = ReviewBidsScreen;
typedef Page9Screen = ReviewBidsScreen;

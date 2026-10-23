import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/shipper_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_bid_item.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/review_bids/active_tender_summary_card.dart';
import '../../widgets/review_bids/top_match_bid_card.dart';
import '../../widgets/review_bids/standard_bid_card.dart';
import '../../widgets/review_bids/broadcast_tender_card.dart';
import '../../widgets/review_bids/review_bids_header.dart';

class ReviewBidsScreen extends StatefulWidget {
  final String initialLanguage;

  const ReviewBidsScreen({
    super.key,
    this.initialLanguage = 'EN',
  });

  @override
  State<ReviewBidsScreen> createState() => _ReviewBidsScreenState();
}

class _ReviewBidsScreenState extends State<ReviewBidsScreen> {
  final ShipperService _shipperService = ShipperService();
  late String _language;
  List<CorridorBidItem> _bids = [];
  /// bidId → load/request id for accept/counter/reject APIs
  final Map<String, String> _requestIdByBidId = {};
  bool _loading = true;
  String _tenderOrigin = '—';
  String _tenderDestination = '—';
  String _tenderCargo = 'Freight';

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _shipperService.listBids();
      final mapped = <CorridorBidItem>[];
      _requestIdByBidId.clear();

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final bidId = row['id']?.toString() ?? '';
        final requestId = row['load_id']?.toString() ??
            row['request_id']?.toString() ??
            '';
        if (bidId.isEmpty || requestId.isEmpty) continue;
        _requestIdByBidId[bidId] = requestId;
        mapped.add(_mapBid(row, isTopMatch: i == 0));
      }

      if (rows.isNotEmpty) {
        _tenderOrigin = rows.first['origin_city']?.toString() ?? '—';
        _tenderDestination = rows.first['destination_city']?.toString() ?? '—';
        _tenderCargo = rows.first['cargo_description']?.toString() ?? 'Freight';
      }

      if (!mounted) return;
      setState(() {
        _bids = mapped;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _bids = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bids = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load bids'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  CorridorBidItem _mapBid(Map<String, dynamic> row, {required bool isTopMatch}) {
    final bidId = row['id']?.toString() ?? '';
    final name = row['driver_name']?.toString() ?? 'Driver';
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    final amount = row['bid_amount_etb'];
    final ratingRaw = row['driver_rating'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw?.toString() ?? '') ?? 5.0;
    final trips = row['completed_trips'] is num
        ? (row['completed_trips'] as num).toInt()
        : 0;
    final vehicle = row['vehicle_type']?.toString() ?? 'Heavy Rig';
    final capacity = row['capacity_tons'];
    final truckSpec = capacity != null ? '$vehicle • ${capacity}T' : vehicle;
    final status = (row['status']?.toString() ?? '').toUpperCase();

    return CorridorBidItem(
      id: bidId,
      driverName: name,
      driverInitials: initials.isNotEmpty ? initials : 'DR',
      rating: rating,
      reviewsCount: trips,
      truckSpec: truckSpec,
      locationText: '${row['origin_city'] ?? '—'} → ${row['destination_city'] ?? '—'}',
      availabilityText: status.isNotEmpty ? status : 'Pending review',
      bidAmountEtb: amount is num ? amount.toDouble() : 0,
      badgeLabel: isTopMatch ? 'TOP MATCH • VERIFIED PRO' : 'Standard Bid',
      badgeColor: isTopMatch
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981),
      isTopMatch: isTopMatch,
      isEscrowGuaranteed: true,
      isAccepted: status == 'ACCEPTED',
    );
  }

  Future<void> _acceptBid(CorridorBidItem bid) async {
    final requestId = _requestIdByBidId[bid.id];
    if (requestId == null || requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request id for this bid')),
      );
      return;
    }
    try {
      await _shipperService.acceptBid(requestId: requestId, bidId: bid.id);
      if (!mounted) return;
      setState(() {
        _bids = _bids
            .map((b) => b.id == bid.id ? b.copyWith(isAccepted: true) : b)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted bid from ${bid.driverName}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept bid'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _counterBid(CorridorBidItem bid, double amount) async {
    final requestId = _requestIdByBidId[bid.id];
    if (requestId == null || requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request id for this bid')),
      );
      return;
    }
    try {
      await _shipperService.counterBid(
        requestId: requestId,
        bidId: bid.id,
        amountEtb: amount,
      );
      if (!mounted) return;
      setState(() {
        _bids = _bids
            .map((b) =>
                b.id == bid.id ? b.copyWith(counterOfferEtb: amount) : b)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counter-offer ${amount.toStringAsFixed(0)} ETB sent'),
          backgroundColor: AppColors.gold,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send counter-offer'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _rejectBid(CorridorBidItem bid) async {
    final requestId = _requestIdByBidId[bid.id];
    if (requestId == null || requestId.isEmpty) return;
    try {
      await _shipperService.rejectBid(requestId: requestId, bidId: bid.id);
      if (!mounted) return;
      setState(() {
        _bids = _bids.where((b) => b.id != bid.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rejected bid from ${bid.driverName}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject bid'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _handleLanguageTap(String newLang) {
    setState(() => _language = newLang);
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
                        'Selamawit Tadesse',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Bole Dry Port Logistics • Enterprise',
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
                title: Text('Shipper Active Hub (Page 06)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_rounded, color: AppColors.gold),
                title: Text('Escrow Vaults (Page 05)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Corridor Modules Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  CorridorNavigationSheet.show(context);
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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

              ActiveTenderSummaryCard(
                origin: _tenderOrigin,
                destination: _tenderDestination,
                cargoSpec: _tenderCargo,
                distanceKm: 0,
                bidsCount: _bids.length,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.gavel_rounded, color: Color(0xFF94A3B8), size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'No bids yet',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Carrier bids on your open loads will appear here.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                if (_bids.any((b) => b.isTopMatch))
                  TopMatchBidCard(
                    item: _bids.firstWhere((b) => b.isTopMatch),
                    onAcceptTap: () {
                      final top = _bids.firstWhere((b) => b.isTopMatch);
                      _acceptBid(top);
                    },
                  ),
                const SizedBox(height: 16),
                ..._bids.where((b) => !b.isTopMatch).map(
                      (bid) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Dismissible(
                          key: ValueKey(bid.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                          ),
                          confirmDismiss: (_) async {
                            await _rejectBid(bid);
                            return false;
                          },
                          child: StandardBidCard(
                            item: bid,
                            onCounterOfferSubmitted: (counterAmt) {
                              _counterBid(bid, counterAmt);
                            },
                            onAcceptTap: () => _acceptBid(bid),
                          ),
                        ),
                      ),
                    ),
              ],

              // Expansion Banner: Need More Competitive Rates? Broadcast
              const BroadcastTenderCard(availableTrucksCount: 45),
              const SizedBox(height: 16),

              const SizedBox(height: 100),
            ],
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
            Navigator.pushNamed(context, AppRoutes.page07PostCargo);
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
          }
        },
      ),
    );
  }
}

// Aliases for page 09 semantic naming
typedef Page09Screen = ReviewBidsScreen;
typedef Page9Screen = ReviewBidsScreen;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/shipper_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_bid_item.dart';
import '../../../data/models/corridor_shipment_item.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/review_bids/active_tender_summary_card.dart';
import '../../widgets/review_bids/review_bids_header.dart';
import '../../widgets/review_bids/standard_bid_card.dart';
import '../../widgets/review_bids/top_match_bid_card.dart';

class ReviewBidsScreen extends StatefulWidget {
  final String initialLanguage;
  final List<CorridorBidItem>? initialBids;
  final CorridorShipmentItem? targetShipment;

  const ReviewBidsScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.initialBids,
    this.targetShipment,
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
            _openPostLoadSheet();
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_targetShipment != null) {
      final origin = _targetShipment!.origin;
      final dest = _targetShipment!.destination;
      final cargo = _targetShipment!.cargoType;
      final dist = _targetShipment!.distanceKm;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveTenderSummaryCard(
            origin: origin,
            destination: dest,
            cargoSpec: cargo,
            distanceKm: dist,
            bidsCount: 0,
          ),
          const SizedBox(height: 16),
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.badgeAmberBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.badgeAmberBorder),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.gold,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Awaiting Transporter Bids',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your cargo tender is active on the $origin ➔ $dest corridor. Driver bids and rate quotes will appear here as soon as they are submitted.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadBids,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.gold),
                  label: const Text('Refresh Bids', style: TextStyle(color: AppColors.gold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
    final origin = _targetShipment?.origin ?? firstBid?.originCity ?? 'Addis Ababa';
    final dest = _targetShipment?.destination ?? firstBid?.destinationCity ?? 'Dire Dawa';
    final cargo = _targetShipment?.cargoType ?? firstBid?.cargoDescription ?? '28 MT Dry Bulk (Teff & Grain)';
    final dist = _targetShipment?.distanceKm ?? 452;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActiveTenderSummaryCard(
          origin: origin,
          destination: dest,
          cargoSpec: cargo,
          distanceKm: dist,
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

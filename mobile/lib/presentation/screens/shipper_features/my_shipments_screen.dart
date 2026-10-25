import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_shipment_item.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipments/shipment_card.dart';
import '../../widgets/shipments/shipments_header.dart';
import '../../widgets/shipments/shipments_search_and_filter_bar.dart';

class MyShipmentsScreen extends StatefulWidget {
  final List<CorridorShipmentItem>? initialShipments;

  const MyShipmentsScreen({super.key, this.initialShipments});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  final CorridorService _corridorService = CorridorService();
  String _selectedLanguage = 'EN';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterTab = 0; // 0: All, 1: Active, 2: Bidding, 3: Delivered
  String _selectedCorridor = 'All Corridors';
  List<CorridorShipmentItem> _shipments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialShipments != null) {
      _shipments = List.from(widget.initialShipments!);
    } else {
      _loadShipments();
    }
  }

  Future<void> _loadShipments() async {
    setState(() => _loading = true);
    final realShipments = await _corridorService.fetchRealShipments();
    final realLoads = await _corridorService.fetchShipperLoads();

    final List<CorridorShipmentItem> loaded = [];
    for (final s in realShipments) {
      loaded.add(CorridorShipmentItem.fromLoadMap(s));
    }
    for (final l in realLoads) {
      final id = l['id']?.toString() ?? '';
      if (!loaded.any((item) => item.id.contains(id))) {
        loaded.add(CorridorShipmentItem.fromLoadMap(l));
      }
    }

    if (mounted) {
      setState(() {
        _shipments = loaded;
        _loading = false;
      });
    }
  }

  int get _activeCount =>
      _shipments.where((item) => item.status == ShipmentStatus.inTransit).length;

  int get _biddingCount =>
      _shipments.where((item) => item.status == ShipmentStatus.bidding).length;

  int get _deliveredCount =>
      _shipments.where((item) => item.status == ShipmentStatus.delivered).length;

  List<CorridorShipmentItem> get _filteredShipments {
    return _shipments.where((item) {
      if (_selectedFilterTab == 1 && item.status != ShipmentStatus.inTransit) {
        return false;
      }
      if (_selectedFilterTab == 2 && item.status != ShipmentStatus.bidding) {
        return false;
      }
      if (_selectedFilterTab == 3 && item.status != ShipmentStatus.delivered) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = item.id.toLowerCase().contains(q) ||
            item.origin.toLowerCase().contains(q) ||
            item.destination.toLowerCase().contains(q) ||
            item.cargoType.toLowerCase().contains(q) ||
            (item.driverName?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }
      if (_selectedCorridor != 'All Corridors') {
        final origin = item.origin.toLowerCase();
        final dest = item.destination.toLowerCase();
        final filter = _selectedCorridor.toLowerCase();
        if (!filter.contains(origin) && !filter.contains(dest) && !item.viaRoute.toLowerCase().contains(filter)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _loadShipments();
        },
      ),
    );
  }

  void _handleLanguageTap(String lang) {
    setState(() => _selectedLanguage = lang);
  }

  void _handleFilterSettings() {
    final corridorOptions = [
      'All Corridors',
      ..._corridorService.getCorridors().map((c) => '${c.originCity} ➔ ${c.destinationCity}'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Corridor Filters',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'SELECT STRATEGIC CORRIDOR',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: corridorOptions.map((corridor) {
                  final isSelected = _selectedCorridor == corridor;
                  return ChoiceChip(
                    label: Text(corridor),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCorridor = corridor);
                      Navigator.pop(ctx);
                    },
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.card,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textDark : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallDriver(CorridorShipmentItem item) {
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
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E293B),
                ),
                child: const Icon(Icons.phone_rounded, color: AppColors.gold, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                'Calling Driver',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.driverName ?? "Assigned Driver"} • +251 91 148 2910',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 18),
                  label: const Text('End Call'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReviewBids(CorridorShipmentItem item) {
    Navigator.pushNamed(context, AppRoutes.page09ReviewBids);
  }

  void _handleManifestPass(CorridorShipmentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: Row(
          children: [
            const Icon(Icons.qr_code_rounded, color: AppColors.gold, size: 24),
            const SizedBox(width: 8),
            Text(
              'Digital Manifest Pass',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consignment: ${item.id}',
              style: GoogleFonts.inter(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Carrier: ${item.carrierAssigned ?? "Assigned Carrier"}',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            Text(
              'Status: ${item.gatePassStatus ?? "Gate Pass Valid"}',
              style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.qr_code_2_rounded, size: 90, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.gold)),
          ),
        ],
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
                        'Shipper Account',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Habesha Freight Logistics',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.post_add_rounded, color: AppColors.gold),
                title: Text(
                  'Post Cargo Load',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openPostLoadSheet();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF38BDF8)),
                title: Text(
                  'Escrow & Vaults',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(color: AppColors.error, fontSize: 13),
                ),
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
          onRefresh: _loadShipments,
          color: AppColors.gold,
          backgroundColor: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShipmentsHeader(
                  language: _selectedLanguage,
                  onLanguageChanged: _handleLanguageTap,
                  onProfileTap: _handleProfileTap,
                  liveEnRouteCount: _activeCount,
                ),
                const SizedBox(height: 16),
                ShipmentsSearchAndFilterBar(
                  searchController: _searchController,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onFilterSettingsTap: _handleFilterSettings,
                  selectedTabIndex: _selectedFilterTab,
                  onTabSelected: (idx) => setState(() => _selectedFilterTab = idx),
                  allCount: _shipments.length,
                  activeCount: _activeCount,
                  biddingCount: _biddingCount,
                  deliveredCount: _deliveredCount,
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else
                  _buildShipmentsList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 1, // Shipments tab active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 2) {
            _openPostLoadSheet();
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page09ReviewBids);
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page10LiveTracking);
          }
        },
      ),
    );
  }

  Widget _buildShipmentsList() {
    final list = _filteredShipments;

    if (list.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _selectedFilterTab != 0 || _selectedCorridor != 'All Corridors';

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
                color: isFiltered ? const Color(0xFF1E293B) : AppColors.badgeAmberBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFiltered ? const Color(0xFF334155) : AppColors.badgeAmberBorder,
                ),
              ),
              child: Icon(
                isFiltered ? Icons.filter_list_off_rounded : Icons.local_shipping_outlined,
                color: isFiltered ? const Color(0xFF94A3B8) : AppColors.gold,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isFiltered ? 'No matching shipments' : 'No Shipments Yet',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try adjusting your search query or corridor filter.'
                  : 'You have not posted any cargo shipments yet. Post a load to connect with carriers and receive bids.',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isFiltered)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedFilterTab = 0;
                    _selectedCorridor = 'All Corridors';
                  });
                },
                child: const Text('Clear Filters', style: TextStyle(color: AppColors.gold)),
              )
            else
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = list[index];
        return ShipmentCard(
          item: item,
          onLiveRadarTap: () => Navigator.pushNamed(context, AppRoutes.page10LiveTracking),
          onCallDriverTap: () => _handleCallDriver(item),
          onReviewBidsTap: () => _handleReviewBids(item),
          onManifestPassTap: () => _handleManifestPass(item),
          onPodReceiptTap: () => Navigator.pushNamed(context, AppRoutes.page05EscrowVault),
        );
      },
    );
  }
}

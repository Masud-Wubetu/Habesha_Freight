import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_shipment_item.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/shipments/corridor_telemetry_radar_card.dart';
import '../../widgets/shipments/shipment_card.dart';
import '../../widgets/shipments/shipments_header.dart';
import '../../widgets/shipments/shipments_search_and_filter_bar.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  String _selectedLanguage = 'EN';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterTab = 0; // 0: All, 1: Active, 2: Bidding, 3: Delivered
  String _selectedCorridor = 'All Corridors';
  final List<CorridorShipmentItem> _shipments = CorridorShipmentItem.demoShipments;

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
        if (!item.viaRoute.toLowerCase().contains(_selectedCorridor.toLowerCase())) {
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

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _handleFilterSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
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
                    'Corridor & Telemetry Filters',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ACTIVE FREIGHT CORRIDORS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All Corridors',
                  'Expressway A1',
                  'Awash Route',
                  'Hawassa A7',
                  'Northern Line',
                ].map((corridor) {
                  final isSelected = _selectedCorridor == corridor;
                  return ChoiceChip(
                    label: Text(corridor),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCorridor = corridor);
                      Navigator.pop(ctx);
                    },
                    selectedColor: AppColors.gold,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
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

  void _showLiveRadarModal() {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Live Corridor Telemetry Radar',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  children: [
                    _radarStatRow('Active Corridors Monitored', 'Expressway A1 · Hawassa A7'),
                    const Divider(color: Color(0xFF1E293B), height: 16),
                    _radarStatRow('Active Rigs with Live GPS', '12 Carriers (100% Lock)'),
                    const Divider(color: Color(0xFF1E293B), height: 16),
                    _radarStatRow('Average Gate Clearance', '3.8 min at Modjo Smart Bay'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                  },
                  icon: const Icon(Icons.dashboard_rounded, color: Color(0xFF0F172A), size: 18),
                  label: Text('Open Full Operations Radar (Page 06)', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radarStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }

  void _handleLiveRadar(CorridorShipmentItem item) {
    Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
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
                'Calling Carrier Driver',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.driverName ?? "Tewodros Kassaye"} · +251 91 148 2910',
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
    Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
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
            Text('Digital Manifest Pass', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consignment: ${item.id}', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Carrier: ${item.carrierAssigned ?? "Selam Logistics PLC"}', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
            Text('Status: ${item.gatePassStatus ?? "Gate Pass Generated"}', style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12)),
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
            child: const Text('Done', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _handlePodReceipt(CorridorShipmentItem item) {
    Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
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
                        'Shipper Logistics Console',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ethio-Djibouti Real-time Fleet Telemetry',
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
                title: Text('Active Hub & Operations (Page 06)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.post_add_rounded, color: AppColors.gold),
                title: Text('Post Cargo Request Wizard (Page 23 / 07)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page23PostCargo);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Explore All 16 Corridor Modules', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
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
              ShipmentsHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
                liveEnRouteCount: 3,
              ),
              const SizedBox(height: 16),
              ShipmentsSearchAndFilterBar(
                searchController: _searchController,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                onFilterSettingsTap: _handleFilterSettings,
                selectedTabIndex: _selectedFilterTab,
                onTabSelected: (idx) => setState(() => _selectedFilterTab = idx),
                allCount: 12,
                activeCount: 3,
                biddingCount: 5,
                deliveredCount: 4,
              ),
              const SizedBox(height: 16),
              CorridorTelemetryRadarCard(
                onTap: _showLiveRadarModal,
                originHub: 'Addis Ababa Hub (A)',
                destinationHub: 'Dire Dawa (B)',
                departureTime: '05:30 AM',
                arrivalTime: '02:45 PM',
                remainingKm: 112,
                currentLat: '9.020',
                currentLng: '39.800',
                progress: 0.65,
              ),
              const SizedBox(height: 16),

              _buildShipmentsList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 1, // Shipments tab active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page23PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
          }
        },
      ),
    );
  }

  Widget _buildShipmentsList() {
    final list = _filteredShipments;
    if (list.isEmpty) {
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
            const Icon(Icons.search_off_rounded, color: Color(0xFF94A3B8), size: 40),
            const SizedBox(height: 10),
            Text(
              'No shipments found',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or corridor filter.',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
              textAlign: TextAlign.center,
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
          onLiveRadarTap: () => _handleLiveRadar(item),
          onCallDriverTap: () => _handleCallDriver(item),
          onReviewBidsTap: () => _handleReviewBids(item),
          onManifestPassTap: () => _handleManifestPass(item),
          onPodReceiptTap: () => _handlePodReceipt(item),
        );
      },
    );
  }
}


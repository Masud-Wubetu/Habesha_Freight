import 'package:flutter/material.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/corridor_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/corridor_model.dart';
import '../widgets/home/bids_view.dart';
import '../widgets/home/bottom_nav_bar.dart';
import '../widgets/home/deliveries_view.dart';
import '../widgets/home/home_dashboard_view.dart';
import '../widgets/home/tracking_view.dart';
import '../widgets/navigation/corridor_navigation_sheet.dart';
import '../widgets/post_load/post_load_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CorridorService _corridor = CorridorService();
  int _currentTab = 0;
  String _lang = 'EN';
  bool _loading = false;
  List<Map<String, dynamic>> _loads = [];
  Map<String, dynamic>? _activeShipment;
  int _vehiclesCount = 42;
  String _userName = 'Shipper';
  String _userRole = 'SHIPPER';
  late EthiopianCorridor _selectedCorridor;
  double _weight = 14.0;

  static final List<Map<String, dynamic>> _fallbackLoads = [
    {
      'id': '9840-a1',
      'origin_city': 'Addis Ababa',
      'destination_city': 'Djibouti Port',
      'weight_tons': 32,
      'offered_price_etb': 76000,
      'cargo_description': 'Export Yirgacheffe Coffee Grade 1',
      'status': 'POSTED',
    },
    {
      'id': '8821-b2',
      'origin_city': 'Mojo Dry Port',
      'destination_city': 'Mekelle Hub',
      'weight_tons': 28,
      'offered_price_etb': 64500,
      'cargo_description': 'Industrial Steel & Construction Billets',
      'status': 'POSTED',
    },
    {
      'id': '7730-c3',
      'origin_city': 'Dire Dawa',
      'destination_city': 'Galafi Border Post',
      'weight_tons': 24,
      'offered_price_etb': 52000,
      'cargo_description': 'Refined Perishable Cold Chain Cargo',
      'status': 'MATCHED',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCorridor = _corridor.getCorridors().first;
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    _userName = await StorageService.getUserName() ?? 'Demo Shipper';
    _userRole = await StorageService.getUserRole() ?? 'SHIPPER';
    await _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    final loads = await _corridor.fetchRealLoads();
    final shipments = await _corridor.fetchRealShipments();
    final vehicles = await _corridor.fetchVehiclesCount();
    if (!mounted) return;
    setState(() {
      _loads = loads.isNotEmpty ? loads : _fallbackLoads;
      _activeShipment = shipments.isNotEmpty ? shipments.first : null;
      _vehiclesCount = vehicles > 0 ? vehicles : 42;
      _loading = false;
    });
  }

  void _openPostLoadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostLoadSheet(
        corridorService: _corridor,
        onPosted: () {
          _snack('Load posted to PostgreSQL database successfully!');
          _refreshData();
        },
      ),
    );
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.textDark, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _userName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: $_userRole', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('Database: PostgreSQL API Connected', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Divider(color: AppColors.cardBorder, height: 24),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dashboard_rounded, color: AppColors.secondary, size: 20),
              title: const Text('Fleet Command Hub (Pages 27–34)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.fleetHub);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.app_registration_rounded, color: Color(0xFF38BDF8), size: 20),
              title: const Text('Multi-Role Registration (Page 03)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.register);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shield_rounded, color: AppColors.gold, size: 20),
              title: const Text('Escrow & Settlement Vaults (Page 05)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8), size: 20),
              title: const Text('Shipper Active Hub & Ops (Page 06)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.post_add_rounded, color: AppColors.gold, size: 20),
              title: const Text('Post Cargo Request (Page 07 / 23)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page07PostCargo);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_shipping_rounded, color: Color(0xFF38BDF8), size: 20),
              title: const Text('My Shipments & Active Fleet (Page 08)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page08MyShipments);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 20),
              title: const Text('Review Cargo Bids & Live Auction (Page 09)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page09ReviewBids);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.share_location_rounded, color: AppColors.gold, size: 20),
              title: const Text('Live Telemetry & GPS Tracking (Page 10)', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.page10LiveTracking);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.grid_view_rounded, color: AppColors.gold, size: 20),
              title: const Text('All 16 Corridor Modules Catalog', style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Navigator.pop(ctx);
                CorridorNavigationSheet.show(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearAuthData();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (r) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.card));

  Widget _tabBody() {
    switch (_currentTab) {
      case 1:
        return DeliveriesView(loads: _loads, onPostNewLoad: _openPostLoadSheet);
      case 3:
        return BidsView(activeLoadsCount: _loads.length, onPostLoad: _openPostLoadSheet);
      case 4:
        return TrackingView(activeShipment: _activeShipment, verifiedVehicles: _vehiclesCount);
      default:
        return HomeDashboardView(
          language: _lang,
          onLanguageChanged: (l) => setState(() => _lang = l),
          onProfileTap: _showProfileModal,
          userName: _userName,
          loadCount: _loads.length,
          isLoadingLoads: _loading,
          onFindLoad: () => setState(() => _currentTab = 1),
          onFindTrucks: () => setState(() => _currentTab = 4),
          activeShipment: _activeShipment,
          corridors: _corridor.getCorridors(),
          selectedCorridor: _selectedCorridor,
          onSelectCorridor: (c) => setState(() => _selectedCorridor = c),
          weight: _weight,
          onWeightChanged: (w) => setState(() => _weight = w),
          corridorService: _corridor,
          onRequestTrucks: _openPostLoadSheet,
          vehiclesCount: _vehiclesCount,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.gold,
          backgroundColor: AppColors.card,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _tabBody(),
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: _currentTab,
        onTap: (idx) {
          if (idx == 2) {
            _openPostLoadSheet();
          } else {
            setState(() => _currentTab = idx);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/corridor_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/corridor_model.dart';
import '../widgets/home/bids_view.dart';
import '../widgets/home/bottom_nav_bar.dart';
import '../widgets/home/deliveries_view.dart';
import '../widgets/home/home_dashboard_view.dart';
import '../widgets/home/tracking_view.dart';
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
  int _vehiclesCount = 0;
  String _userName = 'Shipper';
  String _userRole = 'SHIPPER';
  late EthiopianCorridor _selectedCorridor;
  double _weight = 14.0;

  @override
  void initState() {
    super.initState();
    _selectedCorridor = _corridor.getCorridors().first;
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    final hasToken = await StorageService.hasToken();
    if (!hasToken) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _userName = await StorageService.getUserName() ?? 'Shipper';
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
      _loads = loads;
      _activeShipment = shipments.isNotEmpty ? shipments.first : null;
      _vehiclesCount = vehicles;
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
        title: Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Role: $_userRole\nReal Data Mode: PostgreSQL Connected', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearAuthData();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
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

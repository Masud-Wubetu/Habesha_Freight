import 'package:flutter/material.dart';
import '../../core/services/corridor_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/corridor_model.dart';
import '../widgets/home/corridors_section.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/live_transit_card.dart';
import '../widgets/home/rate_estimator_section.dart';
import '../widgets/home/telemetry_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CorridorService _corridor = CorridorService();
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

  Future<void> _handlePostLoad() async {
    final tariff = _corridor.calculateTariff(corridor: _selectedCorridor, weightTons: _weight);
    _snack('Broadcasting ${_selectedCorridor.originCity} ➔ ${_selectedCorridor.destinationCity} to carriers...');

    final success = await _corridor.postRealLoad(
      originCity: _selectedCorridor.originCity,
      destinationCity: _selectedCorridor.destinationCity,
      weightTons: _weight,
      offeredPriceEtb: tariff.estimatedPriceEtb,
    );

    if (success) {
      _snack('Load posted to PostgreSQL! Corridors updated.');
      await _refreshData();
    } else {
      _snack('Could not post load. Please verify permissions.');
    }
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HomeHeader(language: _lang, onLanguageChanged: (l) => setState(() => _lang = l), onProfileTap: _showProfileModal),
              const SizedBox(height: 18),
              HeroSection(
                loadCount: _loads.length,
                isLoadingLoads: _loading,
                onFindLoad: () => _snack('${_loads.length} loads live in PostgreSQL database.'),
                onFindTrucks: () => _snack('$_vehiclesCount verified carrier vehicles available.'),
              ),
              const SizedBox(height: 18),
              LiveTransitCard(activeShipment: _activeShipment),
              const SizedBox(height: 20),
              CorridorsSection(
                corridors: _corridor.getCorridors(),
                selectedCorridor: _selectedCorridor,
                onSelect: (c) => setState(() => _selectedCorridor = c),
              ),
              const SizedBox(height: 20),
              RateEstimatorSection(
                corridor: _selectedCorridor,
                weightTons: _weight,
                onWeightChanged: (w) => setState(() => _weight = w),
                corridorService: _corridor,
                onRequestTrucks: _handlePostLoad,
              ),
              const SizedBox(height: 20),
              TelemetrySection(
                verifiedVehicles: _vehiclesCount,
                activeLoadsCount: _loads.length,
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

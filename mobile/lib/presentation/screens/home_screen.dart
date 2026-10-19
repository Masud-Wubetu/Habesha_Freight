import 'package:flutter/material.dart';
import '../../core/services/corridor_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/corridor_model.dart';
import '../widgets/home/corridors_section.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/live_transit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CorridorService _corridorService = CorridorService();
  String _lang = 'EN';
  bool _loadingLoads = false;
  List<Map<String, dynamic>> _loads = [];
  late EthiopianCorridor _selectedCorridor;
  late ActiveTransit _transit;
  late RegionalTelemetry _telemetry;

  @override
  void initState() {
    super.initState();
    _selectedCorridor = _corridorService.getCorridors().first;
    _transit = _corridorService.getActiveTransit();
    _telemetry = _corridorService.getRegionalTelemetry();
    _fetchLoads();
  }

  Future<void> _fetchLoads() async {
    setState(() => _loadingLoads = true);
    final loads = await _corridorService.fetchRealLoads();
    if (!mounted) return;
    setState(() { _loads = loads; _loadingLoads = false; });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.card));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HomeHeader(language: _lang, onLanguageChanged: (l) => setState(() => _lang = l)),
            const SizedBox(height: 18),
            HeroSection(
              loadCount: _loads.length,
              isLoadingLoads: _loadingLoads,
              onFindLoad: () => _snack(_loadingLoads ? 'Scanning loads...' : '${_loads.length} loads live in PostgreSQL'),
              onFindTrucks: () => _snack('Connecting to ${_telemetry.activeTrucks} carriers...'),
            ),
            const SizedBox(height: 18),
            LiveTransitCard(transit: _transit),
            const SizedBox(height: 20),
            CorridorsSection(
              corridors: _corridorService.getCorridors(),
              selectedCorridor: _selectedCorridor,
              onSelect: (c) => setState(() => _selectedCorridor = c),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

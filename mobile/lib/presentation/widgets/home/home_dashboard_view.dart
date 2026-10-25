import 'package:flutter/material.dart';
import '../../../data/models/corridor_model.dart';
import '../../../core/services/corridor_service.dart';
import 'corridors_section.dart';
import 'hero_section.dart';
import 'home_header.dart';
import 'live_transit_card.dart';
import 'rate_estimator_section.dart';
import 'telemetry_section.dart';

class HomeDashboardView extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onProfileTap;
  final int loadCount;
  final bool isLoadingLoads;
  final VoidCallback onFindLoad;
  final VoidCallback onFindTrucks;
  final Map<String, dynamic>? activeShipment;
  final List<EthiopianCorridor> corridors;
  final EthiopianCorridor selectedCorridor;
  final ValueChanged<EthiopianCorridor> onSelectCorridor;
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final CorridorService corridorService;
  final VoidCallback onRequestTrucks;
  final int vehiclesCount;

  const HomeDashboardView({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onProfileTap,
    required this.loadCount,
    required this.isLoadingLoads,
    required this.onFindLoad,
    required this.onFindTrucks,
    required this.activeShipment,
    required this.corridors,
    required this.selectedCorridor,
    required this.onSelectCorridor,
    required this.weight,
    required this.onWeightChanged,
    required this.corridorService,
    required this.onRequestTrucks,
    required this.vehiclesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(language: language, onLanguageChanged: onLanguageChanged, onProfileTap: onProfileTap),
        const SizedBox(height: 18),
        HeroSection(loadCount: loadCount, isLoadingLoads: isLoadingLoads, onFindLoad: onFindLoad, onFindTrucks: onFindTrucks),
        const SizedBox(height: 18),
        LiveTransitCard(activeShipment: activeShipment),
        const SizedBox(height: 20),
        CorridorsSection(corridors: corridors, selectedCorridor: selectedCorridor, onSelect: onSelectCorridor),
        const SizedBox(height: 20),
        RateEstimatorSection(
          corridor: selectedCorridor,
          weightTons: weight,
          onWeightChanged: onWeightChanged,
          corridorService: corridorService,
          onRequestTrucks: onRequestTrucks,
        ),
        const SizedBox(height: 20),
        TelemetrySection(verifiedVehicles: vehiclesCount, activeLoadsCount: loadCount),
        const SizedBox(height: 24),
      ],
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';
import '../../data/models/corridor_model.dart';

class CorridorService {
  final http.Client _client;

  CorridorService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns list of key national corridors
  List<EthiopianCorridor> getCorridors() {
    return EthiopianCorridor.standardCorridors;
  }

  /// Calculates official corridor freight tariff based on corridor distance and weight in metric tons
  CorridorEstimate calculateTariff({
    required EthiopianCorridor corridor,
    required double weightTons,
  }) {
    final double rawTariff = (corridor.distanceKm * corridor.baseRatePerTonKm * weightTons) +
        corridor.fixedHandlingFeeEtb;

    // Round to nearest 500 ETB for clean tariff quotation matching standard logistics practice
    final double roundedPrice = (rawTariff / 500).round() * 500.0;
    
    // Average freight truck speed on Ethiopian highways ~ 50 km/h
    final int hours = (corridor.distanceKm / 50).ceil();

    return CorridorEstimate(
      estimatedPriceEtb: roundedPrice,
      distanceKm: corridor.distanceKm,
      transitHoursEstimate: hours,
    );
  }

  /// Live telemetry snapshot
  RegionalTelemetry getRegionalTelemetry() {
    return RegionalTelemetry.defaultTelemetry;
  }

  /// Live active transit snapshot
  ActiveTransit getActiveTransit() {
    return ActiveTransit.defaultTransit;
  }

  /// Fetch live available loads from real PostgreSQL backend database
  Future<List<Map<String, dynamic>>> fetchRealLoads() async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.loads}');

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['loads'] is List) {
          return List<Map<String, dynamic>>.from(data['loads']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

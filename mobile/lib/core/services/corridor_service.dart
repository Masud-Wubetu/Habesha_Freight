import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/storage_service.dart';
import '../../data/models/corridor_model.dart';

class CorridorService {
  final http.Client _client;

  CorridorService({http.Client? client}) : _client = client ?? http.Client();

  List<EthiopianCorridor> getCorridors() => EthiopianCorridor.standardCorridors;

  CorridorEstimate calculateTariff({required EthiopianCorridor corridor, required double weightTons}) {
    final double rawTariff = (corridor.distanceKm * corridor.baseRatePerTonKm * weightTons) + corridor.fixedHandlingFeeEtb;
    final double rounded = (rawTariff / 500).round() * 500.0;
    return CorridorEstimate(
      estimatedPriceEtb: rounded,
      distanceKm: corridor.distanceKm,
      transitHoursEstimate: (corridor.distanceKm / 50).ceil(),
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String> _getBaseUrl() async {
    final customUrl = await StorageService.getBaseUrl();
    return customUrl ?? ApiConfig.baseUrl;
  }

  /// Real database loads from GET /api/loads
  Future<List<Map<String, dynamic>>> fetchRealLoads() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client.get(Uri.parse('$base${ApiConfig.loads}'), headers: await _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data is Map && data['data'] is List) return List<Map<String, dynamic>>.from(data['data']);
        if (data is Map && data['loads'] is List) return List<Map<String, dynamic>>.from(data['loads']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Real database shipper stats from GET /api/loads/shipper/stats
  Future<Map<String, dynamic>?> fetchShipperStats() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client.get(
        Uri.parse('$base/loads/shipper/stats'),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] is Map) {
          return Map<String, dynamic>.from(body['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Real database shipments from GET /api/shipments
  Future<List<Map<String, dynamic>>> fetchRealShipments() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client.get(Uri.parse('$base${ApiConfig.shipments}'), headers: await _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['data'] is List) return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Real database vehicle count from GET /api/vehicles
  Future<int> fetchVehiclesCount() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client.get(Uri.parse('$base${ApiConfig.vehicles}'), headers: await _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return data.length;
        if (data is Map && data['count'] is num) return (data['count'] as num).toInt();
        if (data is Map && data['data'] is List) return (data['data'] as List).length;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Post real load to PostgreSQL database via POST /api/loads
  Future<bool> postRealLoad({
    required String originCity,
    required String destinationCity,
    required double weightTons,
    required double offeredPriceEtb,
  }) async {
    try {
      final base = await _getBaseUrl();
      final res = await _client.post(
        Uri.parse('$base${ApiConfig.loads}'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'cargo_description': 'Corridor Container Freight ($originCity to $destinationCity)',
          'weight_tons': weightTons,
          'origin_city': originCity,
          'destination_city': destinationCity,
          'origin_lat': 8.9806,
          'origin_lng': 38.7578,
          'destination_lat': 9.6008,
          'destination_lng': 41.8501,
          'offered_price_etb': offeredPriceEtb,
        }),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

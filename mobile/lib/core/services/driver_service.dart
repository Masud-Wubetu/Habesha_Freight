import 'api_client.dart';
import '../config/api_config.dart';

/// Driver-facing API helpers (`/drivers/*`).
class DriverService {
  DriverService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<Map<String, dynamic>> getStats() async {
    final res = await _api.get(ApiConfig.driverStats);
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _api.get(ApiConfig.driverProfile);
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<List<Map<String, dynamic>>> listShipments() async {
    final res = await _api.get(ApiConfig.driverShipments);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> listAvailableLoads() async {
    final res = await _api.get(ApiConfig.availableLoads);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> listBids() async {
    final res = await _api.get(ApiConfig.driverBids);
    return _asList(res['data']);
  }

  Future<Map<String, dynamic>> getEarnings() async {
    final res = await _api.get(ApiConfig.driverEarnings);
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    final res = await _api.post(
      ApiConfig.driverLocation,
      body: {'latitude': lat, 'longitude': lng},
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }

  Future<Map<String, dynamic>> placeBid({
    required String loadId,
    required num amountEtb,
  }) async {
    final res = await _api.post(
      ApiConfig.bids,
      body: {'load_id': loadId, 'bid_amount_etb': amountEtb},
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }
}

List<Map<String, dynamic>> _asList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  if (raw is Map && raw['items'] is List) return _asList(raw['items']);
  return const [];
}

import 'api_client.dart';
import '../config/api_config.dart';

/// Shipper-facing API helpers (`/shipper/*`, `/loads`, `/shipments`).
class ShipperService {
  ShipperService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _api.get(ApiConfig.shipperProfile);
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<List<Map<String, dynamic>>> listCompanies() async {
    final res = await _api.get(ApiConfig.shipperCompanies);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> listRequests() async {
    final res = await _api.get(ApiConfig.shipperRequests);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> listShipments() async {
    final res = await _api.get(ApiConfig.shipments);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> listLoads() async {
    final res = await _api.get(ApiConfig.loads);
    return _asList(res['data']);
  }

  Future<Map<String, dynamic>> acceptBid({
    required String requestId,
    required String bidId,
  }) async {
    final res = await _api.post(ApiConfig.shipperAcceptBid(requestId, bidId));
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }

  Future<Map<String, dynamic>> counterBid({
    required String requestId,
    required String bidId,
    required num amountEtb,
  }) async {
    final res = await _api.post(
      ApiConfig.shipperCounterBid(requestId, bidId),
      body: {'counter_amount_etb': amountEtb},
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }

  Future<Map<String, dynamic>> rejectBid({
    required String requestId,
    required String bidId,
  }) async {
    final res = await _api.post(ApiConfig.shipperRejectBid(requestId, bidId));
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }

  Future<Map<String, dynamic>> rateDriver({
    required String driverId,
    required int rating,
    String? comment,
    String? shipmentId,
  }) async {
    final res = await _api.post(
      ApiConfig.shipperRatings,
      body: {
        'driver_id': driverId,
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (shipmentId != null) 'shipment_id': shipmentId,
      },
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

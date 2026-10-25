import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ShipperService {
  final http.Client _client;

  ShipperService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> _getBaseUrl() async {
    final customUrl = await StorageService.getBaseUrl();
    return customUrl ?? ApiConfig.baseUrl;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Get authenticated shipper profile & database statistics
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client
          .get(Uri.parse('$base/shippers/profile'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 8));
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

  /// Update authenticated shipper profile
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final base = await _getBaseUrl();
      final payload = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) payload['full_name'] = fullName;
      if (email != null && email.isNotEmpty) payload['email'] = email;
      if (phoneNumber != null && phoneNumber.isNotEmpty) payload['phone_number'] = phoneNumber;

      final res = await _client
          .put(
            Uri.parse('$base/shippers/profile'),
            headers: await _authHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get all requests posted by current shipper
  Future<List<Map<String, dynamic>>> getShipmentRequests() async {
    try {
      final base = await _getBaseUrl();
      final res = await _client
          .get(Uri.parse('$base/shippers/requests'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Search real fleet transport companies from PostgreSQL
  Future<List<Map<String, dynamic>>> getFleetCompanies({String? search}) async {
    try {
      final base = await _getBaseUrl();
      final uri = search != null && search.isNotEmpty
          ? Uri.parse('$base/shippers/companies?search=${Uri.encodeComponent(search)}')
          : Uri.parse('$base/shippers/companies');
      final res = await _client
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Submit a direct fleet request to a transport company
  Future<bool> createFleetRequest({
    required String companyId,
    required String originCity,
    required String destinationCity,
    required String cargoDescription,
    required double weightTons,
    required double offeredPriceEtb,
    int trucksNeeded = 1,
  }) async {
    try {
      final base = await _getBaseUrl();
      final res = await _client
          .post(
            Uri.parse('$base/shippers/fleet-requests'),
            headers: await _authHeaders(),
            body: jsonEncode({
              'company_id': companyId,
              'origin_city': originCity,
              'destination_city': destinationCity,
              'cargo_description': cargoDescription,
              'weight_tons': weightTons,
              'offered_price_etb': offeredPriceEtb,
              'trucks_needed': trucksNeeded,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Rate a carrier driver upon completed consignment
  Future<bool> rateDriver({
    required String driverId,
    required String deliveryId,
    required int rating,
    String? comment,
  }) async {
    try {
      final base = await _getBaseUrl();
      final res = await _client
          .post(
            Uri.parse('$base/shippers/ratings/driver'),
            headers: await _authHeaders(),
            body: jsonEncode({
              'driver_id': driverId,
              'delivery_id': deliveryId,
              'rating': rating,
              'comment': comment ?? '',
            }),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class BidSubmissionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const BidSubmissionResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class BidService {
  final http.Client _client;

  BidService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Submit a freight bid to the backend
  Future<BidSubmissionResult> submitBid({
    required String loadId,
    required double bidAmountEtb,
    String? terminalGateSlot,
    bool fuelPassesInclusive = true,
    bool waterproofTarpVerified = true,
    String? note,
  }) async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;

      // Prefer canonical POST /bids; fall back to /drivers/bids if needed.
      final uri = Uri.parse('$base${ApiConfig.bids}');

      final payload = {
        'load_id': loadId,
        'bid_amount_etb': bidAmountEtb,
        'terminal_slot': terminalGateSlot,
        'fuel_toll_inclusive': fuelPassesInclusive,
        'waterproof_tarp_verified': waterproofTarpVerified,
        'note': note,
      };

      final response = await _client
          .post(
            uri,
            headers: _headers(token),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return BidSubmissionResult(
          success: true,
          message: body['message'] ?? 'Bid transmitted to shipper successfully.',
          data: body['data'] as Map<String, dynamic>?,
        );
      } else {
        final fallbackUri = Uri.parse('$base${ApiConfig.driverBids}');
        final fallbackResponse = await _client
            .post(
              fallbackUri,
              headers: _headers(token),
              body: jsonEncode({
                'load_id': loadId,
                'bid_amount_etb': bidAmountEtb,
              }),
            )
            .timeout(const Duration(seconds: 8));

        if (fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 300) {
          final Map<String, dynamic> fallbackBody = jsonDecode(fallbackResponse.body);
          return BidSubmissionResult(
            success: true,
            message: fallbackBody['message'] ?? 'Bid transmitted successfully.',
            data: fallbackBody['data'] as Map<String, dynamic>?,
          );
        }

        try {
          final Map<String, dynamic> errBody = jsonDecode(response.body);
          return BidSubmissionResult(
            success: false,
            message: errBody['message'] ?? 'Failed to submit bid (HTTP ${response.statusCode})',
          );
        } catch (_) {
          return BidSubmissionResult(
            success: false,
            message: 'Server returned HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // Return clear informative message when offline or server unreachable
      return BidSubmissionResult(
        success: false,
        message: 'Could not connect to freight server: $e',
      );
    }
  }

  /// Fetch all bids placed on the current shipper's loads
  Future<List<Map<String, dynamic>>> fetchShipperBids({String? loadId, String? status}) async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;

      final queryParams = <String, String>{};
      if (loadId != null && loadId.isNotEmpty) queryParams['load_id'] = loadId;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      final queryString = queryParams.isNotEmpty
          ? '?${Uri(queryParameters: queryParams).query}'
          : '';

      var uri = Uri.parse('$base/shipper/bids$queryString');
      var res = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) {
        uri = Uri.parse('$base/shippers/bids$queryString');
        res = await _client
            .get(uri, headers: _headers(token))
            .timeout(const Duration(seconds: 8));
      }

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
        if (body is List) {
          return List<Map<String, dynamic>>.from(body);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch bids for a specific load request
  Future<List<Map<String, dynamic>>> fetchRequestBids(String loadId) async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;

      final uri = Uri.parse('$base/shipper/requests/$loadId/bids');
      final res = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
      // Fallback
      return fetchShipperBids(loadId: loadId);
    } catch (_) {
      return [];
    }
  }

  /// Accept a carrier's bid
  Future<bool> acceptBid({required String loadId, required String bidId}) async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base/shipper/requests/$loadId/bids/$bidId/accept');
      final res = await _client.patch(uri, headers: _headers(token));
      if (res.statusCode == 200) return true;

      final fallbackUri = Uri.parse('$base/bids/$bidId/status');
      final fb = await _client.patch(
        fallbackUri,
        headers: _headers(token),
        body: jsonEncode({'status': 'ACCEPTED'}),
      );
      return fb.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Reject a carrier's bid
  Future<bool> rejectBid({required String loadId, required String bidId}) async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base/shipper/requests/$loadId/bids/$bidId/reject');
      final res = await _client.patch(uri, headers: _headers(token));
      if (res.statusCode == 200) return true;

      final fallbackUri = Uri.parse('$base/bids/$bidId/status');
      final fb = await _client.patch(
        fallbackUri,
        headers: _headers(token),
        body: jsonEncode({'status': 'REJECTED'}),
      );
      return fb.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}


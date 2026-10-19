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

      // Try driver route first, fallback to general bids route
      final uri = Uri.parse('$base${ApiConfig.driverBids}');

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
        // If driver route returns 404 or auth issue, try standard /bids endpoint
        final fallbackUri = Uri.parse('$base${ApiConfig.bids}');
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
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Backend default port is 5000 (`backend/src/server.ts`).
  /// On web (including phone browser over LAN), use the page host so the
  /// device can reach the API — not `localhost` on the phone itself.
  static String _defaultBaseUrl() {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return 'http://$host:5000/api';
      }
      return 'http://localhost:5000/api';
    }
    try {
      // Android emulator → host machine. Physical Android: set StorageService base URL
      // or use your LAN IP (e.g. http://10.240.71.57:5000/api).
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  static String baseUrl = _defaultBaseUrl();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String telebirr = '/auth/telebirr';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Company (FLEET_OWNER) — pages 27–34
  static const String companyProfile = '/company/profile';
  static const String companyStats = '/company/stats';
  static const String companyVehicles = '/company/vehicles';
  static const String companyDrivers = '/company/drivers';
  static const String companyDeliveries = '/company/deliveries';
  static const String companyFleetRequests = '/company/fleet-requests';

  static String companyFleetRequestAccept(String id) =>
      '/company/fleet-requests/$id/accept';
  static String companyFleetRequestDecline(String id) =>
      '/company/fleet-requests/$id/decline';
  static String companyFleetRequestAssign(String id) =>
      '/company/fleet-requests/$id/assign';

  // Marketplace (corridor / home / bids)
  static const String loads = '/loads';
  static const String shipments = '/shipments';
  static const String vehicles = '/vehicles';
  static const String bids = '/bids';

  // Escrow / driver
  static const String escrowLedger = '/escrow/ledger/all';
  static String escrowRelease(String shipmentId) =>
      '/escrow/$shipmentId/release';
  static String escrowRefund(String shipmentId) =>
      '/escrow/$shipmentId/refund';
  static const String driverStats = '/driver/stats';
  static const String driverShipments = '/driver/shipments';
  static const String driverBids = '/driver/bids';
  static const String availableLoads = '/driver/loads/available';

  // System
  static const String health = '/health';
}

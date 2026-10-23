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
  static const String profile = '/auth/profile';

  // Company (FLEET_OWNER)
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

  // Marketplace
  static const String loads = '/loads';
  static const String shipments = '/shipments';
  static const String vehicles = '/vehicles';
  static const String bids = '/bids';

  // Shipper
  static const String shipperProfile = '/shipper/profile';
  static const String shipperCompanies = '/shipper/companies';
  static const String shipperRequests = '/shipper/requests';
  static const String shipperFleetRequests = '/shipper/fleet-requests';
  static const String shipperRatings = '/shipper/ratings/driver';
  static String shipperAcceptBid(String requestId, String bidId) =>
      '/shipper/requests/$requestId/bids/$bidId/accept';
  static String shipperCounterBid(String requestId, String bidId) =>
      '/shipper/requests/$requestId/bids/$bidId/counter';
  static String shipperRejectBid(String requestId, String bidId) =>
      '/shipper/requests/$requestId/bids/$bidId/reject';

  // Escrow
  static const String escrowLedger = '/escrow/ledger/all';
  static const String escrowDeposit = '/escrow/deposit';
  static String escrowRelease(String shipmentId) =>
      '/escrow/$shipmentId/release';
  static String escrowRefund(String shipmentId) =>
      '/escrow/$shipmentId/refund';
  static String escrowStatus(String shipmentId) => '/escrow/$shipmentId';

  // Driver (canonical /drivers; backend also aliases /driver)
  static const String driverStats = '/drivers/stats';
  static const String driverShipments = '/drivers/shipments';
  static const String driverBids = '/drivers/bids';
  static const String driverEarnings = '/drivers/earnings';
  static const String driverProfile = '/drivers/profile';
  static const String availableLoads = '/drivers/loads/available';
  static const String driverLocation = '/drivers/location';

  // Tracking / messages
  static String tracking(String shipmentId) => '/tracking/$shipmentId';
  static const String trackingLocation = '/tracking/location';
  static const String messages = '/messages';

  // System
  static const String health = '/health';
}

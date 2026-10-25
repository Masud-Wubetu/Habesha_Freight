import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/services/shipper_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/live_tracking/live_tracking_header.dart';
import '../../widgets/live_tracking/corridor_radar_map_card.dart';
import '../../widgets/live_tracking/telemetry_metrics_row.dart';
import '../../widgets/live_tracking/sensor_integrity_row.dart';
import '../../widgets/live_tracking/driver_contact_card.dart';
import '../../widgets/live_tracking/share_tracking_modal.dart';
import '../../widgets/live_tracking/driver_chat_modal.dart';

class LiveTelemetryTrackingScreen extends StatefulWidget {
  final String initialLanguage;
  final String waybillNumber;
  final bool enableAnimation;
  final Map<String, dynamic>? shipment;

  const LiveTelemetryTrackingScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.waybillNumber = '#HF-8841-ET',
    this.enableAnimation = true,
    this.shipment,
  });

  @override
  State<LiveTelemetryTrackingScreen> createState() =>
      _LiveTelemetryTrackingScreenState();
}

class _LiveTelemetryTrackingScreenState
    extends State<LiveTelemetryTrackingScreen> {
  final ShipperService _shipperService = ShipperService();
  final CorridorService _corridorService = CorridorService();

  late String _language;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _activeShipment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _activeShipment = widget.shipment;
    _loadData();
  }

  Future<void> _loadData() async {
    final prof = await _shipperService.getProfile();
    if (!mounted) return;
    setState(() => _profile = prof);

    if (_activeShipment == null) {
      final shipments = await _corridorService.fetchRealShipments();
      if (!mounted) return;
      final active = shipments.cast<Map<String, dynamic>?>().firstWhere(
        (s) => s != null && (s['status'] == 'in_transit' || s['status'] == 'assigned'),
        orElse: () => null,
      );
      if (active != null) {
        setState(() => _activeShipment = active);
      }
    }
  }

  void _handleLanguageChanged(String newLang) {
    setState(() => _language = newLang);
  }

  void _handleProfileTap() {
    final name = _profile?['full_name'] ?? 'Shipper';
    final email = _profile?['email'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF0F172A), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email.isNotEmpty ? email : 'Verified Shipper Account',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E2E48)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_shipping_rounded, color: Color(0xFF38BDF8)),
                title: Text('My Shipments', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page24MyShipments);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_rounded, color: AppColors.gold),
                title: Text('Review Cargo Bids', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_rounded, color: Color(0xFF34D399)),
                title: Text('Escrow Vault', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Dialing Solomon Tekle (+251 911 482 109)...',
              style: GoogleFonts.inter(fontSize: 12.5),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleChatDriver() {
    DriverChatModal.show(context);
  }

  void _handleShareTrackingLink() {
    ShareTrackingModal.show(
      context,
      waybillNumber: widget.waybillNumber,
      trackingUrl: 'https://track.habeshafreight.et/live/HF-8841-ET',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Branding & Sub-Header Ribbon
              LiveTrackingHeader(
                language: _language,
                onLanguageChanged: _handleLanguageChanged,
                onProfileTap: _handleProfileTap,
                waybillNumber: widget.waybillNumber,
              ),
              const SizedBox(height: 14),

              // 2. Main Corridor Radar Map Card
              CorridorRadarMapCard(
                enableAnimation: widget.enableAnimation,
                speedText: '68 km/h',
                isGpsActive: true,
                originCity: 'Addis Ababa',
                departureTime: 'Departed 04:30',
                destinationCorridor: 'Awash Corridor',
                destinationStatus: 'Next Port Drop',
                driverStatus: 'Driver (Cruising)',
                coordinates: 'LAT: 9.02, LNG: 39.80',
                routeWaypoints: 'Addis Ababa ➔ Modjo ➔ Awash',
                onMapTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CAN-bus GPS telemetry ping: Lat 9.02, Lng 39.80 (Awash Corridor A1)'),
                      backgroundColor: Color(0xFF0F172A),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 3. Telemetry Metrics Row: SPEED (68 km/h), REMAINING (140 km), EST. ARRIVAL (2h 30m)
              const TelemetryMetricsRow(
                speed: '68 km/h',
                speedStatus: 'Cruising',
                remainingKm: '140 km',
                remainingDestination: 'to Awash',
                estArrival: '2h 30m',
                arrivalStatus: 'On Schedule',
              ),
              const SizedBox(height: 12),

              // 4. Sensor Integrity Row: COLD CHAIN (-5°C) & E-SEAL INTEGRITY (SECURE, #SEAL-4401)
              SensorIntegrityRow(
                temperature: '-5°C',
                isColdChainOptimal: true,
                sealStatus: 'SECURE',
                sealId: '#SEAL-4401',
                onColdChainTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reefer Cold Chain Sensor: -5°C (Perishable dairy & vaccines optimal)'),
                      backgroundColor: Color(0xFF0284C7),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onSealTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Digital E-Seal #SEAL-4401: Tamper-proof RFID lock active'),
                      backgroundColor: Color(0xFF059669),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 5. Driver Contact Card: Solomon Tekle, Sinotruk HOWO 30T, Call & Chat buttons
              DriverContactCard(
                driverName: 'Solomon Tekle',
                truckModel: 'Sinotruk HOWO 30T',
                plateNumber: 'Plate 3-824901',
                rating: 4.92,
                phoneNumber: '+251 911 482 109',
                onCallTap: _handleCallDriver,
                onChatTap: _handleChatDriver,
              ),
              const SizedBox(height: 16),

              // 6. Share Live Tracking Link Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleShareTrackingLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 4,
                    shadowColor: AppColors.gold.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.share_location_rounded, size: 20),
                  label: Text(
                    'Share Live Tracking Link',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 4, // Tracking tab active!
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page08MyShipments);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page07PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page09ReviewBids);
          }
        },
      ),
    );
  }
}

/// Semantic aliases for Page 10
typedef Page10Screen = LiveTelemetryTrackingScreen;
typedef Page10 = LiveTelemetryTrackingScreen;

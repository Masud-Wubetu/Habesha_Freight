import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipper_hub/shipper_hub_header.dart';
import '../../widgets/shipper_hub/shipper_profile_card.dart';
import '../../widgets/shipper_hub/operations_metrics_grid.dart';
import '../../widgets/shipper_hub/live_transit_card.dart';

class ShipperActiveHubScreen extends StatefulWidget {
  const ShipperActiveHubScreen({super.key});

  @override
  State<ShipperActiveHubScreen> createState() => _ShipperActiveHubScreenState();
}

class _ShipperActiveHubScreenState extends State<ShipperActiveHubScreen> {
  final CorridorService _corridorService = CorridorService();
  String _selectedLanguage = 'EN';

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _handleProfileTap() {
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
                        'Selamawit Tadesse',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Bole Dry Port Logistics • Enterprise',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_rounded, color: AppColors.gold),
                title: Text('Escrow Vaults (Page 05)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Corridor Modules Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  CorridorNavigationSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications: 3 new carrier updates on Addis-Djibouti Corridor.'),
        backgroundColor: AppColors.gold,
      ),
    );
  }

  void _showDriverContactModal() {
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_pin_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dawit Kebede',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Verified Line-Haul Driver · Volvo FH16',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Column(
                  children: [
                    _infoRow('Plate Number', 'ET 3-48192 (Ethiopian Freight)'),
                    const SizedBox(height: 8),
                    _infoRow('Direct Mobile', '+251 91 148 2910'),
                    const SizedBox(height: 8),
                    _infoRow('Current Gate Target', 'Modjo Dry Port Customs Bay 04'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dialing +251 91 148 2910 (Driver Dawit Kebede)...'),
                        backgroundColor: AppColors.gold,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: Text('Call Driver Now', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLiveTelemetryModal() {
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
                  const Icon(Icons.sensors_rounded, color: Color(0xFF34D399), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Corridor Telematics · #HF-8841',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Live GPS, CAN-bus speed and corridor checkpoints.',
                style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Column(
                  children: [
                    _infoRow('GPS Coordinates', '8.6012° N, 39.1245° E (Awash A1)'),
                    const SizedBox(height: 8),
                    _infoRow('Real-Time Speed', '72.4 km/h (Optimal Fuel Curve)'),
                    const SizedBox(height: 8),
                    _infoRow('Fuel Tank Status', '78% (320 Liters Remaining)'),
                    const SizedBox(height: 8),
                    _infoRow('Weighbridge Compliance', 'Axle 1: 7.8t · Axle 2: 11.2t (Passed)'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWaybillModal() {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, color: Color(0xFF38BDF8), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Electronic Waybill #WB-8841',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0C4A6E), borderRadius: BorderRadius.circular(4)),
                    child: Text('ASYCUDA VALID', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF7DD3FC))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Column(
                  children: [
                    _infoRow('Cargo Description', '28 Tons Construction Reinforcement Steel'),
                    const SizedBox(height: 8),
                    _infoRow('Origin Depot', 'Kality Logistics Terminal Gate 2'),
                    const SizedBox(height: 8),
                    _infoRow('Destination Bay', 'Modjo Dry Port Customs Bay 04'),
                    const SizedBox(height: 8),
                    _infoRow('Customs Seal #', 'ET-CUSTOMS-99214-GREEN'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
        Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  void _openPostLoadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostLoadSheet(
        corridorService: _corridorService,
        onPosted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cargo Request broadcasted across Addis-Djibouti Corridor!'),
              backgroundColor: AppColors.gold,
            ),
          );
        },
      ),
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
              ShipperHubHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
              ),
              const SizedBox(height: 14),

              // Shipper Enterprise Profile Card & Post Cargo CTA Button
              ShipperProfileCard(
                name: 'Selamawit Tadesse',
                company: 'Bole Dry Port Logistics • Enterprise',
                activeCorridor: 'Addis-Djibouti Corridor Active',
                onNotificationTap: _handleNotificationTap,
                onPostCargoTap: _openPostLoadSheet,
              ),
              const SizedBox(height: 14),

              // 2x2 Operations Metrics Grid Cards
              OperationsMetricsGrid(
                activeLoadsCount: 3,
                pendingBidsCount: 8,
                completedCount: 42,
                inEscrowFormatted: '145k',
                onActiveLoadsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viewing 3 active line-haul shipments on A1 corridor.'),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                },
                onPendingBidsTap: () => Navigator.pushNamed(context, AppRoutes.page20SubmitBid),
                onCompletedTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('42 corridor runs successfully completed and settled.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                onInEscrowTap: () => Navigator.pushNamed(context, AppRoutes.page05EscrowVault),
              ),
              const SizedBox(height: 16),

              // Live Transit Priority Shipment Card
              LiveTransitCard(
                shipmentId: 'SHIPMENT #HF-8841',
                transitTag: 'Export Transit',
                origin: 'Addis Ababa',
                originHub: 'Kality Hub',
                destination: 'Modjo Dry Port',
                destinationBay: 'Customs Bay 04',
                speedText: 'Cruising 72 km/h',
                etaText: 'ETA: 48 min',
                progressPercent: 0.65,
                departedTime: 'Departed 08:30',
                corridorName: 'A1 Express Corridor',
                targetTime: 'Target 11:45',
                driverName: 'Dawit Kebede',
                truckModel: 'Volvo FH16 (ET 3-48192)',
                onViewAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Displaying full active line-haul corridor manifest.'),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                },
                onDriverCallTap: _showDriverContactModal,
                onLiveTelemetryTap: _showLiveTelemetryModal,
                onWaybillTap: _showWaybillModal,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 0, // Home / Operations
        onTap: (idx) {
          if (idx == 2) {
            _openPostLoadSheet();
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
          } else if (idx != 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }
}

// Aliases for page 06 semantic naming
typedef Page06Screen = ShipperActiveHubScreen;
typedef Page6Screen = ShipperActiveHubScreen;

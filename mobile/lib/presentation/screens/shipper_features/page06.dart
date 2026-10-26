import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/services/shipper_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/shipper_hub/live_transit_card.dart';
import '../../widgets/shipper_hub/operations_metrics_grid.dart';
import '../../widgets/shipper_hub/shipper_hub_header.dart';
import '../../widgets/shipper_hub/shipper_profile_card.dart';

class ShipperActiveHubScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;
  final List<Map<String, dynamic>>? initialShipments;

  const ShipperActiveHubScreen({
    super.key,
    this.initialProfile,
    this.initialShipments,
  });

  @override
  State<ShipperActiveHubScreen> createState() => _ShipperActiveHubScreenState();
}

class _ShipperActiveHubScreenState extends State<ShipperActiveHubScreen> {
  final ShipperService _shipperService = ShipperService();
  final CorridorService _corridorService = CorridorService();

  String _selectedLanguage = 'EN';
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _shipments = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null || widget.initialShipments != null) {
      _profile = widget.initialProfile;
      _shipments = widget.initialShipments ?? [];
      _isLoading = false;
    } else {
      _loadHubData();
    }
  }

  Future<void> _loadHubData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _shipperService.getProfile(),
      _corridorService.fetchRealShipments(),
    ]);

    if (!mounted) return;
    setState(() {
      _profile = results[0] as Map<String, dynamic>?;
      _shipments = (results[1] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      _isLoading = false;
    });
  }

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _handleProfileTap() {
    final name = _profile?['full_name'] ?? 'Shipper';
    final email = _profile?['email'] ?? '';
    final phone = _profile?['phone_number'] ?? '';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          phone.isNotEmpty ? phone : (email.isNotEmpty ? email : 'Verified Shipper Account'),
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E2E48)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.business_rounded, color: Color(0xFF38BDF8)),
                title: Text('Company Profile', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page14CompanyProfile);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_rounded, color: AppColors.gold),
                title: Text('Escrow Vault', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF34D399)),
                title: Text('My Shipments', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page24MyShipments);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded, color: Color(0xFFA78BFA)),
                title: Text('Freight History', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page11FreightHistory);
                },
              ),
              const Divider(color: Color(0xFF1E2E48)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                title: Text('Sign Out', style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.clearAuthData();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
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
        content: Text('No new corridor notifications.'),
        backgroundColor: Color(0xFF1E2E48),
      ),
    );
  }

  void _showDriverContactModal(Map<String, dynamic> shipment) {
    final driverName = shipment['driver_name'] ?? 'Assigned Carrier';
    final driverPhone = shipment['driver_phone'] ?? shipment['contact_phone'] ?? 'N/A';
    final truckPlate = shipment['license_plate'] ?? shipment['truck_plate'] ?? 'Line-Haul Rig';

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
                        driverName,
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Verified Line-Haul Driver · $truckPlate',
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
                    _infoRow('Carrier Plate', truckPlate),
                    const SizedBox(height: 8),
                    _infoRow('Direct Mobile', driverPhone),
                    const SizedBox(height: 8),
                    _infoRow('Status', (shipment['status'] ?? 'Active').toString().toUpperCase()),
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
                      SnackBar(
                        content: Text('Dialing $driverPhone ($driverName)...'),
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

  void _showWaybillModal(Map<String, dynamic> shipment) {
    final shipmentId = shipment['id']?.toString() ?? 'HF-LOAD';
    final desc = shipment['cargo_description'] ?? 'Container Freight';
    final origin = shipment['origin_city'] ?? 'Addis Ababa';
    final dest = shipment['destination_city'] ?? 'Dire Dawa';

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
                        'Electronic Waybill #$shipmentId',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0C4A6E), borderRadius: BorderRadius.circular(4)),
                    child: Text('VERIFIED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF7DD3FC))),
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
                    _infoRow('Cargo', desc),
                    const SizedBox(height: 8),
                    _infoRow('Origin', origin),
                    const SizedBox(height: 8),
                    _infoRow('Destination', dest),
                    const SizedBox(height: 8),
                    _infoRow('Status', (shipment['status'] ?? 'Active').toString().toUpperCase()),
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

  String _formatAmount(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['full_name'] ?? 'Shipper';
    final company = _profile?['company_name'] ?? 'Logistics Shipper';
    final stats = _profile?['stats'] as Map<String, dynamic>? ?? {};

    final activeLoadsCount = stats['active_loads'] is num
        ? (stats['active_loads'] as num).toInt()
        : _shipments.where((s) => s['status'] == 'in_transit' || s['status'] == 'assigned').length;

    final completedCount = stats['completed_loads'] is num
        ? (stats['completed_loads'] as num).toInt()
        : _shipments.where((s) => s['status'] == 'delivered' || s['status'] == 'completed').length;

    final pendingBidsCount = stats['pending_bids'] is num
        ? (stats['pending_bids'] as num).toInt()
        : 0;

    final escrowVal = stats['in_escrow_etb'] is num
        ? (stats['in_escrow_etb'] as num).toDouble()
        : 0.0;
    final inEscrowFormatted = escrowVal > 0 ? '${_formatAmount(escrowVal)} ETB' : '0 ETB';

    // Find real active shipment
    final activeShipment = _shipments.cast<Map<String, dynamic>?>().firstWhere(
      (s) => s != null && (s['status'] == 'in_transit' || s['status'] == 'assigned' || s['status'] == 'active'),
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: const Color(0xFF0F172A),
          onRefresh: _loadHubData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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

                // Shipper Profile Card
                ShipperProfileCard(
                  name: name,
                  company: company,
                  activeCorridor: activeLoadsCount > 0
                      ? '$activeLoadsCount Active Corridor Consignment${activeLoadsCount > 1 ? 's' : ''}'
                      : 'Ethio-Djibouti Corridor Active',
                  onNotificationTap: _handleNotificationTap,
                  onPostCargoTap: () => Navigator.pushNamed(context, AppRoutes.page23PostCargo),
                ),
                const SizedBox(height: 14),

                // Operations Metrics Grid Cards
                OperationsMetricsGrid(
                  activeLoadsCount: activeLoadsCount,
                  pendingBidsCount: pendingBidsCount,
                  completedCount: completedCount,
                  inEscrowFormatted: inEscrowFormatted,
                  onActiveLoadsTap: () => Navigator.pushNamed(context, AppRoutes.page24MyShipments),
                  onPendingBidsTap: () => Navigator.pushNamed(context, AppRoutes.page08ReviewBids),
                  onCompletedTap: () => Navigator.pushNamed(context, AppRoutes.page24MyShipments),
                  onInEscrowTap: () => Navigator.pushNamed(context, AppRoutes.page05EscrowVault),
                ),
                const SizedBox(height: 16),

                // Priority Consignment or Empty State
                if (_isLoading) ...[
                  Container(
                    height: 160,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: AppColors.gold),
                  ),
                ] else if (activeShipment != null) ...[
                  LiveTransitCard(
                    shipmentId: 'SHIPMENT #${activeShipment['id'] ?? 'HF'}',
                    transitTag: (activeShipment['status'] ?? 'Active').toString().toUpperCase(),
                    origin: activeShipment['origin_city'] ?? 'Addis Ababa',
                    originHub: 'Origin Terminal',
                    destination: activeShipment['destination_city'] ?? 'Dire Dawa',
                    destinationBay: 'Destination Gate',
                    speedText: activeShipment['status'] == 'in_transit' ? 'In Transit' : 'Dispatched',
                    etaText: 'Active',
                    progressPercent: activeShipment['status'] == 'in_transit' ? 0.65 : 0.35,
                    departedTime: 'Registered',
                    corridorName: 'Expressway A1 Corridor',
                    targetTime: 'On Route',
                    driverName: activeShipment['driver_name'] ?? 'Assigned Carrier Driver',
                    truckModel: activeShipment['license_plate'] ?? 'Heavy Freight Rig',
                    onViewAllTap: () => Navigator.pushNamed(context, AppRoutes.page24MyShipments),
                    onDriverCallTap: () => _showDriverContactModal(activeShipment),
                    onWaybillTap: () => _showWaybillModal(activeShipment),
                  ),
                ] else ...[
                  // Clean Empty State
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1628),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E2E48)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_shipping_outlined,
                            color: AppColors.gold,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Active Consignments',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You have no shipments currently moving. Post a new request to connect with verified corridor carriers.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.page23PostCargo),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(
                            'Post Cargo Request',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page24MyShipments);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page23PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
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

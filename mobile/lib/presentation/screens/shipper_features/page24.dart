import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/shipments/corridor_telemetry_radar_card.dart';
import '../../widgets/shipments/shipments_header.dart';
import '../../widgets/shipments/shipments_search_and_filter_bar.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  String _selectedLanguage = 'EN';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterTab = 0; // 0: All, 1: Active, 2: Bidding, 3: Delivered
  String _selectedCorridor = 'All Corridors';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _handleFilterSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Corridor & Telemetry Filters',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ACTIVE FREIGHT CORRIDORS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All Corridors',
                  'Expressway A1',
                  'Awash Route',
                  'Hawassa A7',
                  'Northern Line',
                ].map((corridor) {
                  final isSelected = _selectedCorridor == corridor;
                  return ChoiceChip(
                    label: Text(corridor),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCorridor = corridor);
                      Navigator.pop(ctx);
                    },
                    selectedColor: AppColors.gold,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLiveRadarModal() {
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
                      const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Live Corridor Telemetry Radar',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  children: [
                    _radarStatRow('Active Corridors Monitored', 'Expressway A1 · Hawassa A7'),
                    const Divider(color: Color(0xFF1E293B), height: 16),
                    _radarStatRow('Active Rigs with Live GPS', '12 Carriers (100% Lock)'),
                    const Divider(color: Color(0xFF1E293B), height: 16),
                    _radarStatRow('Average Gate Clearance', '3.8 min at Modjo Smart Bay'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                  },
                  icon: const Icon(Icons.dashboard_rounded, color: Color(0xFF0F172A), size: 18),
                  label: Text('Open Full Operations Radar (Page 06)', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radarStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
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
                        'Shipper Logistics Console',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ethio-Djibouti Real-time Fleet Telemetry',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                title: Text('Active Hub & Operations (Page 06)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.post_add_rounded, color: AppColors.gold),
                title: Text('Post Cargo Request Wizard (Page 23 / 07)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page23PostCargo);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Explore All 16 Corridor Modules', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
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
              ShipmentsHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
                liveEnRouteCount: 3,
              ),
              const SizedBox(height: 16),
              ShipmentsSearchAndFilterBar(
                searchController: _searchController,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                onFilterSettingsTap: _handleFilterSettings,
                selectedTabIndex: _selectedFilterTab,
                onTabSelected: (idx) => setState(() => _selectedFilterTab = idx),
                allCount: 12,
                activeCount: 3,
                biddingCount: 5,
                deliveredCount: 4,
              ),
              const SizedBox(height: 16),
              CorridorTelemetryRadarCard(
                onTap: _showLiveRadarModal,
                originHub: 'Addis Ababa Hub (A)',
                destinationHub: 'Dire Dawa (B)',
                departureTime: '05:30 AM',
                arrivalTime: '02:45 PM',
                remainingKm: 112,
                currentLat: '9.020',
                currentLng: '39.800',
                progress: 0.65,
              ),
              const SizedBox(height: 16),

              // Placeholder for Search & Filter Bar, Radar Card, and Shipments List (Micro-tasks 2-5)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Active Fleet Telemetry & Shipments loading...'
                            : 'Filtering shipments by: "$_searchQuery"...',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 1, // Shipments tab active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page23PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page20SubmitBid);
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
          }
        },
      ),
    );
  }
}

// Aliases for page 24 semantic naming
typedef Page24Screen = MyShipmentsScreen;

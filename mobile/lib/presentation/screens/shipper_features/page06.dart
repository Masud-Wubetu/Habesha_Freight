import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipper_hub/shipper_hub_header.dart';

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

              // Placeholder slot for Profile Card, Post CTA, 2x2 Grid, and Live Transit (populated in micro-tasks 2-5)
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
                    const Icon(Icons.dashboard_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Shipper Active Operations Hub initializing...',
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

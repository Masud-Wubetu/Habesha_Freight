import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipper_escrow/shipper_escrow_header.dart';
import '../../widgets/shipper_escrow/active_escrow_hero_card.dart';

class ShipperEscrowVaultScreen extends StatefulWidget {
  const ShipperEscrowVaultScreen({super.key});

  @override
  State<ShipperEscrowVaultScreen> createState() => _ShipperEscrowVaultScreenState();
}

class _ShipperEscrowVaultScreenState extends State<ShipperEscrowVaultScreen> {
  final CorridorService _corridorService = CorridorService();
  String _selectedLanguage = 'EN';
  int _activeTabIndex = 0; // 0: Active Escrow, 1: Invoices, 2: Disputes

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _onTabSelected(int idx) {
    setState(() {
      _activeTabIndex = idx;
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
                        'Shipper Enterprise Account',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'TIN: 0092837102 · Verified Tier 1',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
                title: Text('Telebirr Merchant Vault: 894,200 ETB Available', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
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

  void _handleManageVaults() {
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
              Text(
                'Settlement Vault Configurations',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Instant payout channels authorized under National Bank of Ethiopia directive.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Telebirr Merchant: Active · Auto-Release Ready', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Daily Escrow Limit: 2,500,000 ETB', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CBE Birr Transit: Active · Interbank Settlement', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Daily Escrow Limit: 5,000,000 ETB', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
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
              content: Text('Load Posted Successfully! Escrow reserved in vault.'),
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
              ShipperEscrowHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
              ),
              const SizedBox(height: 16),

              // Active Escrow Locked Hero Card
              ActiveEscrowHeroCard(
                activeLockedAmount: 150000.0,
                releasedThisMonth: 890000.0,
                activeConsignmentsCount: 2,
                onManageVaults: _handleManageVaults,
              ),
              const SizedBox(height: 16),

              // Placeholder slot for Hero Card, Tabs, Consignment list, and Batch Fund Banner (populated in micro-tasks 2-5)
              InkWell(
                onTap: () => _onTabSelected((_activeTabIndex + 1) % 3),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.gold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Escrow Vault Engine initializing... Tab: $_activeTabIndex',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 3, // Bids / Escrow active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 2) {
            _openPostLoadSheet();
          } else if (idx != 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }
}

// Aliases for page 21/22 semantic naming
typedef Page21Screen = ShipperEscrowVaultScreen;
typedef Page22Screen = ShipperEscrowVaultScreen;

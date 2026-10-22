import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_bid_item.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/review_bids/review_bids_header.dart';

class ReviewBidsScreen extends StatefulWidget {
  final String initialLanguage;

  const ReviewBidsScreen({
    super.key,
    this.initialLanguage = 'EN',
  });

  @override
  State<ReviewBidsScreen> createState() => _ReviewBidsScreenState();
}

class _ReviewBidsScreenState extends State<ReviewBidsScreen> {
  late String _language;
  late List<CorridorBidItem> _bids;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _bids = CorridorBidItem.mockBids();
  }

  void _handleLanguageTap(String newLang) {
    setState(() => _language = newLang);
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
                leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                title: Text('Shipper Active Hub (Page 06)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
              ),
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
              ReviewBidsHeader(
                language: _language,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
                activeBidsCount: _bids.length,
              ),
              const SizedBox(height: 16),

              // Placeholder for Tender Summary Card and Bid Cards (Micro-tasks 2, 3, 4)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Center(
                  child: Text(
                    'Corridor Tender & Active Bids Loading...',
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 3, // Bids Tab active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page08MyShipments);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page07PostCargo);
          } else if (idx == 4) {
            Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
          }
        },
      ),
    );
  }
}

// Aliases for page 08 semantic naming
typedef Page08Screen = ReviewBidsScreen;
typedef Page8Screen = ReviewBidsScreen;

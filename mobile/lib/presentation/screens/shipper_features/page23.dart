import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_cargo/post_cargo_step_header.dart';

class PostCargoRequestScreen extends StatefulWidget {
  const PostCargoRequestScreen({super.key});

  @override
  State<PostCargoRequestScreen> createState() => _PostCargoRequestScreenState();
}

class _PostCargoRequestScreenState extends State<PostCargoRequestScreen> {
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
                        'Shipper Cargo Posting',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'National Logistics Dispatch Wizard',
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
              PostCargoStepHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
                currentStep: 1,
                totalSteps: 2,
                stepTitle: 'CARGO & ROUTE',
                progress: 0.5,
              ),
              const SizedBox(height: 16),

              // Placeholder for classification, waypoints, weight, dispatch mode, CTA (populated in micro-tasks 2-5)
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
                    const Icon(Icons.post_add_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cargo & Route Dispatch Wizard initializing...',
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
        currentIndex: 2, // Center Post Load button active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
          } else if (idx != 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }
}

// Aliases for page 07 / 23 semantic naming
typedef Page23Screen = PostCargoRequestScreen;
typedef Page07Screen = PostCargoRequestScreen;
typedef Page7Screen = PostCargoRequestScreen;

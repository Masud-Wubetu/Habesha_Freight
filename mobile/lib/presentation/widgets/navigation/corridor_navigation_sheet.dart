import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class CorridorNavigationSheet extends StatelessWidget {
  const CorridorNavigationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CorridorNavigationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HABESHA FREIGHT CORRIDOR HUB',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All Modules & Corridors',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.cardBorder, height: 1),

          // Catalog List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // SECTION 1: SHIPPER & BIDDING
                _sectionHeader(
                  title: 'SHIPPER & REGISTRATION PORTALS',
                  subtitle: 'Cargo booking, live manifest, and bidding',
                  color: AppColors.gold,
                  icon: Icons.local_shipping_outlined,
                ),
                _navTile(
                  context,
                  title: 'Shipper Home Dashboard',
                  subtitle: 'Live transit, corridor rate estimator & loads',
                  badge: 'Page 01–02',
                  icon: Icons.dashboard_customize_outlined,
                  route: AppRoutes.home,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Freight History',
                  subtitle: 'Completed deliveries & e-POD receipts',
                  badge: 'Page 11',
                  icon: Icons.history,
                  route: AppRoutes.page11FreightHistory,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Preferred Fleet Directory',
                  subtitle: 'Vetted carriers & direct dispatch',
                  badge: 'Page 12',
                  icon: Icons.groups_outlined,
                  route: AppRoutes.page12PreferredFleet,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Escrow & Invoices',
                  subtitle: 'Vault balance, releases & tax invoices',
                  badge: 'Page 13',
                  icon: Icons.lock_clock,
                  route: AppRoutes.page13EscrowInvoices,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Rate Driver',
                  subtitle: 'Rate your driver and share feedback',
                  badge: 'Page 15',
                  icon: Icons.star_rate,
                  route: AppRoutes.page15RateDriver,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Company Profile',
                  subtitle: 'TIN, gateways & dispatch staff',
                  badge: 'Page 14',
                  icon: Icons.domain,
                  route: AppRoutes.page14CompanyProfile,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Multi-Role Registration',
                  subtitle: 'Choose role: Shipper, Driver, or Fleet Enterprise',
                  badge: 'Page 03',
                  icon: Icons.app_registration_rounded,
                  route: AppRoutes.register,
                  color: const Color(0xFF38BDF8),
                ),
                _navTile(
                  context,
                  title: 'Verify 6-Digit OTP Code',
                  subtitle:
                      'Secure transit code authorization with Ethio Telecom',
                  badge: 'Page 04',
                  icon: Icons.password_rounded,
                  route: AppRoutes.page04VerifyOtp,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Shipper Escrow & Settlement Vaults',
                  subtitle: 'NBE & Telebirr locked funds, POD release, batch funding',
                  badge: 'Page 05',
                  icon: Icons.shield_rounded,
                  route: AppRoutes.page05EscrowVault,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Shipper Active Hub & Operations',
                  subtitle: 'Live transit radar, 2x2 corridor telemetry & driver tracking',
                  badge: 'Page 06',
                  icon: Icons.dashboard_rounded,
                  route: AppRoutes.page06ShipperHub,
                  color: const Color(0xFF38BDF8),
                ),
                _navTile(
                  context,
                  title: 'Post Cargo Request (Step 1)',
                  subtitle: 'Waypoints routing, weight stepper, transit seal & dispatch',
                  badge: 'Page 07 / 23',
                  icon: Icons.post_add_rounded,
                  route: AppRoutes.page07PostCargo,
                  color: AppColors.gold,
                ),
                _navTile(
                  context,
                  title: 'Submit Freight Bid Screen',
                  subtitle:
                      'Dynamic corridor bidding, gate slots, and tariff rates',
                  badge: 'Page 20',
                  icon: Icons.gavel_rounded,
                  route: AppRoutes.page20SubmitBid,
                  color: AppColors.badgeGreenText,
                ),
                _navTile(
                  context,
                  title: 'Carrier & Shipper Sign In',
                  subtitle: 'SMS OTP verification, Telebirr & passwords',
                  badge: 'Auth',
                  icon: Icons.login_rounded,
                  route: AppRoutes.login,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),

                // SECTION 2: FLEET ENTERPRISE (PAGES 27–34)
                _sectionHeader(
                  title: 'FLEET ENTERPRISE MODULES',
                  subtitle:
                      'Pages 27–34 · Line-haul telematics & fleet command',
                  color: const Color(0xFF4EDEA3),
                  icon: Icons.business_center_outlined,
                ),
                _navTile(
                  context,
                  title: 'Fleet Operations Command Hub',
                  subtitle: 'Real-time radar, enterprise KPIs & dispatches',
                  badge: 'Page 27',
                  icon: Icons.dashboard,
                  route: AppRoutes.page27FleetCommand,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Rig Telemetry & CAN-bus',
                  subtitle: 'Live GPS, speed, fuel CAN-bus & immobilizer',
                  badge: 'Page 28',
                  icon: Icons.sensors,
                  route: AppRoutes.page28RigTelemetry,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Driver Roster & Licensing',
                  subtitle: 'Verified Ethiopian truck drivers & performance',
                  badge: 'Page 29',
                  icon: Icons.groups,
                  route: AppRoutes.page29DriverRoster,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Dispatch Matrix & Rig Match',
                  subtitle: 'Assign empty trucks to high-priority manifests',
                  badge: 'Page 30',
                  icon: Icons.route,
                  route: AppRoutes.page30DispatchMatrix,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Escrow Batch Settlements',
                  subtitle: 'CBE & Telebirr released payout ledger',
                  badge: 'Page 31',
                  icon: Icons.account_balance_wallet,
                  route: AppRoutes.page31EscrowBatch,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Fuel & Toll Pass Vouchers',
                  subtitle: 'QR vouchers & RFID corridor gate passes',
                  badge: 'Page 32',
                  icon: Icons.local_gas_station,
                  route: AppRoutes.page32FuelToll,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Workshop Maintenance Orders',
                  subtitle: 'Preventive service & overhaul schedule',
                  badge: 'Page 33',
                  icon: Icons.build_circle_outlined,
                  route: AppRoutes.page33Maintenance,
                  color: const Color(0xFF4EDEA3),
                ),
                _navTile(
                  context,
                  title: 'Corridor Analytics & Dwell Time',
                  subtitle: 'Revenue metrics, gate delays & turn-around',
                  badge: 'Page 34',
                  icon: Icons.insights,
                  route: AppRoutes.page34Analytics,
                  color: const Color(0xFF4EDEA3),
                ),

                const SizedBox(height: 16),

                // SECTION 3: CUSTOMS & INTERMODAL (PAGES 35–40)
                _sectionHeader(
                  title: 'CUSTOMS, CROSS-BORDER & INTERMODAL',
                  subtitle: 'Pages 35–40 · Trade gates & checkpoint telemetry',
                  color: const Color(0xFF9FD1FF),
                  icon: Icons.hub_outlined,
                ),
                _navTile(
                  context,
                  title: 'Customs ASYCUDA Manifest',
                  subtitle: 'Digital customs declaration & e-seal status',
                  badge: 'Page 35',
                  icon: Icons.description_outlined,
                  route: AppRoutes.page35Customs,
                  color: const Color(0xFF9FD1FF),
                ),
                _navTile(
                  context,
                  title: 'Cross-Border Pass QR Code',
                  subtitle: 'Galafi / Dewele gate clearance pass',
                  badge: 'Page 36',
                  icon: Icons.qr_code_2,
                  route: AppRoutes.page36BorderPass,
                  color: const Color(0xFF9FD1FF),
                ),
                _navTile(
                  context,
                  title: 'Axle Load Weighbridge Telemetry',
                  subtitle: 'Kaliti & Mojo weight scale slip & compliance',
                  badge: 'Page 37',
                  icon: Icons.scale,
                  route: AppRoutes.page37Weighbridge,
                  color: const Color(0xFF9FD1FF),
                ),
                _navTile(
                  context,
                  title: 'Regulatory & COMESA Compliance',
                  subtitle: 'Yellow card transit insurance & audits',
                  badge: 'Page 38',
                  icon: Icons.policy_outlined,
                  route: AppRoutes.page38Compliance,
                  color: const Color(0xFF9FD1FF),
                ),
                _navTile(
                  context,
                  title: 'Reefer Cold Chain IoT Telemetry',
                  subtitle: 'Perishable cargo temperature & humidity',
                  badge: 'Page 39',
                  icon: Icons.ac_unit,
                  route: AppRoutes.page39ColdChain,
                  color: const Color(0xFF9FD1FF),
                ),
                _navTile(
                  context,
                  title: 'Mojo Dry Port Intermodal Rail Hub',
                  subtitle: 'Ethiopia-Djibouti standard gauge railway sync',
                  badge: 'Page 40',
                  icon: Icons.train,
                  route: AppRoutes.page40Intermodal,
                  color: const Color(0xFF9FD1FF),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

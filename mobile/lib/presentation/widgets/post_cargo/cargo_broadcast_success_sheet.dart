import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class CargoBroadcastSuccessSheet extends StatelessWidget {
  final String origin;
  final String destination;
  final String cargoLabel;
  final int weightTons;
  final String dispatchModeTitle;
  final bool isGpsMonitored;
  final int distanceKm;

  const CargoBroadcastSuccessSheet({
    super.key,
    required this.origin,
    required this.destination,
    required this.cargoLabel,
    required this.weightTons,
    required this.dispatchModeTitle,
    required this.isGpsMonitored,
    required this.distanceKm,
  });

  static Future<void> show(
    BuildContext context, {
    required String origin,
    required String destination,
    required String cargoLabel,
    required int weightTons,
    required String dispatchModeTitle,
    required bool isGpsMonitored,
    required int distanceKm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CargoBroadcastSuccessSheet(
        origin: origin,
        destination: destination,
        cargoLabel: cargoLabel,
        weightTons: weightTons,
        dispatchModeTitle: dispatchModeTitle,
        isGpsMonitored: isGpsMonitored,
        distanceKm: distanceKm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Success badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Cargo Request Broadcasted!',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Live corridor dispatch active on Expressway A1',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),

            // Summary Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF070D18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.alt_route_rounded,
                    label: 'Corridor Route',
                    value: '$origin ➔ $destination ($distanceKm km)',
                    iconColor: AppColors.gold,
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 18),
                  _infoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Cargo & Load',
                    value: '$cargoLabel • $weightTons Metric Tons',
                    iconColor: const Color(0xFF38BDF8),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 18),
                  _infoRow(
                    icon: Icons.gavel_rounded,
                    label: 'Dispatch Mode',
                    value: dispatchModeTitle,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 18),
                  _infoRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Security & IoT',
                    value: isGpsMonitored
                        ? 'GPS Monitored Live E-Seal'
                        : 'Standard Corridor Manifest',
                    iconColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notification note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF052E16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF166534)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, color: Color(0xFF4ADE80), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '~42 verified drivers alerted. Incoming bids will appear in your Active Hub.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF86EFAC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
                icon: const Icon(Icons.dashboard_rounded, color: Color(0xFF0F172A), size: 18),
                label: Text(
                  'Go to Active Hub & Ops (Page 06)',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.page05EscrowVault);
                },
                icon: const Icon(Icons.shield_rounded, color: AppColors.gold, size: 18),
                label: Text(
                  'View Escrow Settlement Vaults (Page 05)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E293B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

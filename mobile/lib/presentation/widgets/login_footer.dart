import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Understood',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.person_add_rounded, color: AppColors.gold, size: 22),
            const SizedBox(width: 10),
            Text(
              'Create Carrier Account',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your enterprise role to begin registration with the Ethiopian Transport Authority:',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildRoleOption(
              icon: Icons.local_shipping_rounded,
              title: 'Heavy Truck Driver',
              subtitle: 'Dry port corridor & cross-border freight',
              onTap: () {
                Navigator.pop(ctx);
                _showInfoDialog(
                  context,
                  title: 'Driver Onboarding',
                  icon: Icons.local_shipping_rounded,
                  content:
                      'Driver registration requires Grade 4 or Grade 5 Ethiopian driving license, cross-border permit, and vehicle GPS telemetry unit registration.',
                );
              },
            ),
            const SizedBox(height: 10),
            _buildRoleOption(
              icon: Icons.business_rounded,
              title: 'Fleet Carrier / Operator',
              subtitle: 'Multi-truck dispatch & cargo telemetry management',
              onTap: () {
                Navigator.pop(ctx);
                _showInfoDialog(
                  context,
                  title: 'Carrier Onboarding',
                  icon: Icons.business_rounded,
                  content:
                      'Carrier registration requires Ethiopian Commercial Registration Certificate, TIN number, and fleet size verification (minimum 3 heavy commercial trucks).',
                );
              },
            ),
            const SizedBox(height: 10),
            _buildRoleOption(
              icon: Icons.inventory_2_rounded,
              title: 'Cargo Shipper / Importer',
              subtitle: 'Container booking & shipment tracking',
              onTap: () {
                Navigator.pop(ctx);
                _showInfoDialog(
                  context,
                  title: 'Shipper Onboarding',
                  icon: Icons.inventory_2_rounded,
                  content:
                      'Shippers can book container loads from Djibouti Doraleh Port, Modjo Dry Port, and regional dry terminals with automatic customs declaration linkage.',
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  static Widget _buildRoleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Registration Prompt
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an enterprise account? ",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () => _showRegistrationDialog(context),
              child: Text(
                'Register Now',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Policy / Corridor / Support Links
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildFooterLink(
              label: 'Carrier Terms',
              onTap: () => _showInfoDialog(
                context,
                title: 'Carrier Terms of Service',
                icon: Icons.gavel_rounded,
                content:
                    'All logistics operations and freight brokerage on Habesha Freight conform to the Ethiopian Transport Authority Proclamation and bilateral transit agreements with the Republic of Djibouti.',
              ),
            ),
            _buildDot(),
            _buildFooterLink(
              label: 'Support Desk',
              onTap: () => _showInfoDialog(
                context,
                title: 'Dispatch Support Center',
                icon: Icons.headset_mic_rounded,
                content:
                    'INSA & Habesha Freight 24/7 Logistics Command:\n\n• Corridor Hotline: +251 11 551 2233\n• Email: dispatch@habeshafreight.et\n• VHF Channel 16 along Djibouti-Addis corridor.',
              ),
            ),
            _buildDot(),
            _buildFooterLink(
              label: 'Port Corridors',
              onTap: () => _showInfoDialog(
                context,
                title: 'Active Freight Corridors',
                icon: Icons.alt_route_rounded,
                content:
                    '1. Djibouti (Doraleh) ⇄ Modjo Dry Port (780 km)\n2. Djibouti ⇄ Galafi Border Post (210 km)\n3. Berbera Port ⇄ Wajaale ⇄ Dire Dawa (450 km)\n4. Modjo ⇄ Addis Ababa Kality Inland Terminal (65 km)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Security / Version badge
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 13,
              color: AppColors.badgeGreenText,
            ),
            const SizedBox(width: 6),
            Text(
              'Habesha Freight v1.0.0 • 256-bit TLS Encrypted Telemetry',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget _buildFooterLink({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static Widget _buildDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.cardBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

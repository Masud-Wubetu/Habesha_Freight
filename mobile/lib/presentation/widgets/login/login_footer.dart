import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LoginFooter extends StatelessWidget {
  final void Function(String title, String content) onShowInfo;

  const LoginFooter({super.key, required this.onShowInfo});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Wrap(alignment: WrapAlignment.center, children: [
        Text("Don't have an account? ", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => onShowInfo('Registration', 'Register as Driver, Fleet Carrier, or Cargo Shipper via ETA regulatory portal.'),
          child: Text('Register Now', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold, decoration: TextDecoration.underline)),
        ),
      ]),
      const SizedBox(height: 16),
      Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
        _link('Carrier Terms', 'Bilateral Djibouti-Ethiopia logistics treaties apply.'),
        _link('Support Desk', 'INSA Corridor Hotline: +251 11 551 2233'),
        _link('Port Corridors', 'Djibouti ⇄ Modjo (780km), Berbera ⇄ Dire Dawa (450km).'),
      ]),
      const SizedBox(height: 12),
      Text('Habesha Freight v1.0.0 • 256-bit TLS Encrypted', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
    ]);
  }

  Widget _link(String t, String c) => GestureDetector(
    onTap: () => onShowInfo(t, c),
    child: Text(t, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
  );
}

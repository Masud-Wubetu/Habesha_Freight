import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TelebirrButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const TelebirrButton({super.key, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const Expanded(child: Divider(color: AppColors.cardBorder)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OR CONTINUE WITH', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
        const Expanded(child: Divider(color: AppColors.cardBorder)),
      ]),
      const SizedBox(height: 12),
      InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: AppColors.telebirrButton, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.telebirrBorder)),
          child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.telebirrBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.bolt_rounded, color: AppColors.telebirrBlue, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Quick Auth with Telebirr', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('Instant SuperApp verification', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ]),
        ),
      ),
    ]);
  }
}

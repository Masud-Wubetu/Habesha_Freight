import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../navigation/corridor_navigation_sheet.dart';

class HomeHeader extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
          child: const Icon(Icons.local_shipping_outlined, color: AppColors.gold, size: 20),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700), children: const [
            TextSpan(text: 'Habesha ', style: TextStyle(color: Colors.white)),
            TextSpan(text: 'Freight', style: TextStyle(color: AppColors.gold)),
          ])),
          Text('LOGISTICS PLATFORM', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.textMuted)),
        ]),
      ]),
      Row(children: [
        Container(
          height: 30, padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: language, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 14),
              dropdownColor: AppColors.card, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              onChanged: (v) => v != null ? onLanguageChanged(v) : null,
              items: const [DropdownMenuItem(value: 'EN', child: Text('EN')), DropdownMenuItem(value: 'አም', child: Text('አም'))],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => CorridorNavigationSheet.show(context),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 5),
                Text(
                  'Modules',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.gold, AppColors.goldDark]), shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: AppColors.textDark, size: 18),
          ),
        ),
      ]),
    ]);
  }
}

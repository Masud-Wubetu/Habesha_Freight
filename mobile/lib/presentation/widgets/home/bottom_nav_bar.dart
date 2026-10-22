import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HabeshaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HabeshaBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_filled, 'Home'),
            _navItem(1, Icons.inventory_2_outlined, 'Shipments'),
            _postLoadCenterButton(),
            _navItem(3, Icons.gavel_outlined, 'Bids'),
            _navItem(4, Icons.navigation_outlined, 'Tracking'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final sel = currentIndex == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(idx),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: sel ? AppColors.gold : AppColors.textMuted),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? AppColors.gold : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postLoadCenterButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x40FFA726), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.add, color: AppColors.textDark, size: 24),
          ),
          const SizedBox(height: 3),
          Text(
            'Post Load',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

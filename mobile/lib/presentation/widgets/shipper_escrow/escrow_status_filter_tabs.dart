import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class EscrowStatusFilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int activeEscrowCount;
  final int invoicesCount;
  final int disputesCount;

  const EscrowStatusFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeEscrowCount = 2,
    this.invoicesCount = 45,
    this.disputesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1424),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1C2C47)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              index: 0,
              label: 'Active Escrow',
              count: activeEscrowCount,
              isSelected: selectedIndex == 0,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              index: 1,
              label: 'Invoices',
              count: invoicesCount,
              isSelected: selectedIndex == 1,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              index: 2,
              label: 'Disputes',
              count: disputesCount,
              isSelected: selectedIndex == 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required String label,
    required int count,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2D4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.gold.withValues(alpha: 0.6) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF0B1321) : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

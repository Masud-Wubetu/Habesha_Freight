import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class ShipmentsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterSettingsTap;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final int allCount;
  final int activeCount;
  final int biddingCount;
  final int deliveredCount;
  final int awardedCount;

  const ShipmentsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterSettingsTap,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.allCount = 12,
    this.activeCount = 3,
    this.biddingCount = 5,
    this.deliveredCount = 4,
    this.awardedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input with Filter Action Button
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration(
                    hintText: 'Filter by corridor, cargo ID, or driver...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onFilterSettingsTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Status Filter Pills
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildFilterPill(
                index: 0,
                label: 'All',
                count: allCount,
                isSelected: selectedTabIndex == 0,
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                index: 1,
                label: 'Active',
                count: activeCount,
                isSelected: selectedTabIndex == 1,
                highlightColor: const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                index: 2,
                label: 'Bidding',
                count: biddingCount,
                isSelected: selectedTabIndex == 2,
                highlightColor: AppColors.gold,
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                index: 4,
                label: 'Awarded',
                count: awardedCount,
                isSelected: selectedTabIndex == 4,
                highlightColor: const Color(0xFFA855F7),
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                index: 3,
                label: 'Delivered',
                count: deliveredCount,
                isSelected: selectedTabIndex == 3,
                highlightColor: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required int index,
    required String label,
    required int count,
    required bool isSelected,
    Color? highlightColor,
  }) {
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : const Color(0xFF1E293B),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                    : (highlightColor ?? const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

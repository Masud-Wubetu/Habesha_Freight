import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class CargoTypeItem {
  final String id;
  final String label;
  final IconData icon;

  const CargoTypeItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class CargoClassificationSelector extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelected;

  const CargoClassificationSelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  static const List<CargoTypeItem> categories = [
    CargoTypeItem(
      id: 'dry_bulk',
      label: 'Dry Bulk',
      icon: Icons.grain_rounded,
    ),
    CargoTypeItem(
      id: 'container_40ft',
      label: '40ft Container',
      icon: Icons.local_shipping_rounded,
    ),
    CargoTypeItem(
      id: 'cold_chain',
      label: 'Cold Chain',
      icon: Icons.ac_unit_rounded,
    ),
    CargoTypeItem(
      id: 'break_bulk',
      label: 'Break Bulk',
      icon: Icons.inventory_2_outlined,
    ),
    CargoTypeItem(
      id: 'hazardous',
      label: 'Hazardous (ADR)',
      icon: Icons.warning_amber_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARGO CLASSIFICATION',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == selectedId;

              return InkWell(
                onTap: () => onSelected(cat.id),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : const Color(0xFF1E293B),
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
                      Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

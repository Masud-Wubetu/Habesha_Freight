import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ShipperMetricsRow extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool loading;

  const ShipperMetricsRow({
    super.key,
    this.stats,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = stats?['active'] ?? 0;
    final total = stats?['total'] ?? 0;
    final pendingBids = stats?['pendingBids'] ?? 0;
    final totalEscrow = (stats?['totalEscrow'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _buildItem(
            label: 'ACTIVE',
            value: loading ? '—' : '$active',
            color: AppColors.badgeGreenText,
            icon: Icons.sync_rounded,
          ),
          _divider(),
          _buildItem(
            label: 'POSTED',
            value: loading ? '—' : '$total',
            color: Colors.white,
            icon: Icons.inventory_2_outlined,
          ),
          _divider(),
          _buildItem(
            label: 'QUOTES',
            value: loading ? '—' : '$pendingBids',
            color: AppColors.gold,
            icon: Icons.gavel_rounded,
          ),
          _divider(),
          _buildItem(
            label: 'ESCROW',
            value: loading ? '—' : '${(totalEscrow / 1000).toStringAsFixed(totalEscrow >= 1000 ? 1 : 0)}k',
            color: const Color(0xFF38BDF8),
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 24,
        width: 1,
        color: AppColors.cardBorder,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _buildItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

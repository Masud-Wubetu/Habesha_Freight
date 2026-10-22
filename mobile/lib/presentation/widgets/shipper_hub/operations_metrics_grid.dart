import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OperationsMetricsGrid extends StatelessWidget {
  final int activeLoadsCount;
  final int pendingBidsCount;
  final int completedCount;
  final String inEscrowFormatted;
  final VoidCallback? onActiveLoadsTap;
  final VoidCallback? onPendingBidsTap;
  final VoidCallback? onCompletedTap;
  final VoidCallback? onInEscrowTap;

  const OperationsMetricsGrid({
    super.key,
    this.activeLoadsCount = 3,
    this.pendingBidsCount = 8,
    this.completedCount = 42,
    this.inEscrowFormatted = '145k',
    this.onActiveLoadsTap,
    this.onPendingBidsTap,
    this.onCompletedTap,
    this.onInEscrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Active Loads & Pending Bids
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Active Loads',
                icon: Icons.local_shipping_outlined,
                iconColor: const Color(0xFF94A3B8),
                value: '$activeLoadsCount',
                subtitle: 'in transit',
                subtitleColor: const Color(0xFF34D399),
                onTap: onActiveLoadsTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'Pending Bids',
                icon: Icons.gavel_rounded,
                iconColor: const Color(0xFF94A3B8),
                value: '$pendingBidsCount',
                subtitle: 'Needs review',
                subtitleColor: const Color(0xFFFBBF24),
                onTap: onPendingBidsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Completed & In Escrow
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Completed',
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF94A3B8),
                value: '$completedCount',
                subtitle: 'All corridors',
                subtitleColor: const Color(0xFF94A3B8),
                onTap: onCompletedTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'In Escrow',
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF94A3B8),
                value: inEscrowFormatted,
                subtitle: 'ETB Secured',
                subtitleColor: const Color(0xFF38BDF8),
                onTap: onInEscrowTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E2E48), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Icon(icon, size: 16, color: iconColor),
              ],
            ),
            const SizedBox(height: 8),

            // Large Value
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle status
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

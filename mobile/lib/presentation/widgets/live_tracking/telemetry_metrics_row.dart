import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class TelemetryMetricsRow extends StatelessWidget {
  final String speed;
  final String speedStatus;
  final String remainingKm;
  final String remainingDestination;
  final String estArrival;
  final String arrivalStatus;

  const TelemetryMetricsRow({
    super.key,
    this.speed = '68 km/h',
    this.speedStatus = 'Cruising',
    this.remainingKm = '140 km',
    this.remainingDestination = 'to Awash',
    this.estArrival = '2h 30m',
    this.arrivalStatus = 'On Schedule',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Column 1: Speed
        Expanded(
          child: _metricCard(
            icon: Icons.speed_rounded,
            iconColor: AppColors.gold,
            label: 'SPEED',
            value: speed,
            subStatus: speedStatus,
            subStatusColor: const Color(0xFF4ADE80),
          ),
        ),
        const SizedBox(width: 8),

        // Column 2: Remaining
        Expanded(
          child: _metricCard(
            icon: Icons.alt_route_rounded,
            iconColor: const Color(0xFF38BDF8),
            label: 'REMAINING',
            value: remainingKm,
            subStatus: remainingDestination,
            subStatusColor: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(width: 8),

        // Column 3: Est. Arrival
        Expanded(
          child: _metricCard(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.gold,
            label: 'EST. ARRIVAL',
            value: estArrival,
            subStatus: arrivalStatus,
            subStatusColor: const Color(0xFF4ADE80),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subStatus,
    required Color subStatusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subStatus,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: subStatusColor,
            ),
          ),
        ],
      ),
    );
  }
}

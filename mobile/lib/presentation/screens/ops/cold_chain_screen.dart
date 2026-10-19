import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// Page 39 — Cold Chain Specialized Cargo Telemetry
class ColdChainScreen extends StatelessWidget {
  const ColdChainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Cold Chain & Hazmat Telemetry',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          color: AppColors.onSurfaceVariant,
          onPressed: () {},
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              const Expanded(
                child: PageRibbon(
                  page: '39',
                  title: 'Cold Chain & Hazmat Telemetry',
                  textColor: AppColors.tertiary,
                  dotColor: AppColors.tertiary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'IoT Sensors Active • 24/24 Linked',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.ac_unit,
                          size: 22, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REEFER CARGO #CC-8842',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.tertiary,
                            ),
                          ),
                          const Text(
                            'Pharmaceutical Vaccines & Horticulture',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Euro VI Rig',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.route, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Addis Ababa Bole Cargo Terminal → Djibouti Coolport (480 km)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.rv_hookup,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ET-3-9942 • Carrier Transicold Prime',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Master Operator: Fikru Bekele',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text('Secured',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 12, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text('Optimal Range (Zone A)',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Master temp
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              children: [
                Text(
                  '-19.4°C',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tertiary,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'Target: -20.0°C ± 1.5°C',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Text(
                  'Excursion Margin: +0.6°C safe',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TempMeta(
                        label: 'Setpoint Config',
                        value: '-20.0°C',
                        sub: 'Continuous Cryo',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TempMeta(
                        label: 'External Heat Index',
                        value: '+34.2°C',
                        sub: 'Awash Valley Corridor',
                        valueColor: AppColors.errorStrong,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hvac, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continuous Modulated Compressor',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Text(
                              '84% Duty Cycle · Prime Inverter: Operational',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const Text(
                              'Diesel Backup Reserve: 96% Fuel Tank',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Multi-Zone Thermal Array',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Text(
                'NIST Calibrated',
                style: TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ZoneCard(
            icon: Icons.sensors,
            title: 'Zone 1 (Nose / Evaporator)',
            subtitle: 'Direct Chiller Exhaust Flow',
            temp: '-19.8°C',
            status: 'Normal',
            statusColor: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          const _ZoneCard(
            icon: Icons.grid_view,
            title: 'Zone 2 (Core Pallet Middle)',
            subtitle: 'Center Bulkhead Insulation',
            temp: '-19.4°C',
            status: 'Normal',
            statusColor: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          const _ZoneCard(
            icon: Icons.door_back_door,
            title: 'Zone 3 (Rear Door / Bilateral)',
            subtitle: '+0.7°C differential vector',
            temp: '-18.7°C',
            status: 'Safe Margin',
            statusColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HfCard(
                  color: AppColors.surfaceLow,
                  child: Column(
                    children: [
                      const Icon(Icons.water_drop,
                          size: 20, color: AppColors.tertiary),
                      const SizedBox(height: 4),
                      Text(
                        '62% RH',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Text('Humidity Level',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.onSurfaceVariant)),
                      const Text('Target 60% – 65%',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HfCard(
                  color: AppColors.surfaceLow,
                  child: Column(
                    children: [
                      const Icon(Icons.verified,
                          size: 20, color: AppColors.secondary),
                      const SizedBox(height: 4),
                      Text(
                        '0 Open Events',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Text('Seal Integrity',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.onSurfaceVariant)),
                      const Text('MagSeal #CS-9912',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '6-Hour Micro-Thermal Trend',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Text(
                  'Transiting Awash Basin & Mille Desert Crossing',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Zero Excursions',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: CustomPaint(
                    painter: _TrendPainter(),
                    size: const Size(double.infinity, 64),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('02:00 (Awash)',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.onSurfaceVariant)),
                    Text('04:30 (Mille Junction)',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.onSurfaceVariant)),
                    Text('Live (Mile 312)',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.tertiary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.workspace_premium,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'WHO GDP & EFDA Verified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Excursion Count: 0 Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber,
                        size: 20, color: AppColors.errorStrong),
                    const SizedBox(width: 8),
                    Text(
                      'Dangerous Goods / Hazmat',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.errorStrong.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'UN 1845',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorStrong,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Class 9: Solid Carbon Dioxide\nDry Ice Sublimation Refrigerant Dual Mode · 140 kg Bulk',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HazmatMetric(
                        label: 'Spill / Gas Venting',
                        value: '0.0 ppm CO₂',
                        sub: 'Airstream Normal',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HazmatMetric(
                        label: 'Emergency Scrubbers',
                        value: 'Armed & Ready',
                        sub: 'Auto-Evac Ready',
                        valueColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Audit report generated and digitally signed.',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                'Export Certified Cold Chain Audit Slip (PDF) →',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                backgroundColor: AppColors.surfaceHigh,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.tune, color: AppColors.tertiary),
              label: const Text('Reefer Engine Diagnostic Remote Override'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempMeta extends StatelessWidget {
  const _TempMeta({
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.temp,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String temp;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(temp,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiary,
                  )),
              Text(status,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HazmatMetric extends StatelessWidget {
  const _HazmatMetric({
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tertiary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [0.55, 0.48, 0.52, 0.45, 0.50, 0.42, 0.47, 0.44];
    for (var i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // threshold lines
    final thresh = Paint()
      ..color = AppColors.errorStrong.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), thresh);
    final base = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), base);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// Page 37 — Weighbridge Axle Load Telemetry
class WeighbridgeScreen extends StatelessWidget {
  const WeighbridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Weighbridge Telemetry And Axle Load',
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
                  page: '37',
                  title: 'Weighbridge & Axle Load Telemetry',
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'ERA Synced',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
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
                    const Icon(Icons.sensors, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Station #WB-04 • In-Motion Sensor',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Modjo Expressway Weighbridge',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 18, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LEGAL & COMPLIANT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      Text(
                        '0% Overload Penalty',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: _MetaCell(
                        label: 'Vehicle Plate',
                        value: 'ET-3-8821 AA',
                        sub: '6×4 Tractor + 3-Axle Trailer',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _MetaCell(
                        label: 'Scale Time',
                        value: '15:42 EAT',
                        sub: 'Speed (WIM) 8 km/h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gross Vehicle Weight (GVW)',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '47,400',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      ' / 48,000 kg',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.988,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceHighest,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Within Statutory Allowance (98.8%)',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '+600 kg Margin Safe',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.directions_car, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Chassis Load Telemetry',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Text(
                '6 Grounded Axles',
                style: TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Axle chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: i < 1
                        ? AppColors.primary
                        : i < 3
                            ? AppColors.tertiary
                            : AppColors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'A${i + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Steer Axle',
                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Drive Tandem',
                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Trailer Tridem',
                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          const _AxleGroupCard(
            indexLabel: '1',
            title: 'Steer Single Axle',
            subtitle: 'Axle 1 (Front Steering)',
            weight: '6,200 kg',
            max: 'Max: 8,000 kg',
            stress: '77.5% Stress [Optimal Distribution]',
            reserve: '+1,800 kg reserve',
            progress: 0.775,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          const _AxleGroupCard(
            indexLabel: '2-3',
            title: 'Drive Tandem Axles',
            subtitle: 'Dual-Tire Bogie (Tractor Rear)',
            weight: '17,400 kg',
            max: 'Max: 18,000 kg',
            stress: '96.6% Stress [Compliant]',
            reserve: '+600 kg reserve',
            progress: 0.966,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          const _AxleGroupCard(
            indexLabel: '4-6',
            title: 'Semi-Trailer Tridem Group',
            subtitle: 'Tri-Axle Cargo Suspension',
            weight: '23,800 kg',
            max: 'Max: 24,000 kg',
            stress: '99.1% Stress [Compliant Limit]',
            reserve: '+200 kg margin',
            progress: 0.991,
            color: AppColors.tertiary,
          ),
          const SizedBox(height: 20),
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statutory Weight Certificate',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const Text(
                            'Federal Democratic Republic of Ethiopia • ERA',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'VALIDATED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _CertRow(
                  label: 'Digital ERA Slip #',
                  value: '#ERA-WB-2024-9941',
                  hint: 'Cryptographically Signed',
                ),
                const _CertRow(
                  label: 'Station Officer',
                  value: 'Insp. Hailu Girma',
                  hint: 'Modjo Post #4',
                ),
                const _CertRow(
                  label: 'Statutory Fine / Penalty',
                  value: 'ETB 0.00',
                  hint: 'Zero Infractions Logged',
                  valueColor: AppColors.secondary,
                ),
                const _CertRow(
                  label: 'Clearance Corridor',
                  value: 'Ethio-Djibouti Trunk',
                  hint: 'Transit Gate #02 Open',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user,
                          size: 18, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ERA Electronic Seal Active — Verified by Modjo Scale Server',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send_to_mobile),
              label: Text(
                'Transmit Certificate to Rig Driver →',
                style: GoogleFonts.outfit(
                  fontSize: 15,
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
              icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              label: const Text('Export Official ERA Weighbridge Slip (PDF)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;

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
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AxleGroupCard extends StatelessWidget {
  const _AxleGroupCard({
    required this.indexLabel,
    required this.title,
    required this.subtitle,
    required this.weight,
    required this.max,
    required this.stress,
    required this.reserve,
    required this.progress,
    required this.color,
  });

  final String indexLabel;
  final String title;
  final String subtitle;
  final String weight;
  final String max;
  final String stress;
  final String reserve;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  indexLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weight,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    max,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceHighest,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  stress,
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ),
              Text(
                reserve,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  const _CertRow({
    required this.label,
    required this.value,
    required this.hint,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final String hint;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
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
              ],
            ),
          ),
          Text(hint,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

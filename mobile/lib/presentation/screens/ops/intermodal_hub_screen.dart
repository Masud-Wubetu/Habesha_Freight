import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// Page 40 — Multi-Modal Rail Inland Port Intermodal Manager
class IntermodalHubScreen extends StatelessWidget {
  const IntermodalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Multi-Modal Intermodal & Rail Port Hub',
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
                  page: '40',
                  title: 'Multi-Modal Intermodal & Rail Port Hub',
                ),
              ),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'EDR Rail Feed Synced • Mojo Dry Port',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.train,
                  label: 'Line Frequency',
                  value: 'Mojo Electrified Yard',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  icon: Icons.speed,
                  label: 'Corridor Velocity',
                  value: 'Express Class 1',
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
                    const Icon(Icons.swap_horiz,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Yard Match',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Mojo Multi-Modal Inland Dry Port',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const Text(
                            'Terminal 02 • Heavy Cargo Bay',
                            style: TextStyle(
                              fontSize: 11,
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'REQ-9840',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TransferNode(
                        badge: 'INBOUND DRAYAGE',
                        plate: 'ET-3-8821',
                        icon: Icons.local_shipping,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward,
                          color: AppColors.primary, size: 22),
                    ),
                    Expanded(
                      child: _TransferNode(
                        badge: 'EDR ROLLING STOCK',
                        plate: 'EDR W14-DJ',
                        icon: Icons.tram,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.coffee,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coffee Bulk Export (64 MT)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
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
                          'Yard Hoist Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
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
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSFER STATUS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'CONTAINER HOIST STAGED',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.precision_manufacturing,
                        size: 18, color: AppColors.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reach Stacker #04 (Operational)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurface,
                        ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CUSTOM YARD ALLOCATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.grid_view,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Block B • Row 14 • Tier 3',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Mojo Dry Port Customs Enclosure',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Gantry Automated Pin Lock Verified',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Double 20ft / Single 40ft Interlock Ready',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BAY QUEUE #01 Next',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
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
                    const Icon(Icons.departure_board,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EDR Express Train Service',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Freight Train #TF-402',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ON TIME',
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ORIGIN TERMINAL',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant)),
                          Text('Mojo Hub (ET)',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface)),
                          const Text('Express Electric',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.tertiary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.trending_flat,
                        color: AppColors.outline, size: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('MARITIME PORT',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant)),
                          Text('Nagad / Doraleh (DJ)',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface)),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.schedule,
                                  size: 12, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('Tonight 22:30 EAT',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.primary)),
                            ],
                          ),
                          const Text('Platform 3B',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.view_agenda,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flatbed 80ft Wagon #EDR-W-4402',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Text(
                              'Class A Bogie · Double-Stack Capable • Reinforced ISO Twist Pockets • Heavy Tare 22.4 MT',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompareStat(
                        label: 'TRANSIT TIME',
                        value: '14h',
                        sub: 'vs 32h Road',
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompareStat(
                        label: 'COST SAVINGS',
                        value: '-34%',
                        sub: 'ETB 48,000',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompareStat(
                        label: 'CARBON SAVED',
                        value: '-2.8 MT',
                        sub: 'CO2 Offset',
                        color: AppColors.tertiary,
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
              const Icon(Icons.fact_check, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Institutional Validation',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified, size: 14, color: AppColors.secondary),
              const SizedBox(width: 4),
              const Text(
                '4 of 4 Ready',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Handover Checklist',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          const _ChecklistItem(
            title: 'Truck Scale Out Tare Weight',
            subtitle: 'Certified Tare: 14,200 kg (Cleared at Mojo Scale 01)',
            status: 'CLEARED',
          ),
          const SizedBox(height: 8),
          const _ChecklistItem(
            title: 'Container Twist-Lock Inspection',
            subtitle: '4 Corners Mechanically Locked onto Rail Bogie',
            status: 'LOCKED',
          ),
          const SizedBox(height: 8),
          const _ChecklistItem(
            title: 'ASYCUDA Rail Waybill Transfer',
            subtitle: 'Cross-Agency Stamped #ASY-RW-9021',
            status: 'STAMPED',
          ),
          const SizedBox(height: 8),
          const _ChecklistItem(
            title: 'EDR Intermodal Escrow Release',
            subtitle: 'Linked to Commercial Bank of Ethiopia (CBE) Port Vault',
            status: 'SECURED',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Intermodal Custody Sealed — CBE Customs Escrow ID: #CBE-MJO-99201-OK',
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
              icon: const Icon(Icons.assignment_turned_in),
              label: Text(
                'Confirm Road-to-Rail Handover & Seal Bill of Lading',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
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
              icon: const Icon(Icons.track_changes, color: AppColors.tertiary),
              label: const Text(
                'Track EDR Train Telemetry & Doraleh Berth Schedule',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CORRIDOR INTERMODAL MODULES',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.page37Weighbridge),
                  icon: const Icon(Icons.scale, size: 16),
                  label: const Text('Weighbridge Tare'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryContainer,
                    side: const BorderSide(color: AppColors.surfaceBright),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.page31EscrowBatch),
                  icon: const Icon(Icons.account_balance_wallet, size: 16),
                  label: const Text('Escrow Vault'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryContainer,
                    side: const BorderSide(color: AppColors.surfaceBright),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _TransferNode extends StatelessWidget {
  const _TransferNode({
    required this.badge,
    required this.plate,
    required this.icon,
  });

  final String badge;
  final String plate;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            badge,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            plate,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareStat extends StatelessWidget {
  const _CompareStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          const Icon(Icons.check, size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// PAGE 33 — Preventive Maintenance & Workshop Work Orders (stack shell).
class MaintenanceOrdersScreen extends StatefulWidget {
  const MaintenanceOrdersScreen({super.key});

  @override
  State<MaintenanceOrdersScreen> createState() => _MaintenanceOrdersScreenState();
}

class _MaintenanceOrdersScreenState extends State<MaintenanceOrdersScreen> {
  bool _partsApproved = false;
  bool _approving = false;

  Future<void> _approveParts() async {
    setState(() => _approving = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() {
      _approving = false;
      _partsApproved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wabco Kits Released to Eng. Girma Kassa'),
        backgroundColor: AppColors.surfaceBright,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Preventive Maintenance & Workshop Work Orders',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: AppColors.onSurfaceVariant,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              const Expanded(
                child: PageRibbon(
                  page: '33',
                  title: 'PREVENTIVE MAINTENANCE & WORK ORDERS',
                  dotColor: AppColors.primaryContainer,
                  textColor: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Fleet Health: 96.2%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Rig service lifecycle, scheduled overhauls, workshop work orders, and spare parts inventory.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _HealthKpi(
                  label: 'Workshop',
                  value: '2 Rigs',
                  hint: 'Bay 1 & Bay 3',
                  hintColor: AppColors.primary,
                  icon: Icons.precision_manufacturing,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthKpi(
                  label: 'Overdue',
                  value: '0',
                  valueColor: AppColors.secondary,
                  hint: '100% MoT Compliant',
                  icon: Icons.verified,
                  iconColor: AppColors.secondary,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _HealthKpi(
                  label: 'B-Service',
                  value: '4 Rigs',
                  hint: '<1,500 km left',
                  icon: Icons.schedule,
                  iconColor: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceBright.withValues(alpha: 0.45),
                  AppColors.surfaceLow,
                ],
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.handyman, size: 48, color: AppColors.primary),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Kaliti Heavy Bay 01 • Live Telemetry',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ACTIVE SHIFT',
                          style: TextStyle(fontSize: 10, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PriorityWorkOrderCard(
            approving: _approving,
            approved: _partsApproved,
            onApprove: _approveParts,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upcoming Corridor Lifecycle',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const Text(
                '3 Queued',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _LifecycleCard(
            rig: 'ET-3-8821',
            model: 'HOWO A7',
            work: 'B-Service (Oil, Fuel Filters, Differential Fluid)',
            workColor: AppColors.primary,
            badge: 'In 2,400 km',
            badgeColor: AppColors.primary,
            showMetrics: true,
            footerIcon: Icons.calendar_month,
            footerIconColor: AppColors.tertiary,
            footer: 'Booked Slot: Next Monday at Mojo Terminal Bay',
          ),
          const SizedBox(height: 12),
          const _LifecycleCard(
            rig: 'ET-3-7714',
            model: '420HP Low-Bed',
            work: '10-Wheel TPMS Re-torquing & Tread Depth Check',
            badge: 'Tomorrow',
            badgeColor: AppColors.onSurfaceVariant,
            badgeBg: AppColors.surfaceHigh,
            footerIcon: Icons.timer,
            footerIconColor: AppColors.outline,
            footer: 'Scheduled Post-Unloading at Adama Logistics Hub',
          ),
          const SizedBox(height: 12),
          const _LifecycleCard(
            rig: 'ET-3-3310',
            model: 'Volvo FH16 540',
            work: 'Annual Ministry of Transport Statutory Roadworthiness Renewal',
            trailingVerified: true,
            footerIcon: Icons.task_alt,
            footerIconColor: AppColors.secondary,
            footer: 'Documentation Pre-Filled',
            footerTrailing: 'Scheduled Nov 04',
            showFooterBox: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Initiating new digital work order docket...'),
                    backgroundColor: AppColors.surfaceBright,
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHigh,
                foregroundColor: AppColors.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 20),
              label: const Text('Create New Workshop Work Order'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mobile SOS dispatched via Awash Highway Dispatch'),
                    backgroundColor: AppColors.surfaceBright,
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceLow,
                foregroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.car_crash, size: 20),
              label: const Text('Request Heavy Mobile Mechanic SOS Team'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthKpi extends StatelessWidget {
  const _HealthKpi({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    this.valueColor = AppColors.onSurface,
    this.hintColor = AppColors.onSurfaceVariant,
    this.iconColor = AppColors.primary,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color valueColor;
  final Color hintColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          Text(
            hint,
            style: TextStyle(fontSize: 10, color: hintColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PriorityWorkOrderCard extends StatelessWidget {
  const _PriorityWorkOrderCard({
    required this.approving,
    required this.approved,
    required this.onApprove,
  });

  final bool approving;
  final bool approved;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer, AppColors.primary, AppColors.errorStrong],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning_amber, size: 20, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRIORITY WORK ORDER',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.5,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          Text(
                            '#WO-4819',
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Kaliti Central',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
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
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ET-3-9031',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Scania R420 Euro 4',
                            style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: AppColors.outline),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Kaliti Central Heavy Logistics Workshop, Addis Ababa',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _InfoLine(
                  icon: Icons.build,
                  iconColor: AppColors.primary,
                  label: 'Scheduled Work',
                  value: 'Dual Brake Pad Replacement & Air Suspension Calibration',
                ),
                const SizedBox(height: 10),
                const _InfoLine(
                  icon: Icons.engineering,
                  iconColor: AppColors.secondary,
                  label: 'Lead Fleet Engineer',
                  value: 'Eng. Girma Kassa (Chief Fleet Technician)',
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.inventory_2, size: 18, color: AppColors.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Allocated Parts',
                            style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Wabco Heavy Brake Kits ×2',
                                  style: TextStyle(fontSize: 10, color: AppColors.tertiary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'In Stock',
                                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Execution: 65% Complete',
                            style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                          Text(
                            'Est. Rollout: 17:30 EAT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceLowest,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: approved || approving ? null : onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: approved
                          ? AppColors.secondary.withValues(alpha: 0.2)
                          : AppColors.primaryContainer,
                      foregroundColor: approved ? AppColors.secondary : AppColors.onPrimaryContainer,
                      disabledBackgroundColor: approved
                          ? AppColors.secondary.withValues(alpha: 0.2)
                          : AppColors.primaryContainer.withValues(alpha: 0.7),
                      disabledForegroundColor: approved ? AppColors.secondary : AppColors.onPrimaryContainer,
                    ),
                    child: approving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Releasing Wabco Kits...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (approved) const Icon(Icons.check, size: 18),
                              if (approved) const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  approved
                                      ? 'Parts Dispatched to Kaliti Bay 1'
                                      : 'Approve Spare Parts Release & Work Order',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (!approved) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LifecycleCard extends StatelessWidget {
  const _LifecycleCard({
    required this.rig,
    required this.model,
    required this.work,
    required this.footer,
    required this.footerIcon,
    this.workColor = AppColors.onSurface,
    this.badge,
    this.badgeColor = AppColors.primary,
    this.badgeBg,
    this.footerIconColor = AppColors.onSurfaceVariant,
    this.footerTrailing,
    this.showMetrics = false,
    this.showFooterBox = false,
    this.trailingVerified = false,
  });

  final String rig;
  final String model;
  final String work;
  final Color workColor;
  final String? badge;
  final Color badgeColor;
  final Color? badgeBg;
  final IconData footerIcon;
  final Color footerIconColor;
  final String footer;
  final String? footerTrailing;
  final bool showMetrics;
  final bool showFooterBox;
  final bool trailingVerified;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rig,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            model,
                            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(work, style: TextStyle(fontSize: 12, color: workColor)),
                  ],
                ),
              ),
              if (trailingVerified)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                )
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg ?? badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: badgeColor),
                  ),
                ),
            ],
          ),
          if (showMetrics) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Odometer', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        Text(
                          '148,200 km',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Corridor Buffer', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        Text(
                          '~3 corridor runs',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (showFooterBox)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(footerIcon, size: 16, color: footerIconColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      footer,
                      style: TextStyle(fontSize: 10, color: footerIconColor),
                    ),
                  ),
                  if (footerTrailing != null)
                    Text(
                      footerTrailing!,
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                ],
              ),
            )
          else
            Row(
              children: [
                Icon(footerIcon, size: 16, color: footerIconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    footer,
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

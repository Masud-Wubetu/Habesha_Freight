import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/fleet_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// Page 34 — Freight Company Analytics & Corridor Performance Hub
class AnalyticsHubScreen extends StatefulWidget {
  const AnalyticsHubScreen({super.key});

  @override
  State<AnalyticsHubScreen> createState() => _AnalyticsHubScreenState();
}

class _AnalyticsHubScreenState extends State<AnalyticsHubScreen> {
  int _horizon = 0; // 0=30d, 1=Q3, 2=YTD
  final _fleet = FleetService();
  CompanyStats? _stats;
  bool _loading = true;
  bool _live = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _fleet.getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _live = true;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _live = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to sync company stats';
        _live = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Freight Company Analytics & Corridor Performance Hub',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 22),
          color: AppColors.onSurfaceVariant,
          tooltip: 'Refresh stats',
          onPressed: _load,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          color: AppColors.onSurfaceVariant,
          onPressed: () {},
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.primaryContainer,
        onRefresh: _load,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: PageRibbon(
                  page: '34',
                  title: 'Freight Analytics',
                  status: _live
                      ? 'Live company stats'
                      : (_error != null ? 'Design preview' : null),
                  textColor: AppColors.primary,
                  dotColor: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _live ? Icons.cloud_done : Icons.calendar_month,
                      size: 13,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _live
                          ? '${_stats!.shipmentsTotal} shipments · ${_stats!.driversActive} drivers'
                          : 'Monthly Report: Oct 2024',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                color: AppColors.primaryContainer,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Corridor profitability, fuel economy benchmarks, driver turnaround times, and revenue growth across federal transit arteries.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _HorizonSelector(
            selected: _horizon,
            onChanged: (i) => setState(() => _horizon = i),
          ),
          const SizedBox(height: 16),
          _RevenueBanner(stats: _stats, live: _live),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.alt_route,
            title: 'Corridor Benchmarks',
            trailing: _live ? 'Company API' : 'Real-time Telemetry',
          ),
          const SizedBox(height: 12),
          _DjiboutiCorridorCard(),
          const SizedBox(height: 12),
          _CorridorMiniCard(
            from: 'Addis Ababa',
            to: 'Mekelle',
            subtitle: 'Northern Relief & Commercial Trunk',
            badge: 'Strong Volume ★★★★☆',
            badgeColor: AppColors.tertiary,
            volume: '28 Trips (896 MT)',
            avgRev: 'ETB 78,000',
            turnaround: '42 hrs',
            turnaroundColor: AppColors.onSurface,
          ),
          const SizedBox(height: 12),
          _CorridorMiniCard(
            from: 'Addis Ababa',
            to: 'Hawassa SEZ',
            subtitle: 'Hawassa Industrial Park Expressway',
            badge: 'Rapid Turnaround ★★★★☆',
            badgeColor: AppColors.secondary,
            volume: '18 Trips (576 MT)',
            avgRev: 'ETB 44,500',
            turnaround: '18 hrs',
            turnaroundColor: AppColors.secondary,
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.military_tech,
            title: 'Monthly Leaders',
            trailing: 'Excellence Index',
          ),
          const SizedBox(height: 12),
          _LeaderCard(
            icon: Icons.rv_hookup,
            title: 'ET-3-8821',
            chip: 'Scania R500',
            subtitle: '12 completed corridors • 99.4% uptime',
            value: 'ETB 1.48M',
            valueLabel: 'Gross Yield',
            valueColor: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _LeaderCard(
            icon: Icons.person,
            title: 'Kassahun Tadesse',
            verified: true,
            subtitle: '100% on-time • 0 safety infractions',
            value: '4.98',
            valueLabel: 'Driver Score',
            valueColor: AppColors.primary,
            valueIcon: Icons.star,
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceHigh.withValues(alpha: 0.35),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco, color: AppColors.tertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fleet Decarbonization Ledger',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Avg 28.4 L/100km • -8.2% CO2 vs Federal Baseline',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 18),
                  color: AppColors.onSurface,
                  onPressed: () {},
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
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.download, size: 20),
              label: const Text(
                'Export Audited IFRS Financial Report (PDF/Excel)',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.account_balance, size: 16),
            label: const Text(
              'Share Telematics & Carbon Emissions Ledger with FTA',
              textAlign: TextAlign.center,
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
          ),
        ],
        ),
      ),
    );
  }
}

class _HorizonSelector extends StatelessWidget {
  const _HorizonSelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _labels = ['Last 30 Days', 'Q3 Cumulative', '2024 YTD'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.surfaceContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RevenueBanner extends StatelessWidget {
  const _RevenueBanner({this.stats, this.live = false});

  final CompanyStats? stats;
  final bool live;

  String _money(num n) =>
      NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0).format(n);

  @override
  Widget build(BuildContext context) {
    final earnings = stats?.totalEarnings ?? 4820500;
    final delivered = stats?.shipmentsDelivered ?? 0;
    final inTransit = stats?.shipmentsInTransit ?? 0;
    final activeRigs = stats?.vehiclesActive ?? 0;
    final rating = stats?.averageRating ?? 0;

    return HfCard(
      color: AppColors.surfaceLow,
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
                    Text(
                      live ? 'COMPANY EARNINGS (API)' : 'MONTHLY FLEET REVENUE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      live ? _money(earnings) : 'ETB 4,820,500.00',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      live ? Icons.cloud_done : Icons.trending_up,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      live
                          ? '${stats!.shipmentsTotal} trips · ★${rating.toStringAsFixed(1)}'
                          : '+24.8% MoM',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
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
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live ? 'Active Rigs' : 'Net Operating Margin',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            live ? '$activeRigs' : '38.6%',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            live
                                ? 'of ${stats!.vehiclesTotal} total'
                                : 'Target 35%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live ? 'Delivered / In transit' : 'Net Contribution',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        live
                            ? '$delivered / $inTransit'
                            : 'ETB 1,860,700',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operating Expense Allocation',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
              Text(
                '80% Total Direct Cost',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(flex: 42, child: Container(color: AppColors.primaryContainer)),
                  Expanded(flex: 18, child: Container(color: AppColors.tertiaryContainer)),
                  Expanded(flex: 12, child: Container(color: AppColors.secondary)),
                  Expanded(flex: 8, child: Container(color: AppColors.outline)),
                  Expanded(flex: 20, child: Container(color: AppColors.surfaceHighest)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _ExpenseLegend(color: AppColors.primaryContainer, label: 'Diesel: 42% (1.24M)'),
              _ExpenseLegend(color: AppColors.tertiaryContainer, label: 'Wages: 18% (532K)'),
              _ExpenseLegend(color: AppColors.secondary, label: 'Maint: 12% (355K)'),
              _ExpenseLegend(color: AppColors.outline, label: 'Customs: 8% (236K)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseLegend extends StatelessWidget {
  const _ExpenseLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(fontSize: 10, color: AppColors.outline),
          ),
      ],
    );
  }
}

class _DjiboutiCorridorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
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
                          'Addis Ababa',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const Icon(Icons.arrow_right_alt,
                            size: 16, color: AppColors.primary),
                        Text(
                          'Djibouti Port',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Djibouti Mainline Freight Pipeline',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 13, color: AppColors.secondary),
                    SizedBox(width: 2),
                    Text(
                      'Highest Yield',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const _Waypoint(label: 'Kality Dry Port', color: AppColors.primary),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(height: 2, color: AppColors.primary.withValues(alpha: 0.3)),
                      const Icon(Icons.local_shipping, size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
                const _Waypoint(label: 'Doraleh Port', color: AppColors.secondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: const [
              _MetricCell(label: 'Total Volume', value: '42 Trips • 1,512 MT'),
              _MetricCell(
                label: 'Avg Revenue / Trip',
                value: 'ETB 142,000',
                valueColor: AppColors.primary,
              ),
              _MetricCell(label: 'Corridor Fleet Speed', value: '62 km/h'),
              _MetricCell(
                label: 'Mean Turnaround',
                value: '54 Hours',
                valueColor: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Waypoint extends StatelessWidget {
  const _Waypoint({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.onSurface),
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CorridorMiniCard extends StatelessWidget {
  const _CorridorMiniCard({
    required this.from,
    required this.to,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.volume,
    required this.avgRev,
    required this.turnaround,
    required this.turnaroundColor,
  });

  final String from;
  final String to;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String volume;
  final String avgRev;
  final String turnaround;
  final Color turnaroundColor;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
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
                          from,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Icon(Icons.arrow_right_alt,
                            size: 16, color: AppColors.outline),
                        Text(
                          to,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Volume', value: volume)),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Avg Rev',
                  value: avgRev,
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: 'Turnaround',
                  value: turnaround,
                  valueColor: turnaroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueLabel,
    required this.valueColor,
    this.chip,
    this.verified = false,
    this.valueIcon,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String valueLabel;
  final Color valueColor;
  final String? chip;
  final bool verified;
  final IconData? valueIcon;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chip != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chip!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                    if (verified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (valueIcon != null)
                    Icon(valueIcon, size: 15, color: valueColor),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
              Text(
                valueLabel,
                style: const TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

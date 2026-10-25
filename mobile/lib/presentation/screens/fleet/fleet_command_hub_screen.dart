import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/escrow_service.dart';
import 'package:mobile/core/services/fleet_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/kpi_tile.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/navigation/corridor_navigation_sheet.dart';

/// PAGE 27 — Fleet Operations Command Hub (tab shell).
class FleetCommandHubScreen extends StatefulWidget {
  const FleetCommandHubScreen({super.key});

  @override
  State<FleetCommandHubScreen> createState() => _FleetCommandHubScreenState();
}

class _FleetCommandHubScreenState extends State<FleetCommandHubScreen> {
  final _fleet = FleetService();
  final _escrow = EscrowService();

  bool _loading = true;
  String? _error;
  bool _live = false;
  CompanyProfile? _profile;
  CompanyStats? _stats;
  List<FleetDelivery> _deliveries = const [];
  double _lockedEscrow = 0;

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
      final results = await Future.wait([
        _fleet.getProfile(),
        _fleet.getStats(),
        _fleet.getDeliveries(),
        _escrow.getLedger(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as CompanyProfile;
        _stats = results[1] as CompanyStats;
        _deliveries = results[2] as List<FleetDelivery>;
        _lockedEscrow = (results[3] as EscrowLedgerSummary).totalLocked;
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to sync fleet data';
        _live = false;
        _loading = false;
      });
    }
  }

  String _etb(num n) {
    if (n >= 1000000) return 'ETB ${(n / 1000000).toStringAsFixed(2)}M';
    return NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0).format(n);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final activeRigs = stats == null
        ? '—'
        : '${stats.vehiclesActive} / ${stats.vehiclesTotal == 0 ? stats.vehiclesActive : stats.vehiclesTotal}';
    final escrowValue = stats == null
        ? '—'
        : (_lockedEscrow > 0 ? _etb(_lockedEscrow) : _etb(stats.totalEarnings));
    final companyName = _profile?.name ?? (_live ? 'Fleet company' : '—');
    final tin = _profile?.tin ?? '—';

    return Scaffold(
      backgroundColor: AppColors.surface,

      body: SafeArea(
        child: Column(
          children: [
            _BrandHeader(
              subtitle: 'Fleet Overview',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => CorridorNavigationSheet.show(context),
                    icon: const Icon(Icons.grid_view_rounded),
                    color: AppColors.primaryContainer,
                    tooltip: 'All Corridor Modules',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                    icon: const Icon(Icons.storefront_outlined),
                    color: AppColors.onSurfaceVariant,
                    tooltip: 'Shipper Portal',
                  ),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    color: AppColors.onSurfaceVariant,
                    tooltip: 'Refresh from API',
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryContainer,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    PageRibbon(
                      page: '27',
                      title: 'FLEET OPERATIONS COMMAND HUB',
                      status: _live
                          ? 'API Synced'
                          : (_error != null ? 'API Error' : 'Empty'),
                    ),
                    const SizedBox(height: 12),
                    _ApiStatusBanner(
                      loading: _loading,
                      live: _live,
                      error: _error,
                    ),
                    const SizedBox(height: 12),
                    _EnterpriseHeader(companyName: companyName, tin: tin),
                    const SizedBox(height: 12),
                    _KpiGrid(
                      activeRigs: activeRigs,
                      dispatched: stats == null
                          ? '—'
                          : '${stats.shipmentsInTransit + stats.shipmentsDelivered} trips',
                      escrowRevenue: escrowValue,
                      telemetry: stats == null
                          ? '—'
                          : '${stats.driversActive} drivers',
                    ),
                    const SizedBox(height: 12),
                    if (_deliveries.isNotEmpty) ...[
                      _LiveDeliveriesCard(
                        deliveries: _deliveries.take(4).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const _CorridorTelemetryCard(),
                    const SizedBox(height: 12),
                    const _QuickDispatchesCard(),
                    const SizedBox(height: 12),
                    const _TelemetryLogCard(),
                    const SizedBox(height: 12),
                    const _DispatchFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiStatusBanner extends StatelessWidget {
  const _ApiStatusBanner({
    required this.loading,
    required this.live,
    this.error,
  });

  final bool loading;
  final bool live;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HfCard(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryContainer,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Syncing company stats from backend…',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return HfCard(
      color: live ? AppColors.surfaceHigh : AppColors.surfaceLowest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            live ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: live ? AppColors.secondary : AppColors.errorStrong,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              live
                  ? 'Connected to HabeshaFreight API (/company/* + /escrow)'
                  : (error ??
                        'No fleet data — sign in as fleet owner and pull to refresh'),
              style: TextStyle(
                fontSize: 12,
                color: live ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDeliveriesCard extends StatelessWidget {
  const _LiveDeliveriesCard({required this.deliveries});
  final List<FleetDelivery> deliveries;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Deliveries',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...deliveries.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${d.origin} → ${d.destination}',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    d.status,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.subtitle, this.trailing});

  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceLowest.withValues(alpha: 0.7),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HABESHA FREIGHT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _EnterpriseHeader extends StatelessWidget {
  const _EnterpriseHeader({
    this.companyName = 'Nile Trans-Ethiopia Logistics Corp',
    this.tin = '00928374-B',
  });

  final String companyName;
  final String tin;

  @override
  Widget build(BuildContext context) {
    return HfCard(
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
                      'ENTERPRISE PORTAL',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      companyName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tin == '—' ? 'TIN unavailable' : 'TIN: $tin',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.surfaceBright),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const Text(
                    'Telematics Synced (2.4s ago)',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                'Addis Ababa HQ Dispatched',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.activeRigs,
    required this.dispatched,
    required this.escrowRevenue,
    required this.telemetry,
  });

  final String activeRigs;
  final String dispatched;
  final String escrowRevenue;
  final String telemetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: 'Active Rigs',
                value: activeRigs,
                trend: 'Fleet capacity · Tap rigs',
                trendIcon: Icons.arrow_upward,
                trailingIcon: Icons.local_shipping,
                iconColor: AppColors.secondary,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.page28RigTelemetry),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiTile(
                label: 'Dispatched',
                value: dispatched,
                trend: 'Tap for dispatch',
                trendIcon: Icons.trending_up,
                trailingIcon: Icons.scale,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.page30DispatchMatrix),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: 'Escrow Revenue',
                value: escrowRevenue,
                trend: 'CBE Escrow ledger',
                trendColor: AppColors.onSurfaceVariant,
                trailingIcon: Icons.account_balance,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.page31EscrowBatch),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiTile(
                label: 'Drivers',
                value: telemetry,
                valueColor: AppColors.primaryContainer,
                trend: 'Tap driver roster',
                trendColor: AppColors.primaryFixedDim,
                trailingIcon: Icons.groups,
                iconColor: AppColors.primaryContainer,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.page29DriverRoster),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CorridorTelemetryCard extends StatelessWidget {
  const _CorridorTelemetryCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corridor Telemetry',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Text(
                      'Real-time transits across trade gates',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.page28RigTelemetry),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceHigh,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Full Radar', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 176,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          _PulseDot(color: AppColors.secondary),
                          SizedBox(width: 6),
                          Text('GPS Live Sync', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '24 Transits Live',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _CorridorRadarPainter(),
                    size: Size.infinite,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.onSurface,
                          ),
                          children: [
                            const TextSpan(text: 'Djibouti Port ETA: '),
                            TextSpan(
                              text: 'Avg 8h 40m',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'All Checkpoints Clear',
                        style: GoogleFonts.inter(
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
          ),
          const SizedBox(height: 12),
          _CorridorRow(
            icon: Icons.alt_route,
            iconColor: AppColors.primary,
            title: 'A1 Djibouti Mainline',
            subtitle: '14 Rigs in transit • Avg 64 km/h · Tap Border Pass',
            badge: 'Optimal',
            badgeColor: AppColors.secondary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.page36BorderPass),
          ),
          const SizedBox(height: 4),
          _CorridorRow(
            icon: Icons.flag,
            iconColor: AppColors.tertiary,
            title: 'A2 Mekelle Corridor',
            subtitle: '6 Rigs • Customs Cleared · Tap Customs Hub',
            badge: 'Cleared',
            badgeColor: AppColors.secondary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.page35Customs),
          ),
          const SizedBox(height: 4),
          _CorridorRow(
            icon: Icons.warehouse,
            iconColor: AppColors.primaryContainer,
            title: 'Mojo Dry Port Hub',
            subtitle: '4 Rigs loading/docked · Tap Intermodal Hub',
            badge: 'Docking',
            badgeColor: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.page40Intermodal),
          ),
        ],
      ),
    );
  }
}

class _CorridorRow extends StatelessWidget {
  const _CorridorRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDispatchesCard extends StatelessWidget {
  const _QuickDispatchesCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Dispatches',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Icon(Icons.bolt, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.page30DispatchMatrix),
              icon: const Icon(Icons.rv_hookup, size: 20),
              label: const Text('Assign Available Rig'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _GhostAction(
            icon: Icons.local_gas_station,
            iconColor: AppColors.primary,
            label: 'Bulk Corridor Fuel Pass',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.page32FuelToll),
          ),
          const SizedBox(height: 8),
          _GhostAction(
            icon: Icons.receipt_long,
            iconColor: AppColors.secondary,
            label: 'Escrow Batch Reconciliation',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.page31EscrowBatch),
          ),
        ],
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceHigh,
          foregroundColor: AppColors.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 20, color: iconColor),
        label: Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _TelemetryLogCard extends StatelessWidget {
  const _TelemetryLogCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Corridor Telemetry Log',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.page34Analytics),
                child: Text(
                  'View All Logs',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          _LogEvent(
            icon: Icons.verified_user,
            iconBg: const Color(0x264EDEA3),
            iconColor: AppColors.secondary,
            title: 'Rig ET-3-8821',
            time: '12m ago',
            body: 'Customs E-Seal unlocked at Galafi Border',
            meta: 'Security Signature Synced · Tap Border Pass',
            metaIcon: Icons.check_circle,
            metaColor: AppColors.secondary,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.page36BorderPass),
          ),
          const SizedBox(height: 8),
          _LogEvent(
            icon: Icons.balance,
            iconBg: const Color(0x26FFC174),
            iconColor: AppColors.primary,
            title: 'Rig ET-3-1049',
            time: '35m ago',
            body: 'Tare weight verified at Kaliti Weighbridge: 32.4 MT',
            meta: 'Slip #WB-9481 Issued · Tap Weighbridge',
            metaIcon: Icons.done,
            metaColor: AppColors.primary,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.page37Weighbridge),
          ),
          const SizedBox(height: 8),
          _LogEvent(
            icon: Icons.fact_check,
            iconBg: const Color(0x269FD1FF),
            iconColor: AppColors.tertiary,
            title: 'Driver Yohannes T.',
            time: '1h ago',
            body: 'Completed digital e-POD for REQ-9840 Mekelle',
            meta: 'Escrow Trigger Pending · Tap Settlements',
            metaIcon: Icons.payments,
            metaColor: AppColors.secondary,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.page31EscrowBatch),
          ),
        ],
      ),
    );
  }
}

class _LogEvent extends StatelessWidget {
  const _LogEvent({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.body,
    required this.meta,
    required this.metaIcon,
    required this.metaColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String time;
  final String body;
  final String meta;
  final IconData metaIcon;
  final Color metaColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: iconBg,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(metaIcon, size: 13, color: metaColor),
                      const SizedBox(width: 4),
                      Text(
                        meta,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: metaColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DispatchFooter extends StatelessWidget {
  const _DispatchFooter();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceHigh,
      child: Row(
        children: [
          const _PulseDot(color: AppColors.secondary, size: 10),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispatch Operations Center',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Night-Shift Controller: Dawit K.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
            ),
            icon: const Icon(Icons.support_agent, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CorridorRadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(20, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.1,
        size.width * 0.62,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.85,
        size.width - 20,
        size.height * 0.35,
      );

    final dashPaint = Paint()
      ..color = AppColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final metrics = path.computeMetrics().first;
    var distance = 0.0;
    while (distance < metrics.length) {
      final extract = metrics.extractPath(distance, distance + 4);
      canvas.drawPath(extract, dashPaint);
      distance += 8;
    }

    void drawDot(Offset o, Color c, double r) {
      canvas.drawCircle(o, r, Paint()..color = c);
    }

    drawDot(Offset(20, size.height * 0.75), AppColors.secondary, 4);
    drawDot(
      Offset(size.width * 0.5, size.height * 0.35),
      AppColors.primaryContainer,
      5,
    );
    drawDot(Offset(size.width - 20, size.height * 0.35), AppColors.tertiary, 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

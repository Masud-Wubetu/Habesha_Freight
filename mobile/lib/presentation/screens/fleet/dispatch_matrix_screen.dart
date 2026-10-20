import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/fleet_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// PAGE 30 — Corridor Dispatch Route Assignment Matrix (stack shell).
class DispatchMatrixScreen extends StatefulWidget {
  const DispatchMatrixScreen({super.key});

  @override
  State<DispatchMatrixScreen> createState() => _DispatchMatrixScreenState();
}

class _DispatchMatrixScreenState extends State<DispatchMatrixScreen> {
  final _fleet = FleetService();
  bool _dispatching = false;
  bool _authorized = false;
  bool _loading = true;
  bool _live = false;
  String? _error;
  List<Map<String, dynamic>> _requests = const [];

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
      final requests = await _fleet.getFleetRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests;
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
        _error = 'Unable to sync fleet requests';
        _live = false;
        _loading = false;
      });
    }
  }

  Future<void> _authorize() async {
    setState(() {
      _dispatching = true;
      _authorized = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _dispatching = false;
      _authorized = true;
    });
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _authorized = false);
  }

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Dispatch Route Manager',
      actions: [
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          color: AppColors.onSurfaceVariant,
          tooltip: 'Refresh requests',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: AppColors.onSurfaceVariant,
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.primaryContainer,
        onRefresh: _load,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          PageRibbon(
            page: '30',
            title: 'CORRIDOR DISPATCH MATRIX',
            status: _live
                ? '${_requests.length} open requests'
                : 'Live Route Planner',
            dotColor: AppColors.primaryContainer,
            textColor: AppColors.primary,
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                color: AppColors.primaryContainer,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ),
          if (_error != null && !_live)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Design preview — $_error',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 12),
          HfCard(
            color: AppColors.surfaceLow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.satellite_alt, size: 18, color: AppColors.secondary),
                    SizedBox(width: 6),
                    Text(
                      'GPS Transit Uplink Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '24/7 CONTROL NODE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_live && _requests.isNotEmpty) ...[
            const SizedBox(height: 12),
            HfCard(
              color: AppColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open fleet requests (API)',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._requests.take(6).map((r) {
                    final origin = r['origin_city']?.toString() ?? '—';
                    final dest = r['destination_city']?.toString() ?? '—';
                    final cargo = r['cargo_description']?.toString() ?? 'Freight';
                    final status = r['status']?.toString() ?? 'OPEN';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.route, color: AppColors.primary),
                      title: Text(
                        '$origin → $dest',
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                      ),
                      subtitle: Text(
                        '$cargo · $status',
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const _ConsignmentCard(),
          const SizedBox(height: 12),
          const _MapPreview(),
          const SizedBox(height: 16),
          const _FleetMatchSection(),
          const SizedBox(height: 16),
          const _CorridorGatesSection(),
          const SizedBox(height: 16),
          const _DisbursementsSection(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _dispatching ? null : _authorize,
              style: ElevatedButton.styleFrom(
                backgroundColor: _authorized ? AppColors.secondary : AppColors.primary,
                foregroundColor: _authorized ? AppColors.onSecondary : AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_dispatching)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  else
                    Icon(_authorized ? Icons.check_circle : Icons.bolt, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _dispatching
                          ? 'Transmitting Digital Escrow...'
                          : _authorized
                              ? 'Corridor Dispatch Authorized!'
                              : 'Authorize Dispatch & Transmit Work Order',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  if (!_dispatching && !_authorized) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHigh,
                foregroundColor: AppColors.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.tune, size: 18, color: AppColors.onSurfaceVariant),
              label: const Text('Adjust Assigned Rig / Driver'),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ConsignmentCard extends StatelessWidget {
  const _ConsignmentCard();

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CARGO MATCH',
                  style: TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'REQ-9945',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text('FTA Gold', style: TextStyle(fontSize: 10, color: AppColors.secondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '40 MT Structural Steel & Rebar',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Text(
            'Sur Construction Ltd (Verified Partner)',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trip_origin, size: 20, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Kaliti Industrial Hub',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '452 km',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Dire Dawa Dry Port',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 1,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceHighest,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AGREED GROSS FARE',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    'ETB 115,000',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'Escrow Secured (CBE)',
                      style: TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceBright.withValues(alpha: 0.5),
            AppColors.surfaceLow,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.map, size: 56, color: AppColors.primary),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLowest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.alt_route, size: 16, color: AppColors.secondary),
                      SizedBox(width: 4),
                      Text(
                        'Route 1: Via Adama Expressway',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Primary Corridor',
                    style: TextStyle(fontSize: 10, color: AppColors.onPrimary),
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

class _FleetMatchSection extends StatelessWidget {
  const _FleetMatchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Fleet Assignment Match',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    '98% Compatibility',
                    style: TextStyle(fontSize: 10, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        HfCard(
          color: AppColors.surfaceLow,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 28),
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
                            'Rig ET-3-7714',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Ready Bay 3',
                            style: TextStyle(fontSize: 10, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'SinoTruk 420HP Low-Bed Trailer',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.tire_repair, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text('Tires 94%', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        SizedBox(width: 12),
                        Icon(Icons.local_gas_station, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text('Fuel 88%', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        HfCard(
          color: AppColors.surfaceLow,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 28),
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
                            'Mekonnen Haile',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const Icon(Icons.star, size: 16, color: AppColors.primary),
                        const Text(' 4.9', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                    const Text(
                      'Dire Dawa Corridor Veteran (340+ runs)',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety, size: 14, color: AppColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Rest Hours Reset',
                          style: TextStyle(fontSize: 10, color: AppColors.secondary),
                        ),
                        Text(
                          '  | Grade A License',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        HfCard(
          color: AppColors.surfaceHigh.withValues(alpha: 0.6),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.payments, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROJECTED NET FLEET YIELD',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      'ETB 42,800',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+37.2% Margin',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CorridorGatesSection extends StatelessWidget {
  const _CorridorGatesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corridor Clearance & Gates',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        HfCard(
          color: AppColors.surfaceLow,
          child: Column(
            children: [
              const _GateRow(
                icon: Icons.wb_cloudy,
                iconColor: AppColors.tertiary,
                title: 'Expressway Visibility',
                subtitle: 'Optimal, Dry pavement on Adama Trunk',
                badge: 'All Clear',
                badgeColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              const _GateRow(
                icon: Icons.scale,
                iconColor: AppColors.primary,
                title: 'Modjo Weighbridge',
                subtitle: 'Gate 2 Open • Estimated queue: ~5 mins',
                badge: 'Expedited',
                badgeColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              const _GateRow(
                icon: Icons.toll,
                iconColor: AppColors.secondary,
                title: 'Awash Arba Corridor Toll',
                subtitle: 'RFID FastPass active • Priority lane reserved',
                badge: 'Pre-Cleared',
                badgeColor: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.task_alt, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'High-Tension Steel Strapping Protocol Verified',
                            style: TextStyle(fontSize: 10, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.task_alt, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Customs Transit GPS Barcode Seal #ET-9945-C Attached',
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
        ),
      ],
    );
  }
}

class _GateRow extends StatelessWidget {
  const _GateRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badge,
            style: TextStyle(fontSize: 10, color: badgeColor),
          ),
        ),
      ],
    );
  }
}

class _DisbursementsSection extends StatelessWidget {
  const _DisbursementsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disbursements & Advances',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: HfCard(
                color: AppColors.surfaceLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_gas_station, size: 18, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'FUEL VOUCHER',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ETB 34,500',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'TotalEnergies #7741',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: HfCard(
                color: AppColors.surfaceLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 18, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text(
                          'DRIVER PER DIEM',
                          style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ETB 6,000',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Telebirr Direct Instant',
                      style: TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

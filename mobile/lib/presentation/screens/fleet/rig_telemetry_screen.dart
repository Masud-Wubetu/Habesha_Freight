import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/fleet_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// PAGE 28 — Rig Inventory & Telemetry Drilldown (stack shell).
class RigTelemetryScreen extends StatefulWidget {
  const RigTelemetryScreen({super.key});

  @override
  State<RigTelemetryScreen> createState() => _RigTelemetryScreenState();
}

class _RigTelemetryScreenState extends State<RigTelemetryScreen> {
  final _fleet = FleetService();
  bool _loading = true;
  bool _live = false;
  String? _error;
  List<FleetVehicle> _vehicles = const [];
  FleetVehicle? _selected;

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
      final vehicles = await _fleet.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _selected = vehicles.isNotEmpty ? vehicles.first : null;
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
        _error = 'Unable to sync vehicles';
        _live = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plate = _selected?.plateNumber ?? 'SinoTruk 380HP';
    return StackScaffold(
      title: 'Rig Telemetry Drilldown',
      actions: [
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          color: AppColors.onSurfaceVariant,
          tooltip: 'Refresh fleet',
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
              page: '28',
              title: 'RIG INVENTORY & TELEMETRY',
              status: _live ? '${_vehicles.length} rigs • $plate' : 'SinoTruk 380HP',
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
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Design preview — $_error',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ),
            if (_live && _vehicles.isNotEmpty) ...[
              const SizedBox(height: 12),
              HfCard(
                color: AppColors.surfaceLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company fleet (API)',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._vehicles.map((v) {
                      final selected = _selected?.id == v.id;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.local_shipping,
                          color: selected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                        ),
                        title: Text(
                          v.plateNumber,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${v.makeModel} · ${v.capacityTons ?? '—'}t · ${v.verificationStatus}',
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                        ),
                        trailing: Icon(
                          v.isActive ? Icons.check_circle : Icons.pause_circle,
                          color: v.isActive ? AppColors.secondary : AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                        onTap: () => setState(() => _selected = v),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const _VehicleProfileCard(),
            const SizedBox(height: 16),
            const _CorridorTrajectoryCard(),
            const SizedBox(height: 16),
            const _CanBusSection(),
            const SizedBox(height: 16),
            const _StatutoryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _live && _selected != null
                            ? 'Diagnostics for ${_selected!.plateNumber}: zero active fault codes (telemetry demo).'
                            : 'All 44 ECU parameters verified: Zero active fault codes.',
                      ),
                      backgroundColor: AppColors.surfaceBright,
                    ),
                  );
                },
                icon: const Icon(Icons.terminal, size: 20),
                label: const Text('Remote Engine Diagnostics Log →'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: const Color(0xFF2A1700),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Reassign Corridor Route / Driver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleProfileCard extends StatelessWidget {
  const _VehicleProfileCard();

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
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLowest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ET-3-8821 AA',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 6, color: AppColors.secondary),
                              SizedBox(width: 6),
                              Text(
                                '72 km/h Transit',
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
                    const SizedBox(height: 4),
                    Text(
                      'SinoTruk HOWO A7 6x4',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Text(
                      'Heavy Prime Mover • 40T Gross GVM • 380HP Euro III',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 144,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceBright.withValues(alpha: 0.4),
                  AppColors.surfaceContainer,
                ],
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.local_shipping, size: 64, color: AppColors.primary),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CAN-BUS SYNC: 100% LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.sensors, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Online (0.4s ping)',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.primary,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.inventory_2, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE MANIFEST • REQ-9912',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '36 MT Export Sesame Seeds → Djibouti Port',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Container: TGHU-882019-2 • Seal: ET-DJ-00892',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceHigh,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kassahun Tadesse',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Lic #CDL-ET-9901 • 98.4% Safety Score',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceHigh,
                  foregroundColor: AppColors.onSurface,
                ),
                icon: const Icon(Icons.call, size: 18, color: AppColors.secondary),
                label: const Text('Call Cab', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CorridorTrajectoryCard extends StatelessWidget {
  const _CorridorTrajectoryCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Corridor Trajectory',
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
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ETA: 06h 45m',
                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mojo Dry Port',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Dep 02:40 AM',
                    style: TextStyle(fontSize: 10, color: AppColors.secondary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Doraleh Terminal (DJ)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Dest. Berth 4',
                    style: TextStyle(fontSize: 10, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.58,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLowest,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.toll, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Awash Arba Toll Plaza',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Upcoming checkpoint queue clear',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '44 km',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      '~38 mins',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CanBusSection extends StatelessWidget {
  const _CanBusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.insights, color: AppColors.secondary, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'CAN-Bus Telemetry',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.circle, size: 6, color: AppColors.secondary),
                SizedBox(width: 4),
                Text(
                  'STREAMING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(child: _FuelTile()),
            SizedBox(width: 8),
            Expanded(child: _PowertrainTile()),
          ],
        ),
        const SizedBox(height: 8),
        const _ESealCard(),
        const SizedBox(height: 8),
        const _TpmsCard(),
      ],
    );
  }
}

class _FuelTile extends StatelessWidget {
  const _FuelTile();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fuel Dual Tanks',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              Icon(Icons.local_gas_station, size: 20, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '420',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const TextSpan(
                  text: ' / 600L',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLowest,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.lock, size: 14, color: AppColors.secondary),
              SizedBox(width: 4),
              Text(
                'Anti-siphon armed',
                style: TextStyle(fontSize: 10, color: AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PowertrainTile extends StatelessWidget {
  const _PowertrainTile();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Powertrain',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              Icon(Icons.memory, size: 20, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Coolant', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(
                '88°C',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Oil Press', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(
                '4.2 Bar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Nominal (0 DTC codes)',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ESealCard extends StatelessWidget {
  const _ESealCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock, color: AppColors.secondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Customs E-Seal',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Galileo Sat-Sync: 14 Sats Locked • 3.2m Acc',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.battery_charging_full, size: 16, color: AppColors.secondary),
                  Text(
                    ' 94%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Text(
                'Tamper: None',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TpmsCard extends StatelessWidget {
  const _TpmsCard();

  @override
  Widget build(BuildContext context) {
    Widget tire(String psi) => Container(
          width: 24,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
          ),
          child: Text(
            psi,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: AppColors.secondary,
            ),
          ),
        );

    return HfCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.tire_repair, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'TPMS Active Array',
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
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '10 / 10 Nominal (120 PSI)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [tire('120'), const SizedBox(width: 8), const Text('FL', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant))]),
                    const Text('STEER AXLE', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Row(children: [const Text('FR', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)), const SizedBox(width: 8), tire('120')]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [tire('119'), const SizedBox(width: 4), tire('121')]),
                    const Text('DRIVE 1', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Row(children: [tire('120'), const SizedBox(width: 4), tire('120')]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [tire('120'), const SizedBox(width: 4), tire('120')]),
                    const Text('DRIVE 2', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Row(children: [tire('122'), const SizedBox(width: 4), tire('119')]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Avg temperature across dual assemblies: 42°C (Within threshold)',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatutoryCard extends StatelessWidget {
  const _StatutoryCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Statutory & Maintenance',
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
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'All Clear',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _StatRow(
            icon: Icons.assignment_turned_in,
            iconColor: AppColors.secondary,
            title: 'Annual MoT Certificate',
            subtitle: 'Federal Transport Authority',
            trailing: 'Valid: Jan 2026',
            trailingColor: AppColors.secondary,
          ),
          const SizedBox(height: 4),
          const _StatRow(
            icon: Icons.security,
            iconColor: AppColors.primary,
            title: '3rd Party Cargo & Rig Cover',
            subtitle: 'Nyala Insurance • #NY-99042',
            trailing: 'Active',
          ),
          const SizedBox(height: 4),
          const _StatRow(
            icon: Icons.build_circle,
            iconColor: AppColors.onSurfaceVariant,
            title: 'Service Schedule',
            subtitle: 'Next B-Service (Filters & Drivetrain)',
            trailing: 'In 2,400 km',
            trailingColor: AppColors.primary,
            trailingBold: true,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.trailingColor = AppColors.onSurface,
    this.trailingBold = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final Color trailingColor;
  final bool trailingBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
          Text(
            trailing,
            style: TextStyle(
              fontSize: 12,
              fontWeight: trailingBold ? FontWeight.w700 : FontWeight.w500,
              color: trailingColor,
            ),
          ),
        ],
      ),
    );
  }
}

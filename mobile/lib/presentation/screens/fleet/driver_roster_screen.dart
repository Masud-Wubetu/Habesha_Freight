import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/fleet_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';

/// PAGE 29 — Driver Compliance & Roster Directory (tab shell).
class DriverRosterScreen extends StatefulWidget {
  const DriverRosterScreen({super.key});

  @override
  State<DriverRosterScreen> createState() => _DriverRosterScreenState();
}

class _DriverRosterScreenState extends State<DriverRosterScreen> {
  final _fleet = FleetService();
  int _filter = 0;
  bool _loading = true;
  bool _live = false;
  String? _error;
  List<FleetDriver> _drivers = const [];
  String _query = '';

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
      final drivers = await _fleet.getDrivers();
      if (!mounted) return;
      setState(() {
        _drivers = drivers;
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
        _error = 'Unable to sync roster';
        _live = false;
        _loading = false;
      });
    }
  }

  List<FleetDriver> get _filtered {
    var list = _drivers;
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((d) =>
              d.fullName.toLowerCase().contains(q) ||
              d.phone.contains(q) ||
              (d.email?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    switch (_filter) {
      case 1:
        return list.where((d) => d.status == 'ACTIVE').toList();
      case 2:
        return list.where((d) => d.status != 'ACTIVE').toList();
      case 3:
        return list
            .where((d) =>
                d.kycStatus != 'APPROVED' && d.kycStatus != 'VERIFIED')
            .toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _live ? _drivers.length : 32;
    final active = _live
        ? _drivers.where((d) => d.status == 'ACTIVE').length
        : 24;
    final standby = _live ? (total - active).clamp(0, total) : 6;
    final expiring = _live
        ? _drivers
            .where((d) =>
                d.kycStatus != 'APPROVED' && d.kycStatus != 'VERIFIED')
            .length
        : 2;
    final verifiedPct = _live && total > 0
        ? '${((_drivers.where((d) => d.isVerified || d.kycStatus == 'APPROVED').length / total) * 100).toStringAsFixed(0)}%'
        : '100%';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryContainer,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    PageRibbon(
                      page: '29',
                      title: 'DRIVER COMPLIANCE & ROSTER',
                      status: _live
                          ? '$total Drivers • API Synced'
                          : '32 Drivers Enrolled',
                    ),
                    if (_loading || _error != null) ...[
                      const SizedBox(height: 8),
                      _RosterStatusBanner(loading: _loading, live: _live, error: _error),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Active Roster & Certifications',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.26,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time telemetry, bilateral road freight credentials, and medical status tracking.',
                      style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Driver enrollment uses company POST /drivers (admin flow).'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add, size: 20),
                        label: Text(
                          'Enroll New Driver & Verify MoT Credentials →',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ScoreTile(
                            label: 'Active Drivers',
                            value: '$active',
                            hint: _live ? 'From company roster API' : 'Corridor on-time transit rate',
                            accent: AppColors.secondary,
                            icon: Icons.verified,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ScoreTile(
                            label: 'KYC Cleared',
                            value: verifiedPct,
                            hint: _live ? 'Verified / approved drivers' : 'Breathalyzer & checklist complete',
                            accent: AppColors.primary,
                            icon: Icons.task_alt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: AppColors.onSurface),
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search by driver name, license, or rig...',
                        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        filled: true,
                        fillColor: AppColors.surfaceLowest,
                        prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        suffixIcon: IconButton(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, size: 18),
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip(0, 'All', '$total'),
                          _chip(1, 'On Route', '$active', dot: AppColors.secondary),
                          _chip(2, 'Resting / Standby', '$standby', dot: AppColors.tertiary),
                          _chip(3, 'Expiring Compliance', '$expiring',
                              dot: AppColors.primary, pulse: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_live) ...[
                      if (_filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No drivers match this filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      else
                        ..._filtered.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LiveDriverCard(driver: d),
                            )),
                    ] else ...[
                      const _DriverDawitCard(),
                      const SizedBox(height: 12),
                      const _DriverBirhanuCard(),
                      const SizedBox(height: 12),
                      const _DriverKassahunCard(),
                      const SizedBox(height: 12),
                    ],
                    HfCard(
                      color: AppColors.surfaceLow,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.policy, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Federal Logistics Audit Ready',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const Text(
                                  'Ministry of Transport & Logistics synchronization current.',
                                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHigh),
                            icon: const Icon(Icons.download, size: 18, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 22),
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
                  'Drivers Directory',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Refresh roster',
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.onSurfaceVariant,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 18, color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _chip(int index, String label, String count, {Color? dot, bool pulse = false}) {
    final isSelected = _filter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = index),
        backgroundColor: AppColors.surfaceLow,
        selectedColor: AppColors.primary,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
            const SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ),
      ),
    );
  }
}

class _RosterStatusBanner extends StatelessWidget {
  const _RosterStatusBanner({
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
      return const LinearProgressIndicator(
        color: AppColors.primaryContainer,
        backgroundColor: AppColors.surfaceHigh,
      );
    }
    if (error == null) return const SizedBox.shrink();
    return HfCard(
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Icon(
            live ? Icons.cloud_done : Icons.cloud_off,
            size: 18,
            color: live ? AppColors.secondary : AppColors.primaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              live ? 'Live roster' : 'Showing design preview — $error',
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDriverCard extends StatelessWidget {
  const _LiveDriverCard({required this.driver});

  final FleetDriver driver;

  @override
  Widget build(BuildContext context) {
    final active = driver.status == 'ACTIVE';
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.airline_seat_recline_normal,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      driver.phone.isEmpty ? (driver.email ?? '—') : driver.phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (active ? AppColors.secondary : AppColors.tertiary)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  driver.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.secondary : AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metaChip('KYC', driver.kycStatus),
              const SizedBox(width: 8),
              _metaChip(
                'Verified',
                driver.isVerified ? 'YES' : 'NO',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label · $value',
        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final String hint;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(icon, size: 40, color: accent.withValues(alpha: 0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.32,
                  color: AppColors.onSurface,
                ),
              ),
              Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverDawitCard extends StatelessWidget {
  const _DriverDawitCard();

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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.airline_seat_recline_normal, color: AppColors.primary, size: 28),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: AppColors.onSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dawit Wolde',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 12, color: AppColors.primary),
                        const Text(' 4.98', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                    const Text(
                      '310 Completed Corridors • Senior Captain',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'In Transit • 68 km/h',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
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
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('ET-3-4412', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Text(
                      'FAW J5P 32T Heavy Haul',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.alt_route, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                          children: [
                            const TextSpan(text: 'Addis Ababa', style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(text: ' → ', style: TextStyle(color: AppColors.primary)),
                            const TextSpan(text: 'Hawassa', style: TextStyle(fontWeight: FontWeight.w500)),
                            const TextSpan(
                              text: ' (Industrial Park Textile Run)',
                              style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _badge(Icons.local_fire_department, 'Dangerous Goods Hazmat Certified', AppColors.primary),
              _badge(Icons.shield, 'Zero Incidents 24 Mo', AppColors.secondary),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi, size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    'GPS Lock: Mojo Expressway KM 84',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              Text(
                'ETA: 2h 15m',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color == AppColors.secondary ? color : AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _DriverBirhanuCard extends StatelessWidget {
  const _DriverBirhanuCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(height: 4, color: AppColors.primary),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 28),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.priority_high, size: 10, color: AppColors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Birhanu Bekele',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, size: 12, color: AppColors.primary),
                              const Text(' 4.82', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                            ],
                          ),
                          const Text(
                            '185 Corridors • Grade-B Master',
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: AppColors.tertiary),
                          SizedBox(width: 6),
                          Text('On Standby', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
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
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('ET-3-9031', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          Text(
                            'Scania R420 Euro 4',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.warehouse, size: 18, color: AppColors.onSurfaceVariant),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stationed: Kaliti Logistics Terminal Yard #4',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MoT Commercial License expires in 8 days',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Mandatory bi-annual cardiovascular & vision renewal needed before corridor assignment.',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surfaceHigh,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.medical_services, size: 18),
                    label: Text(
                      'Trigger Medical Recertification',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
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

class _DriverKassahunCard extends StatelessWidget {
  const _DriverKassahunCard();

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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.airline_seat_recline_normal, color: AppColors.primary, size: 28),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: AppColors.onSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kassahun Tadesse',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 12, color: AppColors.primary),
                        const Text(' 4.95', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                    const Text(
                      '240 Corridors • Djibouti Line Specialist',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Customs Cleared',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
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
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('ET-3-8821', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Text(
                      'SinoTruk HOWO A7',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.share_location, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                          children: [
                            const TextSpan(text: 'Mojo Dry Port', style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(text: ' → ', style: TextStyle(color: AppColors.primary)),
                            const TextSpan(text: 'Djibouti Port', style: TextStyle(fontWeight: FontWeight.w500)),
                            const TextSpan(
                              text: ' (Galafi Checkpoint)',
                              style: TextStyle(fontSize: 10, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _badge(Icons.flag, 'COMESA Yellow Card Active', AppColors.secondary),
              _badge(Icons.qr_code_scanner, 'Single Customs Declaration Logged', AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.satellite_alt, size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    'Live GPS Feed Connected',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              Text(
                'Clearance Verified',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

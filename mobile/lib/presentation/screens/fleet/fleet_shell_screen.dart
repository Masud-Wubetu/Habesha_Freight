import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/screens/fleet/analytics_hub_screen.dart';
import 'package:mobile/presentation/screens/fleet/dispatch_matrix_screen.dart';
import 'package:mobile/presentation/screens/fleet/driver_roster_screen.dart';
import 'package:mobile/presentation/screens/fleet/escrow_batch_screen.dart';
import 'package:mobile/presentation/screens/fleet/fleet_command_hub_screen.dart';
import 'package:mobile/presentation/screens/fleet/fuel_toll_screen.dart';
import 'package:mobile/presentation/screens/fleet/maintenance_orders_screen.dart';
import 'package:mobile/presentation/screens/fleet/rig_telemetry_screen.dart';
import 'package:mobile/presentation/screens/ops/border_pass_screen.dart';
import 'package:mobile/presentation/screens/ops/cold_chain_screen.dart';
import 'package:mobile/presentation/screens/ops/compliance_audit_screen.dart';
import 'package:mobile/presentation/screens/ops/customs_hub_screen.dart';
import 'package:mobile/presentation/screens/ops/intermodal_hub_screen.dart';
import 'package:mobile/presentation/screens/ops/weighbridge_screen.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';

/// Fleet / ops mobile shell: pages 27–40 catalog + bottom tabs.
class FleetShellScreen extends StatefulWidget {
  const FleetShellScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<FleetShellScreen> createState() => _FleetShellScreenState();
}

class _FleetShellScreenState extends State<FleetShellScreen> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  static const _tabs = [
    _TabSpec('Command', Icons.dashboard_outlined, Icons.dashboard),
    _TabSpec('Fleet', Icons.local_shipping_outlined, Icons.local_shipping),
    _TabSpec('More', Icons.grid_view_outlined, Icons.grid_view),
    _TabSpec('Finance', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
    _TabSpec('Ops', Icons.hub_outlined, Icons.hub),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _tab,
        children: [
          const FleetCommandHubScreen(),
          const DriverRosterScreen(),
          _MoreCatalog(onOpen: _open),
          const EscrowBatchScreen(),
          _OpsCatalog(onOpen: _open),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLowest,
          border: Border(top: BorderSide(color: AppColors.surfaceBright)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _tab == i;
                final spec = _tabs[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? spec.activeIcon : spec.icon,
                          size: 22,
                          color: selected
                              ? AppColors.primaryContainer
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          spec.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? AppColors.primaryContainer
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _open(String route) {
    final map = <String, WidgetBuilder>{
      AppRoutes.page28RigTelemetry: (_) => const RigTelemetryScreen(),
      AppRoutes.page30DispatchMatrix: (_) => const DispatchMatrixScreen(),
      AppRoutes.page32FuelToll: (_) => const FuelTollScreen(),
      AppRoutes.page33Maintenance: (_) => const MaintenanceOrdersScreen(),
      AppRoutes.page34Analytics: (_) => const AnalyticsHubScreen(),
      AppRoutes.page35Customs: (_) => const CustomsHubScreen(),
      AppRoutes.page36BorderPass: (_) => const BorderPassScreen(),
      AppRoutes.page37Weighbridge: (_) => const WeighbridgeScreen(),
      AppRoutes.page38Compliance: (_) => const ComplianceAuditScreen(),
      AppRoutes.page39ColdChain: (_) => const ColdChainScreen(),
      AppRoutes.page40Intermodal: (_) => const IntermodalHubScreen(),
    };
    final builder = map[route];
    if (builder == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _MoreCatalog extends StatelessWidget {
  const _MoreCatalog({required this.onOpen});
  final void Function(String route) onOpen;

  @override
  Widget build(BuildContext context) {
    final items = [
      _CatalogItem('28', 'Rig Telemetry', 'CAN-bus & immobilizer', AppRoutes.page28RigTelemetry, Icons.sensors),
      _CatalogItem('30', 'Dispatch Matrix', 'Assign empty trucks', AppRoutes.page30DispatchMatrix, Icons.route),
      _CatalogItem('32', 'Fuel & Toll Pass', 'QR vouchers & RFID', AppRoutes.page32FuelToll, Icons.local_gas_station),
      _CatalogItem('33', 'Workshop Orders', 'Preventive maintenance', AppRoutes.page33Maintenance, Icons.build_circle_outlined),
      _CatalogItem('34', 'Corridor Analytics', 'Revenue & dwell time', AppRoutes.page34Analytics, Icons.insights),
    ];
    return _CatalogScaffold(
      ribbonPage: '27+',
      ribbonTitle: 'FLEET ASSET COMMAND',
      ribbonStatus: 'Pages 28–34',
      heading: 'Fleet modules',
      items: items,
      onOpen: onOpen,
    );
  }
}

class _OpsCatalog extends StatelessWidget {
  const _OpsCatalog({required this.onOpen});
  final void Function(String route) onOpen;

  @override
  Widget build(BuildContext context) {
    final items = [
      _CatalogItem('35', 'Customs Manifest', 'ASYCUDA declarations', AppRoutes.page35Customs, Icons.description_outlined),
      _CatalogItem('36', 'Border Pass QR', 'Galafi / Dewele gate', AppRoutes.page36BorderPass, Icons.qr_code_2),
      _CatalogItem('37', 'Weighbridge', 'Axle load telemetry', AppRoutes.page37Weighbridge, Icons.scale),
      _CatalogItem('38', 'Compliance Audit', 'COMESA & EIC cover', AppRoutes.page38Compliance, Icons.policy_outlined),
      _CatalogItem('39', 'Cold Chain', 'Reefer IoT telemetry', AppRoutes.page39ColdChain, Icons.ac_unit),
      _CatalogItem('40', 'Intermodal Hub', 'Rail & Mojo dry port', AppRoutes.page40Intermodal, Icons.train),
    ];
    return _CatalogScaffold(
      ribbonPage: '35+',
      ribbonTitle: 'CUSTOMS & INTERMODAL',
      ribbonStatus: 'Pages 35–40',
      heading: 'Corridor operations',
      items: items,
      onOpen: onOpen,
    );
  }
}

class _CatalogItem {
  const _CatalogItem(this.page, this.title, this.subtitle, this.route, this.icon);
  final String page;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}

class _CatalogScaffold extends StatelessWidget {
  const _CatalogScaffold({
    required this.ribbonPage,
    required this.ribbonTitle,
    required this.ribbonStatus,
    required this.heading,
    required this.items,
    required this.onOpen,
  });

  final String ribbonPage;
  final String ribbonTitle;
  final String ribbonStatus;
  final String heading;
  final List<_CatalogItem> items;
  final void Function(String route) onOpen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          PageRibbon(page: ribbonPage, title: ribbonTitle, status: ribbonStatus),
          const SizedBox(height: 16),
          Text(
            heading,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stitch Nocturne Corridor · HabeshaFreight mobile',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HfCard(
                onTap: () => onOpen(item.route),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAGE ${item.page}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            item.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

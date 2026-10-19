import 'package:flutter/material.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth_gate.dart';
import 'presentation/screens/fleet/analytics_hub_screen.dart';
import 'presentation/screens/fleet/dispatch_matrix_screen.dart';
import 'presentation/screens/fleet/driver_roster_screen.dart';
import 'presentation/screens/fleet/escrow_batch_screen.dart';
import 'presentation/screens/fleet/fleet_command_hub_screen.dart';
import 'presentation/screens/fleet/fleet_shell_screen.dart';
import 'presentation/screens/fleet/fuel_toll_screen.dart';
import 'presentation/screens/fleet/maintenance_orders_screen.dart';
import 'presentation/screens/fleet/rig_telemetry_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/ops/border_pass_screen.dart';
import 'presentation/screens/ops/cold_chain_screen.dart';
import 'presentation/screens/ops/compliance_audit_screen.dart';
import 'presentation/screens/ops/customs_hub_screen.dart';
import 'presentation/screens/ops/intermodal_hub_screen.dart';
import 'presentation/screens/ops/weighbridge_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabeshaFreightApp());
}

class HabeshaFreightApp extends StatelessWidget {
  const HabeshaFreightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Auth → fleet/ops shell (pages 27–40, stitch Nocturne Corridor)
      home: const AuthGate(),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.fleetHub: (_) => const FleetShellScreen(),
        AppRoutes.page27FleetCommand: (_) => const FleetCommandHubScreen(),
        AppRoutes.page28RigTelemetry: (_) => const RigTelemetryScreen(),
        AppRoutes.page29DriverRoster: (_) => const DriverRosterScreen(),
        AppRoutes.page30DispatchMatrix: (_) => const DispatchMatrixScreen(),
        AppRoutes.page31EscrowBatch: (_) => const EscrowBatchScreen(),
        AppRoutes.page32FuelToll: (_) => const FuelTollScreen(),
        AppRoutes.page33Maintenance: (_) => const MaintenanceOrdersScreen(),
        AppRoutes.page34Analytics: (_) => const AnalyticsHubScreen(),
        AppRoutes.page35Customs: (_) => const CustomsHubScreen(),
        AppRoutes.page36BorderPass: (_) => const BorderPassScreen(),
        AppRoutes.page37Weighbridge: (_) => const WeighbridgeScreen(),
        AppRoutes.page38Compliance: (_) => const ComplianceAuditScreen(),
        AppRoutes.page39ColdChain: (_) => const ColdChainScreen(),
        AppRoutes.page40Intermodal: (_) => const IntermodalHubScreen(),
      },
    );
  }
}

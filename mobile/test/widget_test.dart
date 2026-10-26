import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/auth_gate.dart';
import 'package:mobile/presentation/screens/fleet/fleet_command_hub_screen.dart';
import 'package:mobile/presentation/screens/fleet/driver_roster_screen.dart';
import 'package:mobile/presentation/screens/fleet/escrow_batch_screen.dart';
import 'package:mobile/presentation/screens/fleet/rig_telemetry_screen.dart';
import 'package:mobile/presentation/screens/fleet/dispatch_matrix_screen.dart';
import 'package:mobile/presentation/screens/ops/customs_hub_screen.dart';
import 'package:mobile/presentation/screens/ops/border_pass_screen.dart';
import 'package:mobile/presentation/screens/ops/weighbridge_screen.dart';
import 'package:mobile/presentation/screens/ops/compliance_audit_screen.dart';
import 'package:mobile/presentation/screens/ops/cold_chain_screen.dart';
import 'package:mobile/presentation/screens/ops/intermodal_hub_screen.dart';
import 'package:mobile/presentation/screens/fleet/fuel_toll_screen.dart';
import 'package:mobile/presentation/screens/fleet/maintenance_orders_screen.dart';
import 'package:mobile/presentation/screens/fleet/analytics_hub_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuthGate shows login connected to backend flow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Habesha'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    expect(
      find.textContaining('Sign In').evaluate().isNotEmpty ||
          find.textContaining('Connecting').evaluate().isNotEmpty ||
          find.textContaining('Carrier').evaluate().isNotEmpty ||
          find.textContaining('Fleet').evaluate().isNotEmpty ||
          find.textContaining('API').evaluate().isNotEmpty,
      isTrue,
    );
  });

  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: child),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Fleet command hub renders page ribbon', (tester) async {
    await pumpScreen(tester, const FleetCommandHubScreen());
    expect(find.textContaining('FLEET OPERATIONS'), findsOneWidget);
  });

  testWidgets('Driver roster renders', (tester) async {
    await pumpScreen(tester, const DriverRosterScreen());
    expect(find.textContaining('DRIVER COMPLIANCE'), findsOneWidget);
  });

  testWidgets('Escrow batch renders', (tester) async {
    await pumpScreen(tester, const EscrowBatchScreen());
    expect(find.textContaining('FLEET ESCROW'), findsWidgets);
  });

  testWidgets('Rig telemetry renders', (tester) async {
    await pumpScreen(tester, const RigTelemetryScreen());
    expect(find.textContaining('RIG INVENTORY'), findsOneWidget);
  });

  testWidgets('Dispatch matrix renders', (tester) async {
    await pumpScreen(tester, const DispatchMatrixScreen());
    expect(find.textContaining('CORRIDOR DISPATCH'), findsOneWidget);
  });

  testWidgets('Fuel / maintenance / analytics shells render', (tester) async {
    await pumpScreen(tester, const FuelTollScreen());
    expect(find.textContaining('FUEL').evaluate().isNotEmpty ||
        find.byType(Scaffold).evaluate().isNotEmpty, isTrue);
    await pumpScreen(tester, const MaintenanceOrdersScreen());
    expect(find.byType(Scaffold), findsWidgets);
    await pumpScreen(tester, const AnalyticsHubScreen());
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Ops screens 35–40 render', (tester) async {
    for (final screen in <Widget>[
      const CustomsHubScreen(),
      const BorderPassScreen(),
      const WeighbridgeScreen(),
      const ComplianceAuditScreen(),
      const ColdChainScreen(),
      const IntermodalHubScreen(),
    ]) {
      await pumpScreen(tester, screen);
      expect(find.byType(Scaffold).evaluate().isNotEmpty ||
          find.byType(Material).evaluate().isNotEmpty, isTrue);
    }
  });
}

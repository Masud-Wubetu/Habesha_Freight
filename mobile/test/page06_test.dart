import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page06.dart';

void main() {
  Widget createTestWidget({
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? shipments,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Page06Screen(
        initialProfile: profile,
        initialShipments: shipments,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 06 renders empty state cleanly for a new registered shipper',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      profile: {
        'full_name': 'Masud Wubetu',
        'company_name': 'Habesha Logistics PLC',
        'stats': {
          'active_loads': 0,
          'completed_loads': 0,
          'in_escrow_etb': 0,
        },
      },
      shipments: [],
    ));
    await tester.pumpAndSettle();

    // Verify User Info
    expect(find.text('Masud Wubetu'), findsOneWidget);
    expect(find.text('Habesha Logistics PLC'), findsOneWidget);

    // Verify Empty State & CTAs
    expect(find.text('No Active Consignments'), findsOneWidget);
    expect(find.text('Post Cargo Request'), findsAtLeastNWidgets(1));
    expect(find.text('0 ETB'), findsOneWidget);

    // Verify no fake names or wireframe page ribbons
    expect(find.text('Selamawit Tadesse'), findsNothing);
    expect(find.text('Dawit Kebede'), findsNothing);
    expect(find.textContaining('PAGE 06'), findsNothing);
  });

  testWidgets('Page 06 displays Live Transit card when shipper has an active shipment',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      profile: {
        'full_name': 'Masud Wubetu',
        'company_name': 'Habesha Logistics PLC',
        'stats': {
          'active_loads': 1,
          'completed_loads': 4,
          'in_escrow_etb': 85000,
        },
      },
      shipments: [
        {
          'id': 'ET-9921',
          'status': 'in_transit',
          'origin_city': 'Addis Ababa (Kality Port)',
          'destination_city': 'Djibouti Port (PK12)',
          'driver_name': 'Abebe Bikila',
          'license_plate': 'ET-3-88192',
        }
      ],
    ));
    await tester.pumpAndSettle();

    // Verify Active Load Card
    expect(find.text('Masud Wubetu'), findsOneWidget);
    expect(find.text('Live Transit'), findsOneWidget);
    expect(find.text('Addis Ababa (Kality Port)'), findsOneWidget);
    expect(find.text('Djibouti Port (PK12)'), findsOneWidget);
    expect(find.text('Driver: Abebe Bikila'), findsOneWidget);
    expect(find.text('85k ETB'), findsOneWidget);
  });
}

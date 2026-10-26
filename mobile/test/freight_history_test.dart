import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper/freight_history_screen.dart';

void main() {
  Widget createTestWidget({List<ShipmentHistoryEntry>? shipments}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: FreightHistoryScreen(initialShipments: shipments),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('FreightHistoryScreen renders empty state cleanly for a new registered shipper',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(shipments: []));
    await tester.pumpAndSettle();

    // Verify Title & Empty State
    expect(find.text('Freight History'), findsOneWidget);
    expect(find.text('0 Completed'), findsOneWidget);
    expect(find.text('No Freight History Yet'), findsOneWidget);
    expect(find.text('Post Cargo Request'), findsOneWidget);

    // Verify no fake names or numbers
    expect(find.text('Kassahun Berhanu'), findsNothing);
    expect(find.text('45 Completed'), findsNothing);
    expect(find.text('1,250,000'), findsNothing);
    expect(find.text('Load Older Corridors (42 more)'), findsNothing);
  });

  testWidgets('FreightHistoryScreen renders shipment entry accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      shipments: const [
        ShipmentHistoryEntry(
          id: 'WB-99120',
          date: '2026-10-20',
          routeFrom: 'Addis Ababa',
          routeTo: 'Djibouti FTZ',
          cargo: '24T Export Harar Coffee',
          amount: '68,000',
          status: 'DELIVERED',
          driverName: 'Tesfaye Belay',
          truckInfo: 'Rig • ET-3-99124',
          rating: '5.0',
        ),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('1 Completed'), findsOneWidget);
    expect(find.text('WB-99120'), findsOneWidget);
    expect(find.text('Addis Ababa'), findsOneWidget);
    expect(find.text('Djibouti FTZ'), findsOneWidget);
    expect(find.text('Tesfaye Belay'), findsOneWidget);
    expect(find.text('68,000'), findsAtLeastNWidgets(1));
    expect(find.text('Download PDF Receipt'), findsOneWidget);
  });
}

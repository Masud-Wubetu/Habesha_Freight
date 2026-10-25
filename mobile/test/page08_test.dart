import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/corridor_shipment_item.dart';
import 'package:mobile/presentation/screens/shipper_features/page08.dart';

void main() {
  Widget createTestWidget({List<CorridorShipmentItem>? shipments}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Page08Screen(initialShipments: shipments),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 08 (My Shipments) renders branding header and cargo tracker ribbon',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(shipments: CorridorShipmentItem.demoShipments));
    await tester.pumpAndSettle();

    // Brand Header
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('HabeshaFreight'),
      ),
      findsOneWidget,
    );
    expect(find.text('LOGISTICS EXCHANGE'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Sub-header and Title
    expect(find.text('SHIPPER CARGO TRACKER'), findsOneWidget);
    expect(find.text('My Shipments'), findsOneWidget);
  });

  testWidgets('Page 08 renders search bar, filter tabs, and shipment items',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(shipments: CorridorShipmentItem.demoShipments));
    await tester.pumpAndSettle();

    // Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Bidding'), findsOneWidget);
    expect(find.text('Delivered'), findsAtLeastNWidgets(1));

    // Shipment Item cards
    expect(find.text('#HF-9012'), findsOneWidget);
    expect(find.text('Addis Ababa'), findsAtLeastNWidgets(1));
    expect(find.text('Dire Dawa'), findsAtLeastNWidgets(1));
  });

  testWidgets('Page 08 renders clean empty state when no shipments exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(shipments: []));
    await tester.pumpAndSettle();

    expect(find.text('No Shipments Yet'), findsOneWidget);
    expect(find.text('Post Cargo Load'), findsOneWidget);
  });
}

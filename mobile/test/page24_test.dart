import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page24.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const MyShipmentsScreen(),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 24 renders header, telemetry badge, and branding',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify brand header
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('HabeshaFreight'),
      ),
      findsOneWidget,
    );
    expect(find.text('LOGISTICS EXCHANGE'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Verify telemetry title and badge
    expect(find.text('ACTIVE FLEET TELEMETRY'), findsOneWidget);
    expect(find.text('My Shipments'), findsOneWidget);
    expect(find.text('3 Live En-Route'), findsOneWidget);
    expect(
      find.text('Real-time GPS corridor tracking and cargo negotiation hub'),
      findsOneWidget,
    );
  });

  testWidgets('Page 24 renders search bar and all 4 status filter tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify search hint
    expect(
      find.text('Filter by corridor, cargo ID, or driver...'),
      findsOneWidget,
    );

    // Verify filter tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('(12)'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('(3)'), findsOneWidget);
    expect(find.text('Bidding'), findsOneWidget);
    expect(find.text('(5)'), findsOneWidget);
    expect(find.text('Delivered'), findsNWidgets(2)); // Filter tab + Card 4 badge
    expect(find.text('(4)'), findsOneWidget);
  });

  testWidgets('Page 24 renders Key Corridor Telemetry radar card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Key Corridor Telemetry'), findsOneWidget);
    expect(find.text('Live Radar'), findsNWidgets(2)); // Card badge + In-transit button
    expect(find.text('Addis Ababa Hub (A)'), findsOneWidget);
    expect(find.text('Dire Dawa (B)'), findsOneWidget);
    expect(find.text('22°C Awash'), findsOneWidget);
    expect(find.text('Est. Remaining: 112 km'), findsOneWidget);
    expect(find.text('Departure: 05:30 AM'), findsOneWidget);
    expect(find.text('Arrival: 02:45 PM'), findsOneWidget);
  });

  testWidgets('Page 24 renders all 4 multi-state shipment cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Card 1: In Transit #HF-9012
    expect(find.text('#HF-9012'), findsOneWidget);
    expect(find.text('Dry Bulk • Grain'), findsOneWidget);
    expect(find.text('In Transit'), findsOneWidget);
    expect(find.text('Tewodros Kassaye'), findsOneWidget);
    expect(find.text('68 km/h'), findsOneWidget);

    // Card 2: Bidding #HF-8841
    expect(find.text('#HF-8841'), findsOneWidget);
    expect(find.text('General Cargo • FMCG'), findsOneWidget);
    expect(find.text('5 Bids Active'), findsOneWidget);
    expect(find.text('18,500'), findsOneWidget);
    expect(find.text('Review Bids'), findsOneWidget);

    // Card 3: Awaiting Dispatch #HF-7720
    expect(find.text('#HF-7720'), findsOneWidget);
    expect(find.text('Agricultural • Coffee Bags'), findsOneWidget);
    expect(find.text('Awaiting Dispatch'), findsOneWidget);
    expect(find.text('Manifest Pass'), findsOneWidget);
    expect(find.text('Cargo Insured (NIC)'), findsOneWidget);

    // Card 4: Delivered #HF-6504
    expect(find.text('#HF-6504'), findsOneWidget);
    expect(find.text('Construction • Rebar 40T'), findsOneWidget);
    expect(find.text('Delivered'), findsNWidgets(2)); // Status badge + Filter pill
    expect(find.text('POD Receipt'), findsOneWidget);
  });

  testWidgets('Page 24 filters list when selecting filter tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Active tab
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    expect(find.text('#HF-9012'), findsOneWidget);
    expect(find.text('#HF-8841'), findsNothing);
    expect(find.text('#HF-7720'), findsNothing);

    // Tap Bidding tab
    await tester.tap(find.text('Bidding'));
    await tester.pumpAndSettle();

    expect(find.text('#HF-8841'), findsOneWidget);
    expect(find.text('#HF-9012'), findsNothing);

    // Tap All tab
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('#HF-9012'), findsOneWidget);
    expect(find.text('#HF-8841'), findsOneWidget);
  });

  testWidgets('Page 24 opens manifest pass modal and call driver modal',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Manifest Pass button
    await tester.tap(find.text('Manifest Pass'));
    await tester.pumpAndSettle();

    expect(find.text('Digital Manifest Pass'), findsOneWidget);
    expect(find.text('Consignment: #HF-7720'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Digital Manifest Pass'), findsNothing);

    // Tap Call Driver button
    final phoneBtn = find.byIcon(Icons.phone_rounded);
    expect(phoneBtn, findsOneWidget);
    await tester.tap(phoneBtn);
    await tester.pumpAndSettle();

    expect(find.text('Calling Carrier Driver'), findsOneWidget);
    expect(find.text('End Call'), findsOneWidget);

    // Dismiss call modal
    await tester.tap(find.text('End Call'));
    await tester.pumpAndSettle();

    expect(find.text('Calling Carrier Driver'), findsNothing);
  });
}

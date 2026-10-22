import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page10.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Page10Screen(enableAnimation: false),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 10 renders branding header and sub-header ribbon',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
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

    // Sub-header Ribbon
    expect(find.text('LIVE TELEMETRY'), findsOneWidget);
    expect(find.text('#HF-8841-ET'), findsOneWidget);
  });

  testWidgets('Page 10 renders Corridor Telemetry Radar Card and route schematic',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Card Header
    expect(find.text('CORRIDOR\nTELEMETRY'), findsOneWidget);
    expect(find.text('GPS\nActive'), findsOneWidget);

    // Origin and Destination tags on map
    expect(find.text('Addis Ababa'), findsAtLeastNWidgets(1));
    expect(find.text('Departed 04:30'), findsOneWidget);
    expect(find.text('Awash Corridor'), findsOneWidget);
    expect(find.text('Next Port Drop'), findsOneWidget);

    // Truck Marker and Coordinates
    expect(find.text('Driver (Cruising)'), findsOneWidget);
    expect(find.text('LAT: 9.02, LNG: 39.80'), findsOneWidget);

    // Route Schematic
    expect(find.text('Optimal'), findsOneWidget);
  });

  testWidgets('Page 10 renders 3 Telemetry Metrics and IoT Sensor Integrity Row',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Metrics Row
    expect(find.text('SPEED'), findsOneWidget);
    expect(find.text('Cruising'), findsOneWidget);
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('140 km'), findsOneWidget);
    expect(find.text('to Awash'), findsOneWidget);
    expect(find.text('EST. ARRIVAL'), findsOneWidget);
    expect(find.text('2h 30m'), findsOneWidget);
    expect(find.text('On Schedule'), findsOneWidget);

    // IoT Sensor Row
    expect(find.text('COLD CHAIN'), findsOneWidget);
    expect(find.text('-5°C'), findsOneWidget);
    expect(find.text('E-SEAL'), findsOneWidget);
    expect(find.text('SECURE'), findsOneWidget);
    expect(find.text('#SEAL-4401'), findsOneWidget);
  });

  testWidgets('Page 10 renders Driver Contact Card and opens Chat Modal',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Driver Card
    expect(find.text('Solomon Tekle'), findsOneWidget);
    expect(find.text('Sinotruk HOWO 30T • Plate 3-824901'), findsOneWidget);
    expect(find.text('4.92'), findsOneWidget);
    expect(find.text('+251 911 482 109'), findsOneWidget);

    // Tap Chat button
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.pumpAndSettle();

    // Chat Modal should be visible
    expect(find.text('Message driver Solomon...'), findsOneWidget);
    expect(
      find.text('Departed Addis Ababa Kality terminal. Transit documents signed.'),
      findsOneWidget,
    );
  });

  testWidgets('Page 10 opens Share Live Tracking Modal on button tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Share button
    expect(find.text('Share Live Tracking Link'), findsOneWidget);

    // Tap Share button
    await tester.tap(find.text('Share Live Tracking Link'));
    await tester.pumpAndSettle();

    // Modal elements
    expect(find.text('Share Live Tracking'), findsOneWidget);
    expect(
      find.text('https://track.habeshafreight.et/live/HF-8841-ET'),
      findsOneWidget,
    );
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Send via SMS'), findsOneWidget);
    expect(find.text('Telegram Bot'), findsOneWidget);
  });
}

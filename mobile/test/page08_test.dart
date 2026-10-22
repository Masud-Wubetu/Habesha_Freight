import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page08.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Page08Screen(),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 08 (My Shipments) renders branding header and telemetry ribbon',
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

    // Sub-header and Title
    expect(find.text('ACTIVE FLEET TELEMETRY'), findsOneWidget);
    expect(find.text('My Shipments'), findsOneWidget);
    expect(find.text('3 Live En-Route'), findsOneWidget);
  });

  testWidgets('Page 08 renders Corridor Telemetry Radar Card and search bar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Radar Card elements
    expect(find.text('Key Corridor Telemetry'), findsOneWidget);
    expect(find.text('Live Radar'), findsAtLeastNWidgets(1));

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
}

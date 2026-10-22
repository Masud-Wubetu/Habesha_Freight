import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page23.dart';

void main() {
  Widget createTestWidget({String initialLanguage = 'EN'}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ProofOfDeliveryInspectionScreen(
        initialLanguage: initialLanguage,
        enableAnimation: false,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
      'Page 23 renders app bar, sub-header pills, and shipment route card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // App Bar
    expect(find.text('Proof Of Delivery Inspection'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);

    // Sub-header pills
    expect(
      find.text('PAGE 23: PROOF OF DELIVERY INSPECTION'),
      findsOneWidget,
    );
    expect(find.text('LIVE OPS'), findsOneWidget);

    // Shipment & Route Card
    expect(find.text('REQ-9840'), findsOneWidget);
    expect(find.text('32 MT Dry Bulk Cargo'), findsOneWidget);
    expect(find.text('ORIGIN'), findsOneWidget);
    expect(find.text('Kaliti Logistics ...'), findsOneWidget);
    expect(find.text('DESTINATION'), findsOneWidget);
    expect(find.text('Mekelle Indust...'), findsOneWidget);
  });

  testWidgets(
      'Page 23 displays Arrival & Geofence Verified card accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('ARRIVED AT DESTINATION'), findsOneWidget);
    expect(
      find.text('Bay 12 South, Mekelle Industrial Park'),
      findsOneWidget,
    );
    expect(find.text('14:22 EAT'), findsOneWidget);
    expect(find.text('Geofence Verified (±4m)'), findsOneWidget);
  });

  testWidgets(
      'Page 23 displays all 4 Inspection Checklist items and allows toggling',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Section Header
    expect(find.text('Inspection Checklist'), findsOneWidget);
    expect(find.text('4 / 4 Cleared'), findsOneWidget);
    expect(find.text('Mandatory'), findsOneWidget);

    // Checklist Items
    expect(find.text('Customs Seal Integrity'), findsOneWidget);
    expect(find.text('Seal #ET-9941 Intact & Verified'), findsOneWidget);
    expect(find.text('Verified'), findsNWidgets(2)); // Item 1 & Item 3

    expect(find.text('Tarpaulin Condition'), findsOneWidget);
    expect(find.text('Dry bulk waterproof • No ingress'), findsOneWidget);
    expect(find.text('Passed'), findsNWidgets(2)); // Item 2 & Item 4

    expect(find.text('Quantity Reconciliation'), findsOneWidget);
    expect(find.text('640 of 640 Bags Counted Mat...'), findsOneWidget);

    expect(find.text('Transit Shock & Structural'), findsOneWidget);
    expect(find.text('Zero payload spillage or tears'), findsOneWidget);

    // Tap Item 1 to toggle to Unverified
    await tester.tap(find.text('Customs Seal Integrity'));
    await tester.pumpAndSettle();

    expect(find.text('3 / 4 Cleared'), findsOneWidget);
    expect(find.text('Unverified'), findsOneWidget);

    // Tap Item 1 again to verify
    await tester.tap(find.text('Customs Seal Integrity'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 4 Cleared'), findsOneWidget);
  });

  testWidgets(
      'Page 23 photographic evidence displays cards and captures offload proof',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Photographic Evidence'), findsOneWidget);
    expect(find.text('2 of 3 captured'), findsOneWidget);
    expect(find.text('Seal Cut (#ET-9...'), findsOneWidget);
    expect(find.text('Cargo in Bay 12'), findsOneWidget);
    expect(find.text('REQUIRED'), findsOneWidget);

    // Tap Add Offload Proof card to open modal
    await tester.tap(find.text('REQUIRED'));
    await tester.pumpAndSettle();

    expect(find.text('Capture Offload Proof'), findsOneWidget);
    expect(find.text('Bay 12 Dock'), findsOneWidget);

    // Tap camera capture button
    await tester.tap(find.text('Simulate Camera Shutter Capture'));
    await tester.pumpAndSettle();

    // Proof now captured
    expect(find.text('3 of 3 captured'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
  });

  testWidgets(
      'Page 23 receiving agent handover card, call action, and proceed button work',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Handover card
    expect(find.text('RECEIVING AGENT HANDOVER'), findsOneWidget);
    expect(find.text('On-Site'), findsOneWidget);
    expect(find.text('MT'), findsOneWidget);
    expect(find.text('Mulugeta Tesfaye'), findsOneWidget);
    expect(
      find.text('Warehouse Supervisor • Mekelle De...'),
      findsOneWidget,
    );
    expect(find.text('ID: MK-DEPOT-882'), findsOneWidget);
    expect(find.text('+251 91 234 5678'), findsOneWidget);

    // Call button
    await tester.tap(find.byIcon(Icons.phone_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Call Receiving Agent'), findsOneWidget);
    await tester.tap(find.text('Call Receiving Agent'));
    await tester.pumpAndSettle();

    // Proceed to e-POD Signature (Page 24) button
    final proceedBtn = find.text('Proceed to e-POD Signature (Page 24)');
    expect(proceedBtn, findsOneWidget);
    expect(
      find.text('Tamper-evident chain of custody cryptographic sealing'),
      findsOneWidget,
    );

    await tester.tap(proceedBtn);
    await tester.pumpAndSettle();

    expect(find.text('Proceed to e-POD Signature'), findsOneWidget);
    expect(find.text('Open Page 24'), findsOneWidget);
    await tester.tap(find.text('Open Page 24'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 23 toggles language between English and Amharic seamlessly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap language toggle
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('አማ'), findsOneWidget);
    expect(find.text('የጭነት ማስረከቢያ ፍተሻ'), findsOneWidget);
    expect(find.text('መድረሻው ላይ ደርሷል'), findsOneWidget);
    expect(find.text('የፍተሻ ማረጋገጫ ዝርዝር'), findsOneWidget);
    expect(find.text('የጉምሩክ ማሸጊያ ታማኝነት'), findsOneWidget);
    expect(find.text('የተቀባይ ወኪል ርክክብ'), findsOneWidget);
    expect(find.text('በቦታው ይገኛሉ'), findsOneWidget);
  });
}

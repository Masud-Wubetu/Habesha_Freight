import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page24.dart';

void main() {
  Widget createTestWidget({String initialLanguage = 'EN'}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: EPodSignatureScreen(
        initialLanguage: initialLanguage,
        enableAnimation: false,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
      'Page 24 renders app bar, sub-header pills, and Consignee route card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // App Bar
    expect(find.text('E Pod Signature Upload'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);

    // Sub-header pills
    expect(
      find.text('PAGE 24: E-POD SIGNATURE & CARGO HANDOVER'),
      findsOneWidget,
    );
    expect(find.text('Live Handover'), findsOneWidget);

    // Consignee & Route Card
    expect(find.text('REQ-9840'), findsOneWidget);
    expect(find.text('Addis Ababa → Mojo Dry Port'), findsOneWidget);
    expect(find.text('CONSIGNEE FACILITY'), findsOneWidget);
    expect(find.text('Ethio Agri-Export Ltd.'), findsOneWidget);
    expect(find.text('640 Export Grade Bags'), findsOneWidget);
    expect(find.text('Full Transit Insured'), findsOneWidget);
  });

  testWidgets(
      'Page 24 displays Receiver Official Verification details accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('RECEIVER OFFICIAL VERIFICATION'), findsOneWidget);
    expect(find.text('TIN / ID Validated'), findsOneWidget);
    expect(find.text('Mulugeta Tesfaye'), findsOneWidget);
    expect(find.text('Depot Chief Receiving Officer'), findsOneWidget);
    expect(find.text('TIN: ET-00948219-B • Modjo Hub'), findsOneWidget);
  });

  testWidgets(
      'Page 24 renders Digital Signature Canvas card with stylus telemetry and supports re-sign',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Digital Signature Canvas Header & OTP
    expect(find.text('Digital Signature\nCanvas'), findsOneWidget);
    expect(find.text('OTP 849201'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    // Stylus Telemetry inside Canvas
    expect(find.text('STYLUS CAPTURE 240Hz'), findsOneWidget);
    expect(find.text('Biometric Latency: 12ms'), findsOneWidget);
    expect(find.text('Signed at 14:38 EAT • Oct 11, 2024'), findsOneWidget);
    expect(find.text('Clear / Re-sign'), findsOneWidget);

    // Terminal Tablet Stylus ID
    expect(find.textContaining('HAB-T904-ETH'), findsOneWidget);

    // Tap Clear / Re-sign
    await tester.tap(find.text('Clear / Re-sign'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
      'Page 24 displays Handover Remarks & Notes with working presets and inspect log',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Section title & chips
    expect(find.text('Handover Remarks & Notes'), findsOneWidget);
    expect(find.text('Inspect Log'), findsOneWidget);
    expect(find.text('Preset: Pristine condition'), findsOneWidget);
    expect(find.text('Seals Intact'), findsOneWidget);

    // Initial remarks text
    expect(
      find.text(
        'All 640 bags received in pristine condition. No damages or losses recorded.',
      ),
      findsOneWidget,
    );

    // Tap "Seals Intact" chip
    await tester.tap(find.text('Seals Intact'));
    await tester.pumpAndSettle();

    // Tap "Inspect Log" to open modal
    await tester.tap(find.text('Inspect Log'));
    await tester.pumpAndSettle();

    expect(find.text('Inspection Event Audit Log'), findsOneWidget);
    expect(find.text('Geofence Entry confirmed (Bay 12)'), findsOneWidget);

    // Dismiss modal
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 24 displays Cryptographic Proof & Escrow card and SHA-256 hash',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('CRYPTOGRAPHIC PROOF & ESCROW'), findsOneWidget);
    expect(find.text('Tamper-Proof'), findsOneWidget);
    expect(
      find.text(
        'SHA-256: 8f4b62d87e1a0b3c59e74d12aa9820f1249b65e94120ca9810ef8c4a938c391',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Irrevocable Handover e-POD Recorded'),
      findsOneWidget,
    );
    expect(find.text('Smart Contract'), findsOneWidget);
    expect(find.text('#4910'), findsOneWidget);
  });

  testWidgets(
      'Page 24 handles Submit e-POD & Authorize Escrow workflow with confirmation dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final submitButton = find.text('Submit e-POD & Authorize Escrow');
    expect(submitButton, findsOneWidget);

    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Confirmation dialog
    expect(find.text('Confirm e-POD & Release Escrow'), findsOneWidget);
    expect(find.text('45,000 ETB'), findsOneWidget);
    expect(find.text('Confirm & Release'), findsOneWidget);

    // Tap Confirm & Release
    await tester.tap(find.text('Confirm & Release'));
    await tester.pumpAndSettle();

    expect(find.text('Escrow Released Successfully ✓'), findsOneWidget);
  });

  testWidgets(
      'Page 24 handles Download PDF Delivery Receipt bottom sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final downloadButton = find.text('Download PDF Delivery Receipt');
    expect(downloadButton, findsOneWidget);

    await tester.ensureVisible(downloadButton);
    await tester.pumpAndSettle();
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();

    // Bottom sheet
    expect(find.text('Official Delivery Receipt'), findsOneWidget);
    expect(find.text('PDF • 1.4 MB'), findsOneWidget);
    expect(find.text('Save Receipt to Device'), findsOneWidget);

    await tester.tap(find.text('Save Receipt to Device'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Page 24 toggles language to Amharic (አማ)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);

    // Toggle language
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('አማ'), findsOneWidget);
    expect(find.text('የ e-POD ፊርማ ማረጋገጫ'), findsOneWidget);
    expect(find.text('ገጽ 24፡ የ e-POD ፊርማ እና የጭነት ርክክብ'), findsOneWidget);
  });
}

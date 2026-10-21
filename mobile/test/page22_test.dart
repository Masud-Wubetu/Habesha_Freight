import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page22.dart';

void main() {
  Widget createTestWidget({String initialLanguage = 'EN'}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: LiveCorridorTrackingScreen(
        initialLanguage: initialLanguage,
        enableAnimation: false,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 22 renders header, brand logo, and Waybill #HF-9012 active run card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Brand Header
    expect(find.text('Habesha'), findsOneWidget);
    expect(find.text('Freight'), findsOneWidget);
    expect(find.text('LOGISTICS EXCHANGE'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Active Corridor Run Card
    expect(find.text('ACTIVE CORRIDOR RUN'), findsOneWidget);
    expect(find.text('Waybill #HF-9012'), findsOneWidget);
    expect(find.text('GPS Locked'), findsOneWidget);
  });

  testWidgets('Page 22 renders A1 transit route map view card and badges',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Floating Map Badges
    expect(find.text('A1 Transit Route'), findsOneWidget);
    expect(find.text('Sat 12/14 Ping'), findsOneWidget);

    // Live Point Floating Card
    expect(find.text('Live Point'), findsOneWidget);
    expect(find.text('Awash National Park Bypass'), findsOneWidget);
    expect(find.text('Bearing'), findsOneWidget);
    expect(find.text('84° '), findsOneWidget);
    expect(find.text('ENE'), findsOneWidget);
  });

  testWidgets('Page 22 displays Corridor Telemetry and all 4 milestone steps',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Telemetry Header
    expect(find.text('Corridor Telemetry'), findsOneWidget);
    expect(find.text('65% Completed'), findsOneWidget);

    // Milestone 1: Addis Ababa
    expect(find.text('Addis Ababa (Kality Hu...)'), findsOneWidget);
    expect(find.text('Departed 05:30 AM EAT'), findsOneWidget);

    // Milestone 2: Adama Expressway
    expect(find.text('Adama Expressway T...'), findsOneWidget);
    expect(find.text('Cleared 07:12 AM EAT'), findsOneWidget);

    // Passed badges (2 passed steps)
    expect(find.text('Passed'), findsNWidgets(2));

    // Milestone 3: Awash Checkpoint
    expect(find.text('Awash Checkpoi...'), findsOneWidget);
    expect(find.text('Cruising: 68 km/h • Weight Scan Queue Clear'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    // Milestone 4: Dire Dawa FTZ
    expect(find.text('Dire Dawa Free Trade Zo...'), findsOneWidget);
    expect(find.text('Scheduled Terminal Gate B'), findsOneWidget);
    expect(find.text('ETA 3h 15m'), findsOneWidget);
  });

  testWidgets('Page 22 displays 2x2 Telemetry Metrics Grid accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tile 1: Cruising Speed
    expect(find.text('CRUISING SPEED'), findsOneWidget);
    expect(find.text('68'), findsOneWidget);
    expect(find.text('km/h'), findsOneWidget);
    expect(find.text('Speed Limit (80) Safe'), findsOneWidget);

    // Tile 2: Remaining Distance
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('140'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('Total run: 452 km'), findsOneWidget);

    // Tile 3: Next Toll / Gate
    expect(find.text('NEXT TOLL / GATE'), findsOneWidget);
    expect(find.text('Mojo-Awash Toll'), findsOneWidget);
    expect(find.text('Lane 3 FastPass (E-Tag)'), findsOneWidget);

    // Tile 4: Cargo Temp
    expect(find.text('CARGO TEMP'), findsOneWidget);
    expect(find.text('-5°C'), findsOneWidget);
    expect(find.text('Sensor Seal OK'), findsOneWidget);
  });

  testWidgets('Page 22 operational controls: POD OTP verification flow works',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Operational Controls Header
    expect(find.text('OPERATIONAL STEERING CONTROLS'), findsOneWidget);
    expect(find.text('Active Mode'), findsOneWidget);

    // Initial state: Verify POD OTP
    final podPillFinder = find.text('Verify POD OTP');
    expect(podPillFinder, findsOneWidget);

    // Tap to open OTP Modal
    await tester.tap(podPillFinder);
    await tester.pumpAndSettle();

    // Verify modal header & instructions
    expect(find.text('Verify Proof of Delivery (POD)'), findsOneWidget);
    expect(find.text('Waybill #HF-9012'), findsNWidgets(2)); // in screen + modal

    // Tap Verify button in bottom sheet
    final verifyButton = find.text('Verify & Release Escrow Payout');
    expect(verifyButton, findsOneWidget);
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    // Button should now show verified state
    expect(find.text('POD Verified (Release OK)'), findsOneWidget);
  });

  testWidgets('Page 22 operational controls: SOS emergency modal opens and displays hotlines',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // SOS Corridor Emergency button
    final sosBanner = find.text('SOS Corridor Emergency');
    expect(sosBanner, findsOneWidget);
    expect(find.text('24/7 Hotline'), findsOneWidget);

    await tester.tap(sosBanner);
    await tester.pumpAndSettle();

    // Emergency Dialog opens
    expect(find.text('Corridor Emergency'), findsOneWidget);
    expect(find.text('Federal Highway Police'), findsOneWidget);
    expect(find.text('991'), findsOneWidget);
    expect(find.text('Emergency Ambulance'), findsOneWidget);
    expect(find.text('907'), findsOneWidget);
    expect(find.text('Habesha 24/7 Dispatch Control'), findsOneWidget);
    expect(find.text('+251-911-84920'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.text('Corridor Emergency'), findsNothing);
  });

  testWidgets('Page 22 contact card actions (Chat & Call) and Language toggle to Amharic',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Contact Card
    expect(find.text('Selamawit ...'), findsOneWidget);
    expect(find.text('Abebe Trading Corp • Di...'), findsOneWidget);

    // Chat modal test
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Direct Message: Selamawit'), findsOneWidget);
    expect(find.text('Send Message'), findsOneWidget);
    await tester.tap(find.text('Send Message'));
    await tester.pumpAndSettle();

    // Call modal test
    await tester.tap(find.byIcon(Icons.phone_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Selamawit Tadesse'), findsOneWidget);
    expect(find.text('+251-912-348-902 • Abebe Trading Corp'), findsOneWidget);
    expect(find.text('Call Receiver Contact'), findsOneWidget);
    await tester.tap(find.text('Call Receiver Contact'));
    await tester.pumpAndSettle();

    // Toggle Language to Amharic
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('አማ'), findsOneWidget);
    expect(find.text('የጭነት ልውውጥ'), findsOneWidget);
    expect(find.text('ንቁ የኮሪደር ጉዞ'), findsOneWidget);
    expect(find.text('ጂፒኤስ ተቆልፏል'), findsOneWidget);
    expect(find.text('የኮሪደር መረጃ'), findsOneWidget);
    expect(find.text('65% ተጠናቋል'), findsOneWidget);
    expect(find.text('የጉዞ ፍጥነት'), findsOneWidget);
    expect(find.text('የቀረ ርቀት'), findsOneWidget);
  });
}

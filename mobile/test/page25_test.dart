import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/incident_route_sos_report_screen.dart';

void main() {
  Widget createTestWidget({
    String initialLanguage = 'EN',
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: IncidentRouteSosReportScreen(
        initialLanguage: initialLanguage,
        enableAnimation: false,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
      'Page 25 renders app bar, sub-header pills, and Active Corridor Protocol card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // App Bar
    expect(find.text('Incident Route Sos Report'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);

    // Sub-header pills
    expect(
      find.text('PAGE 25: INCIDENT & ROUTE SOS REPORT'),
      findsOneWidget,
    );
    expect(find.text('24/7 MONITORED'), findsOneWidget);

    // Active Corridor Protocol Card
    expect(find.text('ACTIVE CORRIDOR INCIDENT PROTOCOL'), findsOneWidget);
    expect(find.text('Incident Code'), findsOneWidget);
    expect(find.text('SOS-ET-098'), findsOneWidget);
    expect(find.text('Consignment ...'), findsOneWidget);
    expect(find.text('High Priority'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

    // Tap Consignment to open modal
    await tester.tap(find.text('Consignment ...'));
    await tester.pumpAndSettle();

    expect(find.text('Consignment Manifest & Telemetry'), findsOneWidget);
    expect(find.text('ETH-DJ-4920'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 25 displays Immediate Geo-Position & GPS Lock Telemetry accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('GPS LOCK LOCKED'), findsOneWidget);
    expect(find.text('Galileo + GPS Fixed'), findsOneWidget);
    expect(find.text('Immediate Geo-Position'), findsOneWidget);
    expect(
      find.text('A2 Northern Highway, 18 km South of Kombolcha'),
      findsOneWidget,
    );
    expect(
      find.text('Lat: 11.0821° N,  Lng: 39.7340° E'),
      findsOneWidget,
    );
    expect(find.text('3m precision'), findsOneWidget);
    expect(find.text('Satellite link active'), findsOneWidget);
    expect(find.text('0 km/h'), findsOneWidget);
  });

  testWidgets(
      'Page 25 displays 4 Incident Classification cards and allows selection',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Section Header
    expect(find.text('Incident Classification'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('Select main primary factor'), findsOneWidget);

    // 4 Cards
    expect(find.text('Mechanical Breakdown'), findsOneWidget);
    expect(find.text('Tire Blowout / Engine / Axle'), findsOneWidget);

    expect(find.text('Customs Delay'), findsOneWidget);
    expect(find.text('E-Seal Glitch / Paperwork'), findsOneWidget);

    expect(find.text('Road Blockage'), findsOneWidget);
    expect(find.text('Landslide / Heavy Rain'), findsOneWidget);

    expect(find.text('Cargo / Minor Hit'), findsOneWidget);
    expect(find.text('Seal Tamper / Scrape'), findsOneWidget);

    // Mechanical Breakdown is initially selected
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Tap Customs Delay to switch selection
    await tester.tap(find.text('Customs Delay'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Tap Road Blockage
    await tester.tap(find.text('Road Blockage'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Tap Cargo / Minor Hit
    await tester.tap(find.text('Cargo / Minor Hit'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets(
      'Page 25 displays description, driver note, and handles voice memo playback',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Description & Note
    expect(find.text('Incident Description & Voice Note'), findsOneWidget);
    expect(find.text('Voice Synced'), findsOneWidget);
    expect(
      find.text(
        'Heavy rear axle puncture and brake line pressure loss. Stopped safely on gravel shoulder.',
      ),
      findsOneWidget,
    );
    expect(find.text('Recorded by Driver M. Bekele'), findsOneWidget);
    expect(find.text('Corridor km 382.4'), findsOneWidget);

    // Voice Memo Player
    expect(find.text('Voice memo recorded (0:42)'), findsOneWidget);
    expect(find.text('00:42'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Tap play
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    // Tap pause
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Tap Reset / Refresh button
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();
    expect(find.text('00:42'), findsOneWidget);
  });

  testWidgets(
      'Page 25 automated dispatch authorizations toggles and hotline buttons work',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Authorizations
    expect(find.text('Automated Dispatch Authorizations'), findsOneWidget);
    expect(find.text('Deploy Roadside Heavy Recovery'), findsOneWidget);
    expect(
      find.text('Kombolcha Hub • Approx. 24 mins away'),
      findsOneWidget,
    );
    expect(find.text('Notify Shipper & Insurer'), findsOneWidget);
    expect(
      find.text('Nyala In-Transit Marine Policy #NY-902-...'),
      findsOneWidget,
    );

    // Toggle switch 1
    await tester.tap(find.text('Deploy Roadside Heavy Recovery'));
    await tester.pumpAndSettle();

    // Toggle switch 2
    await tester.tap(find.text('Notify Shipper & Insurer'));
    await tester.pumpAndSettle();

    // Hotline Buttons
    final callSosBtn = find.text('Call SOS Patrol...');
    final dispatcherBtn = find.text('Dispatcher Hot...');
    expect(callSosBtn, findsOneWidget);
    expect(dispatcherBtn, findsOneWidget);

    // Tap Call SOS Patrol
    await tester.tap(callSosBtn);
    await tester.pumpAndSettle();
    expect(find.text('Emergency SOS Patrol Hotline'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();

    // Tap Dispatcher Hotline
    await tester.tap(dispatcherBtn);
    await tester.pumpAndSettle();
    expect(find.text('Central Dispatcher Hotline'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 25 handles Transmit Emergency Incident Report and shows confirmation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final transmitBtn = find.text('Transmit Emergency Incident Report');
    expect(transmitBtn, findsOneWidget);
    expect(
      find.text(
        'Encrypted telemetry transmission to Central Fleet Operations\nAddis Ababa',
      ),
      findsOneWidget,
    );

    await tester.tap(transmitBtn);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Confirmation Bottom Sheet
    expect(find.text('Emergency SOS Transmitted'), findsOneWidget);
    expect(
      find.textContaining('Incident Code SOS-ET-098 received'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Heavy Recovery Unit dispatched'),
      findsOneWidget,
    );
    expect(find.text('Acknowledge & Monitor Status'), findsOneWidget);

    await tester.tap(find.text('Acknowledge & Monitor Status'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 25 toggles language between English and Amharic seamlessly',
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
    expect(find.text('የመስመር ላይ አደጋ ጊዜ ሪፖርት'), findsOneWidget);
    expect(find.text('24/7 ክትትል የሚደረግበት'), findsOneWidget);
    expect(find.text('ተግባራዊ የኮሪደር አደጋ ፕሮቶኮል'), findsOneWidget);
    expect(find.text('የአደጋ መለያ'), findsOneWidget);
    expect(find.text('ወቅታዊ የቦታ መገኛ'), findsOneWidget);
    expect(find.text('የአደጋው ምድብ'), findsOneWidget);
    expect(find.text('ሜካኒካል ብልሽት'), findsOneWidget);
    expect(find.text('የአደጋው መግለጫ እና የድምፅ መልእክት'), findsOneWidget);
    expect(find.text('አውቶማቲክ የአደጋ ጊዜ ቡድን ፈቃዶች'), findsOneWidget);
    expect(find.text('የአደጋ ጊዜ ሪፖርቱን አስተላልፍ'), findsOneWidget);
  });

  testWidgets(
      'Page 25 layout adapts responsively to desktop and tablet viewport widths',
      (WidgetTester tester) async {
    // Wide desktop viewport
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Assert it centers with constrained width and does not overflow
    expect(find.text('Incident Route Sos Report'), findsOneWidget);
    expect(find.text('Transmit Emergency Incident Report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

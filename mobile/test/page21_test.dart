import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page21.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const MyBidPipelineScreen(),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 21 renders header, contract awarded banner, and live pipeline header',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify brand header
    expect(find.text('Habesha'), findsOneWidget);
    expect(find.text('Freight'), findsOneWidget);
    expect(find.text('LOGISTICS EXCHANGE'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Verify Contract Awarded Banner
    expect(find.text('CONTRACT AWARDED'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Waybill #HF-9012'), findsOneWidget);
    expect(find.text('Addis Ababa → Dire Dawa • 45,000 ETB'), findsOneWidget);
    expect(find.text('View Dispatch Slip'), findsOneWidget);
    expect(find.text('Departure\nReady'), findsOneWidget);

    // Verify Title & Live board
    expect(find.text('My Bid Pipeline'), findsOneWidget);
    expect(find.text('LIVE BOARD'), findsOneWidget);
  });

  testWidgets('Page 21 displays KPI stats and filter tab segment properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Metrics cards
    expect(find.text('ACTIVE CAP'), findsOneWidget);
    expect(find.text('146.5k'), findsOneWidget);
    expect(find.text('3 bids open'), findsOneWidget);

    expect(find.text('WIN RATE'), findsOneWidget);
    expect(find.text('68.2%'), findsOneWidget);
    expect(find.text('Top 5% Carrier'), findsOneWidget);

    expect(find.text('AVG LEAD'), findsOneWidget);
    expect(find.text('42m'), findsOneWidget);
    expect(find.text('Shipper reply'), findsOneWidget);

    // Filter tabs
    expect(find.text('Active\nBids'), findsOneWidget);
    expect(find.text('Awarded &\nWon'), findsOneWidget);
    expect(find.text('Past\nArchive'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('Page 21 displays all 3 active bid cards and toll intel card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Card 1: Counter-Offer
    expect(find.text('ACTION REQUIRED: COUNTER-OFFER'), findsOneWidget);
    expect(find.text('Modjo Dry P...'), findsOneWidget);
    expect(find.text('Dire Dawa F...'), findsOneWidget);
    expect(find.text('28T Wheat Bulk • Hopper Trailer • 440 km'), findsOneWidget);
    expect(find.text('Your Submitted Bid'), findsOneWidget);
    expect(find.text('78,000 ETB'), findsOneWidget);
    expect(find.text('Shipper Counter-Offer'), findsOneWidget);
    expect(find.text('74,500 ETB'), findsOneWidget);
    expect(find.text('Ethio-Grains Logistics Plc'), findsOneWidget);
    expect(find.text('Expires in 18m'), findsOneWidget);
    expect(find.text('Accept 74,500 ETB'), findsOneWidget);
    expect(find.text('Re-Counter'), findsOneWidget);
    expect(find.text('Reject Counter-Offer'), findsOneWidget);

    // Card 2: Under Shipper Review
    expect(find.text('UNDER SHIPPER REVIEW'), findsOneWidget);
    expect(find.text('Target: 35,000 ETB'), findsOneWidget);
    expect(find.text('Addis Aba...'), findsOneWidget);
    expect(find.text('Hawas...'), findsOneWidget);
    expect(find.text('22T Export Coffee Bags • 218 km'), findsOneWidget);
    expect(find.text('2 Competitor Bids Logged'), findsOneWidget);
    expect(find.text('Competitive'), findsOneWidget);
    expect(find.text('Submitted 22 mins\nago'), findsOneWidget);
    expect(find.text('Modify\nBid'), findsOneWidget);
    expect(find.text('Withdraw'), findsOneWidget);

    // Card 3: Shipper Shortlisted
    expect(find.text('SHIPPER SHORTLISTED'), findsOneWidget);
    expect(find.text('32,000'), findsOneWidget);
    expect(find.text('Matched rate'), findsOneWidget);
    expect(find.text('Kaliti D...'), findsOneWidget);
    expect(find.text('Adama Ind...'), findsOneWidget);
    expect(find.text('20T Portland Cement • Flatbed 3-Axle'), findsOneWidget);
    expect(find.text('Awaiting Final Allocation'), findsOneWidget);
    expect(find.text('Stage 2 of 3'), findsOneWidget);
    expect(find.text('Truck: ET-3-84920'), findsOneWidget);
    expect(find.text('Message Shipper'), findsOneWidget);

    // Bottom Expressway Toll Intel Card
    expect(find.text('Adama Expressway Toll Intel'), findsOneWidget);
    expect(find.text('Flow rate normal • Toll booths clear'), findsOneWidget);
    expect(find.text('Live GPS'), findsOneWidget);

    // Bottom Navigation Bar
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Shipments'), findsOneWidget);
    expect(find.text('Post Load'), findsOneWidget);
    expect(find.text('Bids'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
  });

  testWidgets('Page 21 interactive actions: dispatch slip and counter-offer acceptance work',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap View Dispatch Slip button
    final dispatchBtn = find.text('View Dispatch Slip');
    expect(dispatchBtn, findsOneWidget);
    await tester.tap(dispatchBtn);
    await tester.pumpAndSettle();

    // Verify modal appears
    expect(find.text('Dispatch Slip HF-9012'), findsOneWidget);
    expect(find.text('Download Official PDF Slip'), findsOneWidget);

    // Close modal
    await tester.tap(find.text('Download Official PDF Slip'));
    await tester.pumpAndSettle();

    // Tap Accept 74,500 ETB
    final acceptBtn = find.text('Accept 74,500 ETB');
    expect(acceptBtn, findsOneWidget);
    await tester.tap(acceptBtn);
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Accept Counter-Offer?'), findsOneWidget);
    await tester.tap(find.text('Confirm & Lock'));
    await tester.pumpAndSettle();

    // Notice appears
    expect(find.text('Counter-offer of 74,500 ETB accepted! Waybill issued.'), findsOneWidget);
  });

  testWidgets('Page 21 language switcher toggles seamlessly between English and Amharic',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify initial English
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('My Bid Pipeline'), findsOneWidget);
    expect(find.text('CONTRACT AWARDED'), findsOneWidget);

    // Tap language switcher
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    // Verify Amharic texts
    expect(find.text('አማ'), findsOneWidget);
    expect(find.text('የእኔ ጨረታ ዝርዝር'), findsOneWidget);
    expect(find.text('ውል ተሰጥቷል'), findsOneWidget);
    expect(find.text('ቀጥታ ሰሌዳ'), findsOneWidget);
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/corridor_bid_item.dart';
import 'package:mobile/presentation/screens/shipper_features/page09.dart';

final _sampleBids = [
  const CorridorBidItem(
    id: 'bid-girma',
    driverName: 'Girma Tadesse',
    driverInitials: 'GT',
    rating: 4.9,
    reviewsCount: 142,
    truckSpec: 'Sinotruk HOWO 371 • Dry Bulk Grain Spec',
    locationText: 'Kality Depot (11 km away)',
    availabilityText: 'Ready 2:00 PM today',
    bidAmountEtb: 38000,
    badgeLabel: 'TOP MATCH • VERIFIED PRO',
    badgeColor: Color(0xFFF59E0B),
    isTopMatch: true,
    isEscrowGuaranteed: true,
    estTransit: '9h 45m',
    gpsStatus: 'Live Active',
    fuelIncluded: 'Yes (Full)',
  ),
  const CorridorBidItem(
    id: 'bid-solomon',
    driverName: 'Solomon Tekle',
    driverInitials: 'ST',
    rating: 4.8,
    reviewsCount: 85,
    truckSpec: 'FAW J6P 32T Heavy Semi-Trailer',
    locationText: 'Akaki Dry Port (15 km away)',
    availabilityText: 'Ready 4:30 PM',
    bidAmountEtb: 36500,
    badgeLabel: 'Lowest Fare Offered',
    badgeColor: Color(0xFF10B981),
    isTopMatch: false,
    submittedAgo: 'Submitted 18m ago',
  ),
  const CorridorBidItem(
    id: 'bid-bekele',
    driverName: 'Bekele Wolde',
    driverInitials: 'BW',
    rating: 4.7,
    reviewsCount: 64,
    truckSpec: 'Mercedes Actros 3340 • Tarpaulin Covered',
    locationText: 'Dukem Corridor (22 km away)',
    availabilityText: 'Ready 8:00 AM tomorrow',
    bidAmountEtb: 39200,
    badgeLabel: 'High-Capacity Heavy Rig',
    badgeColor: Color(0xFF38BDF8),
    isTopMatch: false,
    submittedAgo: 'Submitted 41m ago',
  ),
];

void main() {
  Widget createTestWidget({List<CorridorBidItem>? bids}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ReviewBidsScreen(initialBids: bids ?? _sampleBids),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 09 renders branding header and sub-header ribbon',
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
    expect(find.text('ETHIOPIA NATIONAL LOGISTICS'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Sub-header Ribbon
    expect(find.text('CARGO BIDS & OFFERS'), findsOneWidget);
    expect(find.text('3 Active Bids • Live Tender'), findsOneWidget);
  });

  testWidgets('Page 09 renders active tender summary card with route and escrow banner',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tender status and Route
    expect(find.text('Live Corridor Tender'), findsOneWidget);
    expect(find.text('Addis Ababa'), findsOneWidget);
    expect(find.text('Dire Dawa'), findsOneWidget);
    expect(find.text('28 MT Dry Bulk (Teff & Grain)'), findsOneWidget);
    expect(find.text('452 km Corridor'), findsOneWidget);

    // Bids Placed Counter
    expect(find.text('BIDS PLACED'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Drivers'), findsOneWidget);

    // Clean bids status pill
    expect(find.text('3 Carrier Bids'), findsOneWidget);
  });

  testWidgets('Page 09 renders Top Match Verified Pro bid card (Girma Tadesse)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Top Match Badges
    expect(find.text('TOP MATCH • VERIFIED PRO'), findsOneWidget);
    expect(find.text('Escrow Guaranteed'), findsOneWidget);

    // Driver Profile
    expect(find.text('Girma Tadesse'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text(' (142)'), findsOneWidget);
    expect(find.text('Sinotruk HOWO 371 • Dry Bulk Grain Spec'), findsOneWidget);
    expect(find.text('Kality Depot (11 km away)'), findsOneWidget);
    expect(find.text('Ready 2:00 PM today'), findsOneWidget);

    // 3-Column Telemetry
    expect(find.text('EST. TRANSIT'), findsOneWidget);
    expect(find.text('9h 45m'), findsOneWidget);
    expect(find.text('GPS UNIT'), findsOneWidget);
    expect(find.text('Live Active'), findsOneWidget);
    expect(find.text('FUEL INCLUDED'), findsOneWidget);
    expect(find.text('Yes (Full)'), findsOneWidget);

    // Price and Buttons
    expect(find.text('38,000'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Accept Bid'), findsOneWidget);
  });

  testWidgets('Page 09 renders Standard Bid Cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Card 2: Solomon Tekle
    expect(find.text('Lowest Fare Offered'), findsOneWidget);
    expect(find.text('Solomon Tekle'), findsOneWidget);
    expect(find.text('36,500'), findsOneWidget);

    // Card 3: Bekele Wolde
    expect(find.text('High-Capacity Heavy Rig'), findsOneWidget);
    expect(find.text('Bekele Wolde'), findsOneWidget);
    expect(find.text('39,200'), findsOneWidget);

    // Action buttons on standard cards
    expect(find.text('Counter Offer'), findsNWidgets(2));
    expect(find.text('Accept'), findsNWidgets(2));
  });

  testWidgets('Page 09 renders clean empty state when no bids exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(bids: []));
    await tester.pumpAndSettle();

    expect(find.text('No Active Bids Yet'), findsOneWidget);
    expect(find.text('Post Cargo Load'), findsOneWidget);
  });

  testWidgets('Page 09 opens Counter Offer modal and recalculates discount',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap first Counter Offer button
    await tester.tap(find.text('Counter Offer').first);
    await tester.pumpAndSettle();

    // Modal should be visible
    expect(find.text('Counter Offer to Solomon Tekle'), findsOneWidget);
    expect(find.text('Original Bid: 36500 ETB'), findsOneWidget);
    expect(find.text('Submit Counter Offer'), findsOneWidget);

    // Tap -10% chip
    await tester.tap(find.text('-10% (32850 ETB)'));
    await tester.pumpAndSettle();

    // Submit counter offer
    await tester.tap(find.text('Submit Counter Offer'));
    await tester.pumpAndSettle();

    // Countered state should reflect
    expect(find.text('Countered'), findsOneWidget);
  });

  testWidgets('Page 09 opens Award Freight Contract confirmation dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Accept Bid on Top Match
    await tester.tap(find.text('Accept Bid'));
    await tester.pumpAndSettle();

    // Modal dialog
    expect(find.text('Award Freight Contract'), findsOneWidget);
    expect(find.text('Lock Escrow Payout: 38000 ETB'), findsOneWidget);
    expect(find.text('Confirm & Award'), findsOneWidget);

    // Confirm award
    await tester.tap(find.text('Confirm & Award'));
    await tester.pumpAndSettle();

    // Should show Awarded state
    expect(find.text('Awarded'), findsOneWidget);
  });
}

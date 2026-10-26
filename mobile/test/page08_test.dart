import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/data/models/corridor_shipment_item.dart';
import 'package:mobile/presentation/screens/shipper_features/page08.dart';

final List<CorridorShipmentItem> _sampleShipments = [
  const CorridorShipmentItem(
    id: '#HF-9012',
    cargoType: 'Dry Bulk • Grain',
    status: ShipmentStatus.inTransit,
    origin: 'Addis Ababa',
    destination: 'Dire Dawa',
    viaRoute: 'Via Awash',
    distanceKm: 452,
    lowestOfferEtb: 45000,
    driverName: 'Tewodros Kassaye',
  ),
  const CorridorShipmentItem(
    id: '#HF-8841',
    cargoType: 'General Cargo • FMCG',
    status: ShipmentStatus.bidding,
    origin: 'Addis Ababa',
    destination: 'Adama',
    viaRoute: 'Expressway A1',
    distanceKm: 85,
    lowestOfferEtb: 18500,
    bidsCount: 3,
  ),
  const CorridorShipmentItem(
    id: '#HF-7720',
    cargoType: 'Agricultural • Coffee Bags',
    status: ShipmentStatus.awaitingDispatch,
    origin: 'Hawassa',
    destination: 'Modjo',
    viaRoute: 'A7 Corridor',
    distanceKm: 215,
    carrierAssigned: 'Selam Logistics PLC',
  ),
  const CorridorShipmentItem(
    id: '#HF-6504',
    cargoType: 'Construction • Rebar 40T',
    status: ShipmentStatus.delivered,
    origin: 'Addis Ababa',
    destination: 'Bahir Dar',
    viaRoute: 'Route 3 Corridor',
    distanceKm: 560,
    deliveredDate: 'Yesterday',
  ),
];

void main() {
  Widget createTestWidget({List<CorridorShipmentItem>? shipments}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Page08Screen(initialShipments: shipments ?? _sampleShipments),
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

    await tester.pumpWidget(createTestWidget(shipments: _sampleShipments));
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

    await tester.pumpWidget(createTestWidget(shipments: _sampleShipments));
    await tester.pumpAndSettle();

    // Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Bidding'), findsOneWidget);
    expect(find.text('Awarded'), findsOneWidget);
    expect(find.text('Delivered'), findsAtLeastNWidgets(1));

    // Shipment Item cards
    expect(find.text('#HF-9012'), findsOneWidget);
    expect(find.text('Addis Ababa'), findsAtLeastNWidgets(1));
    expect(find.text('Dire Dawa'), findsAtLeastNWidgets(1));
  });

  testWidgets('Page 08 opens review, awarded manifest, and delivered POD detail views',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(shipments: _sampleShipments));
    await tester.pumpAndSettle();

    // 1. Test POD Receipt dialog for Delivered shipment
    final podButton = find.text('POD Receipt').first;
    await tester.ensureVisible(podButton);
    await tester.tap(podButton);
    await tester.pumpAndSettle();

    expect(find.text('Proof of Delivery & Settlement'), findsOneWidget);
    expect(find.text('STATUS: DELIVERED • ESCROW SETTLED'), findsOneWidget);
    expect(find.text('Waybill Manifest'), findsOneWidget);

    // Close POD dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // 2. Test Manifest Pass dialog for Awarded shipment
    final manifestPassButton = find.text('Manifest Pass').first;
    await tester.ensureVisible(manifestPassButton);
    await tester.tap(manifestPassButton);
    await tester.pumpAndSettle();

    expect(find.text('Consignment Awarded'), findsOneWidget);
    expect(find.text('STATUS: CONTRACT AWARDED • AWAITING DISPATCH'), findsOneWidget);
    expect(find.text('Consignment ID'), findsOneWidget);

    // Dismiss dialog
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // 3. Test Review Bids modal for Bidding shipment
    final reviewBidsButton = find.text('Review Bids').first;
    await tester.ensureVisible(reviewBidsButton);
    await tester.tap(reviewBidsButton);
    await tester.pumpAndSettle();

    expect(find.text('Cargo Tender Live on Board'), findsOneWidget);
    expect(find.text('Review Live Driver Bids'), findsOneWidget);
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


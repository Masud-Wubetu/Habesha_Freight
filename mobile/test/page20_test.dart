import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/bid_service.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper_features/page20.dart';

class FakeBidService extends BidService {
  @override
  Future<BidSubmissionResult> submitBid({
    required String loadId,
    required double bidAmountEtb,
    String? terminalGateSlot,
    bool fuelPassesInclusive = true,
    bool waterproofTarpVerified = true,
    String? note,
  }) async {
    return const BidSubmissionResult(
      success: true,
      message: 'Bid transmitted to shipper successfully.',
    );
  }
}

void main() {
  Widget createTestWidget({BidService? bidService}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: SubmitFreightBidScreen(
        bidService: bidService ?? FakeBidService(),
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Page 20 renders all core header, route, and badge components',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header elements
    expect(find.text('LIVE BIDDING'), findsOneWidget);
    expect(find.text('Submit Freight\nBid'), findsOneWidget);
    expect(find.text('#REQ-9840'), findsOneWidget);

    // Verify route strip
    expect(find.text('CORRIDOR ACTIVE'), findsOneWidget);
    expect(find.byIcon(Icons.alt_route_rounded), findsOneWidget);
  });

  testWidgets('Page 20 displays Escrow Payout calculations accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // As requested, dual cards are rendered
    expect(find.text('ESCROW PAYOUT TRANSPARENCY'), findsNWidgets(2));
    expect(find.text('REAL-TIME AUDIT'), findsNWidgets(2));
    expect(find.text('Guaranteed Settled Yield'), findsNWidgets(2));

    // Initial 76,000 ETB math:
    // Platform fee (2.5%) = 1,900 ETB
    // Withholding tax (2.0%) = 1,520 ETB
    // Net take-home = 72,580 ETB
    expect(find.text('-1,900 ETB'), findsNWidgets(2));
    expect(find.text('-1,520 ETB'), findsNWidgets(2));
    expect(find.text('72,580'), findsNWidgets(2));
  });

  testWidgets('Page 20 stepper and quick presets update bid amount dynamically',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Initial amount display
    expect(find.text('76,000'), findsOneWidget);

    // Tap '+' to increase by 1,000 ETB
    final plusBtn = find.byIcon(Icons.add_rounded);
    expect(plusBtn, findsOneWidget);
    await tester.tap(plusBtn);
    await tester.pumpAndSettle();

    // Amount should now be 77,000
    expect(find.text('77,000'), findsOneWidget);

    // Tap preset '80,000 ETB'
    final preset80k = find.text('80,000 ETB');
    expect(preset80k, findsOneWidget);
    await tester.tap(preset80k);
    await tester.pumpAndSettle();

    // Amount should now be 80,000
    expect(find.text('80,000'), findsOneWidget);

    // 80,000 * 0.025 = 2,000 ETB fee
    // 80,000 * 0.020 = 1,600 ETB tax
    // Net take-home = 76,400 ETB
    expect(find.text('-2,000 ETB'), findsNWidgets(2));
    expect(find.text('-1,600 ETB'), findsNWidgets(2));
    expect(find.text('76,400'), findsNWidgets(2));
  });

  testWidgets('Page 20 readiness checklist and bottom transmit button work properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify checklist items
    expect(find.text('Fuel & corridor toll passes fully inclusive'), findsOneWidget);
    expect(find.text('Heavy waterproof tarp equipped & verified'), findsOneWidget);

    // Verify bottom transmit button
    expect(find.text('Confirm & Transmit Bid to Shipper'), findsOneWidget);

    // Tap transmit button to open confirmation dialog
    await tester.tap(find.text('Confirm & Transmit Bid to Shipper'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Bid Transmitted!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap done to dismiss
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Bid Transmitted!'), findsNothing);
  });
}

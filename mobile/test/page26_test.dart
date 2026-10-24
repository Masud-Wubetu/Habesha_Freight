import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/screens/shipper_features/instant_escrow_payout_settlement_screen.dart';

void main() {
  Widget createWidgetUnderTest({
    double grossFareEtb = 76000.00,
    double platformFeePercent = 2.5,
    double withholdingTaxPercent = 2.0,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InstantEscrowPayoutSettlementScreen(
        tripId: 'REQ-9840',
        originCity: 'Addis Ababa',
        destinationCity: 'Mekelle',
        distanceKm: 780,
        grossFareEtb: grossFareEtb,
        platformFeePercent: platformFeePercent,
        withholdingTaxPercent: withholdingTaxPercent,
        smartEscrowLockId: 'ESCROW-ET-883921-CBE',
        morTaxClearanceId: '#TR-99402',
        enableAnimation: false,
      ),
    );
  }

  group('Page 26 - Instant Escrow Payout Settlement Screen Tests', () {
    testWidgets('Renders app bar, header pills, and trip context card',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // App bar title
      expect(find.textContaining('Instant Escrow Payout'), findsOneWidget);

      // Sub-header tags
      expect(
        find.textContaining('PAGE 26: INSTANT ESCROW PAYOUT SETTLEMENT'),
        findsOneWidget,
      );
      expect(find.text('Secured Payout'), findsOneWidget);

      // e-POD Verified status pill
      expect(
        find.textContaining('e-POD Verified • Escrow Released by Shipper'),
        findsOneWidget,
      );

      // Trip details
      expect(find.textContaining('Trip REQ-9840'), findsOneWidget);
      expect(find.text('Addis Ababa'), findsOneWidget);
      expect(find.text('Mekelle'), findsOneWidget);
      expect(find.textContaining('780 km'), findsOneWidget);
    });

    testWidgets('Displays Carrier Net Settlement and Audited Ledger calculations',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Label and funds status
      expect(find.text('CARRIER NET SETTLEMENT'), findsOneWidget);
      expect(
        find.text('Funds Available for Instant Withdrawal'),
        findsOneWidget,
      );

      // Hero Net Amount: ETB 72,580.00
      expect(find.text('ETB 72,580.00'), findsNWidgets(2)); // in hero and in ledger highlight

      // Audited ledger rows
      expect(find.text('AUDITED LEDGER SUMMARY'), findsOneWidget);
      expect(find.text('Validated'), findsOneWidget);
      expect(find.text('Gross Agreed Fare'), findsOneWidget);
      expect(find.text('ETB 76,000.00'), findsOneWidget);

      // Deductions
      expect(find.textContaining('HabeshaFreight Fee (2.5%)'), findsOneWidget);
      expect(find.text('-ETB 1,900.00'), findsOneWidget);
      expect(find.textContaining('MoR Withholding Tax (2.0%)'), findsOneWidget);
      expect(find.text('-ETB 1,520.00'), findsOneWidget);
      expect(find.text('Net Credited Balance'), findsOneWidget);
    });

    testWidgets('Renders 3 Disbursement Channels and allows channel switching',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Section header
      expect(find.text('Disbursement Channel'), findsOneWidget);
      expect(find.text('0s processing'), findsOneWidget);

      // Channel 1: Telebirr
      expect(find.text('Telebirr Instant Wallet'), findsOneWidget);
      expect(find.text('+251 91 1*** ***5'), findsOneWidget);
      expect(find.text('Fastest'), findsOneWidget);
      expect(find.text('Fee: 0 ETB • Instant Direct Deposit'), findsOneWidget);

      // Channel 2: CBE
      expect(find.text('Commercial Bank of Ethiopia'), findsOneWidget);
      expect(find.text('CBE Acct #180028941029'), findsOneWidget);
      expect(find.text('Est. arrival: 5 - 15 minutes'), findsOneWidget);

      // Channel 3: Awash Bank
      expect(find.text('Awash Bank Direct Transfer'), findsOneWidget);
      expect(find.text('AWASH Acct #01438920199'), findsOneWidget);

      // Initial primary CTA text reflects Telebirr
      expect(
        find.textContaining('Transfer ETB 72,580 to Telebirr Now'),
        findsOneWidget,
      );

      // Tap on Commercial Bank of Ethiopia channel
      await tester.ensureVisible(find.text('Commercial Bank of Ethiopia'));
      await tester.tap(find.text('Commercial Bank of Ethiopia'));
      await tester.pumpAndSettle();

      // Primary CTA dynamically updates to CBE
      expect(
        find.textContaining('Transfer ETB 72,580 to CBE Now'),
        findsOneWidget,
      );

      // Tap on Awash Bank
      await tester.ensureVisible(find.text('Awash Bank Direct Transfer'));
      await tester.tap(find.text('Awash Bank Direct Transfer'));
      await tester.pumpAndSettle();

      // Primary CTA dynamically updates to Awash Bank
      expect(
        find.textContaining('Transfer ETB 72,580 to Awash Bank Now'),
        findsOneWidget,
      );
    });

    testWidgets('Displays Security & Statutory Clearance with IDs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Security & Statutory Clearance'), findsOneWidget);
      expect(find.text('Smart Escrow Lock:'), findsOneWidget);
      expect(find.text('ESCROW-ET-883921-CBE'), findsOneWidget);
      expect(find.text('MoR Tax Clearance:'), findsOneWidget);
      expect(find.text('#TR-99402'), findsOneWidget);
    });

    testWidgets('Executes instant transfer and displays success receipt bottom sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Scroll to primary button
      final transferButton = find.textContaining('Transfer ETB 72,580');
      await tester.ensureVisible(transferButton);
      await tester.tap(transferButton);
      await tester.pump(); // starts loading

      // Advance simulated timer
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Verify Receipt bottom sheet
      expect(find.text('Payout Disbursed Successfully!'), findsOneWidget);
      expect(find.text('Disbursed Amount'), findsOneWidget);
      expect(find.text('Destination Channel'), findsOneWidget);
      expect(find.text('Telebirr'), findsOneWidget);
      expect(find.text('+251 91 1*** ***5'), findsNWidgets(2));
      expect(find.text('#REQ-9840'), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.text('Done & Return to Overview'));
      await tester.pumpAndSettle();
      expect(find.text('Payout Disbursed Successfully!'), findsNothing);
    });

    testWidgets('Opens Driver Earnings & Wallet ledger bottom sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final walletButton = find.text('View Updated Driver Earnings & Wallet');
      await tester.ensureVisible(walletButton);
      await tester.tap(walletButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Driver Earnings & Escrow Ledger'),
        findsOneWidget,
      );
      expect(find.text('ETB 482,900'), findsOneWidget);
      expect(find.text('Recent Automated Settlements'), findsOneWidget);

      // Close wallet modal
      await tester.tap(find.text('Close Wallet Overview'));
      await tester.pumpAndSettle();
      expect(find.text('Driver Earnings & Escrow Ledger'), findsNothing);
    });

    testWidgets('Toggles language seamlessly between English and Amharic',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('EN'), findsOneWidget);

      // Tap language switch to switch to Amharic
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      expect(find.text('አማ'), findsOneWidget);
      expect(find.text('የአጓጓዥ የተጣራ ክፍያ'), findsOneWidget);
      expect(find.text('የክፍያ መቀበያ መስመር'), findsOneWidget);
      expect(find.text('የቴሌብር አፋጣኝ ቦርሳ'), findsOneWidget);

      // Tap back to English
      await tester.tap(find.text('አማ'));
      await tester.pumpAndSettle();

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('CARRIER NET SETTLEMENT'), findsOneWidget);
      expect(find.text('Telebirr Instant Wallet'), findsOneWidget);
    });

    testWidgets('Adapts responsively to desktop and mobile viewport widths',
        (WidgetTester tester) async {
      // Desktop width test
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ETB 72,580.00'), findsWidgets);

      // Mobile narrow width test
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Disbursement Channel'), findsOneWidget);

      tester.view.resetPhysicalSize();
    });
  });
}

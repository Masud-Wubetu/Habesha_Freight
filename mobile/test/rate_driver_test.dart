import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper/rate_driver_screen.dart';

void main() {
  Widget createTestWidget({
    String? driverName,
    String? waybillNumber,
    double? escrowAmount,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: RateDriverScreen(
        driverName: driverName,
        waybillNumber: waybillNumber,
        escrowAmount: escrowAmount,
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('RateDriverScreen renders driver and escrow details accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      driverName: 'Abebe Chala',
      waybillNumber: 'WB-7729',
      escrowAmount: 45000,
    ));
    await tester.pumpAndSettle();

    // Verify Title & Labels
    expect(find.text('Rate Delivery & Release Escrow'), findsOneWidget);
    expect(find.text('Rate driver performance for Waybill #WB-7729'), findsOneWidget);
    expect(find.text('Abebe Chala'), findsOneWidget);
    expect(find.text('45,000 ETB locked in escrow will be released to Abebe Chala upon review submission.'), findsOneWidget);
    expect(find.text('Submit Rating & Release 45,000 ETB'), findsOneWidget);
    expect(find.text('Report Transit Dispute'), findsOneWidget);

    // Verify no unsplash mock image is used
    expect(find.byType(Image), findsNothing);
  });
}

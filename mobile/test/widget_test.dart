import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('HabeshaFreightApp renders Page 20 Submit Freight Bid smoke test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HabeshaFreightApp());
    await tester.pumpAndSettle();

    expect(find.text('LIVE BIDDING'), findsOneWidget);
    expect(find.text('Submit Freight\nBid'), findsOneWidget);
  });

  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('National Freight Network'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Masud Wubetu',
      'user_role': 'SHIPPER',
    });
  });

  group('Shipper Home Dashboard - Clean Real Data UI', () {
    testWidgets('Renders clean simplified home dashboard without mock cards or header overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify clean header with Habesha Freight branding and user initial
      expect(find.text('Habesha '), findsOneWidget);
      expect(find.text('Freight'), findsOneWidget);
      expect(find.text('M'), findsOneWidget); // Initial 'M' for Masud

      // 2. Verify clean personalized greeting without marketing filler
      expect(find.text('Welcome, Masud'), findsOneWidget);
      expect(find.text('Post Cargo Load'), findsOneWidget);
      expect(find.text('My Shipments'), findsOneWidget);

      // Verify old crowded tags are removed
      expect(find.text('SHIPPER CARGO PORTAL'), findsNothing);
      expect(
        find.text(
          'Instant direct matching, verified carrier telemetry, and transparent corridor rates across Ethiopia.',
        ),
        findsNothing,
      );

      // 3. Verify clean Shipper Metrics Row (ACTIVE, POSTED, QUOTES, ESCROW)
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('POSTED'), findsOneWidget);
      expect(find.text('QUOTES'), findsOneWidget);
      expect(find.text('ESCROW'), findsOneWidget);

      // 4. Verify clean live transit card: When no shipment is in transit,
      // it must NOT show fake driver "Ibrahim Kedir" or mock delivered cement!
      expect(find.text('Assigned Driver: Ibrahim Kedir'), findsNothing);
      expect(find.text('Ibrahim Kedir'), findsNothing);
      expect(find.text('Construction Cement'), findsNothing);

      // 5. Verify single consolidated Corridor Tariff Estimator
      expect(find.text('Corridor Tariff Estimator'), findsOneWidget);
      expect(find.text('Book Freight on This Route'), findsOneWidget);

      // Verify the old duplicate "6 Strategic Corridors" list was removed
      expect(find.text('6 Strategic Corridors'), findsNothing);
      expect(find.text('Key Ethiopian Corridors'), findsNothing);
    });
  });
}

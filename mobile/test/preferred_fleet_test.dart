import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper/preferred_fleet_directory.dart';

void main() {
  Widget createTestWidget({List<PreferredCarrier>? carriers}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: PreferredFleetScreen(initialCarriers: carriers),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('PreferredFleetScreen renders clean empty state when no fleets found',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(carriers: []));
    await tester.pumpAndSettle();

    // Verify Title & Empty State
    expect(find.text('Preferred Fleets'), findsOneWidget);
    expect(find.text('0 Active'), findsOneWidget);
    expect(find.text('No Transport Fleets Found'), findsOneWidget);
    expect(find.text('Broadcast Cargo Load'), findsOneWidget);

    // Verify mock placeholders are removed
    expect(find.text('Abyssinia Freight PLC'), findsNothing);
    expect(find.text('Selam Logistics PLC'), findsNothing);
  });

  testWidgets('PreferredFleetScreen renders real transport company card and buttons',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      carriers: const [
        PreferredCarrier(
          id: 'comp-101',
          name: 'Nile Trans Logistics PLC',
          type: 'Commercial Carrier • 18 Available Trucks',
          route: 'Addis Ababa → Djibouti Port Corridor',
          tag: '18 Trucks',
          rating: '4.9',
          trips: '240',
          badge: 'Verified Operator',
          category: 'Heavy Trailers',
          phone: '+251 91 123 4567',
          icon: Icons.local_shipping,
        ),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('1 Active'), findsOneWidget);
    expect(find.text('Nile Trans Logistics PLC'), findsOneWidget);
    expect(find.text('Verified Operator'), findsOneWidget);
    expect(find.text('Request Quote'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });
}

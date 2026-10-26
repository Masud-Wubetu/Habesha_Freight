import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/shipper/company_profile_screen.dart';

void main() {
  Widget createTestWidget({Map<String, dynamic>? profile}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ShipperCompanyProfileScreen(initialProfile: profile),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('ShipperCompanyProfileScreen displays authenticated shipper details accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      profile: {
        'full_name': 'Masud Wubetu',
        'company_name': 'Habesha Express Freight',
        'email': 'masud@habeshafreight.et',
        'phone_number': '+251 91 122 3344',
        'stats': {
          'total_loads': 3,
          'active_loads': 1,
          'completed_loads': 2,
        },
      },
    ));
    await tester.pumpAndSettle();

    // Verify Title & Profile Values
    expect(find.text('Habesha Express Freight'), findsOneWidget);
    expect(find.text('Masud Wubetu • Registered Enterprise'), findsOneWidget);
    expect(find.text('Masud Wubetu'), findsOneWidget);
    expect(find.text('+251 91 122 3344'), findsOneWidget);
    expect(find.text('masud@habeshafreight.et'), findsOneWidget);
    expect(find.text('3 Loads'), findsOneWidget);
    expect(find.text('Edit Shipper Profile'), findsOneWidget);

    // Verify fake mock names are removed
    expect(find.text('Ethio Agricultural Exports Ltd'), findsNothing);
    expect(find.text('Selamawit Tadesse'), findsNothing);
  });
}

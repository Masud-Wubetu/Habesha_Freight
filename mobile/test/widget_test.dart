import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('HabeshaFreightApp renders login header smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HabeshaFreightApp());
    expect(find.text('National Freight Network'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('HabeshaFreightApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HabeshaFreightApp());
    expect(find.text('Habesha Freight Mobile'), findsOneWidget);
  });
}

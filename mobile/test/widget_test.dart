import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HabeshaFreightApp renders home screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const HabeshaFreightApp());
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('LOGISTICS PLATFORM'), findsOneWidget);
  });
}

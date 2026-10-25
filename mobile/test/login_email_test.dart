import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Login Screen - Email & Password Sign In', () {
    testWidgets('Renders email and password fields without any phone UI',
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
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Welcome Back header
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Sign in with your email address and password.'),
        findsOneWidget,
      );

      // Verify Email Address field
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('name@example.com'), findsOneWidget);

      // Verify Password field
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);

      // Verify Sign In CTA
      expect(find.text('Sign In'), findsOneWidget);

      // Ensure Phone Number UI, OTP Request, and +251 are absent
      expect(find.text('Request OTP Code'), findsNothing);
      expect(find.text('Mobile / Email'), findsNothing);
      expect(find.text('+251'), findsNothing);
      expect(find.text('Phone'), findsNothing);
    });

    testWidgets('Validates empty and invalid email format', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final signInBtn = find.text('Sign In');

      // 1. Empty submit
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email address.'), findsOneWidget);

      // 2. Invalid email format
      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com'),
        'notanemail',
      );
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('Quick demo roles autofill email and password', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Shipper demo role
      await tester.tap(find.text('Shipper'));
      await tester.pumpAndSettle();

      expect(find.text('shipper@habeshafreight.et'), findsOneWidget);
      expect(find.text('Password123!'), findsOneWidget);
    });
  });
}

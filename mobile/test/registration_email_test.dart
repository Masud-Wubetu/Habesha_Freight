import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/presentation/screens/registration_screen.dart';
import 'package:mobile/presentation/screens/verify_otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Registration Screen - Email & Password Flow', () {
    testWidgets('Renders name, email, and password fields without any phone UI',
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
          home: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify account credentials section
      expect(find.text('Account Credentials'), findsOneWidget);

      // Verify Full Name field exists
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your full name'), findsOneWidget);

      // Verify Email Address field exists
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('name@example.com'), findsOneWidget);

      // Verify Password field exists
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('At least 6 characters'), findsOneWidget);

      // Ensure Phone Number UI and +251 country code are completely absent
      expect(find.text('Phone Number'), findsNothing);
      expect(find.text('+251'), findsNothing);
      expect(find.text('9XX XXX XXX'), findsNothing);

      // Verify Continue button exists
      expect(find.text('Continue to Verification'), findsOneWidget);
    });

    testWidgets('Shows validation error if name is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final continueBtn = find.text('Continue to Verification');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name.'), findsWidgets);
    });

    testWidgets('Shows validation error if email format is invalid',
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
          home: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your full name'),
        'Masud Wubetu',
      );

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com'),
        'invalid-email',
      );

      final continueBtn = find.text('Continue to Verification');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsWidgets);
    });

    testWidgets('Shows validation error if password is under 6 characters',
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
          home: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your full name'),
        'Masud Wubetu',
      );

      // Enter valid email
      await tester.enterText(
        find.widgetWithText(TextField, 'name@example.com'),
        'masud@example.com',
      );

      // Enter short password
      await tester.enterText(
        find.widgetWithText(TextField, 'At least 6 characters'),
        '123',
      );

      final continueBtn = find.text('Continue to Verification');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters long.'),
        findsWidgets,
      );
    });

    testWidgets('VerifyOtpScreen renders email and displays verification UI',
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
          home: const VerifyOtpScreen(
            email: 'masud@example.com',
            demoOtp: '123456',
            fullName: 'Masud Wubetu',
            role: 'SHIPPER',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(
        find.text(
          'Please enter the 6-digit verification code sent to your email address.',
        ),
        findsOneWidget,
      );
      expect(find.text('VERIFICATION EMAIL'), findsOneWidget);
      expect(find.text('masud@example.com'), findsOneWidget);
      expect(find.text('Verify & Continue'), findsOneWidget);
      expect(find.text('Fill Test OTP: 123456'), findsOneWidget);
    });
  });
}

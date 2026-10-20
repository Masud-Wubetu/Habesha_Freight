import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/registration_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabeshaFreightApp());
}

class HabeshaFreightApp extends StatelessWidget {
  const HabeshaFreightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegistrationScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}


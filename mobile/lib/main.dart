import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/shipper_features/page20.dart';

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
      home: const SubmitFreightBidScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/page20': (context) => const SubmitFreightBidScreen(),
      },
    );
  }
}


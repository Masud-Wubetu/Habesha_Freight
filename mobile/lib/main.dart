import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            'Habesha Freight Mobile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}


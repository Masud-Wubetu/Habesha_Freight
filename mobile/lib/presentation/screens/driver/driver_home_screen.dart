
import 'package:flutter/material.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = true;

  // Main theme colors
  static const Color navy = Color(0xFF0F172A);
  static const Color gold = Color(0xFFFFB300);
  static const Color background = Color(0xFF0B1120);
  static const Color muted = Color(0xFF94A3B8);
  static const Color blue = Color(0xFF4385D7);
  static const Color green = Color(0xFF239B70);

  // Dark UI card colors
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Driver Dashboard',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your logistics overview',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

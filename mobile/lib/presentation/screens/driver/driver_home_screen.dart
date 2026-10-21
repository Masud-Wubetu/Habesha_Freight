
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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAvailabilityCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Dashboard header
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Dashboard',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
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
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: textWhite,
            size: 25,
          ),
        ),
      ],
    );
  }

  // Driver availability card
  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isAvailable
                  ? green.withValues(alpha: 0.15)
                  : muted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isAvailable
                  ? Icons.local_shipping_rounded
                  : Icons.pause_circle_outline_rounded,
              color: _isAvailable ? green : muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability Status',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isAvailable
                      ? 'Available for Loads'
                      : 'Currently Offline',
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isAvailable
                      ? 'Ready to receive delivery requests'
                      : 'You will not receive new requests',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeThumbColor: gold,
            activeTrackColor: gold.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';

class DirectCargoOffersScreen extends StatefulWidget {
  const DirectCargoOffersScreen({super.key, this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  State<DirectCargoOffersScreen> createState() =>
      _DirectCargoOffersScreenState();
}

class _DirectCargoOffersScreenState
    extends State<DirectCargoOffersScreen> {
  static const Color _background = Color(0xFF061426);
  static const Color _surface = Color(0xFF0E1C2F);
  static const Color _surfaceHigh = Color(0xFF132A44);
  static const Color _border = Color(0xFF1E3A5F);
  static const Color _gold = Color(0xFFFFB21A);
  static const Color _green = Color(0xFF32D6A0);
  static const Color _muted = Color(0xFF91A4BC);
  static const Color _white = Color(0xFFF4F7FC);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _surfaceHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleDriverNavigation(int index) {
    switch (index) {
      case 0:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('loads');
        } else {
          _showMessage('Available Loads screen is not connected yet');
        }
        break;
      case 1:
        // This is the current Offers screen.
        break;
      case 2:
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (widget.onNavigate != null) {
          widget.onNavigate!.call('home');
        } else {
          _showMessage('Home screen navigation is not connected yet');
        }
        break;
      case 3:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('bids');
        } else {
          _showMessage('Bids screen is not connected yet');
        }
        break;
      case 4:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('tracking');
        } else {
          _showMessage('Tracking screen is not connected yet');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeading(),
                    const SizedBox(height: 16),

                    // Page 18 offer content will be added in Parts 2–5.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: 1,
        onTap: _handleDriverNavigation,
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(
          bottom: BorderSide(color: Color(0xFF10243B)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: _gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Habesha',
                        style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: 'Freight',
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 18, height: 1.05),
                ),
                SizedBox(height: 2),
                Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFF172E49)),
            ),
            child: const Row(
              children: [
                Text(
                  'EN',
                  style: TextStyle(
                    color: _white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.language_rounded,
                  color: _muted,
                  size: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _showMessage('Profile selected'),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _background,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct Cargo Offers',
          style: TextStyle(
            color: _white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage direct offers from shippers',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

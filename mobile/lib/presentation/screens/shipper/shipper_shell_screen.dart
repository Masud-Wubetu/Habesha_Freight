
import 'package:flutter/material.dart';

import 'package:mobile/presentation/screens/shipper/freight_history_screen.dart';
import 'package:mobile/presentation/screens/shipper/preferred_directory_screen.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

class ShipperShellScreen extends StatefulWidget {
  const ShipperShellScreen({super.key});

  @override
  State<ShipperShellScreen> createState() =>
      _ShipperShellScreenState();
}

class _ShipperShellScreenState extends State<ShipperShellScreen> {
  int _currentIndex = 0;

  // Pages managed by the Shipper shell.
  late final List<Widget> _pages = [
    _buildHomePage(),
    const FreightHistoryScreen(),
    _buildPostLoadPage(),
    _buildBidsPage(),
    _buildTrackingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onAddPressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A111F),
        title: const Text(
          'HabeshaFreight',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Shipper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your freight and find trusted carriers.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _homeAction(
              icon: Icons.people_alt_outlined,
              title: 'Preferred Directory',
              description: 'Browse your preferred transport partners.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PreferredDirectoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _homeAction(
              icon: Icons.history,
              title: 'Freight History',
              description: 'View completed shipments and receipts.',
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeAction({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF131C31),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFB300), size: 30),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPostLoadPage() {
    return _placeholderPage(
      'Post Load',
      'Create a new freight request.',
      Icons.add_box_outlined,
    );
  }

  Widget _buildBidsPage() {
    return _placeholderPage(
      'Bids',
      'Review offers from transport providers.',
      Icons.gavel,
    );
  }

  Widget _buildTrackingPage() {
    return _placeholderPage(
      'Tracking',
      'Track your active shipments.',
      Icons.location_on_outlined,
    );
  }

  Widget _placeholderPage(
    String title,
    String description,
    IconData icon,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A111F),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFB300), size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

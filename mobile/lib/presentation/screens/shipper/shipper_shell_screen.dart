import 'package:flutter/material.dart';

import 'package:mobile/presentation/screens/shipper/freight_history_screen.dart';
import 'package:mobile/presentation/screens/shipper_features/page06.dart';
import 'package:mobile/presentation/screens/shipper_features/page09.dart';
import 'package:mobile/presentation/screens/shipper_features/page10.dart';
import 'package:mobile/presentation/screens/shipper_features/page23.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

class ShipperShellScreen extends StatefulWidget {
  const ShipperShellScreen({super.key});

  @override
  State<ShipperShellScreen> createState() => _ShipperShellScreenState();
}

class _ShipperShellScreenState extends State<ShipperShellScreen> {
  int _currentIndex = 0;

  // Real production screens managed by the Shipper shell
  late final List<Widget> _pages = [
    const ShipperActiveHubScreen(),
    const FreightHistoryScreen(),
    const PostCargoRequestScreen(),
    const Page09Screen(),
    const Page10Screen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: const {0: 0, 1: 1, 3: 2, 4: 3}[_currentIndex] ?? -1,
        onItemSelected: (i) =>
            setState(() => _currentIndex = const [0, 1, 3, 4][i]),
        onAddPressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
    );
  }
}

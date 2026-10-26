import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/driver/available_loads_screen.dart';
import 'package:mobile/presentation/screens/driver/direct_offers_screen.dart';
import 'package:mobile/presentation/screens/driver/driver_home_screen.dart';

class DriverShellScreen extends StatelessWidget {
  const DriverShellScreen({super.key, this.initialTab = 2});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    switch (initialTab) {
      case 0:
        return const AvailableFreightLoadsScreen();
      case 1:
        return const DirectCargoOffersScreen();
      case 2:
      default:
        return const DriverHomeScreen();
    }
  }
}

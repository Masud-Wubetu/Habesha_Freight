import 'package:flutter/material.dart';

class ShipperBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onAddPressed;

  const ShipperBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    this.onAddPressed,
  });

  static const Color bgColor = Color(0xFF0A111F);
  static const Color primaryYellow = Color(0xFFFFB300);
  static const Color textMuted = Color(0xFF8B95A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: Color(0xFF1F2A40), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Shipments',
              index: 1,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: onAddPressed,
                  backgroundColor: primaryYellow,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_rounded, size: 30),
                ),
              ),
            ),
            _buildNavItem(icon: Icons.gavel_rounded, label: 'Bids', index: 2),
            _buildNavItem(
              icon: Icons.location_on_rounded,
              label: 'Tracking',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onItemSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: isActive ? primaryYellow : textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? primaryYellow : textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

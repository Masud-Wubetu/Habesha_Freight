
import 'package:flutter/material.dart';

class DriverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DriverBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _navy = Color(0xFF101B2D);
  static const Color _gold = Color(0xFFFFC857);
  static const Color _muted = Color(0xFF9BA8BA);

  static const List<IconData> _icons = [
    Icons.local_shipping_rounded,
    Icons.local_offer_outlined,
    Icons.dashboard_outlined,
    Icons.gavel,
    Icons.location_on_outlined,
  ];

  static const List<String> _labels = [
    'Load',
    'Offer',
    'Home',
    'Bids',
    'Tracking',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navy,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_labels.length, (index) {
            final bool isActive = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          end: isActive ? _gold : _muted,
                        ),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        builder: (context, color, child) => Transform.scale(
                          scale: isActive ? 1.08 : 1,
                          child: Icon(
                            _icons[index],
                            size: 23,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? _gold : _muted,
                        ),
                        child: Text(_labels[index]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EthiopianFlag extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const EthiopianFlag({
    super.key,
    this.width = 28,
    this.height = 18,
    this.borderRadius = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _EthiopianFlagPainter(),
        ),
      ),
    );
  }
}

class _EthiopianFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripeHeight = size.height / 3;

    // Green stripe (Top)
    final greenPaint = Paint()..color = AppColors.flagGreen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeHeight), greenPaint);

    // Yellow stripe (Middle)
    final yellowPaint = Paint()..color = AppColors.flagYellow;
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight),
      yellowPaint,
    );

    // Red stripe (Bottom)
    final redPaint = Paint()..color = AppColors.flagRed;
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight),
      redPaint,
    );

    // Center Blue Circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height * 0.28;
    final bluePaint = Paint()..color = AppColors.flagBlue;
    canvas.drawCircle(center, radius, bluePaint);

    // Center Yellow Star
    final starPaint = Paint()
      ..color = AppColors.flagYellow
      ..style = PaintingStyle.fill;

    final starPath = Path();
    const numPoints = 5;
    final outerRadius = radius * 0.75;
    final innerRadius = radius * 0.35;

    for (int i = 0; i < numPoints * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / numPoints) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

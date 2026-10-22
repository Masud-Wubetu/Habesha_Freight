import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class CorridorRadarMapCard extends StatefulWidget {
  final String speedText;
  final bool isGpsActive;
  final String originCity;
  final String departureTime;
  final String destinationCorridor;
  final String destinationStatus;
  final String driverStatus;
  final String coordinates;
  final String routeWaypoints;
  final VoidCallback? onMapTap;
  final bool enableAnimation;

  const CorridorRadarMapCard({
    super.key,
    this.speedText = '68 km/h',
    this.isGpsActive = true,
    this.originCity = 'Addis Ababa',
    this.departureTime = 'Departed 04:30',
    this.destinationCorridor = 'Awash Corridor',
    this.destinationStatus = 'Next Port Drop',
    this.driverStatus = 'Driver (Cruising)',
    this.coordinates = 'LAT: 9.02, LNG: 39.80',
    this.routeWaypoints = 'Addis Ababa ➔ Modjo ➔ Awash',
    this.onMapTap,
    this.enableAnimation = true,
  });

  @override
  State<CorridorRadarMapCard> createState() => _CorridorRadarMapCardState();
}

class _CorridorRadarMapCardState extends State<CorridorRadarMapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.enableAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: CORRIDOR TELEMETRY | 68 km/h • GPS Active
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.satellite_alt_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CORRIDOR\nTELEMETRY',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      widget.speedText,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GPS\nActive',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color: const Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tactical Radar Map Area
          InkWell(
            onTap: widget.onMapTap,
            child: Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF070D18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Dot Matrix Grid Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DotMatrixAndTrajectoryPainter(
                        pulseValue: _pulseController.value,
                      ),
                    ),
                  ),

                  // Origin Node: Addis Ababa (Bottom Left)
                  Positioned(
                    left: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF042F1A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF15803D)),
                          ),
                          child: Text(
                            widget.originCity,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4ADE80),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.departureTime,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Destination Node: Awash Corridor (Top Right)
                  Positioned(
                    right: 20,
                    top: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF450A0A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFB91C1C)),
                          ),
                          child: Text(
                            widget.destinationCorridor,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF87171),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.destinationStatus,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Moving Truck Marker in Center of Trajectory
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: 40,
                        bottom: 40,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Floating Badge: Driver (Cruising)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB45309),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.driverStatus,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Truck Icon with Pulsing Halo
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.gold,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.25 + _pulseController.value * 0.35,
                                      ),
                                      blurRadius: 14 + _pulseController.value * 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_shipping_rounded,
                                  color: AppColors.gold,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Telemetry Coordinates
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.coordinates,
                                  style: GoogleFonts.sourceCodePro(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF7DD3FC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Route Schematic at Bottom of Card: Addis Ababa ➔ Modjo ➔ Awash | Optimal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.alt_route_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 11),
                        children: [
                          TextSpan(
                            text: 'Addis Ababa',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const TextSpan(
                            text: ' ➔ Modjo ➔ Awash',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF166534)),
                  ),
                  child: Text(
                    'Optimal',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dot-matrix tactical grid and dashed trajectory arc
class _DotMatrixAndTrajectoryPainter extends CustomPainter {
  final double pulseValue;

  _DotMatrixAndTrajectoryPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw dot matrix background
    final dotPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    const spacing = 16.0;
    for (double x = 8; x < size.width; x += spacing) {
      for (double y = 8; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    // 2. Trajectory Arc: Curves from bottom-left (40, size.height - 40) to top-right (size.width - 40, 40)
    final p0 = Offset(40, size.height - 40);
    final p2 = Offset(size.width - 40, 40);
    final p1 = Offset(size.width * 0.45, size.height * 0.35); // Control point

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    // Glowing underlying line
    final glowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawPath(path, glowPaint);

    // Dashed trajectory line
    final trajectoryPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed path
    for (double t = 0.0; t < 1.0; t += 0.04) {
      final start = _bezierPoint(p0, p1, p2, t);
      final end = _bezierPoint(p0, p1, p2, math.min(1.0, t + 0.02));
      canvas.drawLine(start, end, trajectoryPaint);
    }

    // Start node dot (Green)
    final startDot = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(p0, 5, startDot);
    canvas.drawCircle(
      p0,
      8 + pulseValue * 3,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // End node dot (Red/Pink)
    final endDot = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(p2, 5, endDot);
    canvas.drawCircle(
      p2,
      8 + (1 - pulseValue) * 3,
      Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  Offset _bezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1 - t;
    final x = u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx;
    final y = u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _DotMatrixAndTrajectoryPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}

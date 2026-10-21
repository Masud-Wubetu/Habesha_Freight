import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiveCorridorTrackingApp());
}

/// Standalone runnable wrapper for testing & Chrome preview of Page 22
class LiveCorridorTrackingApp extends StatelessWidget {
  const LiveCorridorTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight - Live Corridor Tracking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LiveCorridorTrackingScreen(),
    );
  }
}

// Convenient alias for Page 22
typedef Page22Screen = LiveCorridorTrackingScreen;

class LiveCorridorTrackingScreen extends StatefulWidget {
  final String initialLanguage;
  final bool enableAnimation;

  const LiveCorridorTrackingScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.enableAnimation = true,
  });

  @override
  State<LiveCorridorTrackingScreen> createState() => _LiveCorridorTrackingScreenState();
}

class _LiveCorridorTrackingScreenState extends State<LiveCorridorTrackingScreen>
    with SingleTickerProviderStateMixin {
  // Language state
  late String _selectedLanguage;

  // Telemetry dynamic states
  final double _completionRatio = 0.65; // 65% Completed
  final double _speed = 68.0; // 68 km/h
  final double _distanceRemaining = 140.0; // 140 km
  final double _totalDistance = 452.0; // 452 km
  final int _cargoTemp = -5; // -5°C
  bool _podVerified = false;
  String _otpInput = '';

  // Pulsing animation for radar and GPS indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _t(String en, String am) => _selectedLanguage == 'አማ' ? am : en;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.enableAnimation) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = (_selectedLanguage == 'EN') ? 'አማ' : 'EN';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF132033),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        content: Text(
          _selectedLanguage == 'EN'
              ? 'Language changed to English'
              : 'ቋንቋ ወደ አማርኛ ተቀይሯል (Amharic)',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070F1C),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Top App Bar
                _buildHeader(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Corridor Run Bar
                        _buildActiveCorridorRunCard(),

                        const SizedBox(height: 12),

                        // A1 Transit Route Map View
                        _buildTransitMapCard(),

                        const SizedBox(height: 12),

                        // Corridor Telemetry & Milestones Card
                        _buildCorridorTelemetryCard(),

                        const SizedBox(height: 12),

                        // 2x2 Telemetry Metrics Grid
                        _buildTelemetryMetricsGrid(),

                        const SizedBox(height: 16),

                        // Operational Steering Controls Header & Actions
                        _buildSteeringControlsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF132033),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Habesha',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Freight',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFF59E0B),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _t('LOGISTICS EXCHANGE', 'የጭነት ልውውጥ'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions: Language Switcher & Avatar
          Row(
            children: [
              InkWell(
                onTap: _toggleLanguage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111D2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF22354E), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedLanguage,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.translate_rounded,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _showProfileModal,
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Active Corridor Run Card (Waybill #HF-9012, GPS Locked)
  // ---------------------------------------------------------------------------
  Widget _buildActiveCorridorRunCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1829),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF162B44),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Green indicator & Waybill Title
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('ACTIVE CORRIDOR RUN', 'ንቁ የኮሪደር ጉዞ'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Waybill #HF-9012',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: GPS Locked Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF111D2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2D42), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _t('GPS Locked', 'ጂፒኤስ ተቆልፏል'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // A1 Transit Route Map View Card
  // ---------------------------------------------------------------------------
  Widget _buildTransitMapCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2D42), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Custom Painter representing the A1 transit road corridor
            Positioned.fill(
              child: CustomPaint(
                painter: _A1CorridorMapPainter(
                  pulseValue: _pulseAnimation.value,
                ),
              ),
            ),

            // Top Badges Overlay
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // A1 Transit Route badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09121D).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1F2E45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          color: Color(0xFFF59E0B),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _t('A1 Transit Route', 'A1 የትራንዚት መስመር'),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Satellite Ping Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09121D).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1F2E45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cell_tower_rounded,
                          color: Color(0xFF38BDF8),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Sat 12/14 Ping',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Live Point Overlay Card
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1626).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2D42)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_shipping_rounded,
                          color: Color(0xFF0F172A),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Live Point', 'የአሁን ቦታ'),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _t('Awash National Park Bypass', 'አዋሽ ብሔራዊ ፓርክ ማለፊያ'),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _t('Bearing', 'አቅጣጫ'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '84° ',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF34D399),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'ENE',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Corridor Telemetry & Milestones Card
  // ---------------------------------------------------------------------------
  Widget _buildCorridorTelemetryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF162B44)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + "Corridor Telemetry" + "65% Completed"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _t('Corridor Telemetry', 'የኮሪደር መረጃ'),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF065F46)),
                ),
                child: Text(
                  _t('65% Completed', '65% ተጠናቋል'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Progress Track with Truck Thumb Indicator
          LayoutBuilder(
            builder: (context, constraints) {
              final double trackWidth = constraints.maxWidth;
              final double thumbPosition = trackWidth * _completionRatio - 12;

              return SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Container(
                      height: 6,
                      width: trackWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF172538),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Active completed bar (Green/Teal to Amber gradient)
                    Container(
                      height: 6,
                      width: trackWidth * _completionRatio,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Moving Truck marker thumb
                    Positioned(
                      left: math.max(0, thumbPosition),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_shipping_rounded,
                            color: Color(0xFF0F172A),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Milestone 1: Addis Ababa (Kality Hub)
          _buildMilestoneRow(
            icon: Icons.check_rounded,
            iconBgColor: const Color(0xFF064E3B),
            iconColor: const Color(0xFF34D399),
            title: 'Addis Ababa (Kality Hu...)',
            subtitle: _t('Departed 05:30 AM EAT', 'ተነስቷል 05:30 ጧት'),
            badgeText: _t('Passed', 'አልፏል'),
            badgeBgColor: const Color(0xFF063327),
            badgeTextColor: const Color(0xFF34D399),
            showConnectingLine: true,
          ),

          // Milestone 2: Adama Expressway Toll
          _buildMilestoneRow(
            icon: Icons.check_rounded,
            iconBgColor: const Color(0xFF064E3B),
            iconColor: const Color(0xFF34D399),
            title: 'Adama Expressway T...',
            subtitle: _t('Cleared 07:12 AM EAT', 'አልፏል 07:12 ጧት'),
            badgeText: _t('Passed', 'አልፏል'),
            badgeBgColor: const Color(0xFF063327),
            badgeTextColor: const Color(0xFF34D399),
            showConnectingLine: true,
          ),

          // Milestone 3: Awash Checkpoint (ACTIVE)
          _buildMilestoneRow(
            icon: Icons.radio_button_checked_rounded,
            iconBgColor: const Color(0xFF451A03),
            iconColor: const Color(0xFFF59E0B),
            title: 'Awash Checkpoi...',
            hasActiveDot: true,
            subtitle: _t(
              'Cruising: 68 km/h • Weight Scan Queue Clear',
              'ፍጥነት፡ 68 ኪ.ሜ/ሰ • የሚዛን ሰልፍ የለም',
            ),
            badgeText: _t('Active', 'በሂደት'),
            badgeBgColor: const Color(0xFF451A03),
            badgeTextColor: const Color(0xFFF59E0B),
            badgeBorderColor: const Color(0xFF78350F),
            showConnectingLine: true,
          ),

          // Milestone 4: Dire Dawa Free Trade Zone
          _buildMilestoneRow(
            icon: Icons.flag_outlined,
            iconBgColor: const Color(0xFF132033),
            iconColor: const Color(0xFF94A3B8),
            title: 'Dire Dawa Free Trade Zo...',
            subtitle: _t('Scheduled Terminal Gate B', 'የተመደበው በር ቢ'),
            badgeText: _t('ETA 3h 15m', 'የሚደርስበት 3ሰ 15ደ'),
            badgeBgColor: const Color(0xFF111D2E),
            badgeTextColor: const Color(0xFFCBD5E1),
            showConnectingLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    Color? badgeBorderColor,
    bool hasActiveDot = false,
    bool showConnectingLine = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step icon and vertical connector
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 15),
                ),
              ),
              if (showConnectingLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF1E2D42),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Milestone details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasActiveDot) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(6),
              border: badgeBorderColor != null
                  ? Border.all(color: badgeBorderColor)
                  : null,
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                color: badgeTextColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2x2 Telemetry Metrics Grid
  // ---------------------------------------------------------------------------
  Widget _buildTelemetryMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1: Cruising Speed & Remaining Distance
          Row(
            children: [
              // Cruising Speed
              Expanded(
                child: _buildMetricTile(
                  title: _t('CRUISING SPEED', 'የጉዞ ፍጥነት'),
                  topIcon: Icons.speed_rounded,
                  topIconColor: const Color(0xFF2DD4BF),
                  mainValue: '${_speed.round()}',
                  unit: 'km/h',
                  bottomWidget: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _t('Speed Limit (80) Safe', 'ፍጥነት (80) ደህንነቱ የተጠበቀ'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF10B981),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Remaining Distance
              Expanded(
                child: _buildMetricTile(
                  title: _t('REMAINING', 'የቀረ ርቀት'),
                  topIcon: Icons.straighten_rounded,
                  topIconColor: const Color(0xFF38BDF8),
                  mainValue: '${_distanceRemaining.round()}',
                  unit: 'km',
                  bottomWidget: Text(
                    _t(
                      'Total run: ${_totalDistance.round()} km',
                      'አጠቃላይ: ${_totalDistance.round()} ኪ.ሜ',
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Next Toll / Gate & Cargo Temperature
          Row(
            children: [
              // Next Toll / Gate
              Expanded(
                child: _buildMetricTile(
                  title: _t('NEXT TOLL / GATE', 'ቀጣይ መክፈያ / በር'),
                  topIcon: Icons.toll_outlined,
                  topIconColor: const Color(0xFFF59E0B),
                  mainValue: 'Mojo-Awash Toll',
                  isSmallValue: true,
                  bottomWidget: Text(
                    _t('Lane 3 FastPass (E-Tag)', 'ሌን 3 ፋስትፓስ (ኢ-ታግ)'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF59E0B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Cargo Temp (Cold-Chain)
              Expanded(
                child: _buildMetricTile(
                  title: _t('CARGO TEMP', 'የጭነት ሙቀት'),
                  topIcon: Icons.ac_unit_rounded,
                  topIconColor: const Color(0xFF60A5FA),
                  mainValue: '$_cargoTemp°C',
                  valueColor: const Color(0xFF38BDF8),
                  bottomWidget: Row(
                    children: [
                      const Icon(
                        Icons.sensors_rounded,
                        color: Color(0xFF10B981),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _t('Sensor Seal OK', 'የሴንሰር ማህተም ትክክል'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF10B981),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required IconData topIcon,
    required Color topIconColor,
    required String mainValue,
    String? unit,
    Color? valueColor,
    bool isSmallValue = false,
    required Widget bottomWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1829),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF162B44)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(topIcon, color: topIconColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),

          // Main Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  mainValue,
                  style: GoogleFonts.outfit(
                    color: valueColor ?? Colors.white,
                    fontSize: isSmallValue ? 15 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Subtext widget
          bottomWidget,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Operational Steering Controls Section
  // ---------------------------------------------------------------------------
  Widget _buildSteeringControlsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('OPERATIONAL STEERING CONTROLS', 'የክንውን መቆጣጠሪያዎች'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _t('Active Mode', 'ንቁ ሁነታ'),
                style: GoogleFonts.inter(
                  color: const Color(0xFFF59E0B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Verify POD OTP Pill Button
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _showPodOtpModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1829),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _podVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _podVerified ? Icons.check_circle_rounded : Icons.key_rounded,
                      color: _podVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _podVerified
                          ? _t('POD Verified (Release OK)', 'ማስረከቢያ ተረጋግጧል')
                          : _t('Verify POD OTP', 'የማስረከቢያ OTP አረጋግጥ'),
                      style: GoogleFonts.inter(
                        color: _podVerified ? const Color(0xFF10B981) : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SOS Corridor Emergency Banner Card
          InkWell(
            onTap: _showSosEmergencyModal,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF991B1B),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF991B1B).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _t('SOS Corridor Emergency', 'የአደጋ ጊዜ ድጋፍ'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 24/7 Hotline Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF450A0A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _t('24/7 Hotline', '24/7 መስመር'),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact Card: Selamawit (Abebe Trading Corp)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1829),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF162B44)),
            ),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'img',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Company Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Selamawit ...',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Abebe Trading Corp • Di...',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Chat Action Button
                InkWell(
                  onTap: _showMessageModal,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF132033),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF23354E)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Call Action Button
                InkWell(
                  onTap: _showCallModal,
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.phone_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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

  // ---------------------------------------------------------------------------
  // Interactive Modals & Bottom Sheets
  // ---------------------------------------------------------------------------

  // POD OTP Verification Modal
  void _showPodOtpModal() {
    String tempPin = _otpInput;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C1829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _t('Verify Proof of Delivery (POD)', 'የማስረከቢያ ማረጋገጫ (POD)'),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Waybill #HF-9012',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(
                      'Ask Selamawit (Abebe Trading Corp) at Dire Dawa Free Trade Zone for the 6-digit confirmation OTP.',
                      'በድሬዳዋ ነፃ የንግድ ቀጠና ከሰላማዊት (አበበ ትሬዲንግ ኮርፕ) የተላከውን 6 አሃዝ OTP ያስገቡ።',
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // PIN Input Field
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 10,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: GoogleFonts.outfit(
                        color: const Color(0xFF475569),
                        fontSize: 22,
                        letterSpacing: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF09121D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E2D42)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        tempPin = val;
                      });
                    },
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _podVerified = true;
                          _otpInput = tempPin;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF064E3B),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              _t(
                                'POD Verified! Escrow payout released to your wallet.',
                                'POD ተረጋግጧል! ክፍያው ወደ ዋሌትዎ ገብቷል።',
                              ),
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        _t('Verify & Release Escrow Payout', 'አረጋግጥ እና ክፍያውን ልቀቅ'),
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // SOS Emergency Modal
  void _showSosEmergencyModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111D2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF991B1B)),
          ),
          title: Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t('Corridor Emergency', 'የአደጋ ጊዜ ድጋፍ'),
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  'Distress Telemetry Active: Awash National Park Bypass (km 312). GPS Coordinates: 8.98° N, 40.15° E.',
                  'የአደጋ ጥሪ መረጃ፡ አዋሽ ብሔራዊ ፓርክ ማለፊያ (ኪ.ሜ 312)። ጂፒኤስ፡ 8.98° ሰ፣ 40.15° ም።',
                ),
                style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
              ),
              const SizedBox(height: 14),
              _buildSosOption(
                icon: Icons.local_police_outlined,
                title: _t('Federal Highway Police', 'የፌደራል አውራ ጎዳና ፖሊስ'),
                number: '991',
              ),
              const SizedBox(height: 8),
              _buildSosOption(
                icon: Icons.medical_services_outlined,
                title: _t('Emergency Ambulance', 'የአደጋ ጊዜ አምቡላንስ'),
                number: '907',
              ),
              const SizedBox(height: 8),
              _buildSosOption(
                icon: Icons.support_agent_rounded,
                title: _t('Habesha 24/7 Dispatch Control', 'የሀበሻ 24/7 የቁጥጥር ማዕከል'),
                number: '+251-911-84920',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _t('Dismiss', 'ዝጋ'),
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSosOption({
    required IconData icon,
    required String title,
    required String number,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF09121D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E2D42)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFEF4444), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            number,
            style: GoogleFonts.outfit(
              color: const Color(0xFFF59E0B),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Direct Message Modal
  void _showMessageModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C1829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('Direct Message: Selamawit', 'ቀጥታ መልእክት፡ ሰላማዊት'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('Consignee Representative • Abebe Trading Corp', 'የተቀባይ ወኪል • አበበ ትሬዲንግ ኮርፕ'),
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
              ),
              const SizedBox(height: 14),
              TextField(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: _t('Type arrival query or gate instructions...', 'መልእክትዎን እዚህ ይጻፉ...'),
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF09121D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E2D42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF064E3B),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          _t('Message transmitted to Selamawit.', 'መልእክቱ ለሰላማዊት ተልኳል።'),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    _t('Send Message', 'መልእክት ላክ'),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Direct Call Modal
  void _showCallModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C1829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selamawit Tadesse',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+251-912-348-902 • Abebe Trading Corp',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF064E3B),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          _t('Connecting voice channel to receiver...', 'ድምጽ መስመር በመገናኘት ላይ...'),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: Text(
                    _t('Call Receiver Contact', 'ተቀባይን ይደውሉ'),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Profile Modal
  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F172A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dawit Transport Fleet',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Carrier Rig ET-3-84920 • Tier 1 Certified',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E2D42)),
              const SizedBox(height: 8),
              _buildModalRow(Icons.alt_route_rounded, 'Active Run: A1 Corridor Transit'),
              _buildModalRow(Icons.local_shipping_outlined, 'Cargo: 28T Wheat Bulk (Reefer Tarp)'),
              _buildModalRow(Icons.security_rounded, 'Cargo Escrow: 45,000 ETB Locked'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Custom Painter: A1 Corridor Highway Map
// -----------------------------------------------------------------------------
class _A1CorridorMapPainter extends CustomPainter {
  final double pulseValue;

  _A1CorridorMapPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Background fill
    final Paint bgPaint = Paint()..color = const Color(0xFF0D1829);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Secondary grid lines and road network
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF15263F)
      ..strokeWidth = 1.0;

    for (double i = 0; i < w; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), gridPaint);
    }
    for (double i = 0; i < h; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(w, i), gridPaint);
    }

    // 3. Terrain contour curves (Afar / Awash Valley)
    final Paint riverPaint = Paint()
      ..color = const Color(0xFF16324F).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Path riverPath = Path()
      ..moveTo(0, h * 0.45)
      ..cubicTo(w * 0.25, h * 0.35, w * 0.4, h * 0.7, w * 0.7, h * 0.5)
      ..cubicTo(w * 0.85, h * 0.35, w * 0.95, h * 0.6, w, h * 0.55);
    canvas.drawPath(riverPath, riverPaint);

    // 4. Planned Corridor Highway (A1 Transit Highway)
    final Path highwayPath = Path()
      ..moveTo(w * 0.08, h * 0.78) // Addis Ababa / Kality
      ..quadraticBezierTo(w * 0.28, h * 0.70, w * 0.42, h * 0.52) // Adama
      ..quadraticBezierTo(w * 0.55, h * 0.38, w * 0.68, h * 0.32) // Awash Bypass
      ..quadraticBezierTo(w * 0.82, h * 0.28, w * 0.94, h * 0.22); // Dire Dawa

    // Muted remaining road path (Awash -> Dire Dawa)
    final Paint remainingRoadPaint = Paint()
      ..color = const Color(0xFF243B55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highwayPath, remainingRoadPaint);

    // 5. Completed highway segment (Addis Ababa -> Awash Live Point)
    final Path completedHighwayPath = Path()
      ..moveTo(w * 0.08, h * 0.78)
      ..quadraticBezierTo(w * 0.28, h * 0.70, w * 0.42, h * 0.52)
      ..quadraticBezierTo(w * 0.55, h * 0.38, w * 0.68, h * 0.32);

    final Paint completedRoadPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(completedHighwayPath, completedRoadPaint);

    // 6. Checkpoint waypoint circles
    // Origin (Addis Ababa)
    _drawStationPoint(canvas, Offset(w * 0.08, h * 0.78), const Color(0xFF10B981), 'Addis');
    // Adama Expressway
    _drawStationPoint(canvas, Offset(w * 0.42, h * 0.52), const Color(0xFF10B981), 'Adama');
    // Destination (Dire Dawa)
    _drawStationPoint(canvas, Offset(w * 0.94, h * 0.22), const Color(0xFF64748B), 'Dire Dawa');

    // 7. Live Awash Truck Pin (Amber with pulsing beacon)
    final Offset livePoint = Offset(w * 0.68, h * 0.32);

    // Pulsing aura
    final Paint auraPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(livePoint, 14 * pulseValue, auraPaint);

    final Paint liveCirclePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(livePoint, 7, liveCirclePaint);

    final Paint liveInnerDot = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(livePoint, 3, liveInnerDot);
  }

  void _drawStationPoint(Canvas canvas, Offset offset, Color color, String label) {
    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, 4.5, dotPaint);

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF070F1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(offset, 4.5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _A1CorridorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}

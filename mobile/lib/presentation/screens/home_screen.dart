import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/corridor_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/corridor_model.dart';
import '../widgets/home/corridors_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CorridorService _corridorService = CorridorService();

  String _selectedLanguage = 'EN';
  bool _isLoadingLoads = false;
  List<Map<String, dynamic>> _backendLoads = [];

  // Active Corridor Selection for Rate Estimator (Microstep 4 & 5)
  late EthiopianCorridor _selectedCorridor;
  // ignore: unused_field
  double _cargoWeightTons = 14.0;
  late ActiveTransit _activeTransit;
  late RegionalTelemetry _telemetry;

  @override
  void initState() {
    super.initState();
    final corridors = _corridorService.getCorridors();
    _selectedCorridor = corridors.first;
    _activeTransit = _corridorService.getActiveTransit();
    _telemetry = _corridorService.getRegionalTelemetry();
    _fetchLiveLoads();
  }

  Future<void> _fetchLiveLoads() async {
    setState(() => _isLoadingLoads = true);
    final loads = await _corridorService.fetchRealLoads();
    if (!mounted) return;
    setState(() {
      _backendLoads = loads;
      _isLoadingLoads = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar Header
              _buildTopHeader(),
              const SizedBox(height: 18),

              // 2. Hero Section
              _buildHeroSection(),
              const SizedBox(height: 20),

              // 3. Live GPS Telemetry & Active Transit Card
              _buildLiveTransitCard(),
              const SizedBox(height: 24),

              // 4. Key Ethiopian Corridors
              CorridorsSection(
                corridors: _corridorService.getCorridors(),
                selectedCorridor: _selectedCorridor,
                onSelect: (c) => setState(() => _selectedCorridor = c),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 1. TOP APP BAR HEADER
  // ==========================================================================
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo + Title
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Habesha',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Freight',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'LOGISTICS PLATFORM',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Language Switcher + User Profile Avatar
        Row(
          children: [
            // Language Pill
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  dropdownColor: AppColors.card,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLanguage = val);
                  },
                  items: const [
                    DropdownMenuItem(value: 'EN', child: Text('EN')),
                    DropdownMenuItem(value: 'አም', child: Text('አም')),
                    DropdownMenuItem(value: 'OR', child: Text('OR')),
                    DropdownMenuItem(value: 'TI', child: Text('TI')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Profile Avatar
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shipper profile & credentials active.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.textDark,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. HERO SECTION
  // ==========================================================================
  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Badge Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.badgeAmberBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.badgeAmberBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'ADDIS / SHIPPER HOME DASHBOARD • ETHIOPIAN NATIONAL FREIGHT NETWORK',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.badgeAmberText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main Title
        Text(
          'Move Your Cargo.\nFind the Right Truck.',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Instant direct matching, verified carrier telemetry, and transparent corridor rates across Ethiopia.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Dual Action CTA Buttons
        Row(
          children: [
            // Primary: Find a Load
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isLoadingLoads
                            ? 'Scanning freight corridor loads from database...'
                            : _backendLoads.isNotEmpty
                                ? '${_backendLoads.length} active freight loads retrieved from PostgreSQL.'
                                : 'Corridors active: 6 freight routes ready.',
                      ),
                      backgroundColor: AppColors.card,
                    ),
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: Text(
                  'Find a Load',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Secondary: Find Trucks
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connecting to ${_telemetry.activeTrucks} verified Ethiopian carriers...',
                      ),
                      backgroundColor: AppColors.card,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Find Trucks',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.cardBorder),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // 3. LIVE GPS TELEMETRY & ACTIVE TRANSIT CARD
  // ==========================================================================
  Widget _buildLiveTransitCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live GPS Status Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeGreenText,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.badgeGreenText,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live GPS Active',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.badgeGreenText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                '${_activeTransit.speedKmH.toInt()} km/h / ${_activeTransit.etaMinutes} min',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Transit Card Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Vehicle Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: AppColors.gold,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Transit: ${_activeTransit.transitNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeTransit.carrierName,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.badgeGreenBorder),
                        ),
                        child: Text(
                          _activeTransit.status,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.badgeGreenText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'In-Transit',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Visual Route Progress Track
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track background line
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Progress line
                  FractionallySizedBox(
                    widthFactor: _activeTransit.progressPercent,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold, AppColors.badgeGreenText],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Moving indicator on track
                  FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: Align(
                      alignment: Alignment(_activeTransit.progressPercent * 2 - 1, 0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textDark,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route Origin & Destination Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trip_origin_rounded,
                        size: 12,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_activeTransit.originCity}, ${_activeTransit.originTime}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _activeTransit.destinationCity,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.badgeGreenText,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

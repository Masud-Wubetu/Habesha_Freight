import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_cargo/cargo_broadcast_success_sheet.dart';
import '../../widgets/post_cargo/cargo_classification_selector.dart';
import '../../widgets/post_cargo/corridor_waypoints_card.dart';
import '../../widgets/post_cargo/dispatch_mode_selector.dart';
import '../../widgets/post_cargo/post_cargo_step_header.dart';
import '../../widgets/post_cargo/publish_cargo_cta.dart';
import '../../widgets/post_cargo/weight_and_transit_seal_row.dart';

// Export ProofOfDeliveryInspectionScreen for Page 23 POD inspection callers & tests
export 'proofOfDeliveryInspection.dart'
    show ProofOfDeliveryInspectionScreen, ProofOfDeliveryInspectionApp;

class PostCargoRequestScreen extends StatefulWidget {
  const PostCargoRequestScreen({super.key});

  @override
  State<PostCargoRequestScreen> createState() => _PostCargoRequestScreenState();
}

class _PostCargoRequestScreenState extends State<PostCargoRequestScreen> {
  String _selectedLanguage = 'EN';
  String _selectedCargoType = 'container_40ft';
  String _origin = 'Addis Ababa (Kality Port)';
  String _destination = 'Dire Dawa (Free Trade Zone)';
  int _distanceKm = 452;
  int _weightTons = 24;
  bool _isGpsMonitored = true;
  DispatchMode _dispatchMode = DispatchMode.openBidding;
  int _fixedOfferAmount = 52000;
  bool _isPublishing = false;

  String get _cargoLabel {
    switch (_selectedCargoType) {
      case 'dry_bulk':
        return 'Dry Bulk';
      case 'container_40ft':
        return '40ft Container';
      case 'cold_chain':
        return 'Cold Chain';
      case 'break_bulk':
        return 'Break Bulk';
      case 'hazardous':
        return 'Hazardous (ADR)';
      default:
        return 'General Cargo';
    }
  }

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _isPublishing = false);

    final modeLabel = _dispatchMode == DispatchMode.openBidding
        ? 'Open Bidding (Drivers bidding 48,000–54,000 ETB)'
        : 'Fixed Offer (${_fixedOfferAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ETB)';

    await CargoBroadcastSuccessSheet.show(
      context,
      origin: _origin,
      destination: _destination,
      cargoLabel: _cargoLabel,
      weightTons: _weightTons,
      dispatchModeTitle: modeLabel,
      isGpsMonitored: _isGpsMonitored,
      distanceKm: _distanceKm,
    );
  }

  final List<Map<String, dynamic>> _corridorHubs = const [
    {'name': 'Addis Ababa (Kality Port)', 'region': 'Sheger / Central', 'km': 0},
    {'name': 'Dire Dawa (Free Trade Zone)', 'region': 'Eastern Dry Port', 'km': 452},
    {'name': 'Modjo Dry Port (Multimodal)', 'region': 'Oromia Logistics Hub', 'km': 73},
    {'name': 'Djibouti (PK12 Terminal)', 'region': 'Red Sea Maritime', 'km': 865},
    {'name': 'Hawassa Industrial Park', 'region': 'Sidama Textile Corridor', 'km': 275},
    {'name': 'Kombolcha Dry Port', 'region': 'Amhara Northern Corridor', 'km': 376},
    {'name': 'Semera Logistics Center', 'region': 'Afar Port Gate', 'km': 588},
    {'name': 'Moyale Border Post', 'region': 'Kenya Border Highway', 'km': 770},
  ];

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _swapWaypoints() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  void _pickHub({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOrigin ? 'Select Pickup Origin' : 'Select Dropoff Destination',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ethio-Djibouti & Trans-African Freight Terminals',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _corridorHubs.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E293B), height: 1),
                  itemBuilder: (context, index) {
                    final hub = _corridorHubs[index];
                    final name = hub['name'] as String;
                    final region = hub['region'] as String;
                    final isCurrent = isOrigin ? _origin == name : _destination == name;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.gold : const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOrigin ? Icons.upload_rounded : Icons.download_rounded,
                          color: isCurrent ? const Color(0xFF0F172A) : Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        region,
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isOrigin) {
                            _origin = name;
                          } else {
                            _destination = name;
                          }
                          // Recalculate indicative distance
                          if ((_origin.contains('Addis') && _destination.contains('Dire')) ||
                              (_destination.contains('Addis') && _origin.contains('Dire'))) {
                            _distanceKm = 452;
                          } else if (_origin.contains('Djibouti') || _destination.contains('Djibouti')) {
                            _distanceKm = 865;
                          } else if (_origin.contains('Modjo') || _destination.contains('Modjo')) {
                            _distanceKm = 380;
                          } else {
                            _distanceKm = 520;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProfileTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF0F172A), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipper Cargo Posting',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'National Logistics Dispatch Wizard',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                title: Text('Active Hub & Operations (Page 06)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page06ShipperHub);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Corridor Modules Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  CorridorNavigationSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCargoStepHeader(
                language: _selectedLanguage,
                onLanguageChanged: _handleLanguageTap,
                onProfileTap: _handleProfileTap,
                currentStep: 1,
                totalSteps: 2,
                stepTitle: 'CARGO & ROUTE',
                progress: 0.5,
              ),
              const SizedBox(height: 16),

              CargoClassificationSelector(
                selectedId: _selectedCargoType,
                onSelected: (id) => setState(() => _selectedCargoType = id),
              ),
              const SizedBox(height: 16),
              CorridorWaypointsCard(
                origin: _origin,
                destination: _destination,
                distanceKm: _distanceKm,
                corridorName: 'Expressway A1',
                onOriginTap: () => _pickHub(isOrigin: true),
                onDestinationTap: () => _pickHub(isOrigin: false),
                onSwapTap: _swapWaypoints,
              ),
              const SizedBox(height: 16),
              WeightAndTransitSealRow(
                weightTons: _weightTons,
                onWeightChanged: (w) => setState(() => _weightTons = w),
                isGpsMonitored: _isGpsMonitored,
                onTransitSealToggle: (val) => setState(() => _isGpsMonitored = val),
              ),
              const SizedBox(height: 16),
              DispatchModeSelector(
                selectedMode: _dispatchMode,
                onModeChanged: (mode) => setState(() => _dispatchMode = mode),
                fixedOfferAmount: _fixedOfferAmount,
                onFixedOfferChanged: (amt) => setState(() => _fixedOfferAmount = amt),
              ),
              const SizedBox(height: 20),
              PublishCargoCta(
                onPublish: _handlePublish,
                availableTrucksCount: 42,
                isLoading: _isPublishing,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 2, // Center Post Load button active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page24MyShipments);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
          } else if (idx != 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }
}

// Aliases for page 07 / 23 semantic naming
typedef Page23Screen = PostCargoRequestScreen;
typedef Page07Screen = PostCargoRequestScreen;
typedef Page7Screen = PostCargoRequestScreen;


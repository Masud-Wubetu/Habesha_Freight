import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProofOfDeliveryInspectionApp());
}

/// Standalone runnable wrapper for testing & Chrome preview of Page 23
class ProofOfDeliveryInspectionApp extends StatelessWidget {
  const ProofOfDeliveryInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight - Proof Of Delivery Inspection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ProofOfDeliveryInspectionScreen(),
    );
  }
}

// Convenient alias for Page 23
typedef Page23Screen = ProofOfDeliveryInspectionScreen;

class ProofOfDeliveryInspectionScreen extends StatefulWidget {
  final String initialLanguage;
  final bool enableAnimation;
  final String? shipmentId;

  const ProofOfDeliveryInspectionScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.enableAnimation = true,
    this.shipmentId,
  });

  @override
  State<ProofOfDeliveryInspectionScreen> createState() =>
      _ProofOfDeliveryInspectionScreenState();
}

class _ProofOfDeliveryInspectionScreenState
    extends State<ProofOfDeliveryInspectionScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedLanguage;
  final ApiClient _api = ApiClient();
  final TextEditingController _otpController = TextEditingController();
  bool _verifying = false;

  // Interactive Checklist states
  bool _item1Verified = true;
  bool _item2Passed = true;
  bool _item3Verified = true;
  bool _item4Passed = true;

  // Photographic Evidence states
  bool _offloadProofCaptured = false;

  // Pulsing animation for Live Ops beacon
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _t(String en, String am) => _selectedLanguage == 'አማ' ? am : en;

  String? get _resolvedShipmentId {
    if (widget.shipmentId != null && widget.shipmentId!.trim().isNotEmpty) {
      return widget.shipmentId!.trim();
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) return args.trim();
    if (args is Map) {
      final id = args['shipmentId'] ?? args['shipment_id'] ?? args['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
    _otpController.dispose();
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

  int get _clearedCount {
    int count = 0;
    if (_item1Verified) count++;
    if (_item2Passed) count++;
    if (_item3Verified) count++;
    if (_item4Passed) count++;
    return count;
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
                _buildTopAppBar(),

                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub-header Pill Row (Page 23 Tag & Live Ops)
                        _buildSubHeaderPillRow(),

                        const SizedBox(height: 14),

                        // Shipment & Route Card (REQ-9840)
                        _buildShipmentRouteCard(),

                        const SizedBox(height: 12),

                        // Arrival & Geofence Verification Card
                        _buildArrivalGeofenceCard(),

                        const SizedBox(height: 16),

                        // Inspection Checklist Section
                        _buildInspectionChecklistSection(),

                        const SizedBox(height: 16),

                        // Photographic Evidence Section
                        _buildPhotographicEvidenceSection(),

                        const SizedBox(height: 16),

                        // Receiving Agent Handover Card
                        _buildReceivingAgentCard(),

                        const SizedBox(height: 20),

                        // Proceed to e-POD Signature Button
                        _buildProceedButton(),

                        const SizedBox(height: 10),

                        // Security & Cryptographic Sealing Footer
                        _buildSecurityFooter(),

                        const SizedBox(height: 16),
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
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF070F1C),
        border: Border(
          bottom: BorderSide(color: Color(0xFF132033), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button + Title
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF132033),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            _t('Navigation root reached.', 'የመነሻ ማውጫ ላይ ደርሰዋል።'),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1B2C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E2D42), width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _t('Proof Of Delivery Inspection', 'የጭነት ማስረከቢያ ፍተሻ'),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Language toggle + User Avatar
          Row(
            children: [
              InkWell(
                onTap: _toggleLanguage,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111D2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22354E), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedLanguage,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.translate_rounded,
                        color: Colors.white70,
                        size: 14,
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
                  width: 36,
                  height: 36,
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
                      size: 21,
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
  // Sub-header Pill Row (Page 23 Tag & Live Ops)
  // ---------------------------------------------------------------------------
  Widget _buildSubHeaderPillRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Badge: PAGE 23: PROOF OF DELIVERY INSPECTION
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF181814),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFFF59E0B),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _t(
                      'PAGE 23: PROOF OF DELIVERY INSPECTION',
                      'ገጽ 23፡ የጭነት ማስረከቢያ ፍተሻ',
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF59E0B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right Badge: LIVE OPS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B192A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF13324E),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                _t('LIVE OPS', 'ቀጥታ ክትትል'),
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shipment & Route Card (REQ-9840)
  // ---------------------------------------------------------------------------
  Widget _buildShipmentRouteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1829),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF162B44), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: REQ-9840 & Cargo Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REQ-9840',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF59E0B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF101F33),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1D3554), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF94A3B8),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('32 MT Dry Bulk Cargo', '32 ሜ.ቶ ደረቅ ጭነት'),
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
          const SizedBox(height: 12),

          // Route: Origin -> Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Origin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('ORIGIN', 'መነሻ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kaliti Logistics ...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),

              // Destination
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _t('DESTINATION', 'መድረሻ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mekelle Indust...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Arrival & Geofence Verification Card
  // ---------------------------------------------------------------------------
  Widget _buildArrivalGeofenceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E385C), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Building Icon + Status Title + Bay name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF063327),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF065F46), width: 1.2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.warehouse_rounded,
                    color: Color(0xFF34D399),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _t('ARRIVED AT DESTINATION', 'መድረሻው ላይ ደርሷል'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF34D399),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bay 12 South, Mekelle Industrial Park',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Info Strip: Time & Geofence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF081220),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF14243B), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF94A3B8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '14:22 EAT',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Geofence
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFF10B981),
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _t('Geofence Verified (±4m)', 'የአካባቢ ክልል ተረጋግጧል (±4m)'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF10B981),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
  // Inspection Checklist Section (4 / 4 Cleared)
  // ---------------------------------------------------------------------------
  Widget _buildInspectionChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _t('Inspection Checklist', 'የፍተሻ ማረጋገጫ ዝርዝር'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF063327),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF065F46), width: 1),
                    ),
                    child: Text(
                      '$_clearedCount / 4 Cleared',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _t('Mandatory', 'ግዴታ'),
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Item 1: Customs Seal Integrity
        _buildChecklistItem(
          index: 1,
          title: _t('Customs Seal Integrity', 'የጉምሩክ ማሸጊያ ታማኝነት'),
          subtitle: 'Seal #ET-9941 Intact & Verified',
          badgeText: _item1Verified ? 'Verified' : 'Unverified',
          isVerified: _item1Verified,
          onTap: () {
            setState(() => _item1Verified = !_item1Verified);
            _showChecklistFeedback(
              'Customs Seal',
              _item1Verified ? 'marked as Verified' : 'marked as Pending',
            );
          },
        ),

        const SizedBox(height: 8),

        // Item 2: Tarpaulin Condition
        _buildChecklistItem(
          index: 2,
          title: _t('Tarpaulin Condition', 'የሸራው ሁኔታ'),
          subtitle: 'Dry bulk waterproof • No ingress',
          badgeText: _item2Passed ? 'Passed' : 'Pending',
          isVerified: _item2Passed,
          onTap: () {
            setState(() => _item2Passed = !_item2Passed);
            _showChecklistFeedback(
              'Tarpaulin Condition',
              _item2Passed ? 'marked as Passed' : 'marked as Pending',
            );
          },
        ),

        const SizedBox(height: 8),

        // Item 3: Quantity Reconciliation
        _buildChecklistItem(
          index: 3,
          title: _t('Quantity Reconciliation', 'የመጠን ማስታረቅ'),
          subtitle: '640 of 640 Bags Counted Mat...',
          badgeText: _item3Verified ? 'Verified' : 'Unverified',
          isVerified: _item3Verified,
          onTap: () {
            setState(() => _item3Verified = !_item3Verified);
            _showChecklistFeedback(
              'Quantity Reconciliation',
              _item3Verified ? 'marked as Verified' : 'marked as Pending',
            );
          },
        ),

        const SizedBox(height: 8),

        // Item 4: Transit Shock & Structural
        _buildChecklistItem(
          index: 4,
          title: _t('Transit Shock & Structural', 'የጉዞ ድንጋጤ እና መዋቅራዊ ፍተሻ'),
          subtitle: 'Zero payload spillage or tears',
          badgeText: _item4Passed ? 'Passed' : 'Pending',
          isVerified: _item4Passed,
          onTap: () {
            setState(() => _item4Passed = !_item4Passed);
            _showChecklistFeedback(
              'Transit Shock',
              _item4Passed ? 'marked as Passed' : 'marked as Pending',
            );
          },
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1829),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVerified
                ? const Color(0xFF142B42)
                : const Color(0xFF33202A),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Number Circle
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF112338),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isVerified
                    ? const Color(0xFF042F24)
                    : const Color(0xFF28181F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isVerified
                      ? const Color(0xFF065F46)
                      : const Color(0xFF5F2636),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified
                        ? Icons.check_circle_outline_rounded
                        : Icons.pending_outlined,
                    color: isVerified
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF43F5E),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      color: isVerified
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFB7185),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChecklistFeedback(String title, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF111D2E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        content: Text(
          '$title $status.',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Photographic Evidence Section (2 of 3 captured)
  // ---------------------------------------------------------------------------
  Widget _buildPhotographicEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _t('Photographic Evidence', 'የፎቶግራፍ ማስረጃ'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _offloadProofCaptured
                  ? _t('3 of 3 captured', '3 ከ 3 ተመዝግቧል')
                  : _t('2 of 3 captured', '2 ከ 3 ተመዝግቧል'),
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 Cards Row (Photo 1, Photo 2, Add Photo 3)
        Row(
          children: [
            // Photo 1: Seal Cut (#ET-9...)
            Expanded(
              child: _buildCapturedPhotoCard(
                title: 'Seal Cut (#ET-9...',
                type: _PhotoType.seal,
                onTap: () => _showPhotoDetailModal(
                  title: 'Customs Seal Cut (#ET-9941)',
                  description:
                      'Official tamper-evident high security bolt seal verified intact prior to terminal unlatching at Mekelle Industrial Bay 12.',
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Photo 2: Cargo in Bay 12
            Expanded(
              child: _buildCapturedPhotoCard(
                title: 'Cargo in Bay 12',
                type: _PhotoType.bayCargo,
                onTap: () => _showPhotoDetailModal(
                  title: 'Cargo Position: Bay 12 South',
                  description:
                      'Full 32 MT dry bulk grain shipment unloaded into protected terminal warehouse dock under supervision.',
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Photo 3: Add Offload Proof (Action card)
            Expanded(
              child: _buildAddPhotoActionCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapturedPhotoCard({
    required String title,
    required _PhotoType type,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3550), width: 1.2),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: type == _PhotoType.seal
                ? [const Color(0xFF162F4A), const Color(0xFF0A1522)]
                : [const Color(0xFF4A3416), const Color(0xFF1A1207)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Custom Stylized Background Canvas
              CustomPaint(
                painter: _PhotoPlaceholderPainter(type: type),
              ),

              // Dark Vignette
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // Top-Right Checkmark Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF0F172A),
                      size: 14,
                      weight: 700,
                    ),
                  ),
                ),
              ),

              // Bottom Caption Overlay
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoActionCard() {
    return InkWell(
      onTap: _showAddPhotoModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: _offloadProofCaptured
              ? const Color(0xFF0A221C)
              : const Color(0xFF0C1829),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _offloadProofCaptured
                ? const Color(0xFF10B981)
                : const Color(0xFF1E3550),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _offloadProofCaptured
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF16253A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _offloadProofCaptured
                      ? Icons.check_circle_rounded
                      : Icons.add_a_photo_outlined,
                  color: _offloadProofCaptured
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _offloadProofCaptured
                  ? _t('Offload Proof', 'የማራገፊያ ማስረጃ')
                  : _t('Add Offload\nProof', 'የማራገፊያ\nማስረጃ ጨምር'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _offloadProofCaptured ? 'VERIFIED' : 'REQUIRED',
              style: GoogleFonts.inter(
                color: _offloadProofCaptured
                    ? const Color(0xFF34D399)
                    : const Color(0xFFF59E0B),
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Receiving Agent Handover Card
  // ---------------------------------------------------------------------------
  Widget _buildReceivingAgentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1829),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF162B44), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: RECEIVING AGENT HANDOVER & On-Site Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('RECEIVING AGENT HANDOVER', 'የተቀባይ ወኪል ርክክብ'),
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2236),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3D5F), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('On-Site', 'በቦታው ይገኛሉ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Agent Profile: MT Avatar + Name/Role + Call Button
          Row(
            children: [
              // Initials Avatar: MT
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D42),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E4666), width: 1),
                ),
                child: Center(
                  child: Text(
                    'MT',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFF59E0B),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mulugeta Tesfaye',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Warehouse Supervisor • Mekelle De...',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Phone Call Button
              InkWell(
                onTap: _showCallModal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF042F24),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF065F46), width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.phone_rounded,
                      color: Color(0xFF34D399),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Divider(color: Color(0xFF14243B), height: 1),

          const SizedBox(height: 10),

          // Bottom Row: ID Badge & Phone Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF94A3B8),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ID: MK-DEPOT-882',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '+251 91 234 5678',
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Proceed to e-POD Signature (Page 24) Button
  // ---------------------------------------------------------------------------
  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 4,
          shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleProceedToSignature,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _t(
                  'Proceed to e-POD Signature (Page 24)',
                  'ወደ e-POD ፊርማ ይቀጥሉ (ገጽ 24)',
                ),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Security & Cryptographic Sealing Footer
  // ---------------------------------------------------------------------------
  Widget _buildSecurityFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF10B981),
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _t(
                'Tamper-evident chain of custody cryptographic sealing',
                'የይዘት ታማኝነት በክሪፕቶግራፊክ ቴክኖሎጂ የተረጋገጠ',
              ),
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interactive Modals & Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _verifyDeliveryOtp() async {
    final shipmentId = _resolvedShipmentId;
    if (shipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t(
              'Missing shipment id — open this screen with a shipment.',
              'የጭነት መለያ የለም።',
            ),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t('Enter the delivery OTP to complete verification.', 'የማረጋገጫ OTP ያስገቡ።'),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _verifying = true);
    try {
      await _api.post(
        ApiConfig.shipmentDeliveryVerify(shipmentId),
        body: {'delivery_otp': otp},
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t(
              'Delivery verified — escrow release triggered.',
              'ማረጋገጫ ተሳክቷል — እስክሮው ተለቋል።',
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF34D399),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(e.message, style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t('Delivery verification failed.', 'ማረጋገጫ አልተሳካም።'),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _handleProceedToSignature() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C1829),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E3550)),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF34D399),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _t('Complete Delivery Verification', 'የማድረስ ማረጋገጫ ጨርስ'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
                  'All $_clearedCount / 4 checklist items verified. Enter the delivery OTP to POST /shipments/:id/delivery-verify.',
                  'ሁሉም $_clearedCount / 4 ማረጋገጫዎች ተጠናቀዋል። የማድረስ OTP ያስገቡ።',
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _t('Delivery OTP', 'የማድረስ OTP'),
                  labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF081220),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF14243B)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _verifying ? null : () => Navigator.pop(context),
              child: Text(
                _t('Review Again', 'እንደገና ይፈትሹ'),
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _verifying ? null : _verifyDeliveryOtp,
              child: Text(
                _verifying
                    ? _t('Verifying…', 'በማረጋገጥ ላይ…')
                    : _t('Verify Delivery', 'ማድረስ አረጋግጥ'),
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddPhotoModal() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _t('Capture Offload Proof', 'የማራገፊያ ማስረጃ ፎቶ አንሳ'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16253A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bay 12 Dock',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
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
                  'Capture clear evidence showing cargo stacked in Mekelle Industrial Park dock with depot supervisor oversight.',
                  'እቃው በመቐለ ኢንዱስትሪ ፓርክ ውስጥ መራገፉን የሚያሳይ ግልጽ ፎቶ ያያይዙ።',
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _offloadProofCaptured = true;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF064E3B),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          _t(
                            'Photo captured & cryptographically hashed (3 of 3 captured).',
                            'ፎቶው ተያይዟል (3 ከ 3 ተመዝግቧል)።',
                          ),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: Text(
                    _t('Simulate Camera Shutter Capture', 'ካሜራ አንሳና አስመዝግብ'),
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

  void _showPhotoDetailModal({required String title, required String description}) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF34D399),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF1E3550)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _t('Close Preview', 'ዝጋ'),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF042F24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Color(0xFF34D399),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mulugeta Tesfaye',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '+251 91 234 5678 • On-Site Supervisor',
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
              Text(
                _t(
                  'Initiate secure voice link with receiving terminal desk at Bay 12 South.',
                  'ከተቀባይ ተቆጣጣሪ ጋር የቀጥታ የስልክ ግንኙነት ያድርጉ።',
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF132033),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          _t(
                            'Calling +251 91 234 5678 (Mulugeta Tesfaye)...',
                            'ወደ +251 91 234 5678 እየተደወለ ነው...',
                          ),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: Text(
                    _t('Call Receiving Agent', 'ለተቀባይ ወኪል ይደውሉ'),
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

  void _showProfileModal() {
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
                          'Habesha Inspector Desk',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Inspector Token: INSP-ET-2024-9102',
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
              const Divider(color: Color(0xFF14243B)),
              const SizedBox(height: 8),
              _buildModalRow(
                Icons.assignment_turned_in_outlined,
                'Order: REQ-9840 (Dry Bulk Cargo)',
              ),
              _buildModalRow(
                Icons.location_on_outlined,
                'Terminal: Mekelle Industrial Park (Bay 12)',
              ),
              _buildModalRow(
                Icons.verified_user_outlined,
                'Status: Arrived & Geofence Verified (±4m)',
              ),
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
// Visual Painter for Stylized Photographic Evidence Placeholders
// -----------------------------------------------------------------------------
enum _PhotoType { seal, bayCargo }

class _PhotoPlaceholderPainter extends CustomPainter {
  final _PhotoType type;

  _PhotoPlaceholderPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    if (type == _PhotoType.seal) {
      // Draw metallic container locking bars and security seal
      final Paint barPaint = Paint()
        ..color = const Color(0xFF334E68)
        ..strokeWidth = 6.0;

      // Vertical container bar
      canvas.drawLine(Offset(w * 0.45, 0), Offset(w * 0.45, h), barPaint);

      // Horizontal latch
      final Paint latchPaint = Paint()
        ..color = const Color(0xFF627D98)
        ..strokeWidth = 8.0;
      canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(w * 0.8, h * 0.5), latchPaint);

      // Seal bolt cylinder
      final Paint boltPaint = Paint()..color = const Color(0xFF9FB3C8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: 22, height: 32),
          const Radius.circular(4),
        ),
        boltPaint,
      );

      // Red security band on seal
      final Paint bandPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.47), width: 22, height: 6),
        bandPaint,
      );
    } else {
      // Draw stacked cargo sacks in warehouse bay with warm amber light
      final Paint wallPaint = Paint()..color = const Color(0xFF261808);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), wallPaint);

      // Warm warehouse floodlight gradient
      final Paint glowPaint = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFD97706), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: w * 0.6));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);

      // Stacked bags
      final Paint sackPaint = Paint()..color = const Color(0xFFB45309);
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 4; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                col * (w / 4) + 2,
                h * 0.45 + (row * 16),
                w / 4 - 4,
                14,
              ),
              const Radius.circular(3),
            ),
            sackPaint,
          );
        }
      }

      // Warehouse bay floor
      final Paint floorPaint = Paint()..color = const Color(0xFF1C1917);
      canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.18), floorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PhotoPlaceholderPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

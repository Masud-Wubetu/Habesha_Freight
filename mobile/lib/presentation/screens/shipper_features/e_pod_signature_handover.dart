import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/escrow_service.dart';
import '../../../core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EPodSignatureApp());
}

/// Standalone runnable wrapper for testing & Chrome preview of Page 24
class EPodSignatureApp extends StatelessWidget {
  const EPodSignatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight - E-Pod Signature Upload',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const EPodSignatureScreen(),
    );
  }
}

// Convenient alias for Page 24
typedef Page24Screen = EPodSignatureScreen;

class EPodSignatureScreen extends StatefulWidget {
  final String initialLanguage;
  final bool enableAnimation;
  final String? shipmentId;

  const EPodSignatureScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.enableAnimation = true,
    this.shipmentId,
  });

  @override
  State<EPodSignatureScreen> createState() => _EPodSignatureScreenState();
}

class _EPodSignatureScreenState extends State<EPodSignatureScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedLanguage;
  final ApiClient _api = ApiClient();
  final EscrowService _escrow = EscrowService();
  bool _submitting = false;

  // Remarks TextEditingController
  late final TextEditingController _remarksController;

  // Signature points for interactive canvas
  final List<Offset> _userSignaturePoints = [];
  bool _useDefaultSignature = true;

  // Escrow & submission state
  bool _escrowSubmitted = false;

  // Pulsing animation for Live Handover beacon
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

    _remarksController = TextEditingController(
      text:
          'All 640 bags received in pristine condition. No damages or losses recorded.',
    );

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
    _remarksController.dispose();
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
                _buildTopAppBar(),

                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub-header Pill Row
                        _buildSubHeaderPillRow(),

                        const SizedBox(height: 14),

                        // Consignee & Route Card
                        _buildConsigneeRouteCard(),

                        const SizedBox(height: 14),

                        // Receiver Official Verification Card
                        _buildReceiverVerificationCard(),

                        const SizedBox(height: 14),

                        // Digital Signature Canvas Card
                        _buildSignatureCanvasCard(),

                        const SizedBox(height: 14),

                        // Handover Remarks & Notes Section
                        _buildHandoverRemarksSection(),

                        const SizedBox(height: 14),

                        // Cryptographic Proof & Escrow Card
                        _buildCryptographicProofCard(),

                        const SizedBox(height: 20),

                        // Primary Action: Submit e-POD & Authorize Escrow
                        _buildSubmitEscrowButton(),

                        const SizedBox(height: 12),

                        // Secondary Action: Download PDF Delivery Receipt
                        _buildDownloadReceiptButton(),

                        const SizedBox(height: 24),
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
                    _t('E Pod Signature Upload', 'የ e-POD ፊርማ ማረጋገጫ'),
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
  // Sub-header Pill Row
  // ---------------------------------------------------------------------------
  Widget _buildSubHeaderPillRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Badge: PAGE 24: E-POD SIGNATURE & CARGO HANDOVER
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF141D2B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1E3550),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFFF59E0B),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _t(
                      'PAGE 24: E-POD SIGNATURE & CARGO HANDOVER',
                      'ገጽ 24፡ የ e-POD ፊርማ እና የጭነት ርክክብ',
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF59E0B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right Badge: Live Handover
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF091F2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF11384E),
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
                _t('Live Handover', 'ቀጥታ ርክክብ'),
                style: GoogleFonts.inter(
                  color: const Color(0xFF34D399),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Consignee & Route Card
  // ---------------------------------------------------------------------------
  Widget _buildConsigneeRouteCard() {
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
          // Top Row: REQ-9840, Route, and Box Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191D16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'REQ-9840',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Addis Ababa → Mojo Dry Port',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.archive_outlined,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Consignee Facility Title & Name
          Text(
            _t('CONSIGNEE FACILITY', 'የተቀባይ ድርጅት'),
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ethio Agri-Export Ltd.',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Badges: Bags Count & Insurance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bags
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF38BDF8),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _t('640 Export Grade Bags', '640 የኤክስፖርት ከረጢቶች'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Full Transit Insured
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF34D399),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _t('Full Transit Insured', 'ሙሉ የጉዞ ዋስትና ያለው'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF34D399),
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Receiver Official Verification Card
  // ---------------------------------------------------------------------------
  Widget _buildReceiverVerificationCard() {
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
          // Header: RECEIVER OFFICIAL VERIFICATION + TIN / ID Validated
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('RECEIVER OFFICIAL VERIFICATION', 'ኦፊሴላዊ የተቀባይ ማረጋገጫ'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF052B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF065F46), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF34D399),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('TIN / ID Validated', 'የግብር/መታወቂያ ተረጋግጧል'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
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

          // Officer Profile: Photo Avatar + Title + Credentials
          Row(
            children: [
              // Photo Avatar with Verified Shield Overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFF78350F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          // Safety vest badge indicator
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 32,
                              height: 10,
                              color: const Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF070F1C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF10B981),
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name, Title, and TIN
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
                      _t('Depot Chief Receiving Officer', 'የመጋዘኑ ዋና ተረካቢ ኃላፊ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF10B981),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'TIN: ET-00948219-B • Modjo Hub',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFCBD5E1),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
  // Digital Signature Canvas Card
  // ---------------------------------------------------------------------------
  Widget _buildSignatureCanvasCard() {
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
          // Header Row: Edit Icon + Title + OTP Verified Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _t('Digital Signature\nCanvas', 'የዲጂታል ፊርማ\nሰሌዳ'),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF052B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF065F46), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sms_outlined,
                      color: Color(0xFF34D399),
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OTP 849201',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _t('Verified', 'ተረጋግጧል'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6EE7B7),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive / Stylized Signature Canvas Box
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: const Color(0xFF070E18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF14243B), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Signature Canvas Gesture Detector
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _useDefaultSignature = false;
                        _userSignaturePoints.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _userSignaturePoints.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _userSignaturePoints.add(Offset.zero);
                      });
                    },
                    child: CustomPaint(
                      painter: _SignatureCanvasPainter(
                        points: _userSignaturePoints,
                        useDefault: _useDefaultSignature,
                      ),
                    ),
                  ),

                  // Top Header inside Canvas: Stylus Capture & Biometric Latency
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'STYLUS CAPTURE 240Hz',
                            style: GoogleFonts.robotoMono(
                              color: const Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Biometric Latency: 12ms',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF59E0B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Info inside Canvas: Timestamp & Clear / Re-sign
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Signed at 14:38 EAT • Oct 11, 2024',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _userSignaturePoints.clear();
                              _useDefaultSignature = !_useDefaultSignature;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF111D2E),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  _useDefaultSignature
                                      ? 'Default verified signature restored.'
                                      : 'Signature canvas cleared. Draw your signature now.',
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            _t('Clear / Re-sign', 'አጥፋ / እንደገና ፈርም'),
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF59E0B),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Strip: Terminal Tablet Stylus ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF081220),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF132238)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  color: Color(0xFF34D399),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Terminal Tablet Stylus ID: ',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: 'HAB-T904-ETH',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
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
  // Handover Remarks & Notes Section
  // ---------------------------------------------------------------------------
  Widget _buildHandoverRemarksSection() {
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
          // Header: Handover Remarks & Notes + Inspect Log
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('Handover Remarks & Notes', 'የማስረከቢያ አስተያየቶች እና ማስታወሻዎች'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showInspectLogModal,
                child: Text(
                  _t('Inspect Log', 'ምዝግብ ፍተሻ'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF59E0B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Preset Chips Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Chip 1: Preset: Pristine condition
              InkWell(
                onTap: () {
                  setState(() {
                    _remarksController.text =
                        'All 640 bags received in pristine condition. No damages or losses recorded.';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101E30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Color(0xFFF59E0B),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _t('Preset: Pristine condition', 'ምርጫ፡ እንከን የለሽ ሁኔታ'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chip 2: Seals Intact
              InkWell(
                onTap: () {
                  setState(() {
                    if (!_remarksController.text.contains('Seals Intact')) {
                      _remarksController.text += ' Seals Verified Intact.';
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101E30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E3550), width: 1),
                  ),
                  child: Text(
                    _t('Seals Intact', 'ማህተሞች አልተነኩም'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Notes TextField Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF070F1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF14243B)),
            ),
            child: TextField(
              controller: _remarksController,
              maxLines: 3,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cryptographic Proof & Escrow Card
  // ---------------------------------------------------------------------------
  Widget _buildCryptographicProofCard() {
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
          // Header: CRYPTOGRAPHIC PROOF & ESCROW + Tamper-Proof Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF34D399),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _t('CRYPTOGRAPHIC PROOF & ESCROW', 'ክሪፕቶግራፊክ ማረጋገጫ እና እስክሮው'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
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
                  color: const Color(0xFF042F24),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _t('Tamper-Proof', 'የማይቀየር'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF34D399),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // SHA-256 Hash Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF070E18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF13243A)),
            ),
            child: Text(
              'SHA-256: 8f4b62d87e1a0b3c59e74d12aa9820f1249b65e94120ca9810ef8c4a938c391',
              style: GoogleFonts.robotoMono(
                color: const Color(0xFFCBD5E1),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Row: Irrevocable Handover & Smart Contract #4910
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _t(
                          'Irrevocable Handover e-POD Recorded',
                          'የማይቀለበስ የ e-POD ርክክብ ተመዝግቧል',
                        ),
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _t('Smart Contract', 'ስማርት ውል'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 9.5,
                    ),
                  ),
                  Text(
                    '#4910',
                    style: GoogleFonts.inter(
                      color: Colors.white,
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
    );
  }

  // ---------------------------------------------------------------------------
  // Action Buttons
  // ---------------------------------------------------------------------------
  Widget _buildSubmitEscrowButton() {
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
        onPressed: _showEscrowAuthorizationModal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _escrowSubmitted
                    ? _t('Escrow Released Successfully ✓', 'እስክሮው በተሳካ ሁኔታ ተለቋል ✓')
                    : _t('Submit e-POD & Authorize Escrow', 'e-POD አስመዝግብና እስክሮው ፍቀድ'),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontSize: 16,
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

  Widget _buildDownloadReceiptButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF111D2E),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF1E3550), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showDownloadReceiptModal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.download_rounded,
              color: Color(0xFFF59E0B),
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _t('Download PDF Delivery Receipt', 'የፒዲኤፍ ርክክብ ደረሰኝ አውርድ'),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interactive Modals & Dialogs
  // ---------------------------------------------------------------------------
  Future<void> _confirmAndReleaseEscrow() async {
    final shipmentId = _resolvedShipmentId;
    if (shipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t(
              'Missing shipment id — cannot confirm delivery or release escrow.',
              'የጭነት መለያ የለም።',
            ),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.patch(ApiConfig.shipperConfirmDelivery(shipmentId));
      try {
        await _escrow.release(shipmentId);
      } on ApiException {
        // Confirm succeeded; release may already be done via OTP verify.
      }
      if (!mounted) return;
      setState(() {
        _escrowSubmitted = true;
        _submitting = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t(
              'Delivery confirmed and escrow release requested.',
              'ማድረስ ተረጋገጠ፤ እስክሮው መልቀቅ ተጠይቋል።',
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
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(e.message, style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t('Failed to confirm delivery / release escrow.', 'አልተሳካም።'),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showEscrowAuthorizationModal() {
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
                Icons.verified_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _t('Confirm e-POD & Release Escrow', 'e-POD አረጋግጥና እስክሮው ልቀቅ'),
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
                  'Confirm delivery and release freight escrow for shipment ${_resolvedShipmentId ?? '(missing id)'}?',
                  'ማድረስን አረጋግጠው የጭነት እስክሮውን ይልቀቁ?',
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF062A1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF065F46)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _t('Escrow Payout', 'የእስክሮው ክፍያ'),
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          '45,000 ETB',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _t('Recipient Account', 'የተቀባይ አካውንት'),
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'CBE: 1000****8492',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _t('Cancel', 'ሰርዝ'),
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
              onPressed: _submitting ? null : () => _confirmAndReleaseEscrow(),
              child: Text(
                _submitting
                    ? _t('Submitting…', 'በመላክ ላይ…')
                    : _t('Confirm & Release', 'አረጋግጥና ልቀቅ'),
                style: GoogleFonts.inter(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDownloadReceiptModal() {
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFEF4444),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _t('Official Delivery Receipt', 'ኦፊሴላዊ የርክክብ ደረሰኝ'),
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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PDF • 1.4 MB',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Document: HF-EPOD-2024-REQ9840.pdf',
                style: GoogleFonts.robotoMono(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _t(
                  'Includes cryptographic SHA-256 seal, digital signature vector, high-resolution cargo inspection photos, and geofence coordinates.',
                  'ክሪፕቶግራፊክ ማህተም፣ ዲጂታል ፊርማ፣ የፍተሻ ፎቶዎች እና የቦታ መጋጠሚያዎችን ያካትታል።',
                ),
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.4,
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
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF132033),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          _t(
                            'Downloading HF-EPOD-2024-REQ9840.pdf...',
                            'HF-EPOD-2024-REQ9840.pdf እየወረደ ነው...',
                          ),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    _t('Save Receipt to Device', 'ደረሰኙን በስልክዎ ያስቀምጡ'),
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

  void _showInspectLogModal() {
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
              Text(
                _t('Inspection Event Audit Log', 'የፍተሻ ክንውኖች ምዝግብ'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildAuditRow('14:22 EAT', 'Geofence Entry confirmed (Bay 12)'),
              _buildAuditRow('14:26 EAT', 'Customs Seal #ET-9941 cut verified'),
              _buildAuditRow('14:32 EAT', '640 Bags offloaded and tallied'),
              _buildAuditRow('14:38 EAT', 'Stylus signature captured (HAB-T904-ETH)'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditRow(String time, String event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.robotoMono(
              color: const Color(0xFFF59E0B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              event,
              style: GoogleFonts.inter(
                color: const Color(0xFFCBD5E1),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
                          'Authorized Depot Officer',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Modjo Logistics Hub • Gate Security Desk',
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
              _buildProfileRow(Icons.inventory_2_outlined, 'Order: REQ-9840 (Ethio Agri-Export)'),
              _buildProfileRow(Icons.pin_drop_outlined, 'Destination: Mojo Dry Port'),
              _buildProfileRow(Icons.security_rounded, 'Handover Escrow: 45,000 ETB Verified'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(IconData icon, String text) {
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
// Custom Painter for Digital Signature Canvas
// -----------------------------------------------------------------------------
class _SignatureCanvasPainter extends CustomPainter {
  final List<Offset> points;
  final bool useDefault;

  _SignatureCanvasPainter({required this.points, required this.useDefault});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Dot Matrix Background
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF1E2D42).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    for (double x = 16; x < w; x += 20) {
      for (double y = 28; y < h - 20; y += 18) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    // 2. Signature Paint
    final Paint signaturePaint = Paint()
      ..color = const Color(0xFFFDBA74) // Light glowing amber
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (useDefault || points.isEmpty) {
      // Draw authentic wave signature path matching screenshot
      final Path path = Path();
      // First wave
      path.moveTo(w * 0.12, h * 0.68);
      path.quadraticBezierTo(w * 0.18, h * 0.44, w * 0.25, h * 0.52);
      path.quadraticBezierTo(w * 0.29, h * 0.58, w * 0.32, h * 0.70);
      // Second wave
      path.quadraticBezierTo(w * 0.37, h * 0.46, w * 0.43, h * 0.54);
      path.quadraticBezierTo(w * 0.47, h * 0.60, w * 0.50, h * 0.72);
      // Third wave
      path.quadraticBezierTo(w * 0.55, h * 0.48, w * 0.61, h * 0.56);
      path.quadraticBezierTo(w * 0.65, h * 0.66, w * 0.68, h * 0.74);
      // Sharp rise & descent loop
      path.lineTo(w * 0.70, h * 0.45);
      path.quadraticBezierTo(w * 0.72, h * 0.40, w * 0.74, h * 0.46);
      path.lineTo(w * 0.74, h * 0.72);
      // Final smooth horizontal tail
      path.quadraticBezierTo(w * 0.80, h * 0.45, w * 0.88, h * 0.58);

      // Underline flourish
      path.moveTo(w * 0.15, h * 0.72);
      path.quadraticBezierTo(w * 0.50, h * 0.75, w * 0.84, h * 0.70);

      canvas.drawPath(path, signaturePaint);
    } else {
      // Draw user interactively drawn strokes
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
          canvas.drawLine(points[i], points[i + 1], signaturePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignatureCanvasPainter oldDelegate) {
    return oldDelegate.points.length != points.length ||
        oldDelegate.useDefault != useDefault;
  }
}

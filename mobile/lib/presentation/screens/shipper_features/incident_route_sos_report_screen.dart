import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IncidentRouteSosReportApp());
}

/// Standalone runnable wrapper for testing & preview of Page 25
class IncidentRouteSosReportApp extends StatelessWidget {
  const IncidentRouteSosReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight - Incident Route SOS Report',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const IncidentRouteSosReportScreen(),
    );
  }
}

// Convenient alias for Page 25
typedef Page25Screen = IncidentRouteSosReportScreen;

enum IncidentClassificationType {
  mechanicalBreakdown,
  customsDelay,
  roadBlockage,
  cargoMinorHit,
}

class IncidentRouteSosReportScreen extends StatefulWidget {
  final String initialLanguage;
  final bool enableAnimation;
  final String? shipmentId;

  const IncidentRouteSosReportScreen({
    super.key,
    this.initialLanguage = 'EN',
    this.enableAnimation = true,
    this.shipmentId,
  });

  @override
  State<IncidentRouteSosReportScreen> createState() =>
      _IncidentRouteSosReportScreenState();
}

class _IncidentRouteSosReportScreenState
    extends State<IncidentRouteSosReportScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedLanguage;
  final ApiClient _api = ApiClient();

  // Selected Classification Factor
  IncidentClassificationType _selectedClassification =
      IncidentClassificationType.mechanicalBreakdown;

  // Dispatch Authorizations Toggles
  bool _deployRoadsideHeavyRecovery = true;
  bool _notifyShipperAndInsurer = true;

  // Audio Voice Memo State
  bool _isPlayingAudio = false;
  int _audioRemainingSeconds = 42;
  Timer? _audioTimer;

  // Description Controller
  late final TextEditingController _descriptionController;

  // Pulsing animation for 24/7 Monitored & Live beacon
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Transmission state
  bool _isTransmitting = false;

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

  String get _disputeCategory {
    switch (_selectedClassification) {
      case IncidentClassificationType.mechanicalBreakdown:
        return 'OTHER';
      case IncidentClassificationType.customsDelay:
        return 'DELAY';
      case IncidentClassificationType.roadBlockage:
        return 'DELAY';
      case IncidentClassificationType.cargoMinorHit:
        return 'DAMAGE';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;

    _descriptionController = TextEditingController(
      text:
          'Heavy rear axle puncture and brake line pressure loss. Stopped safely on gravel shoulder.',
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
    _audioTimer?.cancel();
    _descriptionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = (_selectedLanguage == 'EN') ? 'አማ' : 'EN';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedLanguage == 'EN'
              ? 'Language changed to English'
              : 'ቋንቋ ወደ አማርኛ ተቀይሯል',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF132033),
      ),
    );
  }

  void _toggleAudioPlayback() {
    if (_isPlayingAudio) {
      _audioTimer?.cancel();
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      setState(() {
        _isPlayingAudio = true;
      });
      if (widget.enableAnimation) {
        _audioTimer?.cancel();
        _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          if (_audioRemainingSeconds > 0) {
            setState(() {
              _audioRemainingSeconds--;
            });
          } else {
            timer.cancel();
            setState(() {
              _isPlayingAudio = false;
              _audioRemainingSeconds = 42;
            });
          }
        });
      }
    }
  }

  void _resetAudioPlayback() {
    _audioTimer?.cancel();
    setState(() {
      _isPlayingAudio = false;
      _audioRemainingSeconds = 42;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t('Audio replay reset to 00:42', 'የድምፅ መልእክት ወደ 00:42 ተመልሷል'),
          style: GoogleFonts.inter(fontSize: 13),
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF132033),
      ),
    );
  }

  Future<void> _handleTransmitReport() async {
    final shipmentId = _resolvedShipmentId;
    if (shipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t(
              'Missing shipment id — open this screen with a shipment to file a dispute.',
              'የጭነት መለያ የለም።',
            ),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final reason = _descriptionController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t('Describe the incident before transmitting.', 'ክስተቱን ይግለጹ።'),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _isTransmitting = true);
    try {
      await _api.post(
        ApiConfig.shipperDisputes,
        body: {
          'shipment_id': shipmentId,
          'category': _disputeCategory,
          'reason':
              '${_selectedClassification.name}: $reason'
              '${_deployRoadsideHeavyRecovery ? ' [recovery requested]' : ''}'
              '${_notifyShipperAndInsurer ? ' [insurer notified]' : ''}',
        },
      );
      if (!mounted) return;
      setState(() => _isTransmitting = false);
      _showTransmissionSuccessModal();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isTransmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(e.message, style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTransmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            _t('Failed to open dispute.', 'ክርክር መክፈት አልተሳካም።'),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showTransmissionSuccessModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C192C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF34D399),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _t(
                  'Emergency SOS Transmitted',
                  'የአደጋ ጊዜ ኤስኦኤስ ተላልፏል',
                ),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                  'Incident Code SOS-ET-098 received by Central Fleet Operations Addis Ababa. Telemetry, GPS coordinates, and audio memo logged securely.',
                  'የአደጋ መለያ SOS-ET-098 በአዲስ አበባ ማዕከላዊ ፍሊት ኦፕሬሽን ተቀባይነት አግኝቷል። ቴሌሜትሪ፣ የጂፒኤስ መገኛ እና የድምፅ መዝገብ ተመዝግቧል።',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132033),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _t(
                          'Heavy Recovery Unit dispatched from Kombolcha Hub (ETA ~22 mins)',
                          'ከኮምቦልቻ ማዕከል የከባድ ተሽከርካሪ ማዳኛ ቡድን ተልኳል (የመድረሻ ጊዜ ~22 ደቂቃ)',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFD6E3FE),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _t('Acknowledge & Monitor Status', 'ተቀብለህ ሁኔታውን ተከታተል'),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCallPatrolModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C192C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF881337),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _t('Emergency SOS Patrol Hotline', 'የአደጋ ጊዜ ፓትሮል የስልክ መስመር'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF991B1B),
                  child: Icon(Icons.shield_rounded, color: Colors.white),
                ),
                title: Text(
                  _t('Kombolcha Corridor Highway Police', 'የኮምቦልቻ ኮሪደር አውራ ጎዳና ፖሊስ'),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  '+251 91 199 0000 • Sector Patrol Unit 4',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _t('Dialing Kombolcha Highway Police...', 'ወደ ኮምቦልቻ አውራ ጎዳና ፖሊስ በመደወል ላይ...'),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(_t('Call', 'ደውል')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDispatcherHotlineModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C192C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: Color(0xFF93C5FD),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _t('Central Dispatcher Hotline', 'የማዕከላዊ ዲፓቸር የስልክ መስመር'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1E293B),
                  child: Icon(Icons.support_agent_rounded, color: Color(0xFF60A5FA)),
                ),
                title: Text(
                  _t('Addis Central Fleet Operations Desk', 'የአዲስ አበባ ማዕከላዊ ፍሊት ኦፕሬሽን ዴስክ'),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  '+251 11 551 8888 • Priority 1 Link',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _t('Connecting to Dispatcher Desk...', 'ከዲፓቸር ዴስክ ጋር በመገናኘት ላይ...'),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.headset, size: 16),
                  label: Text(_t('Connect', 'ተገናኝ')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConsignmentDetailsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C192C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('Consignment Manifest & Telemetry', 'የጭነት ዝርዝር መረጃ'),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              _buildConsignmentRow('Consignment ID', 'ETH-DJ-4920'),
              _buildConsignmentRow('Cargo Type', '32 MT Dry Bulk Cargo'),
              _buildConsignmentRow('Origin', 'Kaliti Logistics Hub, Addis Ababa'),
              _buildConsignmentRow('Destination', 'Mekelle Industrial Park'),
              _buildConsignmentRow('E-Seal Number', '#ET-9941 (Intact)'),
              _buildConsignmentRow('Carrier Rig', 'Volvo FH16 (ET-3-89412)'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_t('Close', 'ዝጋ')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConsignmentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071220),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-header Pills: PAGE 25 badge and 24/7 MONITORED
                  _buildSubHeaderPills(),
                  const SizedBox(height: 14),

                  // Active Corridor Incident Protocol Card
                  _buildActiveCorridorProtocolCard(),
                  const SizedBox(height: 16),

                  // Immediate Geo-Position & GPS Lock Telemetry Card
                  _buildGeoPositionCard(),
                  const SizedBox(height: 22),

                  // Incident Classification Section
                  _buildClassificationSectionHeader(),
                  const SizedBox(height: 12),
                  _buildClassificationGrid(),
                  const SizedBox(height: 22),

                  // Incident Description & Voice Note Section
                  _buildVoiceNoteSectionHeader(),
                  const SizedBox(height: 12),
                  _buildDriverNoteCard(),
                  const SizedBox(height: 12),
                  _buildVoiceMemoPlayerCard(),
                  const SizedBox(height: 22),

                  // Automated Dispatch Authorizations Section
                  _buildDispatchAuthorizationsHeader(),
                  const SizedBox(height: 12),
                  _buildDispatchAuthorizationsCards(),
                  const SizedBox(height: 16),

                  // Call SOS Patrol & Dispatcher Hotline Row
                  _buildHotlineActionButtons(),
                  const SizedBox(height: 16),

                  // Transmit Emergency Incident Report Button
                  _buildTransmitCtaButton(),
                  const SizedBox(height: 8),

                  // Footer Telemetry Caption
                  _buildFooterCaption(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF071220),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_t('Back navigation pressed', 'ወደ ኋላ ተመልስ ተጭኗል')),
                duration: const Duration(milliseconds: 600),
              ),
            );
          }
        },
      ),
      title: Text(
        _t('Incident Route Sos Report', 'የመስመር ላይ አደጋ ጊዜ ሪፖርት'),
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        // Language Toggle Button (EN / አማ)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: _toggleLanguage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(36, 32),
              backgroundColor: const Color(0xFF132033),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF28354A)),
              ),
            ),
            child: Text(
              _selectedLanguage,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFC174),
              ),
            ),
          ),
        ),
        // User Profile Avatar
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_t('Driver Profile: M. Bekele', 'የአሽከርካሪ መገለጫ: ኤም. በቀለ')),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFFDBA74),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF431407),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeaderPills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left badge: PAGE 25: INCIDENT & ROUTE SOS REPORT
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E33),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E3250)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  size: 14,
                  color: Color(0xFFFFB95F),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _t(
                      'PAGE 25: INCIDENT & ROUTE SOS REPORT',
                      'ገጽ 25: የመስመር ላይ አደጋ እና የኤስኦኤስ ሪፖርት',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFFFFC174),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right badge: 24/7 MONITORED with pulsing green dot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF063327),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF065F46)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF34D399),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _t('24/7 MONITORED', '24/7 ክትትል የሚደረግበት'),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: const Color(0xFF34D399),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCorridorProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1728),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red Square with Alert Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFB91C1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Active Protocol badge + Incident Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF991B1B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _t(
                            'ACTIVE CORRIDOR INCIDENT PROTOCOL',
                            'ተግባራዊ የኮሪደር አደጋ ፕሮቶኮል',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _t('Incident Code', 'የአደጋ መለያ'),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          'SOS-ET-098',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Consignment ... and High Priority
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showConsignmentDetailsModal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('Consignment ...', 'ጭነት ቁጥር...'),
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF192A40),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF2E466B)),
                      ),
                      child: Text(
                        _t('High Priority', 'ከፍተኛ ቅድሚያ'),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF93C5FD),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeoPositionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges Row: GPS LOCK LOCKED + Galileo + GPS Fixed
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF063327),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF065F46)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _t('GPS LOCK LOCKED', 'የጂፒኤስ መቆለፊያ ተረጋግጧል'),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14243B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF223A5E)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.satellite_alt_rounded,
                      size: 13,
                      color: Color(0xFF93C5FD),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('Galileo + GPS Fixed', 'ጋሊሊዮ + ጂፒኤስ ተገናኝቷል'),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF93C5FD),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Immediate Geo-Position and Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF16253B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF60A5FA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('Immediate Geo-Position', 'ወቅታዊ የቦታ መገኛ'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t(
                        'A2 Northern Highway, 18 km South of Kombolcha',
                        'ኤ2 ሰሜን አውራ ጎዳና፣ ከኮምቦልቻ በስተደቡብ 18 ኪ.ሜ',
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: 11.0821° N,  Lng: 39.7340° E',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom telemetry metrics row: 3m precision | Satellite link active | 0 km/h
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF091422),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF17283E)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                // 3m precision
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.adjust_rounded,
                      size: 14,
                      color: Color(0xFF34D399),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('3m precision', 'የ3ሜ ትክክለኛነት'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD6E3FE),
                      ),
                    ),
                  ],
                ),

                // Satellite link active
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.podcasts_rounded,
                      size: 14,
                      color: Color(0xFF60A5FA),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('Satellite link active', 'የሳተላይት ግንኙነት ንቁ ነው'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD6E3FE),
                      ),
                    ),
                  ],
                ),

                // 0 km/h
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('0 km/h', '0 ኪ.ሜ/ሰ'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _t('Incident Classification', 'የአደጋው ምድብ'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _t('Select main primary factor', 'ዋናውን ምክንያት ይምረጡ'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildClassificationCard(
                type: IncidentClassificationType.mechanicalBreakdown,
                title: _t('Mechanical Breakdown', 'ሜካኒካል ብልሽት'),
                subtitle: _t('Tire Blowout / Engine / Axle', 'የጎማ መፈንዳት / ሞተር / አክሰል'),
                icon: Icons.car_repair_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildClassificationCard(
                type: IncidentClassificationType.customsDelay,
                title: _t('Customs Delay', 'የጉምሩክ መዘግየት'),
                subtitle: _t('E-Seal Glitch / Paperwork', 'የኤሌክትሮኒክ ማህተም / ሰነዶች'),
                icon: Icons.assignment_late_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildClassificationCard(
                type: IncidentClassificationType.roadBlockage,
                title: _t('Road Blockage', 'የመንገድ መዘጋት'),
                subtitle: _t('Landslide / Heavy Rain', 'የመሬት መንሸራተት / ከባድ ዝናብ'),
                icon: Icons.terrain_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildClassificationCard(
                type: IncidentClassificationType.cargoMinorHit,
                title: _t('Cargo / Minor Hit', 'የጭነት አደጋ / ግጭት'),
                subtitle: _t('Seal Tamper / Scrape', 'የማህተም መነካካት / ጭረት'),
                icon: Icons.inventory_2_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationCard({
    required IncidentClassificationType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedClassification == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedClassification = type;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF0F1E33),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFBBF24)
                : const Color(0xFF1E3250),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon Container and Radio Check
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD97706).withValues(alpha: 0.3)
                        : const Color(0xFF16253B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF2E1A00)
                        : const Color(0xFF93C5FD),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: isSelected
                      ? const Color(0xFF2E1A00)
                      : const Color(0xFF475569),
                ),
              ],
            ),

            // Bottom Column: Title and Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF1E1100)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF5A3600)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceNoteSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _t('Incident Description & Voice Note', 'የአደጋው መግለጫ እና የድምፅ መልእክት'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic_none_rounded,
              size: 14,
              color: Color(0xFF34D399),
            ),
            const SizedBox(width: 4),
            Text(
              _t('Voice Synced', 'ድምፅ ተመሳስሏል'),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF34D399),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverNoteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E33),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _descriptionController.text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD6E3FE),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('Recorded by Driver M. Bekele', 'በአሽከርካሪ ኤም. በቀለ የተመዘገበ'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _t('Corridor km 382.4', 'ኮሪደር ኪ.ሜ 382.4'),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFC174),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMemoPlayerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E33),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Row(
        children: [
          // Play / Pause Circle Button
          GestureDetector(
            onTap: _toggleAudioPlayback,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFDBA74),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlayingAudio
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: const Color(0xFF431407),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Voice Memo Title & Waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Voice memo recorded (0:42)', 'የተቀዳ የድምፅ መልእክት (0:42)'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                _buildWaveformBars(),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Duration Text: 00:42
          Text(
            '00:${_audioRemainingSeconds.toString().padLeft(2, '0')}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 8),

          // Replay / Refresh Button
          GestureDetector(
            onTap: _resetAudioPlayback,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF16253B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF243B5C)),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars() {
    final barHeights = [
      8.0, 14.0, 20.0, 12.0, 18.0, 22.0, 16.0, 10.0,
      18.0, 24.0, 16.0, 12.0, 8.0, 14.0, 18.0, 10.0,
      16.0, 22.0, 12.0, 8.0, 14.0, 10.0
    ];

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(barHeights.length, (index) {
          final isActive = index < (_isPlayingAudio ? 16 : 8);
          return Container(
            width: 3,
            height: barHeights[index],
            margin: const EdgeInsets.only(right: 2.5),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF34D399)
                  : const Color(0xFF1E3250),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDispatchAuthorizationsHeader() {
    return Text(
      _t('Automated Dispatch Authorizations', 'አውቶማቲክ የአደጋ ጊዜ ቡድን ፈቃዶች'),
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDispatchAuthorizationsCards() {
    return Column(
      children: [
        // Switch 1: Deploy Roadside Heavy Recovery
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E3250)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF16253B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rv_hookup_rounded,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        'Deploy Roadside Heavy Recovery',
                        'ከባድ የመንገድ ላይ ድጋፍ መኪና ላክ',
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34D399),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _t(
                              'Kombolcha Hub • Approx. 24 mins away',
                              'ኮምቦልቻ ማዕከል • በግምት 24 ደቂቃዎች ይርቃል',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildCustomToggleSwitch(
                value: _deployRoadsideHeavyRecovery,
                onChanged: (val) {
                  setState(() {
                    _deployRoadsideHeavyRecovery = val;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Switch 2: Notify Shipper & Insurer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E3250)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF16253B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        'Notify Shipper & Insurer',
                        'ለላኪው እና ለመድን ሰጪው አሳውቅ',
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t(
                        'Nyala In-Transit Marine Policy #NY-902-...',
                        'የኒያላ የትራንዚት መድን ፖሊሲ #NY-902-...',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildCustomToggleSwitch(
                value: _notifyShipperAndInsurer,
                onChanged: (val) {
                  setState(() {
                    _notifyShipperAndInsurer = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFF59E0B) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2E1A00),
              shape: BoxShape.circle,
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildHotlineActionButtons() {
    return Row(
      children: [
        // Button 1: Call SOS Patrol...
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showCallPatrolModal,
            icon: const Icon(
              Icons.phone_in_talk_rounded,
              size: 16,
              color: Color(0xFF881337),
            ),
            label: Text(
              _t('Call SOS Patrol...', 'የአደጋ ጊዜ ፓትሮል ደውል...'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF881337),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD1D1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Button 2: Dispatcher Hot...
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showDispatcherHotlineModal,
            icon: const Icon(
              Icons.headset_mic_rounded,
              size: 16,
              color: Color(0xFF93C5FD),
            ),
            label: Text(
              _t('Dispatcher Hot...', 'የመቆጣጠሪያ መስመር...'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD6E3FE),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF132338),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF233854)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransmitCtaButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isTransmitting ? null : _handleTransmitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          disabledBackgroundColor: const Color(0xFF78350F),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isTransmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1100)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF1E1100),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _t(
                        'Transmit Emergency Incident Report',
                        'የአደጋ ጊዜ ሪፖርቱን አስተላልፍ',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1100),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterCaption() {
    return Center(
      child: Text(
        _t(
          'Encrypted telemetry transmission to Central Fleet Operations\nAddis Ababa',
          'ደህንነቱ የተጠበቀ መረጃ ወደ ማዕከላዊ ፍሊት ኦፕሬሽን\nአዲስ አበባ',
        ),
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
          height: 1.35,
        ),
      ),
    );
  }
}

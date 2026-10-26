import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/escrow_service.dart';
import 'package:mobile/core/services/shipper_service.dart';

class RateDriverScreen extends StatefulWidget {
  final String? driverId;
  final String? deliveryId;
  final String? driverName;
  final String? waybillNumber;
  final double? escrowAmount;

  const RateDriverScreen({
    super.key,
    this.driverId,
    this.deliveryId,
    this.driverName,
    this.waybillNumber,
    this.escrowAmount,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  final ShipperService _shipperService = ShipperService();
  final EscrowService _escrowService = EscrowService();
  final TextEditingController _notesController = TextEditingController(
    text:
        'Solomon arrived ahead of schedule at Kaliti depot and unloaded punctually at Adama. Excellent transit updates throughout the corridor.',
  );

  // Local State for interactions
  int _rating = 4; // The screenshot shows 4 stars filled
  final List<bool> _selectedTags = [true, true, true, true, false];
  int _selectedTipIndex = 0;
  bool _submitting = false;

  String? _driverId;
  String? _shipmentId;
  bool _argsResolved = false;

  // Local theme colors
  static const Color _bgDark = Color(0xFF0B1120);
  static const Color _bgCard = Color(0xFF1E293B);
  static const Color _bgCardLight = Color(0xFF273549);
  static const Color _bgInput = Color(0xFF0F172A);
  static const Color _textMain = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _accentGold = Color(0xFFFBBF24);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _borderColor = Color(0xFF334155);
  static const Color _errorRed = Color(0xFFF87171);

  final List<String> _tagLabels = [
    "On-Time Delivery",
    "Safe & Secure Cargo",
    "Polite Communication",
    "Clean Truck Bed & Tarp",
    "GPS Telemetry Maintained",
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitRating() async {
    setState(() => _isSubmitting = true);

    final selectedFeedback = <String>[];
    for (int i = 0; i < _selectedTags.length; i++) {
      if (_selectedTags[i]) selectedFeedback.add(_tagLabels[i]);
    }
    final fullComment = [
      if (selectedFeedback.isNotEmpty) '[Tags: ${selectedFeedback.join(', ')}]',
      _commentController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    final driverId = widget.driverId ?? 'driver-default';
    final deliveryId = widget.deliveryId ?? 'del-default';

    final ok = await _shipperService.rateDriver(
      driverId: driverId,
      deliveryId: deliveryId,
      rating: _rating,
      comment: fullComment,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully! Consignment settled.'),
          backgroundColor: _accentGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.page05EscrowVault);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit rating. Please check connection.'),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  void _showDisputeModal() {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report Transit Dispute',
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Describe any cargo damage, shortage, or unauthorized delay before releasing escrow.',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: _textMain, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter dispute details...',
                  hintStyle: const TextStyle(color: _textMuted, fontSize: 12),
                  filled: true,
                  fillColor: _bgInput,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dispute logged. Escrow held pending corridor arbitration.'),
                        backgroundColor: _errorRed,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _errorRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('File Formal Dispute', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsResolved) return;
    _argsResolved = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _driverId = args['driverId']?.toString() ?? args['driver_id']?.toString();
      _shipmentId =
          args['shipmentId']?.toString() ?? args['shipment_id']?.toString();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRating({required bool releaseEscrow}) async {
    final driverId = _driverId;
    if (driverId == null || driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing driverId. Open this screen with route args.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final selectedTags = <String>[];
      for (var i = 0; i < _tagLabels.length; i++) {
        if (_selectedTags[i]) selectedTags.add(_tagLabels[i]);
      }
      final commentParts = <String>[
        if (_notesController.text.trim().isNotEmpty) _notesController.text.trim(),
        if (selectedTags.isNotEmpty) selectedTags.join(', '),
      ];

      await _shipperService.rateDriver(
        driverId: driverId,
        rating: _rating,
        comment: commentParts.isEmpty ? null : commentParts.join(' · '),
        shipmentId: _shipmentId,
      );

      if (releaseEscrow &&
          _shipmentId != null &&
          _shipmentId!.isNotEmpty) {
        try {
          await _escrowService.release(_shipmentId!);
        } catch (_) {
          // Rating succeeded; release is best-effort.
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            releaseEscrow
                ? 'Rating submitted and escrow release requested'
                : 'Rating submitted',
          ),
          backgroundColor: _accentGreen,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: _errorRed),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit rating'),
          backgroundColor: _errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = widget.driverName ?? 'Carrier Driver';
    final waybill = widget.waybillNumber ?? 'Recent Consignment';
    final escrowAmt = widget.escrowAmount != null
        ? '${widget.escrowAmount!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ETB'
        : 'Escrow Amount';

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: HomeHeader(
          language: 'EN',
          onLanguageChanged: (_) {},
          onProfileTap: () {},
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitleSection(waybill),
              const SizedBox(height: 20),
              _buildEscrowInfoCard(escrowAmt, driverName),
              const SizedBox(height: 12),
              _buildDriverInfoCard(driverName),
              const SizedBox(height: 12),
              _buildRatingCard(),
              const SizedBox(height: 12),
              _buildNotesCard(),
              const SizedBox(height: 24),
              _buildActionButtons(escrowAmt),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page24MyShipments);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page23PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
          } else if (idx != 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accentGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HabeshaFreight',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: const Text(
                'EN',
                style: TextStyle(color: _textMain, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection(String waybill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: _accentGreen, size: 12),
              SizedBox(width: 6),
              Text(
                'CONSIGNMENT DELIVERED',
                style: TextStyle(
                  color: _accentGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Rate Delivery & Release Escrow',
          style: TextStyle(
            color: _textMain,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rate driver performance for Waybill #$waybill',
          style: const TextStyle(color: _textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEscrowInfoCard(String escrowAmt, String driverName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_outline, color: _accentGold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'ESCROW SETTLEMENT',
                      style: TextStyle(
                        color: _accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified_user, color: _accentGreen, size: 14),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$escrowAmt locked in escrow will be released to $driverName upon review submission.',
                  style: const TextStyle(
                    color: _textMain,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard(String driverName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: const Icon(Icons.person, color: _accentGold, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(
                    color: _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Verified Corridor Line-Haul Driver',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _bgCardLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Text(
                  '5.0',
                  style: TextStyle(
                    color: _accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.star, color: _accentGold, size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Performance Rating',
            style: TextStyle(
              color: _textMain,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starIndex),
                icon: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _accentGold,
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_tagLabels.length, (index) {
              final isSelected = _selectedTags[index];
              return InkWell(
                onTap: () => setState(() => _selectedTags[index] = !_selectedTags[index]),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentGreen.withValues(alpha: 0.15) : _bgInput,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _accentGreen : _borderColor,
                    ),
                  ),
                  child: Text(
                    _tagLabels[index],
                    style: TextStyle(
                      color: isSelected ? _accentGreen : _textMuted,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: _accentGold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Corridor Dispatch Notes',
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Public on driver profile',
                style: TextStyle(color: _textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(color: _textMain, fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: _bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 2,
            style: const TextStyle(color: _textMain, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Add remarks about consignment condition or speed...',
              hintStyle: const TextStyle(color: _textMuted, fontSize: 12),
              filled: true,
              fillColor: _bgInput,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String escrowAmt) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _submitting
              ? null
              : () => _submitRating(releaseEscrow: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGold,
            foregroundColor: _bgDark,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Rating & Release Escrow',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _submitting
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Dispute reporting will open from shipment details.',
                      ),
                    ),
                  );
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: _textMain,
            side: BorderSide(color: _borderColor),
            backgroundColor: _bgCard,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

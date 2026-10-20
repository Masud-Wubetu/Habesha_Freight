import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/bid_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
class SubmitFreightBidScreen extends StatefulWidget {
  final String requestId;
  final String originCity;
  final String destinationCity;
  final String tonnage;
  final double initialBidAmount;
  final double corridorAverage;
  final BidService? bidService;

  const SubmitFreightBidScreen({
    super.key,
    this.requestId = '#REQ-9840',
    this.originCity = 'Addis Ababa',
    this.destinationCity = 'Mekelle',
    this.tonnage = '32T',
    this.initialBidAmount = 76000.0,
    this.corridorAverage = 78500.0,
    this.bidService,
  });

  @override
  State<SubmitFreightBidScreen> createState() => _SubmitFreightBidScreenState();
}

// Convenient alias for Page 20
typedef Page20Screen = SubmitFreightBidScreen;

class _SubmitFreightBidScreenState extends State<SubmitFreightBidScreen> {
  late final BidService _bidService;
  final NumberFormat _currencyFormat = NumberFormat('#,###');

  late double _bidAmount;
  bool _fuelPassesInclusive = true;
  bool _waterproofTarpVerified = true;
  bool _isSubmitting = false;

  // Terminal Gate Slots
  int _selectedSlotIndex = 0;
  final List<Map<String, String>> _gateSlots = [
    {
      'title': 'Today at 16:00 PM (Bay 4, Kaliti Terminal)',
      'subtitle': 'Kaliti Freight Logistics Hub, Addis Ababa',
    },
    {
      'title': 'Today at 18:30 PM (Bay 2, Kaliti Terminal)',
      'subtitle': 'Kaliti Freight Logistics Hub, Addis Ababa',
    },
    {
      'title': 'Tomorrow at 07:00 AM (Bay 1, Kaliti Terminal)',
      'subtitle': 'Kaliti Freight Logistics Hub, Addis Ababa',
    },
    {
      'title': 'Tomorrow at 10:00 AM (Bay 6, Kaliti Terminal)',
      'subtitle': 'Kaliti Freight Logistics Hub, Addis Ababa',
    },
  ];

  // Quick presets
  final List<double> _presetFares = [74000.0, 76000.0, 78000.0, 80000.0];

  @override
  void initState() {
    super.initState();
    _bidService = widget.bidService ?? BidService();
    _bidAmount = widget.initialBidAmount;
  }

  // Calculations
  double get _platformFee => _bidAmount * 0.025; // 2.5%
  double get _withholdingTax => _bidAmount * 0.020; // 2.0%
  double get _netTakeHome => _bidAmount - _platformFee - _withholdingTax;

  String _formatEtb(double value) => _currencyFormat.format(value.round());

  void _adjustBid(double delta) {
    setState(() {
      final next = _bidAmount + delta;
      if (next >= 10000) {
        _bidAmount = next;
      }
    });
  }

  void _setPreset(double preset) {
    setState(() {
      _bidAmount = preset;
    });
  }

  String _getMarketTrendText() {
    final diff = ((widget.corridorAverage - _bidAmount) / widget.corridorAverage) * 100;
    if (diff > 0) {
      return '${diff.toStringAsFixed(1)}% under corridor avg • High award probability';
    } else if (diff < 0) {
      return '${(-diff).toStringAsFixed(1)}% above corridor avg • Standard award probability';
    } else {
      return 'At corridor benchmark avg • Competitive match rate';
    }
  }

  void _showGateSlotSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Terminal Gate Slot',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(_gateSlots.length, (index) {
                  final slot = _gateSlots[index];
                  final isSelected = index == _selectedSlotIndex;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedSlotIndex = index);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E2D48) : const Color(0xFF091222),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : const Color(0xFF182742),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: isSelected ? AppColors.gold : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot['title']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  slot['subtitle']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitBid() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final selectedSlot = _gateSlots[_selectedSlotIndex];

    final result = await _bidService.submitBid(
      loadId: widget.requestId.replaceAll('#', ''),
      bidAmountEtb: _bidAmount,
      terminalGateSlot: selectedSlot['title'],
      fuelPassesInclusive: _fuelPassesInclusive,
      waterproofTarpVerified: _waterproofTarpVerified,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show confirmation dialog reflecting real execution
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF063327),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF065F46)),
              ),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bid Transmitted!',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.requestId,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.message,
              style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF091222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF182742)),
              ),
              child: Column(
                children: [
                  _dialogDetailRow('Gross Proposed Bid', '${_formatEtb(_bidAmount)} ETB'),
                  const SizedBox(height: 6),
                  _dialogDetailRow('Guaranteed Settled Yield', '${_formatEtb(_netTakeHome)} ETB', isGreen: true),
                  const SizedBox(height: 6),
                  _dialogDetailRow('Corridor Route', '${widget.originCity} → ${widget.destinationCity}'),
                  const SizedBox(height: 6),
                  _dialogDetailRow('Terminal Slot', selectedSlot['title']?.split('(').first.trim() ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lock_rounded, size: 13, color: AppColors.badgeGreenText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Protected by HabeshaFreight Smart Escrow Protocol',
                    style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogDetailRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF34D399) : Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Strip
                    _buildRouteStrip(),
                    const SizedBox(height: 14),

                    // First Escrow Payout Transparency Card
                    _buildEscrowPayoutCard(),
                    const SizedBox(height: 14),

                    // Proposed Bid Fare Stepper Card
                    _buildProposedBidFareCard(),
                    const SizedBox(height: 14),

                    // Second Escrow Payout Transparency Card (as specified in user requirements)
                    _buildEscrowPayoutCard(),
                    const SizedBox(height: 14),

                    // Loading Schedule & Rig Readiness Card
                    _buildLoadingScheduleCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Transmit Button Container
            _buildBottomActionContainer(),
          ],
        ),
      ),
    );
  }

  /// Top App Bar with Close Button, Live Bidding Badge, Screen Title, and #REQ ID
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Close Button
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF131D31),
                border: Border.all(color: const Color(0xFF223554), width: 1.2),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Live Bidding Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE BIDDING',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF34D399),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Submit Freight\nBid',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          // Right side actions & Request ID Pill Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => CorridorNavigationSheet.show(context),
                icon: const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.gold),
                tooltip: 'All Corridor Modules',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF131D31),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF223554)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.gold,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.requestId,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFCBD5E1),
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

  /// Route Information Strip
  Widget _buildRouteStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1323),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF182742)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.alt_route_rounded,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.originCity,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '  →  ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  TextSpan(
                    text: '${widget.destinationCity} (${widget.tonnage})',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFF04221B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF065F46)),
            ),
            child: Text(
              'CORRIDOR ACTIVE',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2DD4BF),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Escrow Payout Transparency Card with Audit Badge, Fees & Guaranteed Settled Yield
  Widget _buildEscrowPayoutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.gpp_good_outlined,
                color: Color(0xFF34D399),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                'ESCROW PAYOUT TRANSPARENCY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF04231C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF065F46)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'REAL-TIME AUDIT',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF34D399),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1: Gross Proposed Bid
          _buildBreakdownRow(
            icon: Icons.description_outlined,
            label: 'Gross Proposed Bid',
            valueText: '${_formatEtb(_bidAmount)} ETB',
            valueColor: Colors.white,
          ),
          const SizedBox(height: 10),

          // Row 2: Platform Fee
          _buildBreakdownRow(
            icon: Icons.diamond_outlined,
            label: 'HabeshaFreight Platform Fee',
            percentageBadge: '2.5%',
            valueText: '-${_formatEtb(_platformFee)} ETB',
            valueColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 10),

          // Row 3: Withholding Tax
          _buildBreakdownRow(
            icon: Icons.account_balance_outlined,
            label: 'Withholding Tax (MoR)',
            percentageBadge: '2.0%',
            valueText: '-${_formatEtb(_withholdingTax)} ETB',
            valueColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 14),

          // Inner Card: Carrier Net Take-Home
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF091222),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF182742)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARRIER NET TAKE-HOME',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Guaranteed Settled Yield',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF04281E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF065F46)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatEtb(_netTakeHome),
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ETB',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Instant payout via ',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              TextSpan(
                                text: 'Telebirr',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: ' or ',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              TextSpan(
                                text: 'CBE Birr',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142036),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF223554)),
                      ),
                      child: Text(
                        'e-POD Escrow',
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

  Widget _buildBreakdownRow({
    required IconData icon,
    required String label,
    String? percentageBadge,
    required String valueText,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFFCBD5E1),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (percentageBadge != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF182845),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percentageBadge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF38BDF8),
              ),
            ),
          ),
        ],
        const Spacer(),
        Text(
          valueText,
          style: GoogleFonts.outfit(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Proposed Bid Fare Stepper Card with Controls & Presets
  Widget _buildProposedBidFareCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.gold,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR PROPOSED BID FARE (ETB)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF152238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF223554)),
                ),
                child: Text(
                  'INSTANT SHIPPER DISPATCH',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Counter Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF091222),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF182742)),
            ),
            child: Row(
              children: [
                // Decrement Button
                InkWell(
                  onTap: () => _adjustBid(-1000),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16233B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF233658)),
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                // Center Bid Display
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'ETB ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            _formatEtb(_bidAmount),
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF04261F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF065F46)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.south_east_rounded,
                              color: Color(0xFF34D399),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getMarketTrendText(),
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Increment Button
                InkWell(
                  onTap: () => _adjustBid(1000),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16233B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF233658)),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Presets Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK FARE PRESETS',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '±1,000 ETB Step',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Presets Row
          Row(
            children: _presetFares.map((preset) {
              final isSelected = (_bidAmount - preset).abs() < 1.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _setPreset(preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : const Color(0xFF16233B),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? null
                            : Border.all(color: const Color(0xFF233658), width: 1),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${_formatEtb(preset)} ETB',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.textDark : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Loading Schedule & Rig Readiness Card
  Widget _buildLoadingScheduleCard() {
    final currentSlot = _gateSlots[_selectedSlotIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOADING SCHEDULE & RIG READINESS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'Terminal Gate Slot',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Terminal Gate Slot Selector Box
          InkWell(
            onTap: _showGateSlotSelector,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF091222),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF182742)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF142036),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSlot['title']!,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentSlot['subtitle']!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Checkbox 1: Fuel & Toll passes
          InkWell(
            onTap: () => setState(() => _fuelPassesInclusive = !_fuelPassesInclusive),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF091222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF182742)),
              ),
              child: Row(
                children: [
                  _buildCustomCheckbox(_fuelPassesInclusive),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.local_gas_station_outlined,
                    color: Color(0xFF2DD4BF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fuel & corridor toll passes fully inclusive',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Checkbox 2: Heavy Waterproof Tarp
          InkWell(
            onTap: () => setState(() => _waterproofTarpVerified = !_waterproofTarpVerified),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF091222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF182742)),
              ),
              child: Row(
                children: [
                  _buildCustomCheckbox(_waterproofTarpVerified),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF2DD4BF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Heavy waterproof tarp equipped & verified',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool isChecked) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isChecked ? AppColors.gold : const Color(0xFF64748B),
          width: 1.5,
        ),
      ),
      child: isChecked
          ? const Icon(
              Icons.check_rounded,
              color: AppColors.textDark,
              size: 15,
            )
          : null,
    );
  }

  /// Fixed Bottom Container with Action Button and Escrow Protocol Subtext
  Widget _buildBottomActionContainer() {
    final bottomPadding = math.max(16.0, MediaQuery.of(context).padding.bottom + 8.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF080E1A),
        border: Border(
          top: BorderSide(color: Color(0xFF182742), width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confirm & Transmit Button
              SizedBox(
                width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.textDark,
                elevation: 4,
                shadowColor: AppColors.gold.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _isSubmitting ? null : _submitBid,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textDark,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Confirm & Transmit Bid to Shipper',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textDark,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // Enforced Escrow Protocol Subtext
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFF10B981),
                size: 12,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Enforced by HabeshaFreight Smart Escrow Protocol • Instant Shipper Notification',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

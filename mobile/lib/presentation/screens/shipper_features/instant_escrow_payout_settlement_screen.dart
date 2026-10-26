import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/escrow_service.dart';

/// Available payout disbursement channels
enum DisbursementChannelType {
  telebirr,
  cbe,
  awashBank,
}

/// Metadata model for a payout disbursement channel
class DisbursementChannelInfo {
  final DisbursementChannelType type;
  final String title;
  final String titleAmharic;
  final String accountDisplay;
  final String subtitle;
  final String subtitleAmharic;
  final String? badgeText;
  final IconData icon;
  final String channelShortName;

  const DisbursementChannelInfo({
    required this.type,
    required this.title,
    required this.titleAmharic,
    required this.accountDisplay,
    required this.subtitle,
    required this.subtitleAmharic,
    this.badgeText,
    required this.icon,
    required this.channelShortName,
  });
}

/// Page 26: Instant Escrow Payout Settlement Screen
///
/// Implements the carrier/driver payout settlement screen for verified freight trips.
/// Features:
/// - Real-time e-POD verification and escrow release status
/// - Audited ledger breakdown (Gross fare, platform fee, MoR withholding tax, net settlement)
/// - Interactive multi-channel disbursement selection (Telebirr Instant Wallet, CBE, Awash Bank)
/// - Security & Statutory clearance validation codes (Smart Escrow Lock & MoR Tax Clearance)
/// - Instant payout disbursement transaction flow with receipt modal
/// - Driver earnings & wallet ledger modal
/// - Bilingual localization support (English & Amharic)
/// - Fully responsive design with desktop centering and mobile adaptation
class InstantEscrowPayoutSettlementScreen extends StatefulWidget {
  final String? tripId;
  final String? originCity;
  final String? destinationCity;
  final int? distanceKm;
  final double? grossFareEtb;
  final double platformFeePercent;
  final double withholdingTaxPercent;
  final String? smartEscrowLockId;
  final String? morTaxClearanceId;
  final String? shipmentId;

  const InstantEscrowPayoutSettlementScreen({
    super.key,
    this.tripId,
    this.originCity,
    this.destinationCity,
    this.distanceKm,
    this.grossFareEtb,
    this.platformFeePercent = 2.5,
    this.withholdingTaxPercent = 2.0,
    this.smartEscrowLockId,
    this.morTaxClearanceId,
    this.shipmentId,
    this.enableAnimation = true,
  });

  final bool enableAnimation;

  @override
  State<InstantEscrowPayoutSettlementScreen> createState() =>
      _InstantEscrowPayoutSettlementScreenState();
}

// Convenient alias for Page 26
typedef Page26Screen = InstantEscrowPayoutSettlementScreen;

class _InstantEscrowPayoutSettlementScreenState
    extends State<InstantEscrowPayoutSettlementScreen>
    with SingleTickerProviderStateMixin {
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  final EscrowService _escrow = EscrowService();

  // Selected disbursement channel
  DisbursementChannelType _selectedChannel = DisbursementChannelType.telebirr;

  // Language state (English default with Amharic toggle)
  bool _isAmharic = false;

  // Transfer execution state
  bool _isProcessingTransfer = false;
  bool _isTransferCompleted = false;
  bool _loadingLedger = true;
  String? _ledgerError;
  EscrowItem? _activeEscrow;
  EscrowLedgerSummary? _ledger;

  // Bottom navigation tab state
  int _currentNavIndex = 3; // 'Payouts' tab active

  // Pulsing animation for the active status dot
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String get _tripId {
    final fromEscrow = _activeEscrow?.shipmentId;
    if (fromEscrow != null && fromEscrow.isNotEmpty) {
      return fromEscrow.length > 8
          ? fromEscrow.substring(0, 8).toUpperCase()
          : fromEscrow.toUpperCase();
    }
    return widget.tripId?.isNotEmpty == true ? widget.tripId! : '—';
  }

  String get _shipmentId {
    if (widget.shipmentId != null && widget.shipmentId!.trim().isNotEmpty) {
      return widget.shipmentId!.trim();
    }
    return _activeEscrow?.shipmentId ?? '';
  }

  String get _originCity =>
      widget.originCity ?? _activeEscrow?.origin ?? '—';
  String get _destinationCity =>
      widget.destinationCity ?? _activeEscrow?.destination ?? '—';
  double get _grossFareEtb =>
      widget.grossFareEtb ?? _activeEscrow?.grossAmount ?? 0;
  String get _smartEscrowLockId =>
      widget.smartEscrowLockId ??
      _activeEscrow?.gatewayReference ??
      _activeEscrow?.id ??
      '—';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.enableAnimation) {
      _pulseController.repeat(reverse: true);
    }
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadEscrow();
  }

  Future<void> _loadEscrow() async {
    setState(() {
      _loadingLedger = true;
      _ledgerError = null;
    });
    try {
      final ledger = await _escrow.getLedger();
      EscrowItem? active;
      final preferred = _shipmentId;
      if (preferred.isNotEmpty) {
        for (final item in ledger.items) {
          if (item.shipmentId == preferred) {
            active = item;
            break;
          }
        }
        if (active == null) {
          try {
            final status = await _escrow.status(preferred);
            active = EscrowItem.fromJson({
              ...status,
              'shipment_id': preferred,
              'id': status['id'] ?? preferred,
            });
          } catch (_) {}
        }
      }
      if (active == null) {
        for (final item in ledger.items) {
          if (item.status == 'LOCKED' || item.status == 'PENDING') {
            active = item;
            break;
          }
        }
        active ??= ledger.items.isNotEmpty ? ledger.items.first : null;
      }

      if (!mounted) return;
      setState(() {
        _ledger = ledger;
        _activeEscrow = active;
        _loadingLedger = false;
        if (active != null &&
            (active.status == 'RELEASED' || active.status == 'REFUNDED')) {
          _isTransferCompleted = active.status == 'RELEASED';
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _ledgerError = e.message;
        _loadingLedger = false;
        _activeEscrow = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ledgerError = 'Unable to load escrow ledger';
        _loadingLedger = false;
        _activeEscrow = null;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Calculated ledger values
  double get _platformFee =>
      _grossFareEtb * (widget.platformFeePercent / 100);
  double get _withholdingTax =>
      _grossFareEtb * (widget.withholdingTaxPercent / 100);
  double get _netSettlementAmount {
    if (_activeEscrow != null && _activeEscrow!.netPayout > 0) {
      return _activeEscrow!.netPayout;
    }
    return _grossFareEtb - _platformFee - _withholdingTax;
  }

  String _t(String en, String am) => _isAmharic ? am : en;

  List<DisbursementChannelInfo> get _channels => [
        const DisbursementChannelInfo(
          type: DisbursementChannelType.telebirr,
          title: 'Telebirr Instant Wallet',
          titleAmharic: 'የቴሌብር አፋጣኝ ቦርሳ',
          accountDisplay: '+251 91 1*** ***5',
          subtitle: 'Fee: 0 ETB • Instant Direct Deposit',
          subtitleAmharic: 'ክፍያ፡ 0 ብር • ወዲያውኑ ቀጥተኛ ገቢ',
          badgeText: 'Fastest',
          icon: Icons.phone_android_rounded,
          channelShortName: 'Telebirr',
        ),
        const DisbursementChannelInfo(
          type: DisbursementChannelType.cbe,
          title: 'Commercial Bank of Ethiopia',
          titleAmharic: 'የኢትዮጵያ ንግድ ባንክ',
          accountDisplay: 'CBE Acct #180028941029',
          subtitle: 'Est. arrival: 5 - 15 minutes',
          subtitleAmharic: 'የሚደርስበት ጊዜ፡ 5 - 15 ደቂቃዎች',
          icon: Icons.account_balance_rounded,
          channelShortName: 'CBE',
        ),
        const DisbursementChannelInfo(
          type: DisbursementChannelType.awashBank,
          title: 'Awash Bank Direct Transfer',
          titleAmharic: 'አዋሽ ባንክ ቀጥተኛ ዝውውር',
          accountDisplay: 'AWASH Acct #01438920199',
          subtitle: 'RTGS Clearing Window',
          subtitleAmharic: 'የRTGS ማጽጃ መስኮት',
          icon: Icons.credit_card_rounded,
          channelShortName: 'Awash Bank',
        ),
      ];

  Future<void> _handleTransferNow() async {
    if (_isProcessingTransfer) return;

    final shipmentId = _shipmentId;
    if (shipmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          content: Text(
            _t(
              'No escrow shipment available to release.',
              'ለመልቀቅ የእስክሮው ጭነት የለም።',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessingTransfer = true);
    HapticFeedback.mediumImpact();

    try {
      await _escrow.release(shipmentId);
      if (!mounted) return;
      setState(() {
        _isProcessingTransfer = false;
        _isTransferCompleted = true;
      });
      _showTransferReceiptSheet();
      await _loadEscrow();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingTransfer = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessingTransfer = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7F1D1D),
          content: Text(
            _t(
              'Escrow release failed. Try again or contact support.',
              'የእስክሮው መልቀቅ አልተሳካም።',
            ),
          ),
        ),
      );
    }
  }

  void _showTransferReceiptSheet() {
    final channel = _channels.firstWhere((c) => c.type == _selectedChannel);
    final now = DateTime.now();
    final timeFormatted = DateFormat('hh:mm a, dd MMM yyyy').format(now);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF0A1526),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Success icon with pulsing green background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34D399),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  _t('Payout Disbursed Successfully!', 'ክፍያው በተሳካ ሁኔታ ተላልፏል!'),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                Text(
                  _t(
                    'Funds successfully wired to your selected channel with zero settlement delay.',
                    'ገንዘቡ ያለምንም መዘግየት ወደ መረጡት የክፍያ መስመር ተላልፏል።',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Receipt Breakdown card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1E33),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E3250)),
                  ),
                  child: Column(
                    children: [
                      _receiptRow(
                        _t('Disbursed Amount', 'የተላለፈው መጠን'),
                        'ETB ${_currencyFormat.format(_netSettlementAmount)}',
                        isHighlight: true,
                      ),
                      const Divider(color: Color(0xFF1E3250), height: 20),
                      _receiptRow(
                        _t('Destination Channel', 'የመድረሻ መስመር'),
                        channel.channelShortName,
                      ),
                      const SizedBox(height: 8),
                      _receiptRow(
                        _t('Account Ref', 'የሂሳብ ቁጥር'),
                        channel.accountDisplay,
                      ),
                      const SizedBox(height: 8),
                      _receiptRow(
                        _t('Trip Reference', 'የጉዞ መለያ'),
                        '#$_tripId',
                      ),
                      const SizedBox(height: 8),
                      _receiptRow(
                        _t('Escrow Clearance ID', 'የእስክሮው ማጽጃ መለያ'),
                        _smartEscrowLockId,
                      ),
                      const SizedBox(height: 8),
                      _receiptRow(
                        _t('Timestamp', 'የተፈጸመበት ጊዜ'),
                        timeFormatted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Close Button
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
                      _t('Done & Return to Overview', 'ተጠናቋል • ወደ ማጠቃለያው ተመለስ'),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isHighlight ? 16 : 13,
            color: isHighlight ? const Color(0xFF34D399) : Colors.white,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showDriverEarningsWalletModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF091422),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF1E3250), width: 1.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFF59E0B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Driver Earnings & Escrow Ledger', 'የአሽከርካሪ ገቢ እና የእስክሮው መዝገብ'),
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _t('Carrier: M. Bekele (Freight Transporter #881)', 'አጓጓዥ፡ ኤም. በቀለ (የጭነት አጓጓዥ #881)'),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Stat metrics row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E33),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E3250)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('YTD Settled', 'በአመቱ የተከፈለ'),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ETB 482,900',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E33),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E3250)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('Escrow In-Transit', 'በመንገድ ላይ ያለ እስክሮው'),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ETB 0.00',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  _t('Recent Automated Settlements', 'የቅርብ ጊዜ አውቶማቲክ ክፍያዎች'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD6E3FE),
                  ),
                ),
                const SizedBox(height: 10),

                _ledgerItemTile(
                  title: _activeEscrow == null
                      ? (_ledgerError ?? 'No escrow item')
                      : '$_tripId ($_originCity → $_destinationCity)',
                  date: _loadingLedger
                      ? 'Loading…'
                      : (_activeEscrow?.createdAt?.toIso8601String() ??
                          'Ledger'),
                  amount: '+ETB ${_currencyFormat.format(_netSettlementAmount)}',
                  status: _isTransferCompleted
                      ? 'DISBURSED'
                      : (_activeEscrow?.status ?? 'EMPTY'),
                  isCompleted: _isTransferCompleted,
                ),
                if (_ledger != null && _ledger!.items.length > 1) ...[
                  const SizedBox(height: 8),
                  ..._ledger!.items.skip(1).take(2).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ledgerItemTile(
                            title:
                                '${item.shipmentId.length > 8 ? item.shipmentId.substring(0, 8).toUpperCase() : item.shipmentId} (${item.origin ?? '—'} → ${item.destination ?? '—'})',
                            date: item.createdAt?.toIso8601String() ?? '',
                            amount:
                                '+ETB ${_currencyFormat.format(item.netPayout)}',
                            status: item.status,
                            isCompleted: item.status == 'RELEASED',
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD6E3FE),
                      side: const BorderSide(color: Color(0xFF243B5C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _t('Close Wallet Overview', 'የቦርሳ እይታን ዝጋ'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ledgerItemTile({
    required String title,
    required String date,
    required String amount,
    required String status,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E33),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
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
                amount,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF34D399),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? const Color(0xFF34D399)
                      : const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E3250)),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFFD6E3FE),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('Got It', 'ተረድቻለሁ'),
              style: GoogleFonts.inter(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationPanel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F1E33),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _t(
                  'Escrow Release Notification: Shipper released payment on e-POD verification.',
                  'የእስክሮው ማሳወቂያ፡ ላኪው የኢ-ፒኦዲ ማረጋገጫ ሲደርሰው ክፍያውን ፈቅዷል።',
                ),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E3250)),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF59E0B),
              child: Icon(Icons.person, color: Color(0xFF1E1100), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'M. Bekele',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _t('Verified Pro Carrier', 'የተረጋገጠ ፕሮ አጓጓዥ'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF34D399),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: Text(
          _t(
            'Vehicle: Sinotruk HOWO 371 (Plate: AA-3-92144)\nBank Account: CBE, Telebirr & Awash registered.',
            'ተሽከርካሪ፡ ሲኖትራክ ሆዎ 371 (ሰሌዳ፡ አአ-3-92144)\nየባንክ ሂሳብ፡ ንግድ ባንክ፣ ቴሌብር እና አዋሽ ተመዝግቧል።',
          ),
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFD6E3FE)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('Close', 'ዝጋ'),
              style: GoogleFonts.inter(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061426),
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
                  // Sub-header status tags row
                  _buildSubHeaderTagsRow(),
                  const SizedBox(height: 14),

                  // Trip context card (e-POD Verified • Escrow Released by Shipper)
                  _buildTripContextCard(),
                  const SizedBox(height: 14),

                  // Hero Carrier Net Settlement Card with Audited Ledger
                  _buildCarrierNetSettlementCard(),
                  const SizedBox(height: 20),

                  // Disbursement Channel Section
                  _buildDisbursementChannelSection(),
                  const SizedBox(height: 14),

                  // Security & Statutory Clearance Card
                  _buildSecurityClearanceCard(),
                  const SizedBox(height: 20),

                  // Primary CTA Button: Transfer ETB Now
                  _buildPrimaryTransferButton(),
                  const SizedBox(height: 12),

                  // Secondary Button: View Updated Driver Earnings & Wallet
                  _buildViewDriverEarningsButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF061426),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green pulsing beacon dot
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF10B981),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _t('Instant Escrow Payout\nSettlement', 'አፋጣኝ የእስክሮው ክፍያ\nማጠናቀቂያ'),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Language Toggle Pill (EN / AM)
        GestureDetector(
          onTap: () {
            setState(() {
              _isAmharic = !_isAmharic;
            });
            HapticFeedback.selectionClick();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E3250)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  _isAmharic ? 'አማ' : 'EN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD6E3FE),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Notification Bell Icon Button
        GestureDetector(
          onTap: _showNotificationPanel,
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1E33),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFD6E3FE),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // User Avatar Button
        GestureDetector(
          onTap: _showProfileModal,
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFDBA74),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF431407),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeaderTagsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Tag: PAGE 26: INSTANT ESCROW PAYOUT SETTLEMENT
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E3250)),
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
                Flexible(
                  child: Text(
                    _t('PAGE 26: INSTANT ESCROW PAYOUT SETTLEMENT', 'ገጽ 26፡ አፋጣኝ የእስክሮው ክፍያ ማጠናቀቂያ'),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: const Color(0xFF34D399),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right Tag: Secured Payout
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: Color(0xFF34D399),
            ),
            const SizedBox(width: 4),
            Text(
              _t('Secured Payout', 'የተጠበቀ ክፍያ'),
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

  Widget _buildTripContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF18283D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Status Pill: e-POD Verified • Escrow Released by Shipper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF063B2B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF056449)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 13,
                  color: Color(0xFF34D399),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _t('e-POD Verified • Escrow Released by Shipper', 'ኢ-ፒኦዲ ተረጋግጧል • እስክሮው በላኪው ተፈቅዷል'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF34D399),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trip ID
          Text(
            '${_t("Trip", "ጉዞ")} $_tripId',
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Route Details: Addis Ababa -> Mekelle • 780 km
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                _originCity,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD6E3FE),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              Text(
                _destinationCity,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD6E3FE),
                ),
              ),
              Text(
                '•  ${widget.distanceKm ?? '—'} km',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierNetSettlementCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF091628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2F49)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top luminous green accent stripe
          Container(
            height: 3.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF059669),
                  Color(0xFF34D399),
                  Color(0xFF6EE7B7),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                // Carrier Net Settlement Title
                Text(
                  _t('CARRIER NET SETTLEMENT', 'የአጓጓዥ የተጣራ ክፍያ'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),

                // Huge Net Amount in Vibrant Mint Emerald
                Text(
                  'ETB ${_currencyFormat.format(_netSettlementAmount)}',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF34D399),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Funds Available Status Indicator
                Row(
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
                    Flexible(
                      child: Text(
                        _t('Funds Available for Instant Withdrawal', 'ገንዘቡ ወዲያውኑ ለማውጣት ዝግጁ ነው'),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Audited Ledger Summary inner card
                _buildAuditedLedgerSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditedLedgerSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060F1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14243A)),
      ),
      child: Column(
        children: [
          // Audited Ledger Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('AUDITED LEDGER SUMMARY', 'የተመረመረ የሂሳብ መዝገብ'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 13,
                    color: Color(0xFF60A5FA),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _t('Validated', 'ተረጋግጧል'),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF60A5FA),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Line 1: Gross Agreed Fare
          _ledgerLineRow(
            label: _t('Gross Agreed Fare', 'ስምምነት የተደረገበት ጠቅላላ ዋጋ'),
            amount: 'ETB ${_currencyFormat.format(_grossFareEtb)}',
            amountColor: Colors.white,
          ),
          const SizedBox(height: 10),

          // Line 2: HabeshaFreight Fee (2.5%) with Info icon
          _ledgerLineRow(
            labelWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _t(
                      'HabeshaFreight Fee (${widget.platformFeePercent}%)',
                      'የሐበሻ ፍሬይት የአገልግሎት ክፍያ (${widget.platformFeePercent}%)',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD6E3FE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showInfoDialog(
                    _t('HabeshaFreight Platform Fee', 'የሐበሻ ፍሬይት የአገልግሎት ክፍያ'),
                    _t(
                      'Automated 2.5% platform fee covers real-time GPS telemetry, smart contract escrow protection, and 24/7 patrol monitoring.',
                      'አውቶማቲክ የ2.5% የአገልግሎት ክፍያ የቀጥታ የጂፒኤስ ክትትልን፣ የስማርት ውል እስክሮው ዋስትናን እና የ24/7 የፓትሮል ድጋፍን ያካትታል።',
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            amount: '-ETB ${_currencyFormat.format(_platformFee)}',
            amountColor: const Color(0xFFF87171),
          ),
          const SizedBox(height: 10),

          // Line 3: MoR Withholding Tax (2.0%) with Bank icon
          _ledgerLineRow(
            labelWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _t(
                      'MoR Withholding Tax (${widget.withholdingTaxPercent}%)',
                      'የገቢዎች ሚኒስቴር የቅድመ ግብር (${widget.withholdingTaxPercent}%)',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD6E3FE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showInfoDialog(
                    _t('MoR Withholding Tax (2.0%)', 'የገቢዎች ሚኒስቴር የቅድመ ግብር (2.0%)'),
                    _t(
                      'Statutory 2.0% Ministry of Revenues withholding tax. A digital tax clearance certificate #TR-99402 is issued automatically.',
                      'በገቢዎች ሚኒስቴር ህግ መሰረት የተቆረጠ የ2.0% ቅድመ ግብር። ዲጂታል የግብር ማጽጃ ሰርተፍኬት #TR-99402 በራስ-ሰር ተዘጋጅቷል።',
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            amount: '-ETB ${_currencyFormat.format(_withholdingTax)}',
            amountColor: const Color(0xFFF87171),
          ),
          const SizedBox(height: 14),

          // Net Credited Balance Highlight Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF040A12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0D1D2E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _t('Net Credited Balance', 'የተጣራ የተከፈለ ቀሪ ሂሳብ'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ETB ${_currencyFormat.format(_netSettlementAmount)}',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ledgerLineRow({
    String? label,
    Widget? labelWidget,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (labelWidget != null)
          Expanded(child: labelWidget)
        else
          Expanded(
            child: Text(
              label ?? '',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFD6E3FE),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDisbursementChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Disbursement Channel + 0s processing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _t('Disbursement Channel', 'የክፍያ መቀበያ መስመር'),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 15,
                  color: Color(0xFF34D399),
                ),
                const SizedBox(width: 3),
                Text(
                  _t('0s processing', 'ቅጽበታዊ ማስተላለፍ'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 Channels Cards
        ..._channels.map((channel) => _buildChannelCard(channel)),
      ],
    );
  }

  Widget _buildChannelCard(DisbursementChannelInfo channel) {
    final isSelected = _selectedChannel == channel.type;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF091626),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF18283E),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _selectedChannel = channel.type;
            });
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Left Icon Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1E33),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1B2F4A)),
                  ),
                  child: Icon(
                    channel.icon,
                    size: 20,
                    color: channel.type == DisbursementChannelType.telebirr
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF93C5FD),
                  ),
                ),
                const SizedBox(width: 12),

                // Channel details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _isAmharic ? channel.titleAmharic : channel.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (channel.badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF451A03),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _t('Fastest', 'ፈጣን'),
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Account display
                      Text(
                        channel.accountDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle / Fee highlight
                      Row(
                        children: [
                          if (channel.type == DisbursementChannelType.telebirr)
                            const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Color(0xFF34D399),
                            ),
                          if (channel.type == DisbursementChannelType.telebirr)
                            const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _isAmharic
                                  ? channel.subtitleAmharic
                                  : channel.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: channel.type ==
                                        DisbursementChannelType.telebirr
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right radio selection control
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF334155),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Color(0xFF1E1100),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityClearanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF091424),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF16263B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with shield icon
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 16,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _t('Security & Statutory Clearance', 'የደህንነት እና ህጋዊ ፈቃድ'),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD6E3FE),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Smart Escrow Lock
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                _t('Smart Escrow Lock:', 'የስማርት እስክሮው መቆለፊያ፡'),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF060D17),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF132338)),
                ),
                child: Text(
                  _smartEscrowLockId,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: MoR Tax Clearance
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                _t('MoR Tax Clearance:', 'የገቢዎች ሚኒስቴር የግብር ማጽጃ፡'),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0F1E33),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        _t(
                          'Downloading MoR Tax Clearance Certificate #TR-99402.pdf...',
                          'የገቢዎች ሚኒስቴር የግብር ማጽጃ ሰርተፍኬት #TR-99402.pdf በመውረድ ላይ...',
                        ),
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.morTaxClearanceId ?? '—',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.file_download_outlined,
                      size: 14,
                      color: Color(0xFFFBBF24),
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

  Widget _buildPrimaryTransferButton() {
    final channel = _channels.firstWhere((c) => c.type == _selectedChannel);
    final formattedAmount = NumberFormat('#,###').format(_netSettlementAmount);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isProcessingTransfer ? null : _handleTransferNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          disabledBackgroundColor: const Color(0xFF78350F),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessingTransfer
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1100)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _t(
                        'Transfer ETB $formattedAmount to ${channel.channelShortName} Now',
                        'አሁን ETB $formattedAmount ወደ ${channel.channelShortName} አስተላልፍ',
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1100),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF1E1100),
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildViewDriverEarningsButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _showDriverEarningsWalletModal,
        icon: const Icon(
          Icons.account_balance_wallet_outlined,
          size: 17,
          color: Color(0xFFD6E3FE),
        ),
        label: Text(
          _t('View Updated Driver Earnings & Wallet', 'የተሻሻለውን የአሽከርካሪ ገቢ እና ቦርሳ ይመልከቱ'),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD6E3FE),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15243B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF243B5C)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF040E1B),
        border: Border(
          top: BorderSide(color: Color(0xFF14243A), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBarItem(
                index: 0,
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping_rounded,
                label: _t('Loads', 'ጭነቶች'),
              ),
              _navBarItem(
                index: 1,
                icon: Icons.gavel_outlined,
                activeIcon: Icons.gavel_rounded,
                label: _t('My Bids', 'የእኔ ጨረታዎች'),
              ),
              _navBarItem(
                index: 2,
                icon: Icons.navigation_outlined,
                activeIcon: Icons.navigation_rounded,
                label: _t('Trip/Active', 'ጉዞ/ንቁ'),
              ),
              _navBarItem(
                index: 3,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet_rounded,
                label: _t('Payouts', 'ክፍያዎች'),
              ),
              _navBarItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: _t('Profile', 'መገለጫ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBarItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? const Color(0xFFF59E0B) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentNavIndex = index;
          });
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Page 26: Instant Escrow Payout Settlement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF061426),
      ),
      home: const InstantEscrowPayoutSettlementScreen(),
    ),
  );
}

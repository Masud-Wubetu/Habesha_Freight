import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/escrow_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

export '../shipper_features/page05.dart';

  @override
  State<EscrowInvoicesScreen> createState() => _EscrowInvoicesScreenState();
}

class _EscrowInvoicesScreenState extends State<EscrowInvoicesScreen> {
  final EscrowService _escrowService = EscrowService();
  int _selectedTab = 0;
  bool _loading = true;
  List<_EscrowTransaction> _transactions = [];
  double _totalLocked = 0;
  double _totalReleased = 0;

  List<_EscrowTransaction> get _visibleTransactions {
    switch (_selectedTab) {
      case 1:
        return _transactions
            .where((t) => t.kind == _TransactionKind.released)
            .toList();
      case 2:
        return _transactions
            .where((t) => t.kind == _TransactionKind.disputed)
            .toList();
      default:
        return _transactions
            .where((t) =>
                t.kind == _TransactionKind.active ||
                t.kind == _TransactionKind.readyToRelease)
            .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ledger = await _escrowService.getLedger();
      final mapped = ledger.items.map(_mapItem).toList();
      if (!mounted) return;
      setState(() {
        _transactions = mapped;
        _totalLocked = ledger.totalLocked;
        _totalReleased = ledger.totalReleased;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _totalLocked = 0;
        _totalReleased = 0;
        _loading = false;
      });
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _totalLocked = 0;
        _totalReleased = 0;
        _loading = false;
      });
      _showMessage('Unable to load escrow ledger');
    }
  }

  _EscrowTransaction _mapItem(EscrowItem item) {
    final short = item.shipmentId.isNotEmpty
        ? (item.shipmentId.length > 6
            ? item.shipmentId.substring(0, 6).toUpperCase()
            : item.shipmentId.toUpperCase())
        : item.id;
    final status = item.status.toUpperCase();
    final kind = _kindFromStatus(status);
    final amount = item.grossAmount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final provider = kind == _TransactionKind.released
        ? 'Released & Settled'
        : (item.gatewayReference != null &&
                item.gatewayReference!.toLowerCase().contains('cbe')
            ? 'CBE Birr Escrow'
            : 'Telebirr Escrow');

    return _EscrowTransaction(
      id: short,
      paymentMethod: provider,
      origin: item.origin ?? '—',
      destination: item.destination ?? '—',
      amount: amount,
      status: kind == _TransactionKind.released
          ? 'Carrier: ${item.carrierName ?? 'N/A'}'
          : kind == _TransactionKind.readyToRelease
              ? 'Proof Ready · Awaiting POD OTP'
              : 'Status: $status',
      detail: item.cargo ?? item.gatewayReference ?? item.status,
      kind: kind,
      shipmentId: item.shipmentId,
    );
  }

  _TransactionKind _kindFromStatus(String status) {
    if (status == 'RELEASED') return _TransactionKind.released;
    if (status == 'DISPUTED' || status == 'REFUNDED') {
      return _TransactionKind.disputed;
    }
    if (status == 'PENDING') return _TransactionKind.readyToRelease;
    return _TransactionKind.active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A111F),
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Habesha',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Freight',
                    style: TextStyle(color: Color(0xFFFFB300)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'LOGISTICS EXCHANGE',
              style: TextStyle(
                color: Color(0xFF8B95A5),
                fontSize: 8,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'EN 文A',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFFB300),
            child: Icon(Icons.person, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 20),
        ],
      ),

      // Escrow page content.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Escrow & Invoices',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage protected payments and freight invoices.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 20),

            _securityBanner(),
            const SizedBox(height: 16),
            _summaryCard(),
            const SizedBox(height: 16),
            _tabBar(),
            const SizedBox(height: 14),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_visibleTransactions.isEmpty)
              _emptyState()
            else
              ..._visibleTransactions.map(_transactionCard),

            const SizedBox(height: 12),
            _batchFundingCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Reuse the existing shipper bottom navigation bar.
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: 1,
        onItemSelected: _handleNavigation,
        onAddPressed: () {
          _showMessage('Create a new freight request.');
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    // Replace these messages with your app's actual route navigation.
    switch (index) {
      case 0:
        _showMessage('Home selected');
        break;
      case 1:
        _showMessage('Shipments selected');
        break;
      case 2:
        _showMessage('Bids selected');
        break;
      case 3:
        _showMessage('Tracking selected');
        break;
    }
  }

  Widget _securityBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.secondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Protected by National Bank of Ethiopia & Telebirr',
              style: TextStyle(color: AppColors.onSurface, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE ESCROW LOCKED',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _formatEtb(_totalLocked),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' ETB',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hold release triggers on Driver POD OTP',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Released This Month',
                  '${_formatEtb(_totalReleased)} ETB',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'Active Consignments',
                  '${_transactions.where((t) => t.kind != _TransactionKind.released && t.kind != _TransactionKind.disputed).length} Corridor Runs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'SETTLEMENT VAULTS',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _vault('Telebirr Business', '+251 911 ••• 567'),
          const SizedBox(height: 8),
          _vault('CBE Birr Transit', 'Acct •••• 9812'),
          const SizedBox(height: 8),
          _vault('Chapa Card', 'Mastercard •• 4021'),
        ],
      ),
    );
  }

  Widget _metric(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vault(String title, String detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
        ],
      ),
    );
  }

  Widget _tabBar() {
    const tabs = ['Active Escrow', 'Invoices', 'Disputes'];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _selectedTab == index;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() => _selectedTab = index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.surfaceContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: AppColors.onSurfaceVariant,
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            'No disputes to display',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Disputed transactions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(_EscrowTransaction transaction) {
    final released = transaction.kind == _TransactionKind.released;
    final ready = transaction.kind == _TransactionKind.readyToRelease;

    final statusColor = released
        ? AppColors.secondary
        : ready
        ? AppColors.primary
        : AppColors.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${transaction.id}',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      transaction.paymentMethod,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
                    transaction.amount,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    released ? 'ETB Paid' : 'ETB Vaulted',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${transaction.origin} → ${transaction.destination}',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  released
                      ? Icons.receipt_long_outlined
                      : ready
                      ? Icons.warehouse_outlined
                      : Icons.local_shipping_outlined,
                  color: statusColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.detail,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (transaction.kind == _TransactionKind.active)
            const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.outline, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requires Driver Arrival OTP',
                    style: TextStyle(color: AppColors.outline, fontSize: 11),
                  ),
                ),
              ],
            )
          else if (ready)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _showOtpDialog,
                child: const Text('Enter POD OTP to Release'),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _showMessage('Official tax invoice #INV-1092');
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View Official Tax Invoice'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _batchFundingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Consignment Funding',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bulk-lock freight funds for multiple loads',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showMessage('Batch funding'),
            child: const Text('Batch Fund'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOtpDialog() async {
    final controller = TextEditingController();

    final otp = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Release escrow'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Enter POD OTP',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || otp == null) return;

    if (otp.length != 6 || int.tryParse(otp) == null) {
      _showMessage('Enter a valid 6-digit OTP.');
      return;
    }

    _showMessage('OTP captured. Connect the escrow API to release funds.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatEtb(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

enum _TransactionKind { active, readyToRelease, released, disputed }

class _EscrowTransaction {
  const _EscrowTransaction({
    required this.id,
    required this.paymentMethod,
    required this.origin,
    required this.destination,
    required this.amount,
    required this.status,
    required this.detail,
    required this.kind,
    this.shipmentId = '',
  });

  final String id;
  final String paymentMethod;
  final String origin;
  final String destination;
  final String amount;
  final String status;
  final String detail;
  final _TransactionKind kind;
  final String shipmentId;
}

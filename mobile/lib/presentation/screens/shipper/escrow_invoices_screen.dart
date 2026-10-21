import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

class EscrowInvoicesScreen extends StatefulWidget {
  const EscrowInvoicesScreen({super.key});

  @override
  State<EscrowInvoicesScreen> createState() => _EscrowInvoicesScreenState();
}

class _EscrowInvoicesScreenState extends State<EscrowInvoicesScreen> {
  int _selectedTab = 0;

  static const _transactions = <_EscrowTransaction>[
    _EscrowTransaction(
      id: 'HF-9012',
      paymentMethod: 'Telebirr Escrow',
      origin: 'Addis Ababa',
      destination: 'Dire Dawa',
      amount: '38,000',
      status: 'Driver in Transit (Awash Corridor)',
      detail: 'Waypoint 3/5 • Speed: 62 km/h',
      kind: _TransactionKind.active,
    ),
    _EscrowTransaction(
      id: 'HF-8841',
      paymentMethod: 'CBE Birr Escrow',
      origin: 'Addis Ababa',
      destination: 'Adama Cargo Dry Port',
      amount: '18,500',
      status: 'Offloading at Terminal • Proof Ready',
      detail: 'POD Signed by Consignee Bekele M.',
      kind: _TransactionKind.readyToRelease,
    ),
    _EscrowTransaction(
      id: 'HF-7720',
      paymentMethod: 'Released & Settled',
      origin: 'Hawassa',
      destination: 'Modjo Dry Port',
      amount: '42,000',
      status: 'Carrier: Selam Logistics PLC',
      detail: 'Completed Oct 4, 2024 • Invoice #INV-1092',
      kind: _TransactionKind.released,
    ),
  ];

  List<_EscrowTransaction> get _visibleTransactions {
    switch (_selectedTab) {
      case 1:
        return _transactions
            .where((t) => t.kind == _TransactionKind.released)
            .toList();
      case 2:
        return [];
      default:
        return _transactions
            .where((t) => t.kind != _TransactionKind.released)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      // HabeshaFreight branded header.
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

            if (_visibleTransactions.isEmpty)
              _emptyState()
            else
              ..._visibleTransactions.map(_transactionCard),

            const SizedBox(height: 12),
            _batchFundingCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Shipper bottom navigation.
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

          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '150,000',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
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
              Expanded(child: _metric('Released This Month', '890,000 ETB')),
              const SizedBox(width: 10),
              Expanded(
                child: _metric('Active Consignments', '2 Corridor Runs'),
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
}

enum _TransactionKind { active, readyToRelease, released }

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
  });

  final String id;
  final String paymentMethod;
  final String origin;
  final String destination;
  final String amount;
  final String status;
  final String detail;
  final _TransactionKind kind;
}

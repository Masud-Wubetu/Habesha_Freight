export '../phase_11_19_screens.dart' show FreightHistoryScreen;
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class FreightHistoryScreen extends StatefulWidget {
  const FreightHistoryScreen({super.key});

  @override
  State<FreightHistoryScreen> createState() => _FreightHistoryScreenState();
}

class _FreightHistoryScreenState extends State<FreightHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'Last 30 Days';

  final List<Map<String, dynamic>> _shipments = [
    {
      'id': 'HBF-2026-1042',
      'route': 'Addis Ababa → Djibouti',
      'cargo': 'Industrial Machinery',
      'date': 'Oct 18, 2026',
      'amount': '185,000 ETB',
      'status': 'Delivered',
    },
    {
      'id': 'HBF-2026-1038',
      'route': 'Dire Dawa → Addis Ababa',
      'cargo': 'Consumer Goods',
      'date': 'Oct 15, 2026',
      'amount': '72,500 ETB',
      'status': 'Delivered',
    },
    {
      'id': 'HBF-2026-1029',
      'route': 'Modjo → Hawassa',
      'cargo': 'Agricultural Products',
      'date': 'Oct 10, 2026',
      'amount': '96,000 ETB',
      'status': 'Delivered',
    },
    {
      'id': 'HBF-2026-1017',
      'route': 'Addis Ababa → Bahir Dar',
      'cargo': 'Building Materials',
      'date': 'Oct 04, 2026',
      'amount': '143,000 ETB',
      'status': 'Delivered',
    },
  ];

  List<Map<String, dynamic>> get _filteredShipments {
    final query = _searchController.text.toLowerCase().trim();

    return _shipments.where((shipment) {
      final matchesSearch = shipment.values.any(
        (value) => value.toString().toLowerCase().contains(query),
      );

      return matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Habesha',
                        style: TextStyle(color: AppColors.onSurface),
                      ),
                      TextSpan(
                        text: 'Freight',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Freight History',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '45 Completed',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Archived delivery records & verified digital '
                'proof-of-delivery receipts',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),

              // Total disbursed card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL DISBURSED',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '1,250,000 ETB',
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: AppColors.secondary,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '100% Verified POD',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search field
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Waybill #, corridor, or commodity...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  filled: true,
                  fillColor: AppColors.surfaceLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Date filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        'Last 30 Days',
                        'Last 90 Days',
                        'This Year',
                        'All Time',
                      ].map((filter) {
                        final selected = _selectedFilter == filter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: AppColors.surfaceLow,
                            selectedColor: AppColors.primaryContainer,
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMPLETED SHIPMENTS',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${_filteredShipments.length} records',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Shipment history cards
              if (_filteredShipments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No shipments found',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Try another waybill, route, or commodity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._filteredShipments.map(_buildShipmentCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shipment['id'],
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shipment['status'],
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.route_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  shipment['route'],
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.textSecondary,
                size: 17,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  shipment['cargo'],
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: AppColors.cardBorder.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  shipment['date'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                shipment['amount'],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

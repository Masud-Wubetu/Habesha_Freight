import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/shipper_service.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

class FreightHistoryScreen extends StatefulWidget {
  final List<ShipmentHistoryEntry>? initialShipments;

  const FreightHistoryScreen({super.key, this.initialShipments});

  @override
  State<FreightHistoryScreen> createState() => _FreightHistoryScreenState();
}

class _FreightHistoryScreenState extends State<FreightHistoryScreen> {
  final ShipperService _shipperService = ShipperService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Last 30 Days';
  List<_ShipmentHistoryEntry> _shipments = [];
  bool _loading = true;
  double _totalDisbursed = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _shipperService.listShipments();
      final delivered = rows
          .where((r) =>
              (r['status']?.toString() ?? '').toUpperCase() == 'DELIVERED')
          .map(_mapShipment)
          .toList();
      final total = delivered.fold<double>(
        0,
        (sum, s) => sum + (double.tryParse(s.amount.replaceAll(',', '')) ?? 0),
      );
      if (!mounted) return;
      setState(() {
        _shipments = delivered;
        _totalDisbursed = total;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _shipments = [];
        _totalDisbursed = 0;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _shipments = [];
        _totalDisbursed = 0;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load freight history')),
      );
    }
  }

  _ShipmentHistoryEntry _mapShipment(Map<String, dynamic> row) {
    final rawId = row['id']?.toString() ?? '';
    final short = rawId.length > 6
        ? rawId.substring(0, 6).toUpperCase()
        : rawId.toUpperCase();
    final price = row['offered_price_etb'] ?? row['amount_etb'] ?? 0;
    final amountNum = price is num ? price.toDouble() : double.tryParse(price.toString()) ?? 0;
    final amount = amountNum.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final created = row['delivered_at'] ?? row['updated_at'] ?? row['created_at'];
    String dateLabel = '—';
    if (created != null) {
      final dt = DateTime.tryParse(created.toString());
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        dateLabel = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      }
    }
    final weight = row['weight_tons'];
    final cargo = row['cargo_description']?.toString() ?? 'Freight';
    final cargoLabel = weight != null ? '${weight}T $cargo' : cargo;
    final driver = row['driver_name']?.toString() ??
        row['carrier_name']?.toString() ??
        'Carrier';
    final plate = row['plate_number']?.toString();
    final vehicle = row['vehicle_type']?.toString() ?? 'Heavy Rig';

    return _ShipmentHistoryEntry(
      id: 'WB-$short',
      date: dateLabel,
      routeFrom: row['origin_city']?.toString() ?? '—',
      routeTo: row['destination_city']?.toString() ?? '—',
      cargo: cargoLabel,
      amount: amount,
      status: 'Delivered',
      driverName: driver,
      truckInfo: plate != null ? '$vehicle • Plate $plate' : vehicle,
      rating: row['driver_rating']?.toString() ?? '—',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _computeTotalDisbursed() {
    final stats = _profile?['stats'] as Map<String, dynamic>?;
    if (stats != null && stats['total_spent_etb'] is num) {
      return (stats['total_spent_etb'] as num).toDouble();
    }
    return _shipments.fold<double>(0.0, (acc, item) {
      final clean = item.amount.replaceAll(',', '');
      return acc + (double.tryParse(clean) ?? 0.0);
    });
  }

  String _formatCurrency(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return val.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return val.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {

    final filteredShipments = _shipments.where((shipment) {
      final query = _searchController.text.toLowerCase();
      return shipment.id.toLowerCase().contains(query) ||
          shipment.routeFrom.toLowerCase().contains(query) ||
          shipment.routeTo.toLowerCase().contains(query) ||
          shipment.cargo.toLowerCase().contains(query);
    }).toList();

    final totalDisbursed = _computeTotalDisbursed();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Habesha',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Freight',
                        style: TextStyle(color: primaryYellow),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 8,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'EN',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: primaryYellow,
            child: Icon(Icons.person, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Freight History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: innerCardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_shipments.length} Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Archived delivery records & verified digital proof-of-delivery receipts',
                style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Total Disbursed Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: innerCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222E4A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: textLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL DISBURSED',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _totalDisbursed.toStringAsFixed(0).replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]},',
                                    ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'ETB',
                                  style: TextStyle(
                                    color: primaryYellow.withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: innerCardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_shipments.length} Completed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Archived delivery records & verified digital proof-of-delivery receipts',
                  style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),

                // Total Disbursed Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222E4A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: textLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL DISBURSED',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(totalDisbursed),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    'ETB',
                                    style: TextStyle(
                                      color: primaryYellow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Shipment List
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryYellow),
                  ),
                )
              else ...[
                ...filteredShipments.map(
                  (shipment) => _buildShipmentCard(
                    shipment,
                    cardColor,
                    innerCardColor,
                    primaryYellow,
                    textMuted,
                    greenAccent,
                  ),
                ),
                if (filteredShipments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'No shipments found.',
                        style: TextStyle(color: textMuted),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _load,
                  style: TextButton.styleFrom(
                    backgroundColor: innerCardColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: textLight, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Refresh History',
                        style: TextStyle(
                          color: textLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Shipment List or Loading or Empty State
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryYellow),
                    ),
                  )
                else if (filteredShipments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: innerCardColor),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: primaryYellow.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: primaryYellow,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No Freight History Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'When your consignments are completed and delivered on the corridor, their archive records and verified POD receipts will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.page23PostCargo),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text(
                            'Post Cargo Request',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredShipments.map(
                    (shipment) => _buildShipmentCard(shipment),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: 1,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.page10LiveTracking);
              break;
          }
        },
        onAddPressed: () {
          Navigator.pushNamed(context, AppRoutes.page23PostCargo);
        },
      ),
    );
  }

  Widget _buildShipmentCard(ShipmentHistoryEntry shipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipment ID, date, and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        shipment.id,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        shipment.date,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shipment.status,
                      style: const TextStyle(
                        color: greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route and amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shipment.routeFrom,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward,
                            color: primaryYellow,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      shipment.routeTo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                    shipment.amount,
                    style: const TextStyle(
                      color: primaryYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ETB Paid',
                    style: TextStyle(color: textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Cargo information
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: textMuted, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shipment.cargo,
                  style: const TextStyle(color: textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Driver profile card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: innerCardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.driverName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shipment.truckInfo,
                        style: const TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.star, color: primaryYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  shipment.rating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading official receipt for ${shipment.id}...'),
                        backgroundColor: cardColor,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: primaryYellow,
                    size: 18,
                  ),
                  label: const Text(
                    'Download PDF Receipt',
                    style: TextStyle(
                      color: primaryYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: innerCardColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: innerCardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('POD Verified: ${shipment.id}'),
                        backgroundColor: cardColor,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.verified_rounded,
                    color: greenAccent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

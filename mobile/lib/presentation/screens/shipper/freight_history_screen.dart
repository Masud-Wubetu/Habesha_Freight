import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

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
      'id': 'WB-89410',
      'date': 'Oct 4, 2026',
      'routeFrom': 'Modjo Dry Port',
      'routeTo': 'Mekelle IP',
      'cargo': '28T Industrial Rebar',
      'amount': '85,000',
      'status': 'Delivered & Released',
      'driverName': 'Kassahun Berhanu',
      'truckInfo': 'Sinotruk 30T • Plate 3-52419 ET',
      'rating': '4.9',
    },
    {
      'id': 'WB-89204',
      'date': 'Sep 28, 2026',
      'routeFrom': 'Addis Ababa',
      'routeTo': 'Dire Dawa FTZ',
      'cargo': '32T Wheat Flour',
      'amount': '54,000',
      'status': 'Delivered',
      'driverName': 'Solomon Tekle',
      'truckInfo': 'FAW J6P • Plate 3-84091 ET',
      'rating': '5.0',
    },
    {
      'id': 'WB-88912',
      'date': 'Sep 15, 2026',
      'routeFrom': 'Hawassa',
      'routeTo': 'Modjo Hub',
      'cargo': '22T Export Grade Coffee',
      'amount': '42,000',
      'status': 'Delivered',
      'driverName': 'Girma Tadesse',
      'truckInfo': 'Sinotruk • Plate 3-10294 ET',
      'rating': '4.8',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0A111F);
    const Color cardColor = Color(0xFF131C31);
    const Color innerCardColor = Color(0xFF1A243B);
    const Color primaryYellow = Color(0xFFFFB300);
    const Color textMuted = Color(0xFF8B95A5);
    const Color textLight = Color(0xFFE2E8F0);
    const Color greenAccent = Color(0xFF2EBD85);

    final filteredShipments = _shipments.where((shipment) {
      final query = _searchController.text.toLowerCase();

      return shipment['id'].toString().toLowerCase().contains(query) ||
          shipment['routeFrom'].toString().toLowerCase().contains(query) ||
          shipment['routeTo'].toString().toLowerCase().contains(query) ||
          shipment['cargo'].toString().toLowerCase().contains(query);
    }).toList();

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
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      const TextSpan(
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
                Text(
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
              'EN 文A',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: primaryYellow,
            child: const Icon(Icons.person, color: Colors.black, size: 20),
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
                    child: const Text(
                      '45 Completed',
                      style: TextStyle(
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
                              const Text(
                                '1,250,000',
                                style: TextStyle(
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: greenAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: greenAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '100% Verified POD',
                            style: TextStyle(
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
              ),
              const SizedBox(height: 20),

              // Search Field
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search Waybill #, corridor, or commodity...',
                  hintStyle: TextStyle(color: textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: textMuted),
                  filled: true,
                  fillColor: innerCardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Last 30 Days', 'This Quarter', 'All Time'].map((
                    filter,
                  ) {
                    final isSelected = _selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryYellow : innerCardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.black : textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Shipment List
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

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
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
                      Icon(Icons.history, color: textLight, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Load Older Corridors (42 more)',
                        style: TextStyle(
                          color: textLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: 1,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              // Navigate to Home
              break;
            case 1:
              // Already on Freight History
              break;
            case 2:
              // Navigate to Bids
              break;
            case 3:
              // Navigate to Tracking
              break;
          }
        },
        onAddPressed: () {
          // Add your create-shipment action here
        },
      ),
    );
  }

  Widget _buildShipmentCard(
    Map<String, dynamic> shipment,
    Color cardColor,
    Color innerCardColor,
    Color primaryYellow,
    Color textMuted,
    Color greenAccent,
  ) {
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
                        shipment['id'].toString(),
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
                        shipment['date'].toString(),
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
                  color: greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shipment['status'].toString(),
                      style: TextStyle(
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
                            shipment['routeFrom'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward,
                            color: primaryYellow,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      shipment['routeTo'].toString(),
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
                    shipment['amount'].toString(),
                    style: TextStyle(
                      color: primaryYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
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
              Icon(Icons.local_shipping_outlined, color: textMuted, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shipment['cargo'].toString(),
                  style: TextStyle(color: textMuted, fontSize: 12),
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
                        shipment['driverName'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shipment['truckInfo'].toString(),
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.star, color: primaryYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  shipment['rating'].toString(),
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: primaryYellow,
                    size: 18,
                  ),
                  label: Text(
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.verified_rounded,
                    color: textMuted,
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

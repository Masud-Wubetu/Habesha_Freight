import 'package:flutter/material.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/presentation/screens/driver/available_loads_screen.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = true;

  static const Color navy = Color(0xFF0F172A);
  static const Color gold = Color(0xFFFFB300);
  static const Color background = Color(0xFF0B1120);
  static const Color muted = Color(0xFF94A3B8);
  static const Color blue = Color(0xFF4385D7);
  static const Color green = Color(0xFF239B70);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textWhite = Colors.white;

  void _handleDriverNavigation(int index) {
    switch (index) {
      case 0: // Load
        Navigator.push(
          context,
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 240),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AvailableFreightLoadsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: child,
                    ),
                  );
                },
          ),
        );
        break;
      case 1: // Offer
        Navigator.pushNamed(context, AppRoutes.page18DirectOffers);
        break;
      case 2: // Home
        break;
      case 3: // Bids
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bids screen is not connected yet.')),
        );
        break;
      case 4: // Tracking
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking screen is not connected yet.'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      language: 'EN',
                      onLanguageChanged: (_) {},
                      onProfileTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildAvailabilityCard(),
                    const SizedBox(height: 16),
                    _buildUrgentMatchCard(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildActiveDelivery(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('CARRIER ACTIONS', null),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildActiveBidPipeline(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: 2,
        onTap: _handleDriverNavigation,
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Selam, Solomo...',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.settings, size: 16, color: muted),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'FAW 32T Heavy Rig • 3-8...',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'ONLINE',
                  style: TextStyle(
                    color: green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentMatchCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, color: gold),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: gold,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'CORRIDOR URGENT MATCH',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: navy,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.access_time, size: 10, color: muted),
                              SizedBox(width: 4),
                              Text(
                                '42m left',
                                style: TextStyle(color: muted, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hawassa ➔ Modjo Dry Port',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '28T Export Washed Grade-1 Sidama Coffee',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GUARANTEED RATE',
                              style: TextStyle(
                                color: muted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '45,000 ',
                                    style: TextStyle(
                                      color: gold,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ETB',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text(
                            'Quick Bid',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCardDark(
                title: 'TELEBIRR WALLET',
                icon: Icons.account_balance_wallet_outlined,
                mainValue: '42,500',
                unit: 'ETB',
                subWidget: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 12, color: green),
                    SizedBox(width: 4),
                    Text(
                      'Instant Payout',
                      style: TextStyle(color: green, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildStatCardDark(
                title: "TODAY'S BIDS",
                icon: Icons.gavel,
                mainValue: '3',
                suffixText: 'Active',
                subWidget: const Text(
                  '1 Under Final Review',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _buildStatCardDark(
                title: 'ACTIVE RUN',
                icon: Icons.local_shipping_outlined,
                mainValue: '1',
                suffixText: 'Trip',
                subWidget: const Row(
                  children: [
                    Icon(Icons.play_arrow, size: 12, color: gold),
                    SizedBox(width: 4),
                    Text(
                      'In Progress',
                      style: TextStyle(color: gold, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildStatCardDark(
                title: 'SAFETY RATING',
                icon: Icons.star_border,
                mainValue: '4.85',
                starIcon: true,
                subWidget: const Text(
                  '89 Verified Trips',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardDark({
    required String title,
    required IconData icon,
    required String mainValue,
    String? unit,
    String? suffixText,
    bool starIcon = false,
    required Widget subWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(icon, size: 14, color: muted),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: mainValue,
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                if (suffixText != null)
                  TextSpan(
                    text: ' $suffixText',
                    style: const TextStyle(
                      color: textWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (starIcon)
                  const WidgetSpan(
                    child: Icon(Icons.star, color: gold, size: 14),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          subWidget,
        ],
      ),
    );
  }

  Widget _buildActiveDelivery() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: green),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ACTIVE TRIP: #HF-9012',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Dire Dawa Route',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORIGIN', style: TextStyle(color: muted, fontSize: 9)),
                    SizedBox(height: 4),
                    Text(
                      'Addis Ababa',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kality Freight Depot',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward, color: gold, size: 18),
                    SizedBox(height: 4),
                    Text('452 km', style: TextStyle(color: muted, fontSize: 9)),
                  ],
                ),
              ),
              const Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DESTINATION',
                      style: TextStyle(color: muted, fontSize: 9),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dire Dawa',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Industrial Free Zone',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.speed, size: 14, color: green),
                  SizedBox(width: 4),
                  Text(
                    '68 km/h Live Cruise',
                    style: TextStyle(color: green, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 14, color: gold),
                  SizedBox(width: 4),
                  Text(
                    '28T Teff & Grain',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passing Awash Checkpoint',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ETA Dire Dawa: 3h 15m',
                              style: TextStyle(color: Colors.grey, fontSize: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: green),
                        SizedBox(width: 4),
                        Text(
                          'GPS Synced',
                          style: TextStyle(color: Colors.white, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.near_me, size: 16),
                  label: const Text(
                    'Live GPS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textWhite,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text(
                    'Waybill',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.list_alt,
          label: 'Available\nLoads',
          badgeCount: '13',
        ),
        _buildActionButton(
          icon: Icons.local_offer,
          label: 'Direct\nOffers',
          badgeCount: '2',
          iconColor: green,
        ),
        _buildActionButton(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Telebirr\nWallet',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? badgeCount,
    Color? iconColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: navy,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor ?? gold, size: 22),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: gold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textWhite, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBidPipeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: gold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'ACTIVE BID PIPELINE',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Text(
                'View All',
                style: TextStyle(
                  color: gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBidItem(
            route: 'Hawassa ➔ A...',
            status: 'Reviewing',
            statusColor: gold,
            price: '36,500',
            shipper: 'Shipper: Sidama Farmers Coop • 2...',
            time: '18 mins ago',
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildBidItem(
            route: 'Mojo ➔ ...',
            status: 'Counter-Offer',
            statusColor: green,
            price: '78,000',
            shipper: 'Shipper: Ethio Logistics S.C. • 3...',
            subText: 'Shipper offered 74k',
          ),
        ],
      ),
    );
  }

  Widget _buildBidItem({
    required String route,
    required String status,
    required Color statusColor,
    required String price,
    required String shipper,
    String? time,
    String? subText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        route,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shipper,
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' ETB',
                        style: TextStyle(color: muted, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (time != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 10, color: green),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(color: green, fontSize: 9),
                      ),
                    ],
                  ),
                if (subText != null)
                  Text(
                    subText,
                    style: const TextStyle(color: muted, fontSize: 9),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

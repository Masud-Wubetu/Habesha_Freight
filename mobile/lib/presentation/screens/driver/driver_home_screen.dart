import 'package:flutter/material.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/driver_service.dart';
import 'package:mobile/core/services/message_service.dart';
import 'package:mobile/presentation/screens/driver/available_loads_screen.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverService _driverService = DriverService();
  final MessageService _messageService = MessageService();
  bool _loading = true;
  int _conversationCount = 0;

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _shipments = [];
  List<Map<String, dynamic>> _bids = [];
  Map<String, dynamic>? _activeShipment;
  Map<String, dynamic>? _urgentLoad;

  static const Color navy = Color(0xFF0F172A);
  static const Color gold = Color(0xFFFFB300);
  static const Color muted = Color(0xFF94A3B8);
  static const Color green = Color(0xFF239B70);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color textWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _driverService.getStats(),
        _driverService.listShipments(),
        _driverService.listBids(),
        _driverService.listAvailableLoads(),
      ]);
      await _refreshConversationBadge();
      final stats = results[0] as Map<String, dynamic>;
      final shipments = results[1] as List<Map<String, dynamic>>;
      final bids = results[2] as List<Map<String, dynamic>>;
      final loads = results[3] as List<Map<String, dynamic>>;

      Map<String, dynamic>? active;
      for (final s in shipments) {
        final status = (s['status']?.toString() ?? '').toUpperCase();
        if (status == 'IN_TRANSIT' || status == 'DISPATCHED' || status == 'ASSIGNED') {
          active = s;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _shipments = shipments;
        _bids = bids;
        _activeShipment = active;
        _urgentLoad = loads.isNotEmpty ? loads.first : null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = {};
        _shipments = [];
        _bids = [];
        _activeShipment = null;
        _urgentLoad = null;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stats = {};
        _shipments = [];
        _bids = [];
        _activeShipment = null;
        _urgentLoad = null;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load driver home')),
      );
    }
  }

  /// Stub entry for messaging: fetches conversations for badge/count snackbar.
  Future<void> _refreshConversationBadge() async {
    try {
      final conversations = await _messageService.listConversations();
      if (!mounted) return;
      setState(() => _conversationCount = conversations.length);
    } catch (_) {
      if (!mounted) return;
      setState(() => _conversationCount = 0);
    }
  }

  Future<void> _showConversationsStub() async {
    try {
      final conversations = await _messageService.listConversations();
      if (!mounted) return;
      setState(() => _conversationCount = conversations.length);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conversations.isEmpty
                ? 'No conversations yet'
                : '${conversations.length} conversations',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load conversations')),
      );
    }
  }

  void _openAvailableLoads() {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AvailableFreightLoadsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  void _handleDriverNavigation(int index) {
    switch (index) {
      case 0: // Load
        _openAvailableLoads();
        break;
      case 1: // Offer
        Navigator.pushNamed(context, AppRoutes.page18DirectOffers);
        break;
      case 2: // Home
        break;
      case 3: // Bids — open available loads (bid board)
        _openAvailableLoads();
        break;
      case 4: // Tracking
        if (_activeShipment != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tracking ${_activeShipment!['origin_city'] ?? ''} → ${_activeShipment!['destination_city'] ?? ''}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active shipment to track')),
          );
        }
        break;
    }
  }

  String _fmt(num? n) {
    if (n == null) return '0';
    return n.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: gold))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: gold,
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Habesha',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Freight',
                      style: TextStyle(
                        color: gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'LOGISTICS EXCHANGE',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Messages',
          onPressed: _showConversationsStub,
          icon: Badge(
            isLabelVisible: _conversationCount > 0,
            label: Text('$_conversationCount'),
            child: const Icon(Icons.chat_outlined, color: muted),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text('EN', style: TextStyle(color: textWhite, fontSize: 12)),
              SizedBox(width: 4),
              Icon(Icons.translate, size: 14, color: muted),
            ],
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Driver Account Options',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.black, size: 18),
          ),
          color: cardColor,
          onSelected: (val) async {
            if (val == 'signout') {
              await StorageService.clearAuthData();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (r) => false,
              );
            } else if (val == 'shipper') {
              Navigator.pushNamed(context, AppRoutes.home);
            } else if (val == 'fleet') {
              Navigator.pushNamed(context, AppRoutes.fleetHub);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'info',
              enabled: false,
              child: Text(
                'Driver • $_driverName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: gold,
                ),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'shipper',
              child: Row(
                children: [
                  Icon(Icons.storefront_rounded, size: 16, color: gold),
                  SizedBox(width: 8),
                  Text('Shipper Dashboard', style: TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fleet',
              child: Row(
                children: [
                  Icon(Icons.dashboard_rounded, size: 16, color: Color(0xFF34D399)),
                  SizedBox(width: 8),
                  Text('Fleet Command Hub', style: TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ],
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
    final load = _urgentLoad;
    if (load == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No urgent corridor matches right now. Check available loads.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
      );
    }

    final origin = load['origin_city']?.toString() ?? '—';
    final dest = load['destination_city']?.toString() ?? '—';
    final cargo = load['cargo_description']?.toString() ?? 'Freight';
    final priceRaw = load['offered_price_etb'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0;
    final loadId = load['id']?.toString() ?? '';

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
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: gold),
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
                    const SizedBox(height: 10),
                    Text(
                      '$origin ➔ $dest',
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cargo,
                      style: const TextStyle(color: muted, fontSize: 11),
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
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_fmt(price)} ',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'ETB',
                                    style: TextStyle(color: muted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: loadId.isEmpty
                              ? null
                              : () async {
                                  try {
                                    await _driverService.placeBid(
                                      loadId: loadId,
                                      amountEtb: price > 0 ? price : 1,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Quick bid submitted'),
                                        backgroundColor: green,
                                      ),
                                    );
                                    _load();
                                  } on ApiException catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.message)),
                                    );
                                  } catch (_) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bid failed'),
                                      ),
                                    );
                                  }
                                },
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
    final earnings = _stats['totalEarningsEtb'];
    final pendingBids = _stats['pendingBids'] ?? _bids.length;
    final activeJobs = _stats['activeJobs'] ?? (_activeShipment != null ? 1 : 0);
    final rating = _stats['avgRating'] ?? 4.9;
    final trips = _stats['totalTrips'] ?? _shipments.length;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCardDark(
                title: 'TELEBIRR WALLET',
                icon: Icons.account_balance_wallet_outlined,
                mainValue: _fmt(earnings is num ? earnings : 0),
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
                mainValue: '$pendingBids',
                suffixText: 'Active',
                subWidget: Text(
                  '${_bids.length} total bids',
                  style: const TextStyle(color: muted, fontSize: 10),
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
                mainValue: '$activeJobs',
                suffixText: 'Trip',
                subWidget: Row(
                  children: [
                    Icon(
                      Icons.play_arrow,
                      size: 12,
                      color: activeJobs > 0 ? gold : muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeJobs > 0 ? 'In Progress' : 'Idle',
                      style: TextStyle(
                        color: activeJobs > 0 ? gold : muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildStatCardDark(
                title: 'SAFETY RATING',
                icon: Icons.star_border,
                mainValue: '$rating',
                starIcon: true,
                subWidget: Text(
                  '$trips Verified Trips',
                  style: const TextStyle(color: muted, fontSize: 10),
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
    final active = _activeShipment;
    if (active == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No active delivery',
              style: TextStyle(
                color: textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'When you are assigned a run it will appear here.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openAvailableLoads,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Browse Available Loads'),
            ),
          ],
        ),
      );
    }

    final rawId = active['id']?.toString() ?? '';
    final short = rawId.length > 6
        ? rawId.substring(0, 6).toUpperCase()
        : rawId.toUpperCase();
    final origin = active['origin_city']?.toString() ?? '—';
    final dest = active['destination_city']?.toString() ?? '—';
    final cargo = active['cargo_description']?.toString() ?? 'Freight';
    final weight = active['weight_tons'];
    final cargoLabel = weight != null ? '${weight}T $cargo' : cargo;
    final status = active['status']?.toString() ?? 'IN_TRANSIT';

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
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: green),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ACTIVE TRIP: #HF-$short',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                child: Text(
                  status,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORIGIN', style: TextStyle(color: muted, fontSize: 9)),
                    const SizedBox(height: 4),
                    Text(
                      origin,
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward, color: gold, size: 18),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(color: muted, fontSize: 9),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dest,
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 14, color: gold),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cargoLabel,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tracking $origin → $dest')),
                    );
                  },
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Waybill #HF-$short')),
                    );
                  },
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
          badgeCount: _urgentLoad != null ? '1+' : null,
          onTap: _openAvailableLoads,
        ),
        _buildActionButton(
          icon: Icons.local_offer,
          label: 'Direct\nOffers',
          badgeCount: _bids.isNotEmpty ? '${_bids.length}' : null,
          iconColor: green,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.page18DirectOffers),
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
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildActiveBidPipeline() {
    final pipeline = _bids.take(3).toList();

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
              GestureDetector(
                onTap: _openAvailableLoads,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pipeline.isEmpty)
            const Text(
              'No active bids yet. Place a bid on available loads.',
              style: TextStyle(color: muted, fontSize: 12),
            )
          else
            ...pipeline.asMap().entries.map((entry) {
              final bid = entry.value;
              final origin = bid['origin_city']?.toString() ?? '—';
              final dest = bid['destination_city']?.toString() ?? '—';
              final status = (bid['status']?.toString() ?? 'PENDING').toUpperCase();
              final amount = bid['bid_amount_etb'];
              final priceNum = amount is num
                  ? amount.toDouble()
                  : double.tryParse(amount?.toString() ?? '') ?? 0;
              final shipper = bid['shipper_name']?.toString() ?? 'Shipper';
              final statusColor = status.contains('COUNTER')
                  ? green
                  : status == 'ACCEPTED'
                      ? green
                      : gold;
              return Column(
                children: [
                  if (entry.key > 0)
                    const Divider(color: Colors.white12, height: 24),
                  _buildBidItem(
                    route: '$origin ➔ $dest',
                    status: status,
                    statusColor: statusColor,
                    price: _fmt(priceNum),
                    shipper: 'Shipper: $shipper',
                  ),
                ],
              );
            }),
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

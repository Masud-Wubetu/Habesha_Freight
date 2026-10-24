import 'package:flutter/material.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/driver_service.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';

class DirectCargoOffersScreen extends StatefulWidget {
  const DirectCargoOffersScreen({super.key, this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  State<DirectCargoOffersScreen> createState() =>
      _DirectCargoOffersScreenState();
}

class _DirectCargoOffersScreenState extends State<DirectCargoOffersScreen> {
  static const Color _background = Color(0xFF061426);
  static const Color _surface = Color(0xFF0E1C2F);
  static const Color _surfaceHigh = Color(0xFF1D2A3E);
  static const Color _gold = Color(0xFFFFB21A);
  static const Color _green = Color(0xFF4EDEA3);
  static const Color _muted = Color(0xFF91A4BC);
  static const Color _white = Color(0xFFF4F7FC);

  final DriverService _driverService = DriverService();
  final TextEditingController _counterController = TextEditingController();

  bool _standbyEnabled = true;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<Map<String, dynamic>> _offers = [];
  final Set<String> _declinedIds = {};
  final Set<String> _acceptedIds = {};
  String? _counterLoadId;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _driverService.listAvailableLoads();
      if (!mounted) return;
      setState(() {
        _offers = rows;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _offers = [];
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offers = [];
        _error = 'Unable to load direct offers';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visibleOffers => _offers
      .where((o) => !_declinedIds.contains(o['id']?.toString()))
      .toList();

  void _handleDriverNavigation(int index) {
    switch (index) {
      case 0:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('loads');
        } else {
          Navigator.pushNamed(context, AppRoutes.page17AvailableLoads);
        }
        break;
      case 1:
        widget.onNavigate?.call('offers');
        break;
      case 2:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('home');
        } else {
          Navigator.pushNamed(context, AppRoutes.page16DriverHome);
        }
        break;
      case 3:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('bids');
        } else {
          Navigator.pushNamed(context, AppRoutes.page17AvailableLoads);
        }
        break;
      case 4:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('tracking');
        } else {
          Navigator.pushNamed(context, AppRoutes.page16DriverHome);
        }
        break;
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _surfaceHigh),
    );
  }

  num _priceOf(Map<String, dynamic> load) {
    final raw = load['offered_price_etb'];
    if (raw is num) return raw;
    return num.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _fmt(num n) => n.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  Future<void> _placeBidFor(Map<String, dynamic> load, {num? amount}) async {
    final loadId = load['id']?.toString() ?? '';
    if (loadId.isEmpty) {
      _showMessage('Missing load id');
      return;
    }
    final bidAmount = amount ?? _priceOf(load);
    if (bidAmount <= 0) {
      _showMessage('Enter a valid bid amount');
      return;
    }
    setState(() => _submitting = true);
    try {
      await _driverService.placeBid(loadId: loadId, amountEtb: bidAmount);
      if (!mounted) return;
      setState(() {
        _acceptedIds.add(loadId);
        _counterLoadId = null;
        _submitting = false;
      });
      _showMessage('Bid of ${_fmt(bidAmount)} ETB submitted');
      await _loadOffers();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showMessage('Failed to place bid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleOffers;
    final primary = visible.isNotEmpty ? visible.first : null;
    final secondary = visible.length > 1 ? visible[1] : null;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_outlined, color: _gold),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Habesha',
                        style: TextStyle(color: _white),
                      ),
                      TextSpan(
                        text: 'Freight',
                        style: TextStyle(color: _gold),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: _muted,
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
            onPressed: _loading ? null : _loadOffers,
            icon: const Icon(Icons.refresh, color: _muted),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text(
                  'EN',
                  style: TextStyle(color: _gold, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 4),
                Icon(Icons.translate, size: 16, color: _muted),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _gold,
              child: Icon(Icons.person, size: 19, color: Color(0xFF472A00)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : RefreshIndicator(
                color: _gold,
                onRefresh: _loadOffers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildNotificationBanner(visible.length),
                      const SizedBox(height: 16),
                      if (_error != null)
                        _buildStatusMessage(
                          icon: Icons.cloud_off,
                          title: 'Unable to load offers',
                          subtitle: _error!,
                          color: Colors.redAccent,
                        )
                      else if (visible.isEmpty)
                        _buildStatusMessage(
                          icon: Icons.inbox_outlined,
                          title: 'No direct offers',
                          subtitle:
                              'Available loads will appear here when shippers post to the corridor.',
                          color: _muted,
                        )
                      else ...[
                        if (primary != null) _buildPriorityOfferCard(primary),
                        if (secondary != null) ...[
                          const SizedBox(height: 16),
                          _buildSecondaryOfferCard(secondary),
                        ],
                      ],
                      const SizedBox(height: 16),
                      _buildStandbyCard(),
                      if (_counterLoadId != null) ...[
                        const SizedBox(height: 16),
                        _buildCounterForm(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: 1,
        onTap: _handleDriverNavigation,
      ),
    );
  }

  Widget _buildNotificationBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _badge(
                      count > 0 ? '$count Open Loads' : 'No Open Loads',
                      background: const Color(0xFFF59E0B),
                      foreground: const Color(0xFF472A00),
                    ),
                    _badge(
                      '●  Live API',
                      background: const Color(0x334EDEA3),
                      foreground: _green,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Direct Cargo Offers',
                  style: TextStyle(
                    color: _white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Exclusive freight offers routed directly to your '
                  'truck profile by preferred shippers.',
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.forward_to_inbox, color: _gold, size: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOfferCard(Map<String, dynamic> load) {
    final loadId = load['id']?.toString() ?? '';
    final accepted = _acceptedIds.contains(loadId);
    final origin = load['origin_city']?.toString() ?? '—';
    final dest = load['destination_city']?.toString() ?? '—';
    final cargo = load['cargo_description']?.toString() ?? 'Freight';
    final shipper = load['shipper_name']?.toString() ?? 'Shipper';
    final weight = load['weight_tons'];
    final price = _priceOf(load);
    final cargoLine = weight != null ? '${weight}T $cargo' : cargo;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF59E0B),
                  Color(0xFFFFC174),
                  Color(0xFFF59E0B),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _surfaceHigh,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.corporate_fare, color: _gold),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipper,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Row(
                            children: [
                              Icon(Icons.verified, color: _green, size: 13),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Verified shipper',
                                  style: TextStyle(color: _green, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildRoutePanel(origin, dest),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecCard(
                        title: 'CARGO & RIG',
                        value: cargoLine,
                        detail: load['status']?.toString() ?? 'POSTED',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSpecCard(
                        title: 'LOADING SLOT',
                        value: 'As posted',
                        detail: 'Open for bids',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildPayoutPanel(price),
                const SizedBox(height: 12),
                if (accepted)
                  _buildStatusMessage(
                    icon: Icons.check_circle,
                    title: 'Bid Submitted',
                    subtitle: 'Your bid was sent to the shipper.',
                    color: _green,
                  )
                else ...[
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _submitting
                          ? null
                          : () => _placeBidFor(load),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: Text(
                        _submitting ? 'Submitting…' : 'Accept Offer Immediately',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: const Color(0xFF472A00),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _counterController.text =
                                price > 0 ? price.toStringAsFixed(0) : '';
                            setState(() => _counterLoadId = loadId);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('Counter Fare'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _gold,
                            side: const BorderSide(color: Color(0xFF534434)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _declinedIds.add(loadId);
                              if (_counterLoadId == loadId) {
                                _counterLoadId = null;
                              }
                            });
                          },
                          icon: const Icon(Icons.close, size: 17),
                          label: const Text('Decline Offer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFA6A6),
                            side: const BorderSide(color: Color(0xFF28354A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel(String origin, String dest) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'DIRECT CORRIDOR',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 18,
                child: Column(
                  children: [
                    Icon(Icons.circle, size: 11, color: _gold),
                    SizedBox(
                      height: 23,
                      child: VerticalDivider(
                        color: Color(0xFF28354A),
                        thickness: 2,
                      ),
                    ),
                    Icon(Icons.circle, size: 11, color: _green),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      origin,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      dest,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildSpecCard({
    required String title,
    required String value,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _gold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutPanel(num price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GUARANTEED PAYOUT',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _fmt(price),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'ETB',
                      style: TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Shipper offered fare',
                  style: TextStyle(color: _green, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.shield_outlined, color: _green, size: 14),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Escrow Protected',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: _green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'CBE Birr Institutional Guarantee',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryOfferCard(Map<String, dynamic> load) {
    final loadId = load['id']?.toString() ?? '';
    final origin = load['origin_city']?.toString() ?? '—';
    final dest = load['destination_city']?.toString() ?? '—';
    final cargo = load['cargo_description']?.toString() ?? 'Freight';
    final shipper = load['shipper_name']?.toString() ?? 'Shipper';
    final weight = load['weight_tons'];
    final price = _priceOf(load);
    final cargoLine = weight != null ? '${weight}T $cargo' : cargo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _surfaceHigh,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.agriculture_outlined, color: _gold),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipper,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Verified Shipper',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    origin,
                    style: const TextStyle(color: _white, fontSize: 12),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: _gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dest,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: _white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: _gold, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  cargoLine,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _fmt(price),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(
                      text: ' ETB',
                      style: TextStyle(color: _white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : () => _placeBidFor(load),
                  icon: const Icon(Icons.check_circle_outline, size: 17),
                  label: const Text('Review & Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF44391F),
                    foregroundColor: _gold,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _declinedIds.add(loadId));
                  },
                  icon: const Icon(Icons.close, size: 17),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFA6A6),
                    backgroundColor: _surfaceHigh,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandbyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x334EDEA3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.cell_tower, color: _green),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corridor Standby Status',
                      style: TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Broadcasting Availability',
                      style: TextStyle(color: _green, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _standbyEnabled,
                activeThumbColor: _white,
                activeTrackColor: _green,
                onChanged: (value) {
                  setState(() => _standbyEnabled = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              _standbyEnabled
                  ? 'Your truck is visible to shippers posting open loads on the corridor.'
                  : 'Standby paused — you will not receive new direct offer pings.',
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterForm() {
    Map<String, dynamic>? load;
    for (final o in _offers) {
      if (o['id']?.toString() == _counterLoadId) {
        load = o;
        break;
      }
    }
    final shipper = load?['shipper_name']?.toString() ?? 'Shipper';
    final cargo = load?['cargo_description']?.toString() ?? 'Freight';
    final original = load != null ? _priceOf(load) : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Submit Counter Fare',
                  style: TextStyle(
                    color: _white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _counterLoadId = null),
                icon: const Icon(Icons.close, color: _muted),
              ),
            ],
          ),
          Text(
            '$shipper • $cargo',
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Original Dispatch Rate',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                Text(
                  '${_fmt(original)} ETB',
                  style: const TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Proposed Rate (ETB)',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _counterController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: _white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: 'ETB  ',
              prefixStyle: const TextStyle(
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: _surfaceHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submitting || load == null
                ? null
                : () {
                    final rate = num.tryParse(_counterController.text.trim());
                    if (rate == null || rate <= 0) {
                      _showMessage('Enter a valid proposed fare.');
                      return;
                    }
                    _placeBidFor(load, amount: rate);
                  },
            icon: const Icon(Icons.send, size: 17),
            label: const Text('Dispatch Counter to Shipper'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: const Color(0xFF472A00),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _counterLoadId = null),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(
    String text, {
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

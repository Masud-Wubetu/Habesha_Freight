import 'package:flutter/material.dart';
import 'package:mobile/core/routing/app_routes.dart';
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

  bool _standbyEnabled = true;
  bool _offerDeclined = false;
  bool _offerAccepted = false;
  bool _showCounterForm = false;

  final TextEditingController _counterController = TextEditingController(
    text: '36000',
  );

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
          _showMessage('Bids screen is not connected yet.');
        }
        break;
      case 4:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('tracking');
        } else {
          _showMessage('Tracking screen is not connected yet.');
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

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNotificationBanner(),
              const SizedBox(height: 16),
              if (!_offerDeclined) _buildPriorityOfferCard(),
              if (_offerDeclined)
                _buildStatusMessage(
                  icon: Icons.cancel_outlined,
                  title: 'Offer declined',
                  subtitle: 'This direct cargo offer has been dismissed.',
                  color: Colors.redAccent,
                ),
              const SizedBox(height: 16),
              _buildSecondaryOfferCard(),
              const SizedBox(height: 16),
              _buildStandbyCard(),
              if (_showCounterForm) ...[
                const SizedBox(height: 16),
                _buildCounterForm(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: 1,
        onTap: _handleDriverNavigation,
      ),
    );
  }

  Widget _buildNotificationBanner() {
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
                      '2 Urgent Requests',
                      background: const Color(0xFFF59E0B),
                      foreground: const Color(0xFF472A00),
                    ),
                    _badge(
                      '●  Telemetry Synced',
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

  Widget _buildPriorityOfferCard() {
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abyssinia Logistics PLC',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.verified, color: _green, size: 13),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'FTA Tier-1 Enterprise',
                                  style: TextStyle(color: _green, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x33F59E0B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: _gold, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '12:42',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildRoutePanel(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecCard(
                        title: 'CARGO & RIG',
                        value: '20T Portland Cement',
                        detail: 'Dry Sino / FAW 371',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSpecCard(
                        title: 'LOADING SLOT',
                        value: 'Today 17:00 PM',
                        detail: 'Bay 4, Gate 2 Terminal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildPayoutPanel(),
                const SizedBox(height: 12),
                if (_offerAccepted)
                  _buildStatusMessage(
                    icon: Icons.check_circle,
                    title: 'Offer Assigned',
                    subtitle: 'Waybill creation confirmed in this preview.',
                    color: _green,
                  )
                else ...[
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _offerAccepted = true);
                        _showMessage('Offer accepted in the screen preview.');
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text('Accept Offer Immediately'),
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
                            setState(() => _showCounterForm = true);
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
                            setState(() => _offerDeclined = true);
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

  Widget _buildRoutePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF28354A),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '98 km • Express Highway',
                  style: TextStyle(color: _white, fontSize: 10),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Addis Ababa (Kaliti Depot)',
                      style: TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 17),
                    Text(
                      'Adama Industrial Park',
                      style: TextStyle(
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

  Widget _buildPayoutPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUARANTEED PAYOUT',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '32,000',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'ETB',
                      style: TextStyle(
                        color: _white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'All-inclusive net fare',
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

  Widget _buildSecondaryOfferCard() {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ethio Agricultural Export...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Verified Shipper • 18 Loads Completed',
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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _surfaceHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_bottom, color: _gold, size: 13),
                    SizedBox(width: 4),
                    Text(
                      '48 mins',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Modjo Dry Port',
                    style: TextStyle(color: _white, fontSize: 12),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: _gold, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Awash Terminal',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: _white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '140 km',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
              const Expanded(
                child: Text(
                  '26T Export Sesame Bags',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '48,000',
                      style: TextStyle(
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
                  onPressed: () =>
                      _showMessage('Secondary offer selected for review.'),
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
                  onPressed: () => _showMessage('Secondary offer declined.'),
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_shipping, color: _gold, size: 21),
                SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Your truck '),
                        TextSpan(
                          text: 'Plate 3-84091 ET',
                          style: TextStyle(
                            color: _white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' is visible to '),
                        TextSpan(
                          text: '14 preferred shippers',
                          style: TextStyle(
                            color: _gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' in the Addis Ababa – Djibouti trade corridor.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, color: _green, size: 7),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'GPS Ping: Akaki Kality Subcity',
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ),
              Text(
                'Manage Corridor Preferences',
                style: TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterForm() {
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
                onPressed: () {
                  setState(() => _showCounterForm = false);
                },
                icon: const Icon(Icons.close, color: _muted),
              ),
            ],
          ),
          const Text(
            'Abyssinia Logistics PLC • 20T Cement',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Original Dispatch Rate',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                Text(
                  '32,000 ETB',
                  style: TextStyle(color: _white, fontWeight: FontWeight.w600),
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
            onPressed: () {
              final rate = _counterController.text.trim();
              if (rate.isEmpty || int.tryParse(rate) == null) {
                _showMessage('Enter a valid proposed fare.');
                return;
              }
              setState(() => _showCounterForm = false);
              _showMessage('Counter fare prepared: $rate ETB.');
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
            onPressed: () {
              setState(() => _showCounterForm = false);
            },
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

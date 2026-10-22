import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';

class AvailableFreightLoadsScreen extends StatefulWidget {
  const AvailableFreightLoadsScreen({super.key, this.onNavigate});

  final ValueChanged<String>? onNavigate;

  @override
  State<AvailableFreightLoadsScreen> createState() =>
      _AvailableFreightLoadsScreenState();
}

class _AvailableFreightLoadsScreenState
    extends State<AvailableFreightLoadsScreen> {
  static const Color _background = Color(0xFF061426);
  static const Color _surface = Color(0xFF0E1C2F);
  static const Color _surfaceHigh = Color(0xFF132A44);
  static const Color _border = Color(0xFF1E3A5F);
  static const Color _gold = Color(0xFFFFB21A);
  static const Color _green = Color(0xFF32D6A0);
  static const Color _muted = Color(0xFF91A4BC);
  static const Color _white = Color(0xFFF4F7FC);

  final TextEditingController _searchController = TextEditingController();
  String _selectedCorridor = 'All Corridors';
  bool _autoBidEnabled = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _surfaceHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleDriverNavigation(int index) {
    switch (index) {
      case 0:
        // Already on Available Loads.
        break;
      case 1:
        widget.onNavigate?.call('offer');
        if (widget.onNavigate == null) {
          _showMessage('Offer screen is not connected yet');
        }
        break;
      case 2:
        // Return to the previous screen, usually Home.
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          widget.onNavigate?.call('home');
        }
        break;
      case 3:
        widget.onNavigate?.call('bids');
        if (widget.onNavigate == null) {
          _showMessage('Bids screen is not connected yet');
        }
        break;
      case 4:
        widget.onNavigate?.call('tracking');
        if (widget.onNavigate == null) {
          _showMessage('Tracking screen is not connected yet');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeedStatus(),
                    const SizedBox(height: 10),
                    const Text(
                      'Available Loads',
                      style: TextStyle(
                        color: _white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Verified consignments ready for bidding across Ethiopian corridors',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSearchField(),
                    const SizedBox(height: 10),
                    _buildCorridorFilters(),
                    const SizedBox(height: 12),
                    _buildTelemetryCard(),
                    const SizedBox(height: 14),
                    _buildLoadCard(
                      label: 'STANDARD BID',
                      reference: '#ET-8042',
                      distance: '450 km Expressway',
                      origin: 'Modjo Dry Port',
                      destination: 'Dire Dawa',
                      routeDescription: '28T Containerized Wheat & Grain',
                      detail: 'Pickup: Tomorrow, 08:30 AM',
                      category: 'Ethio Agricultural Expo.',
                      rating: '4.8 (124 trips)',
                      price: '65,000',
                      priceCaption: 'Target Budget',
                      trailingCaption: 'Est. Yield',
                      trailingValue: '114 ETB / km',
                      actionLabel: 'Place Bid Now',
                      actionIcon: Icons.gavel_rounded,
                      onAction: () =>
                          _showMessage('Place Bid selected for #ET-8042'),
                      secondaryAction: 'Details',
                      onSecondary: () =>
                          _showMessage('Load details for #ET-8042'),
                    ),
                    const SizedBox(height: 12),
                    _buildLoadCard(
                      label: 'INSTANT DISPATCH',
                      reference: '#ET-7719',
                      distance: '98 km Rapid Link',
                      origin: 'Addis (Kaliti)',
                      destination: 'Adama Hub',
                      routeDescription: '32T Structural Steel & Rebar',
                      detail: 'Pickup: Today, 16:00 PM (Urgent)',
                      category: 'Mugher Cement & Steel',
                      rating: '4.8 (69 loads)',
                      price: '38,000',
                      priceCaption: 'Fixed Guaranteed Rate',
                      trailingCaption: 'Grade Status',
                      trailingValue: 'Immediate on POD',
                      actionLabel: 'Accept Load Instantly (38,000 ETB)',
                      actionIcon: Icons.flash_on_rounded,
                      onAction: () =>
                          _showMessage('Instant load acceptance selected'),
                      isInstant: true,
                    ),
                    const SizedBox(height: 12),
                    _buildLoadCard(
                      label: 'EXPORT GRADE',
                      reference: '#ET-6204',
                      distance: '218 km Highway',
                      origin: 'Hawassa Agri-Agro',
                      destination: 'Modjo Dry Port',
                      routeDescription: '22T Grade-1 Export Coffee',
                      detail: 'Pickup: Oct 10, Morning Window',
                      category: 'Sidama Coffee Union',
                      rating: '4.9 (210 loads)',
                      price: '42,000',
                      priceCaption: 'Shipper’s Baseline',
                      trailingCaption: 'Market Average',
                      trailingValue: '192 ETB / km',
                      actionLabel: 'Submit Bid',
                      actionIcon: Icons.send_rounded,
                      onAction: () =>
                          _showMessage('Submit Bid selected for #ET-6204'),
                      secondaryAction: 'Save',
                      onSecondary: () => _showMessage('Load saved'),
                    ),
                    const SizedBox(height: 12),
                    _buildAutoBidCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverBottomNavBar(
        currentIndex: 0,
        onTap: _handleDriverNavigation,
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(bottom: BorderSide(color: Color(0xFF10243B))),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: _gold,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Habesha',
                        style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: 'Freight',
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 18, height: 1.05),
                ),
                SizedBox(height: 2),
                Text(
                  'LOGISTICS EXCHANGE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _smallHeaderButton('EN', Icons.language_rounded),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _showMessage('Profile selected'),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _background,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallHeaderButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF172E49)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Icon(icon, color: _muted, size: 12),
        ],
      ),
    );
  }

  Widget _buildFeedStatus() {
    return const Wrap(
      spacing: 7,
      runSpacing: 6,
      children: [
        _StatusPill(
          text: 'CORRIDOR FEED LIVE',
          color: _green,
          icon: Icons.circle,
        ),
        _StatusPill(
          text: 'Express Dispatch Active',
          color: _gold,
          icon: Icons.bolt_rounded,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF152B45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _muted, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _white, fontSize: 12),
              cursorColor: _gold,
              decoration: const InputDecoration(
                hintText: 'Cargo, pickup hub, or tonnage...',
                hintStyle: TextStyle(color: _muted, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            onPressed: () => _showMessage('Advanced filters selected'),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.tune_rounded, color: _gold, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorFilters() {
    final corridors = ['All Corridors', 'Addis → Djibouti', 'Modjo →'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: corridors.map((corridor) {
          final selected = _selectedCorridor == corridor;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: InkWell(
              onTap: () => setState(() => _selectedCorridor = corridor),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF5B4218) : _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _gold : const Color(0xFF1B3552),
                  ),
                ),
                child: Text(
                  corridor,
                  style: TextStyle(
                    color: selected ? _gold : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF152B45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: _gold, size: 15),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Toll Corridor Telemetry',
                  style: TextStyle(
                    color: _white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'AI Expressway Clear',
                style: TextStyle(
                  color: _green,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Expanded(
                child: _TelemetryMetric(
                  label: 'Average Diesel',
                  value: '78.4 ETB/L',
                ),
              ),
              Expanded(
                child: _TelemetryMetric(
                  label: 'Modjo Gate Wait',
                  value: '12 min',
                ),
              ),
              Expanded(
                child: _TelemetryMetric(label: 'Toll Passes', value: 'Active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadCard({
    required String label,
    required String reference,
    required String distance,
    required String origin,
    required String destination,
    required String routeDescription,
    required String detail,
    required String category,
    required String rating,
    required String price,
    required String priceCaption,
    required String trailingCaption,
    required String trailingValue,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
    String? secondaryAction,
    VoidCallback? onSecondary,
    bool isInstant = false,
  }) {
    final query = _searchController.text.trim().toLowerCase();
    final searchable =
        '$origin $destination $routeDescription $category $reference'
            .toLowerCase();
    if (query.isNotEmpty && !searchable.contains(query)) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF172D48)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reference,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.location_on_outlined,
                      color: _gold,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        distance,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _RoutePoint(
                        caption: 'Pickup Terminal',
                        location: origin,
                        alignEnd: false,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _gold,
                        size: 19,
                      ),
                    ),
                    Expanded(
                      child: _RoutePoint(
                        caption: 'Destination',
                        location: destination,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF09182A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isInstant
                            ? Icons.inventory_2_outlined
                            : Icons.local_shipping_outlined,
                        color: isInstant ? _green : _gold,
                        size: 15,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routeDescription,
                              style: const TextStyle(
                                color: _white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF102C35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: _green,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rating,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceCaption.toUpperCase(),
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$price ',
                                  style: const TextStyle(
                                    color: _gold,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'ETB',
                                  style: TextStyle(
                                    color: _muted,
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
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trailingCaption,
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: _muted, fontSize: 9),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            trailingValue,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: _white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                if (secondaryAction != null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSecondary,
                          icon: Icon(
                            secondaryAction == 'Save'
                                ? Icons.bookmark_border_rounded
                                : Icons.visibility_outlined,
                            size: 13,
                          ),
                          label: Text(secondaryAction),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _white,
                            side: const BorderSide(color: _border),
                            backgroundColor: _surfaceHigh,
                            minimumSize: const Size(0, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        flex: 2,
                        child: _primaryButton(
                          actionLabel,
                          actionIcon,
                          onAction,
                          compact: true,
                        ),
                      ),
                    ],
                  )
                else
                  _primaryButton(
                    actionLabel,
                    actionIcon,
                    onAction,
                    fullWidth: true,
                    greenButton: isInstant,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool fullWidth = false,
    bool greenButton = false,
    bool compact = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: compact ? 34 : 37,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: compact ? 13 : 15),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: greenButton ? _green : _gold,
          foregroundColor: _background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildAutoBidCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF09182A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF122943)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_outlined, color: _gold, size: 17),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Bid Assistant Active',
                  style: TextStyle(
                    color: _white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Max threshold set to 190 ETB/km',
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _autoBidEnabled,
            onChanged: (value) => setState(() => _autoBidEnabled = value),
            activeColor: _green,
            activeTrackColor: const Color(0xFF1A8068),
            inactiveThumbColor: _muted,
            inactiveTrackColor: _surfaceHigh,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2033),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1B3550)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 7),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryMetric extends StatelessWidget {
  const _TelemetryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 9),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.caption,
    required this.location,
    required this.alignEnd,
  });

  final String caption;
  final String location;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

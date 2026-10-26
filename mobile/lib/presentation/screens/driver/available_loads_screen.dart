import 'package:flutter/material.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/presentation/screens/driver/request_details_screen.dart';
import 'package:mobile/presentation/widgets/driver_bottom_navbar.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

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
        break;
      case 1:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('offer');
        } else {
          Navigator.pushNamed(context, AppRoutes.page18DirectOffers);
        }
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
          _showMessage('Bids screen is not connected yet');
        }
        break;
      case 4:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('tracking');
        } else {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: HomeHeader(
                language: 'EN',
                onLanguageChanged: (_) {},
                onProfileTap: () {},
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeedStatus(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Available Loads',
                            style: TextStyle(
                              color: _white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '24 Live',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 16),
                    _buildLoadCard(
                      label: 'STANDARD BID',
                      reference: '#ET-8942',
                      distance: '450 km Expressway',
                      origin: 'Modjo Dry Port',
                      destination: 'Dire Dawa FTZ',
                      routeDescription: '28T Containerized Wheat & Grain',
                      detail: 'Pickup: Tomorrow, 08:30 AM',
                      cargoNote: 'Since 30T / FAW',
                      category: 'Ethio Agricultural Expo.',
                      rating: '4.95 (124 trips)',
                      statusLabel: 'Telebirr Escrow',
                      price: '65,000',
                      priceCaption: 'Target Budget',
                      trailingCaption: 'Est. Yield',
                      trailingValue: '144 ETB / km',
                      actionLabel: 'Place Bid Now',
                      actionIcon: Icons.gavel_rounded,
                      onAction: () =>
                          _showMessage('Place Bid selected for #ET-8942'),
                      secondaryAction: 'Details',
                      onSecondary: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const RequestDetailsScreen(
                              reference: '#ET-8942',
                              origin: 'Modjo Dry Port',
                              destination: 'Dire Dawa FTZ',
                              cargo: '28T Containerized Wheat & Grain',
                              pickup: 'Tomorrow, 08:30 AM',
                              shipper: 'Ethio Agricultural Expo.',
                              rating: '4.95 (124 trips)',
                              price: '65,000 ETB',
                              priceCaption: 'Target Budget',
                              distance: '450 km Expressway',
                              cargoNote: 'Since 30T / FAW',
                              status: 'Telebirr Escrow',
                            ),
                          ),
                        );
                      },
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
                      cargoNote: 'Flatbed 3-Axle',
                      category: 'Mugher Cement & Steel',
                      rating: '4.80 (89 loads)',
                      statusLabel: 'Funded & Locked',
                      price: '38,000',
                      priceCaption: 'Fixed Guaranteed Rate',
                      trailingCaption: 'Direct Settlement',
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
                      origin: 'Hawassa Agro',
                      destination: 'Modjo Dry Port',
                      routeDescription: '22T Grade-1 Export Coffee',
                      detail: 'Pickup: Oct 10, Morning Window',
                      cargoNote: 'Requires Tarp',
                      category: 'Sidama Coffee Union',
                      rating: '4.91 (210 loads)',
                      statusLabel: '3 Bids Received',
                      price: '42,000',
                      priceCaption: "Shipper's Baseline",
                      trailingCaption: 'Market Average',
                      trailingValue: '192 ETB / km',
                      actionLabel: 'Submit Bid',
                      actionIcon: Icons.send_rounded,
                      onAction: () =>
                          _showMessage('Submit Bid selected for #ET-6204'),
                      secondaryAction: 'Save',
                      secondaryIcon: Icons.bookmark_border_rounded,
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
    final corridors = <MapEntry<String, String>>[
      const MapEntry('All Corridors', '24'),
      const MapEntry('Addis → Djibouti', '8'),
      const MapEntry('Modjo →', '6'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: corridors.map((corridor) {
          final selected = _selectedCorridor == corridor.key;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCorridor = corridor.key;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? _gold : _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _gold : const Color(0xFF1B3552),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      corridor.key,
                      style: TextStyle(
                        color: selected ? _background : _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFD99000)
                            : _surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        corridor.value,
                        style: TextStyle(
                          color: selected ? _background : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
              const Text(
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

  Widget _buildAutoBidCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF09182A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_outlined, color: _gold, size: 18),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Max threshold set to 160 ETB/km',
                  style: TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _autoBidEnabled,
            onChanged: (value) => setState(() => _autoBidEnabled = value),
            activeThumbColor: _gold,
            activeTrackColor: const Color(0xFF8A5A00),
            inactiveThumbColor: _muted,
            inactiveTrackColor: _surfaceHigh,
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
    String? cargoNote,
    String? statusLabel,
    bool isInstant = false,
    String? secondaryAction,
    IconData secondaryIcon = Icons.visibility_outlined,
    VoidCallback? onSecondary,
  }) {
    final query = _searchController.text.trim().toLowerCase();
    final searchableText = [
      label,
      reference,
      distance,
      origin,
      destination,
      routeDescription,
      detail,
      cargoNote ?? '',
      category,
      statusLabel ?? '',
    ].join(' ').toLowerCase();

    if (query.isNotEmpty && !searchableText.contains(query)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A44),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isInstant ? _green : _gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                reference,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.location_on_outlined, color: _gold, size: 14),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  distance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: const BoxDecoration(color: Color(0xFF122238)),
            child: Row(
              children: [
                Expanded(
                  child: _RoutePoint(
                    title: origin,
                    subtitle: isInstant ? 'PICKUP LOCATION' : 'PICKUP TERMINAL',
                    isOrigin: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, color: _gold),
                ),
                Expanded(
                  child: _RoutePoint(
                    title: destination,
                    subtitle: 'DESTINATION',
                    isOrigin: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isInstant
                      ? Icons.view_week_outlined
                      : Icons.local_shipping_outlined,
                  color: isInstant ? _green : _gold,
                  size: 16,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detail,
                        style: TextStyle(
                          color: isInstant ? _green : _muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (cargoNote != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 66,
                    child: Text(
                      cargoNote,
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: _surfaceHigh,
                child: Text(
                  category.trim().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _white, fontSize: 10),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: _gold, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(color: _muted, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (statusLabel != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D393A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isInstant ? _green : const Color(0xFF54D9C4),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PriceMetric(
                  caption: priceCaption,
                  value: '$price ETB',
                  valueColor: isInstant ? _green : _gold,
                ),
              ),
              Expanded(
                child: _PriceMetric(
                  caption: trailingCaption,
                  value: trailingValue,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (secondaryAction != null && onSecondary != null)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: onSecondary,
                    icon: Icon(secondaryIcon, size: 15),
                    label: Text(secondaryAction),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _surfaceHigh,
                      foregroundColor: _white,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  flex: 3,
                  child: _primaryButton(
                    label: actionLabel,
                    icon: actionIcon,
                    onPressed: onAction,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: _primaryButton(
                label: actionLabel,
                icon: actionIcon,
                onPressed: onAction,
                isInstant: isInstant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isInstant = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: ElevatedButton.styleFrom(
        backgroundColor: isInstant ? _green : _gold,
        foregroundColor: _background,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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
    required this.title,
    required this.subtitle,
    required this.isOrigin,
  });

  final String title;
  final String subtitle;
  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isOrigin
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: isOrigin ? TextAlign.left : TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({
    required this.caption,
    required this.value,
    this.alignEnd = false,
    this.valueColor = _PriceMetric.whiteColor,
  });

  final String caption;
  final String value;
  final bool alignEnd;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(color: _PriceMetric.mutedColor, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: _PriceMetric.whiteColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ).copyWith(color: valueColor),
        ),
      ],
    );
  }

  static const Color mutedColor = Color(0xFF91A4BC);
  static const Color whiteColor = Color(0xFFF4F7FC);
}

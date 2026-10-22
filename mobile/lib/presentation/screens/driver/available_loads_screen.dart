
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
        break;
      case 1:
        if (widget.onNavigate != null) {
          widget.onNavigate!.call('offer');
        } else {
          _showMessage('Offer screen is not connected yet');
        }
        break;
      case 2:
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (widget.onNavigate != null) {
          widget.onNavigate!.call('home');
        } else {
          _showMessage('Home screen navigation is not connected yet');
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
        border: Border(
          bottom: BorderSide(color: Color(0xFF10243B)),
        ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),
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
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            icon: const Icon(
              Icons.tune_rounded,
              color: _gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorFilters() {
    final corridors = [
      'All Corridors',
      'Addis → Djibouti',
      'Modjo →',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: corridors.map((corridor) {
          final selected = _selectedCorridor == corridor;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCorridor = corridor;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5B4218)
                      : _surface,
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
                child: _TelemetryMetric(
                  label: 'Toll Passes',
                  value: 'Active',
                ),
              ),
            ],
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
  const _TelemetryMetric({
    required this.label,
    required this.value,
  });

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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
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

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAvailabilityCard(),
              const SizedBox(height: 24),
              _buildUrgentMatchCard(),
              const SizedBox(height: 24),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildActiveDelivery(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Dashboard',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your logistics overview',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: textWhite,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isAvailable
                  ? green.withValues(alpha: 0.15)
                  : muted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isAvailable
                  ? Icons.local_shipping_rounded
                  : Icons.pause_circle_outline_rounded,
              color: _isAvailable ? green : muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability Status',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  _isAvailable ? 'Available for Loads' : 'Currently Offline',
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isAvailable
                      ? 'Ready to receive delivery requests'
                      : 'You will not receive new requests',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeThumbColor: gold,
            activeTrackColor: gold.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentMatchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: gold, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'URGENT MATCH',
                      style: TextStyle(
                        color: gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.local_shipping_outlined, color: muted, size: 22),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Addis Ababa → Hawassa',
            style: TextStyle(
              color: textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Available freight opportunity',
            style: TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.route_rounded, color: blue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Approx. 275 km',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ETB 18,500',
                    style: TextStyle(
                      color: gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Proposed load rate',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Load details will be available soon.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Load Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Statistics',
          style: TextStyle(
            color: textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_shipping_rounded,
                title: 'Deliveries',
                value: '24',
                subtitle: 'Completed trips',
                color: blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Earnings',
                value: 'ETB 48k',
                subtitle: 'Total earned',
                color: gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_rounded,
                title: 'Rating',
                value: '4.8',
                subtitle: 'Driver rating',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.route_rounded,
                title: 'Distance',
                value: '3.2k km',
                subtitle: 'Total travelled',
                color: green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActiveDelivery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Delivery',
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IN TRANSIT',
                  style: TextStyle(
                    color: green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 145,
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 70,
                    color: Color(0xFF334155),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 20,
                  child: _buildMapPoint(color: blue, label: 'Origin'),
                ),
                Positioned(
                  right: 18,
                  bottom: 20,
                  child: _buildMapPoint(color: gold, label: 'Destination'),
                ),
                Center(
                  child: Transform.rotate(
                    angle: 0.5,
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: textWhite,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.trip_origin_rounded, color: blue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Addis Ababa',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_downward_rounded, color: muted, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: gold, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery destination',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Hawassa',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery progress',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              Text(
                '65%',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 7,
              backgroundColor: Color(0xFF334155),
              valueColor: AlwaysStoppedAnimation<Color>(gold),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery tracking will be connected later.'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: gold,
                side: const BorderSide(color: gold),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Track Delivery',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPoint({required Color color, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_rounded, color: color, size: 25),
        Text(label, style: const TextStyle(color: muted, fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.search_rounded,
                title: 'Find Loads',
                subtitle: 'Browse opportunities',
                color: blue,
                onTap: () => _showActionMessage('Find Loads'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.assignment_rounded,
                title: 'My Bids',
                subtitle: 'Review your bids',
                color: gold,
                onTap: () => _showActionMessage('My Bids'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.receipt_long_rounded,
                title: 'Earnings',
                subtitle: 'View payment summary',
                color: green,
                onTap: () => _showActionMessage('Earnings'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_outline_rounded,
                title: 'My Profile',
                subtitle: 'Manage your details',
                color: const Color(0xFFB28DFF),
                onTap: () => _showActionMessage('My Profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action screen will be connected later.')),
    );
  }
}

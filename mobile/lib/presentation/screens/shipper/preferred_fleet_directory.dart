import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/shipper_service.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

class PreferredFleetScreen extends StatefulWidget {
  const PreferredFleetScreen({super.key});

  @override
  State<PreferredFleetScreen> createState() => _PreferredFleetScreenState();
}

class _PreferredFleetScreenState extends State<PreferredFleetScreen> {
  static const Color bg = Color(0xFF071426);
  static const Color card = Color(0xFF111F33);
  static const Color inner = Color(0xFF1A2A40);
  static const Color yellow = Color(0xFFFFA500);
  static const Color muted = Color(0xFFB6C2D2);
  static const Color green = Color(0xFF39D9AD);

  final ShipperService _shipperService = ShipperService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  List<_PreferredCarrier> _carriers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _shipperService.listCompanies();
      final mapped = rows.map(_mapCompany).toList();
      if (!mounted) return;
      setState(() {
        _carriers = mapped;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _carriers = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carriers = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load preferred fleet')),
      );
    }
  }

  _PreferredCarrier _mapCompany(Map<String, dynamic> row) {
    final name = row['name']?.toString() ??
        row['full_name']?.toString() ??
        row['company_name']?.toString() ??
        'Carrier';
    final fleetSize = row['fleet_size'] ?? row['available_trucks'] ?? 0;
    final types = row['vehicle_types'];
    final typeLabel = types is List && types.isNotEmpty
        ? types.take(2).join(', ')
        : 'Enterprise Fleet';
    final rating = row['average_rating'] ?? row['rating'] ?? '4.8';
    final trips = row['completed_trips'] ?? row['review_count'] ?? fleetSize;
    final verified = row['is_verified'] == true ||
        row['kyc_status']?.toString().toUpperCase() == 'APPROVED';
    final hasReefer = types is List &&
        types.any((t) => t.toString().toUpperCase().contains('REEFER') ||
            t.toString().toUpperCase().contains('COLD'));

    return _PreferredCarrier(
      id: row['id']?.toString() ?? '',
      name: name,
      type: '$typeLabel • $fleetSize Units',
      route: row['description']?.toString() ??
          'Nationwide Ethiopian corridors',
      tag: '${row['available_trucks'] ?? fleetSize} Available',
      rating: rating.toString(),
      trips: trips.toString(),
      badge: verified ? 'FTA Certified' : 'Registered Carrier',
      category: hasReefer ? 'Cold Chain' : 'Heavy Trailers',
      icon: hasReefer ? Icons.ac_unit : Icons.local_shipping,
    );
  }

  Future<void> _requestQuote(_PreferredCarrier carrier) async {
    if (carrier.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company id missing for quote request')),
      );
      return;
    }
    try {
      await _shipperService.createFleetRequest({
        'company_id': carrier.id,
        'origin_city': 'Addis Ababa',
        'destination_city': 'Modjo',
        'cargo_description': 'Preferred fleet quote request',
        'weight_tons': 20,
        'offered_price_etb': 25000,
        'trucks_needed': 1,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quote request sent to ${carrier.name}')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send quote request')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

    final filteredCarriers = _carriers.where((carrier) {
      final matchesSearch =
          carrier.name.toLowerCase().contains(query) ||
          carrier.type.toLowerCase().contains(query) ||
          carrier.route.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || carrier.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_shipping, color: yellow, size: 27),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HabeshaFreight',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'LOGISTICS EXCHANGE',
                    style: TextStyle(
                      color: muted,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: inner,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'EN 文A',
              style: TextStyle(color: yellow, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: Color(0xFFFFC16B),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.circle, color: yellow, size: 7),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'VERIFIED LOGISTICS NETWORK',
                    style: TextStyle(
                      color: Color(0xFFFFC16B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: inner,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '⚙ ${_carriers.length} Active Partners',
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Preferred Fleet Directory',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Trusted drivers and transport enterprises across your key industrial corridors.',
              style: TextStyle(color: muted, fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 22),

            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search carrier, vehicle, or route...',
                hintStyle: const TextStyle(color: muted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: muted),
                suffixIcon: const Icon(Icons.mic_none, color: muted),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryChip('All', '${_carriers.length}'),
                  _categoryChip(
                    'Heavy Trailers',
                    '${_carriers.where((c) => c.category == 'Heavy Trailers').length}',
                  ),
                  _categoryChip(
                    'Cold Chain',
                    '${_carriers.where((c) => c.category == 'Cold Chain').length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.alt_route, color: yellow),
                  SizedBox(width: 10),
                  Text(
                    'TOP LANES:',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Addis → Djibouti • Modjo Hub',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFFFC16B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: yellow)),
              )
            else if (filteredCarriers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No carriers found.',
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            else
              ...filteredCarriers.map(_carrierCard),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '♙ FAST ADD',
                          style: TextStyle(
                            color: Color(0xFFFFC16B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Driver to Preferred List',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Connect directly using a verified Ethiopian phone number or scan a driver QR badge.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Driver QR scanner coming soon.'),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Color(0xFFFFC16B),
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: 1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pop(context);
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connect this to your Bids screen.'),
              ),
            );
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connect this to your Tracking screen.'),
              ),
            );
          }
        },
        onAddPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connect this button to Post Load.')),
          );
        },
      ),
    );
  }

  Widget _categoryChip(String label, String count) {
    final selected = _selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? yellow : card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFD98700)
                      : const Color(0xFF26364C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carrierCard(_PreferredCarrier carrier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: inner,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(carrier.icon, color: yellow, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carrier.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      carrier.type,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${carrier.name} saved to favorites.'),
                    ),
                  );
                },
                icon: const Icon(Icons.star_border, color: yellow, size: 27),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: inner,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.alt_route, color: yellow, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    carrier.route,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    carrier.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoTag(
                Icons.star,
                '${carrier.rating} (${carrier.trips} trips)',
              ),
              _infoTag(Icons.verified_user, carrier.badge),
              if (carrier.category == 'Cold Chain')
                _infoTag(Icons.timer, '99.2% On-Time'),
              if (carrier.category == 'Heavy Trailers')
                _infoTag(Icons.bolt, 'Direct Booking'),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _requestQuote(carrier),
                  icon: const Icon(Icons.outgoing_mail, size: 18),
                  label: const Text('Request Quote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contact ${carrier.name} soon.')),
                    );
                  },
                  icon: const Icon(Icons.call, size: 17),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: inner),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _infoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: inner,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: yellow, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _PreferredCarrier {
  const _PreferredCarrier({
    required this.id,
    required this.name,
    required this.type,
    required this.route,
    required this.tag,
    required this.rating,
    required this.trips,
    required this.badge,
    required this.category,
    required this.icon,
  });

  final String id;
  final String name;
  final String type;
  final String route;
  final String tag;
  final String rating;
  final String trips;
  final String badge;
  final String category;
  final IconData icon;
}

import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/shipper_service.dart';
import 'package:mobile/presentation/widgets/shipper_bottom_navbar.dart';

class PreferredFleetScreen extends StatefulWidget {
  final List<PreferredCarrier>? initialCarriers;

  const PreferredFleetScreen({super.key, this.initialCarriers});

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

  void _showDirectRequestModal(PreferredCarrier carrier) {
    final originController = TextEditingController(text: 'Addis Ababa (Kality Port)');
    final destController = TextEditingController(text: 'Dire Dawa FTZ');
    final descController = TextEditingController(text: 'Containerized Cargo Freight');
    final weightController = TextEditingController(text: '24');
    final priceController = TextEditingController(text: '52000');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Request Quote: ${carrier.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _modalField('Pickup Origin', originController),
                  const SizedBox(height: 10),
                  _modalField('Dropoff Destination', destController),
                  const SizedBox(height: 10),
                  _modalField('Cargo Description', descController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _modalField('Weight (Tons)', weightController, isNumber: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _modalField('Offer (ETB)', priceController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              final weight = double.tryParse(weightController.text) ?? 24.0;
                              final price = double.tryParse(priceController.text) ?? 50000.0;

                              final ok = await _shipperService.createFleetRequest(
                                companyId: carrier.id,
                                originCity: originController.text.trim(),
                                destinationCity: destController.text.trim(),
                                cargoDescription: descController.text.trim(),
                                weightTons: weight,
                                offeredPriceEtb: price,
                              );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Quote request sent to ${carrier.name}!'
                                        : 'Failed to send request. Please check connection.',
                                  ),
                                  backgroundColor: ok ? green : Colors.redAccent,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text(
                              'Submit Direct Request',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: inner,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _showContactModal(PreferredCarrier carrier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carrier.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                carrier.type,
                style: const TextStyle(fontSize: 12, color: muted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: inner,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dispatch Phone', style: TextStyle(color: muted, fontSize: 12)),
                    Text(carrier.phone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dialing ${carrier.phone} (${carrier.name})...')),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Dispatch Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

    final filteredCarriers = _carriers.where((carrier) {
      final matchesSearch = carrier.name.toLowerCase().contains(query) ||
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
                    'CARRIER DIRECTORY',
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
              'EN',
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
                  const Icon(Icons.circle, color: yellow, size: 7),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'VERIFIED FLEET DIRECTORY',
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_carriers.length} Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Preferred Fleets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pre-vetted heavy vehicle carriers on the Ethio-Djibouti and regional corridors.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 16),

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
                          decoration: BoxDecoration(
                            color: isSelected ? yellow : card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Carrier List or Empty State
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: yellow),
                  ),
                )
              else if (filteredCarriers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: inner),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: yellow.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: yellow,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Transport Fleets Found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Verified transport operators and fleet companies will appear here once registered.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.page23PostCargo),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text(
                          'Broadcast Cargo Load',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredCarriers.map((c) => _carrierCard(c)),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: ShipperBottomNavBar(
        currentIndex: 0,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.page11FreightHistory);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.page10LiveTracking);
              break;
          }
        },
        onAddPressed: () {
          Navigator.pushNamed(context, AppRoutes.page23PostCargo);
        },
      ),
    );
  }

  Widget _carrierCard(PreferredCarrier carrier) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  carrier.badge,
                  style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                Text(
                  carrier.tag,
                  style: const TextStyle(
                    color: green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _infoTag(Icons.star, '${carrier.rating} (${carrier.trips} runs)'),
              const SizedBox(width: 8),
              _infoTag(Icons.shield_outlined, 'Insured Cargo'),
            ],
          ),
          const SizedBox(height: 16),

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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContactModal(carrier),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: inner),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

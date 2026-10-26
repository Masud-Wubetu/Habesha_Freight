import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

class RateDriverScreen extends StatefulWidget {
  const RateDriverScreen({Key? key}) : super(key: key);

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  // Local State for interactions
  int _rating = 4; // The screenshot shows 4 stars filled
  final List<bool> _selectedTags = [true, true, true, true, false];
  int _selectedTipIndex = 0;

  // Colors
  final Color _bgDark = const Color(0xFF0B1120);
  final Color _bgCard = const Color(0xFF1E293B);
  final Color _bgCardLight = const Color(0xFF273549);
  final Color _bgInput = const Color(0xFF0F172A);
  final Color _textMain = const Color(0xFFF8FAFC);
  final Color _textMuted = const Color(0xFF94A3B8);
  final Color _accentGold = const Color(0xFFFBBF24);
  final Color _accentGreen = const Color(0xFF10B981);
  final Color _borderColor = const Color(0xFF334155);
  final Color _errorRed = const Color(0xFFF87171);

  final List<String> _tagLabels = [
    "On-Time Delivery",
    "Safe & Secure Cargo",
    "Polite Communication",
    "Clean Truck Bed & Tarp",
    "GPS Telemetry Maintained",
  ];

  final List<String> _tips = ['+0 ETB', '+500 ETB', '+1,000 ETB'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: HomeHeader(
          language: 'EN',
          onLanguageChanged: (_) {},
          onProfileTap: () {},
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitleSection(),
              const SizedBox(height: 20),
              _buildEscrowInfoCard(),
              const SizedBox(height: 12),
              _buildDriverInfoCard(),
              const SizedBox(height: 12),
              _buildRatingCard(),
              const SizedBox(height: 12),
              _buildNotesCard(),
              const SizedBox(height: 12),
              _buildTipCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accentGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'CONSIGNMENT COMPLETED',
                style: TextStyle(
                  color: _accentGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Rate Delivery & Release Escrow',
          style: TextStyle(
            color: _textMain,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rate driver performance for Waybill #HF-8841',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEscrowInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_outline, color: _accentGold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CBE BIRR ESCROW PROTECTION',
                      style: TextStyle(
                        color: _accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified_user, color: _accentGreen, size: 14),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            '18,500 ETB locked in CBE Birr Escrow will be released instantly to Solomon upon review submission.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=150',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgCard, width: 2),
                      ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solomon Tekle',
                          style: TextStyle(
                            color: _textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _bgCardLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '4.97',
                                style: TextStyle(
                                  color: _accentGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.star, color: _accentGold, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                '(142 loads)',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner-Operator • FAW J6P 32T Heavy Rig',
                      style: TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: _borderColor, height: 24),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: _textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                'Addis Ababa',
                style: TextStyle(color: _textMain, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Text(
                '98 km',
                style: TextStyle(
                  color: _accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: _textMuted, size: 14),
              const SizedBox(width: 12),
              Icon(Icons.warehouse_outlined, color: _accentGreen, size: 16),
              const SizedBox(width: 4),
              Text(
                'Adama Dry Port',
                style: TextStyle(color: _textMain, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: _accentGreen, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Delivered Today at 14:15 • Signed off by Bekele ...',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Text(
            'DRIVER PERFORMANCE RATING',
            style: TextStyle(
              color: _textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Outstanding Service',
            style: TextStyle(
              color: _accentGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: _accentGold,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'WHAT WENT EXCEPTIONALLY WELL?',
              style: TextStyle(
                color: _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_tagLabels.length, (index) {
              final isSelected = _selectedTags[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTags[index] = !isSelected;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _accentGreen.withOpacity(0.1)
                        : _bgInput,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _accentGreen.withOpacity(0.3)
                          : _borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        color: isSelected ? _accentGreen : _textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tagLabels[index],
                        style: TextStyle(
                          color: isSelected ? _accentGreen : _textMain,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: _accentGold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Corridor Dispatch Notes',
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Public on driver profile',
                style: TextStyle(color: _textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Solomon arrived ahead of schedule at Kaliti depot and unloaded punctually at Adama. Excellent transit updates throughout the corridor.',
              style: TextStyle(color: _textMain, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.card_giftcard, color: _accentGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Appreciation Tip\n(Optional)',
                      style: TextStyle(
                        color: _textMain,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Direct via Telebirr /\nCBE',
                style: TextStyle(color: _textMuted, fontSize: 10, height: 1.3),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_tips.length, (index) {
              final isSelected = _selectedTipIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTipIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index == _tips.length - 1 ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? _bgCardLight : _bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? _textMuted : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tips[index],
                      style: TextStyle(
                        color: _textMain,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGold,
            foregroundColor: _bgDark,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_open, size: 20),
              SizedBox(width: 8),
              Text(
                'Submit Rating & Release 18,500 ETB',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: _textMain,
            side: BorderSide(color: _borderColor),
            backgroundColor: _bgCard,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: _errorRed, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Report Transit Dispute or Cargo Variance',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.dashboard_outlined, 'Home', false),
                  _buildNavItem(
                    Icons.local_shipping_outlined,
                    'Shipments',
                    false,
                  ),
                  const SizedBox(width: 60), // Space for FAB
                  _buildNavItem(Icons.gavel, 'Bids', false),
                  _buildNavItem(Icons.location_on_outlined, 'Tracking', false),
                ],
              ),
              Positioned(
                top: -25,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: _accentGold,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0F172A),
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Text(
                  'Post Load',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? _accentGold : _textMuted, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? _accentGold : _textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

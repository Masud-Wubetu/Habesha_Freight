import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

class ShipperCompanyProfileScreen extends StatefulWidget {
  const ShipperCompanyProfileScreen({Key? key}) : super(key: key);

  @override
  State<ShipperCompanyProfileScreen> createState() =>
      _ShipperCompanyProfileScreenState();
}

class _ShipperCompanyProfileScreenState
    extends State<ShipperCompanyProfileScreen> {
  // Local state for toggles
  bool _corridorNotifications = true;
  bool _smsAlerts = true;
  bool _escrowAutoReceipts = false;

  // Define colors locally to match the dark theme in the screenshot
  final Color _bgDark = const Color(0xFF0F172A);
  final Color _bgCard = const Color(0xFF1E293B);
  final Color _bgInput = const Color(0xFF0B1120);
  final Color _textMain = const Color(0xFFF8FAFC);
  final Color _textMuted = const Color(0xFF94A3B8);
  final Color _accentGold = const Color(0xFFFBBF24);
  final Color _accentGreen = const Color(0xFF10B981);
  final Color _borderColor = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                language: 'EN',
                onLanguageChanged: (_) {},
                onProfileTap: () {},
              ),
              const SizedBox(height: 20),
              _buildHeroProfileCard(),
              const SizedBox(height: 20),
              _buildCorridorPerformance(),
              const SizedBox(height: 20),
              _buildLegalRegister(),
              const SizedBox(height: 24),
              _buildDocumentsSection(),
              const SizedBox(height: 24),
              _buildPreferencesSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 40), // Padding for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeroProfileCard() {
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _bgInput,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Icon(Icons.warehouse, color: _accentGold, size: 32),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgCard, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF0F172A),
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentGreen.withOpacity(0.3)),
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
                      'FTA VERIFIED SHIPPER',
                      style: TextStyle(
                        color: _accentGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ethio Agricultural Exports Ltd',
            style: TextStyle(
              color: _textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _textMuted, size: 14),
              const SizedBox(width: 6),
              Text(
                'Bole Dry Port Logistics • Enterprise Shipper',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.star, color: _accentGold, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4.95',
                            style: TextStyle(
                              color: _textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Partner Rating',
                            style: TextStyle(color: _textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '45 Loads',
                            style: TextStyle(
                              color: _textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Djibouti Corri...',
                            style: TextStyle(color: _textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CORRIDOR PERFORMANCE',
              style: TextStyle(
                color: _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '98.4% On-Time Transit',
              style: TextStyle(
                color: _accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: 0.984,
            backgroundColor: _bgInput,
            valueColor: AlwaysStoppedAnimation<Color>(_accentGreen),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: _accentGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Legal & Regulatory Register',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'MOTI Validated',
              style: TextStyle(color: _textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegalRow(
                leftLabel: 'Taxpayer Identification (TIN)',
                leftValue: '0048291048',
                rightWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: _accentGreen, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: _accentGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: _borderColor, height: 24),
              _buildLegalRow(
                leftLabel: 'Commercial Registration',
                leftValue: 'CR-AA/2021/98124',
                rightWidget: Text(
                  'Federal Ministry',
                  style: TextStyle(color: _textMuted, fontSize: 11),
                ),
              ),
              Divider(color: _borderColor, height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, color: _textMuted, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operations HQ & Staging Depot',
                        style: TextStyle(color: _textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kaliti Industrial Zone, Gate 3',
                        style: TextStyle(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Addis Ababa • Customs Clearance Bay B',
                        style: TextStyle(color: _textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: _borderColor, height: 24),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF334155),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'ST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamawit Tadesse',
                        style: TextStyle(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Dispatch Director',
                        style: TextStyle(color: _textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone, color: _accentGold, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalRow({
    required String leftLabel,
    required String leftValue,
    required Widget rightWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(leftLabel, style: TextStyle(color: _textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              leftValue,
              style: TextStyle(
                color: _textMain,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        rightWidget,
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: _accentGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Official Corridor Documents',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '3 Active',
              style: TextStyle(color: _accentGold, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDocumentItem(
          icon: Icons.description_outlined,
          iconColor: _accentGold,
          title: 'Commercial Trade License',
          subtitle: 'Trade Bureau • Valid 2025',
          tagText: 'PDF',
          tagColor: _accentGreen,
          tagIcon: Icons.check,
        ),
        const SizedBox(height: 8),
        _buildDocumentItem(
          icon: Icons.article_outlined,
          iconColor: Colors.blue,
          title: 'Customs Transit Agreement',
          subtitle: 'Ethiopian Customs Commission',
          tagText: 'PDF',
          tagColor: _accentGreen,
          tagIcon: Icons.check,
        ),
        const SizedBox(height: 8),
        _buildDocumentItem(
          icon: Icons.settings_outlined,
          iconColor: _accentGreen,
          title: 'Transport Authority Compliance',
          subtitle: 'FTA Heavy Haul Transit',
          tagText: 'To 2027',
          tagColor: _accentGold,
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tagText,
    required Color tagColor,
    IconData? tagIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bgInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: _textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tagIcon != null) ...[
                  Icon(tagIcon, color: tagColor, size: 12),
                  const SizedBox(width: 4),
                ],
                Text(
                  tagText,
                  style: TextStyle(
                    color: tagColor,
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

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, color: _textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              'Corridor Dispatch Preferences',
              style: TextStyle(
                color: _textMain,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            children: [
              _buildPreferenceItem(
                title: 'Corridor Notifications',
                subtitle: 'Route deviations, weight checks & port hold alerts',
                value: _corridorNotifications,
                onChanged: (val) =>
                    setState(() => _corridorNotifications = val),
              ),
              Divider(color: _borderColor, height: 1),
              _buildPreferenceItem(
                title: 'SMS Trip Telemetry Alerts',
                subtitle: 'Direct driver check-in pings via Ethio Telecom',
                value: _smsAlerts,
                onChanged: (val) => setState(() => _smsAlerts = val),
              ),
              Divider(color: _borderColor, height: 1),
              _buildPreferenceItem(
                title: 'Escrow Auto-Receipts',
                subtitle: 'Instant milestone settlement via Commercial Bank',
                value: _escrowAutoReceipts,
                onChanged: (val) => setState(() => _escrowAutoReceipts = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _bgDark,
            activeTrackColor: _accentGreen,
            inactiveThumbColor: _textMuted,
            inactiveTrackColor: _bgInput,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Action for Add Sub-Account
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGold,
            foregroundColor: _bgDark,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Sub-Account / Dispatcher',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Action for Edit Company Profile
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: _textMain,
            side: BorderSide(color: _borderColor),
            backgroundColor: _bgCard,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 8),
              Text(
                'Edit Company Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

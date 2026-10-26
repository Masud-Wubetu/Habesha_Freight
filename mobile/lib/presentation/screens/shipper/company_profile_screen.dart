import 'package:flutter/material.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/shipper_service.dart';

typedef CompanyProfileScreen = ShipperCompanyProfileScreen;

class ShipperCompanyProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;

  const ShipperCompanyProfileScreen({super.key, this.initialProfile});

  @override
  State<ShipperCompanyProfileScreen> createState() =>
      _ShipperCompanyProfileScreenState();
}

class _ShipperCompanyProfileScreenState
    extends State<ShipperCompanyProfileScreen> {
  final ShipperService _shipperService = ShipperService();

  // Local state for toggles
  bool _corridorNotifications = true;
  bool _smsAlerts = true;
  bool _escrowAutoReceipts = false;
  bool _loading = true;
  bool _saving = false;

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _companyLabel = 'Shipper Account';
  int _totalLoads = 0;
  bool _isVerified = false;

  // Local theme colors
  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _bgCard = Color(0xFF1E293B);
  static const Color _bgInput = Color(0xFF0B1120);
  static const Color _textMain = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _accentGold = Color(0xFFFBBF24);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _borderColor = Color(0xFF334155);

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      _profile = widget.initialProfile;
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final data = await _shipperService.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = data;
    });
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _profile?['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: _profile?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['phone_number'] ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgDark,
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
                      const Text(
                        'Edit Shipper Profile',
                        style: TextStyle(
                          color: _textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: _textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _modalField('Full Name / Dispatcher', nameCtrl),
                  const SizedBox(height: 12),
                  _modalField('Phone Number', phoneCtrl),
                  const SizedBox(height: 12),
                  _modalField('Official Email', emailCtrl),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              final ok = await _shipperService.updateProfile(
                                fullName: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phoneNumber: phoneCtrl.text.trim(),
                              );

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);

                              if (!mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated successfully!'),
                                    backgroundColor: _accentGreen,
                                  ),
                                );
                                _loadProfile();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update profile. Please try again.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentGold,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                            )
                          : const Text(
                              'Save Changes',
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

  Widget _modalField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: _textMain, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _bgInput,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await _shipperService.getProfile();
      if (!mounted) return;
      final stats = profile['stats'];
      setState(() {
        _fullName = profile['full_name']?.toString() ?? '';
        _email = profile['email']?.toString() ?? '';
        _phone = profile['phone_number']?.toString() ?? '';
        _isVerified = profile['is_verified'] == true ||
            profile['kyc_status']?.toString().toUpperCase() == 'APPROVED';
        _companyLabel = _fullName.isNotEmpty
            ? _fullName
            : (profile['company_name']?.toString() ?? 'Shipper Account');
        if (stats is Map) {
          _totalLoads = int.tryParse(stats['total_loads']?.toString() ?? '') ??
              (stats['total_loads'] is num
                  ? (stats['total_loads'] as num).toInt()
                  : 0);
        }
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load company profile'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final nameController = TextEditingController(text: _fullName);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCard,
        title: Text('Edit Company Profile', style: TextStyle(color: _textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: _textMain),
              decoration: InputDecoration(
                labelText: 'Full name / Company',
                labelStyle: TextStyle(color: _textMuted),
              ),
            ),
            TextField(
              controller: emailController,
              style: TextStyle(color: _textMain),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: _textMuted),
              ),
            ),
            TextField(
              controller: phoneController,
              style: TextStyle(color: _textMain),
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: _textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _accentGold),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await _shipperService.updateProfile({
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_number': phoneController.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _fullName = updated['full_name']?.toString() ?? nameController.text.trim();
        _email = updated['email']?.toString() ?? emailController.text.trim();
        _phone =
            updated['phone_number']?.toString() ?? phoneController.text.trim();
        _companyLabel = _fullName.isNotEmpty ? _fullName : _companyLabel;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          backgroundColor: _accentGreen,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFEF4444)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _profile?['full_name'] ?? 'Shipper';
    final companyName = _profile?['company_name'] ?? 'Commercial Shipper Enterprise';
    final phone = _profile?['phone_number'] ?? 'Not set';
    final email = _profile?['email'] ?? 'Not set';
    final stats = _profile?['stats'] as Map<String, dynamic>? ?? {};
    final totalLoads = stats['total_loads'] ?? 0;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFBBF24)))
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
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
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page24MyShipments);
          } else if (idx == 2) {
            Navigator.pushNamed(context, AppRoutes.page23PostCargo);
          } else if (idx == 3) {
            Navigator.pushNamed(context, AppRoutes.page08ReviewBids);
          } else if (idx != 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accentGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HabeshaFreight',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'COMPANY PROFILE',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: const Text(
                'EN',
                style: TextStyle(color: _textMain, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroProfileCard(String fullName, String companyName, dynamic totalLoads) {
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
                    child: const Icon(Icons.warehouse, color: _accentGold, size: 32),
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
                  color: _accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: _accentGreen, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED SHIPPER',
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
            _companyLabel.isNotEmpty ? _companyLabel : 'Shipper Account',
            style: TextStyle(
              color: _textMain,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, color: _textMuted, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _isVerified
                      ? 'Verified Enterprise Shipper'
                      : 'Shipper account',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          if (_email.isNotEmpty || _phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [_email, _phone].where((s) => s.isNotEmpty).join(' · '),
              style: TextStyle(color: _textMuted, fontSize: 12),
            ),
          ],
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
                          color: _accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star, color: _accentGold, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isVerified ? 'Verified' : 'Pending',
                            style: TextStyle(
                              color: _textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'KYC Status',
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
                          color: Colors.blue.withValues(alpha: 0.1),
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
                            '$_totalLoads Loads',
                            style: TextStyle(
                              color: _textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total posted',
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

  Widget _buildLegalRegister(String fullName, String phone, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.badge_outlined, color: _accentGold, size: 18),
            SizedBox(width: 8),
            Text(
              'Account & Dispatch Information',
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
                        _fullName.isNotEmpty ? _fullName : 'Shipper contact',
                        style: TextStyle(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _phone.isNotEmpty ? _phone : 'Primary contact',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: _textMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tune, color: _accentGold, size: 18),
            SizedBox(width: 8),
            Text(
              'Corridor Preferences',
              style: TextStyle(
                color: _textMain,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildToggleItem(
          title: 'Corridor Dispatch Alerts',
          subtitle: 'Receive real-time carrier arrival alerts',
          value: _corridorNotifications,
          onChanged: (val) => setState(() => _corridorNotifications = val),
        ),
        const SizedBox(height: 8),
        _buildToggleItem(
          title: 'Direct SMS Notifications',
          subtitle: 'Instant phone SMS when driver confirms pickup',
          value: _smsAlerts,
          onChanged: (val) => setState(() => _smsAlerts = val),
        ),
        const SizedBox(height: 8),
        _buildToggleItem(
          title: 'Escrow Auto-Receipts',
          subtitle: 'Generate verified receipt upon milestone release',
          value: _escrowAutoReceipts,
          onChanged: (val) => setState(() => _escrowAutoReceipts = val),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sub-account invites coming soon')),
            );
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
          onPressed: _saving ? null : _saveProfile,
          style: OutlinedButton.styleFrom(
            foregroundColor: _textMain,
            side: BorderSide(color: _borderColor),
            backgroundColor: _bgCard,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Edit Company Profile',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentGold,
          foregroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

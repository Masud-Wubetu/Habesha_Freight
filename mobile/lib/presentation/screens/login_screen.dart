import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../widgets/login/auth_tab_switcher.dart';
import '../widgets/login/login_footer.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/otp_sheet.dart';
import '../widgets/login/password_auth_view.dart';
import '../widgets/login/phone_auth_view.dart';
import '../widgets/login/telebirr_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  AuthTab _tab = AuthTab.password;

  final _phoneCtrl = TextEditingController();
  final _passIdCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true, _loading = false;
  String? _error;
  String? _selectedDemoRole;

  String? _activeSessionRole;
  String? _activeSessionName;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      final role = await StorageService.getUserRole();
      final name = await StorageService.getUserName();
      if (mounted) {
        setState(() {
          _activeSessionRole = role;
          _activeSessionName = name ?? 'User';
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passIdCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onSuccess(UserModel user, String token) {
    final role = user.role.toUpperCase();
    final String targetRoute;
    final String roleLabel;

    if (role == 'SHIPPER') {
      targetRoute = AppRoutes.home;
      roleLabel = 'Shipper Dashboard';
    } else if (role == 'DRIVER') {
      targetRoute = AppRoutes.page16DriverHome;
      roleLabel = 'Driver Portal';
    } else {
      targetRoute = AppRoutes.fleetHub;
      roleLabel = 'Fleet Command Hub';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.badgeGreenText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Welcome, ${user.fullName} • $roleLabel',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  void _selectDemoAccount({
    required String roleKey,
    required String email,
    required String phone,
  }) {
    setState(() {
      _selectedDemoRole = roleKey;
      _passIdCtrl.text = email;
      _phoneCtrl.text = phone;
      _passCtrl.text = 'Password123!';
      _error = null;
    });
  }

  void _resumeActiveSession() {
    final role = _activeSessionRole?.toUpperCase();
    if (role == 'SHIPPER') {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (role == 'DRIVER') {
      Navigator.of(context).pushReplacementNamed(AppRoutes.page16DriverHome);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.fleetHub);
    }
  }

  Future<void> _clearActiveSession() async {
    await StorageService.clearAuthData();
    if (mounted) {
      setState(() {
        _activeSessionRole = null;
        _activeSessionName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Previous session cleared. Sign in below.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handlePhoneOtp() async {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.length < 8) {
      return setState(() => _error = 'Enter valid Ethiopian phone');
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final fullPhone = raw.startsWith('+251')
        ? raw
        : '+251${raw.replaceFirst(RegExp(r'^0'), '')}';
    final res = await _auth.sendOtp(phoneNumber: fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OtpSheet(
          phone: fullPhone,
          demoOtp: res.demoOtp,
          auth: _auth,
          onDone: _onSuccess,
        ),
      );
    } else {
      setState(
        () => _error = res.message.isNotEmpty
            ? res.message
            : 'OTP request failed',
      );
    }
  }

  Future<void> _handlePasswordLogin() async {
    final id = _passIdCtrl.text.trim(), pass = _passCtrl.text;
    if (id.isEmpty || pass.isEmpty) {
      return setState(() => _error = 'Fill all fields');
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _auth.login(identifier: id, password: pass);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.user != null) {
      _onSuccess(res.user!, res.token!);
    } else {
      setState(
        () => _error = res.message.isNotEmpty
            ? res.message
            : 'Invalid credentials',
      );
    }
  }

  Future<void> _handleTelebirr() async {
    setState(() => _loading = true);
    final phone = _tab == AuthTab.phone
        ? _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '')
        : '911123456';
    final fullPhone = phone.startsWith('+251') ? phone : '+251$phone';
    final res = await _auth.telebirrLogin(phoneNumber: fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.user != null) {
      _onSuccess(res.user!, res.token!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'Telebirr auth failed',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showInfo(String t, String c) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            t,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
          ),
          content: Text(
            c,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Widget _buildDemoRoleBar() {
    final accounts = [
      {
        'role': 'SHIPPER',
        'label': 'Shipper',
        'icon': Icons.storefront_rounded,
        'email': 'shipper@habeshafreight.et',
        'phone': '91 112 3456',
        'color': AppColors.gold,
      },
      {
        'role': 'DRIVER',
        'label': 'Driver',
        'icon': Icons.local_shipping_rounded,
        'email': 'driver@habeshafreight.et',
        'phone': '92 265 4321',
        'color': const Color(0xFF38BDF8),
      },
      {
        'role': 'FLEET_OWNER',
        'label': 'Fleet',
        'icon': Icons.dashboard_rounded,
        'email': 'fleet@habeshafreight.et',
        'phone': '91 198 7654',
        'color': const Color(0xFF34D399),
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'QUICK DEMO ROLES (1-TAP AUTOFILL)',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: accounts.map((acc) {
              final isSelected = _selectedDemoRole == acc['role'];
              final color = acc['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _selectDemoAccount(
                      roleKey: acc['role'] as String,
                      email: acc['email'] as String,
                      phone: acc['phone'] as String,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFF334155),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            acc['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? color
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            acc['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionBanner() {
    if (_activeSessionRole == null) return const SizedBox.shrink();
    final role = _activeSessionRole!;
    final name = _activeSessionName ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_circle,
            color: AppColors.primaryContainer,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active: $name',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Role: $role',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _resumeActiveSession,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text(
              'Resume →',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearActiveSession,
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            tooltip: 'Clear session',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 20),
                  _buildActiveSessionBanner(),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to your Habesha Freight account.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildDemoRoleBar(),
                        AuthTabSwitcher(
                          activeTab: _tab,
                          onTabChanged: (t) => setState(() {
                            _tab = t;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: 18),
                        if (_tab == AuthTab.phone)
                          PhoneAuthView(
                            controller: _phoneCtrl,
                            onSubmit: _handlePhoneOtp,
                          )
                        else
                          PasswordAuthView(
                            idController: _passIdCtrl,
                            passController: _passCtrl,
                            obscurePassword: _obscurePass,
                            onToggleObscure: () => setState(
                              () => _obscurePass = !_obscurePass,
                            ),
                            onSubmit: _handlePasswordLogin,
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : (_tab == AuthTab.phone
                                    ? _handlePhoneOtp
                                    : _handlePasswordLogin),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textDark,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _tab == AuthTab.phone
                                            ? 'Request OTP Code'
                                            : 'Sign In',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TelebirrButton(
                          loading: _loading,
                          onTap: _handleTelebirr,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LoginFooter(onShowInfo: _showInfo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

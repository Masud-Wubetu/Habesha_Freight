import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../widgets/login/login_footer.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/password_auth_view.dart';
import '../widgets/login/telebirr_button.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;
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
    _emailCtrl.dispose();
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
  }) {
    setState(() {
      _selectedDemoRole = roleKey;
      _emailCtrl.text = email;
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

  Future<void> _handlePasswordLogin() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (pass.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _auth.login(identifier: email, password: pass);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success && res.user != null) {
      _onSuccess(res.user!, res.token!);
    } else if (res.requiresOtpVerification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty
              ? res.message
              : 'Please verify your email address to continue.'),
          backgroundColor: AppColors.card,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: email,
            role: res.user?.role,
            fullName: res.user?.fullName,
            onVerified: _onSuccess,
          ),
        ),
      );
    } else {
      setState(
        () => _error = res.message.isNotEmpty
            ? res.message
            : 'Invalid email address or password.',
      );
    }
  }

  Future<void> _handleTelebirr() async {
    setState(() => _loading = true);
    final res = await _auth.telebirrLogin(phoneNumber: '+251911123456');
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
        'color': AppColors.gold,
      },
      {
        'role': 'DRIVER',
        'label': 'Driver',
        'icon': Icons.local_shipping_rounded,
        'email': 'driver@habeshafreight.et',
        'color': const Color(0xFF38BDF8),
      },
      {
        'role': 'FLEET_OWNER',
        'label': 'Fleet',
        'icon': Icons.dashboard_rounded,
        'email': 'fleet@habeshafreight.et',
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
                          'Sign in with your email address and password.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDemoRoleBar(),
                        PasswordAuthView(
                          emailController: _emailCtrl,
                          passController: _passCtrl,
                          obscurePassword: _obscurePass,
                          onToggleObscure: () => setState(
                            () => _obscurePass = !_obscurePass,
                          ),
                          onSubmit: _handlePasswordLogin,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorStrong.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.errorStrong.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.errorStrong,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.errorStrong,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handlePasswordLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
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
                                        'Sign In',
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
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
  const LoginScreen({
    super.key,
    this.onAuthenticated,
    this.backendUp = true,
    this.statusMessage,
    this.onRetryConnection,
  });

  final VoidCallback? onAuthenticated;
  final bool backendUp;
  final String? statusMessage;
  final VoidCallback? onRetryConnection;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  AuthTab _tab = AuthTab.password;

  // Demo seed defaults (fleet owner) — editable.
  final _phoneCtrl = TextEditingController(text: '11 987 654');
  final _passIdCtrl = TextEditingController(text: 'fleet@habeshafreight.et');
  final _passCtrl = TextEditingController(text: 'Password123!');
  bool _obscurePass = true, _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passIdCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _finish(UserModel user, String token) {
    final cb = widget.onAuthenticated;
    if (cb != null) {
      cb();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/fleet');
  }

  Future<void> _handlePhoneOtp() async {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.length < 8) {
      return setState(() => _error = 'Enter a valid Ethiopian phone');
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final fullPhone = AuthService.normalizePhone(raw);
    final res = await _auth.sendOtp(phoneNumber: fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      _openOtpSheet(phone: fullPhone, demoOtp: res.demoOtp);
    } else {
      setState(() =>
          _error = res.message.isNotEmpty ? res.message : 'OTP request failed');
    }
  }

  void _openOtpSheet({String? phone, String? email, String? demoOtp}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpSheet(
        phone: phone,
        email: email,
        demoOtp: demoOtp,
        auth: _auth,
        onDone: _finish,
      ),
    );
  }

  Future<void> _handlePasswordLogin() async {
    final id = _passIdCtrl.text.trim();
    final pass = _passCtrl.text;
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

    if (res.success && res.user != null && res.token != null) {
      _finish(res.user!, res.token!);
      return;
    }

    if (res.requiresOtpVerification) {
      final email = res.pendingEmail ?? (id.contains('@') ? id : null);
      if (email != null) {
        final resent = await _auth.resendOtp(email: email);
        if (!mounted) return;
        _openOtpSheet(
          email: email,
          demoOtp: resent.demoOtp,
        );
        setState(() => _error = 'Verify OTP sent to $email');
        return;
      }
    }

    setState(() => _error =
        res.message.isNotEmpty ? res.message : 'Invalid credentials');
  }

  Future<void> _handleTelebirr() async {
    final raw = _phoneCtrl.text.trim().isNotEmpty
        ? _phoneCtrl.text
        : _passIdCtrl.text;
    if (raw.contains('@') || raw.trim().isEmpty) {
      return setState(
          () => _error = 'Enter a phone number for Telebirr quick auth');
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res =
        await _auth.telebirrLogin(phoneNumber: AuthService.normalizePhone(raw));
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.user != null && res.token != null) {
      _finish(res.user!, res.token!);
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

  Future<void> _quickFleetDemo() async {
    setState(() {
      _loading = true;
      _error = null;
      _tab = AuthTab.password;
      _passIdCtrl.text = 'fleet@habeshafreight.et';
      _passCtrl.text = 'Password123!';
    });
    await _handlePasswordLogin();
  }

  void _showInfo(String t, String c) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(t,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
          content: Text(c,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
          ],
        ),
      );

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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.backendUp ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: widget.backendUp
                            ? AppColors.secondary
                            : AppColors.errorStrong,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.statusMessage ??
                              (widget.backendUp
                                  ? 'API online'
                                  : 'API offline'),
                          style: TextStyle(
                            color: widget.backendUp
                                ? AppColors.secondary
                                : AppColors.errorStrong,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.onRetryConnection != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: widget.onRetryConnection,
                          child: const Text('Retry',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
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
                          'Carrier & Shipper Portal',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in with backend credentials (password, OTP, or Telebirr).',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                () => _obscurePass = !_obscurePass),
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
                            onPressed: (_loading || !widget.backendUp)
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
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 16),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: (_loading || !widget.backendUp)
                                ? null
                                : _quickFleetDemo,
                            child: const Text('Quick demo: Fleet Owner'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TelebirrButton(
                          loading: _loading,
                          onTap: widget.backendUp ? _handleTelebirr : () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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

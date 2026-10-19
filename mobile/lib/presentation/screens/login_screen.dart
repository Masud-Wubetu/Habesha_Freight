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
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  AuthTab _tab = AuthTab.phone;

  final _phoneCtrl = TextEditingController(text: '92 265 4321');
  final _passIdCtrl = TextEditingController(text: '+251922654321');
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

  void _onSuccess(UserModel user, String token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.badgeGreenText),
          const SizedBox(width: 8),
          Text('Welcome, ${user.fullName}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        ]),
        content: Text('Authenticated as ${user.role} (${user.phoneNumber})', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark), child: const Text('Proceed'))],
      ),
    );
  }

  Future<void> _handlePhoneOtp() async {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.length < 8) return setState(() => _error = 'Enter valid Ethiopian phone');
    setState(() { _loading = true; _error = null; });
    final fullPhone = raw.startsWith('+251') ? raw : '+251${raw.replaceFirst(RegExp(r'^0'), '')}';
    final res = await _auth.sendOtp(phoneNumber: fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => OtpSheet(phone: fullPhone, demoOtp: res.demoOtp, auth: _auth, onDone: _onSuccess));
    } else {
      setState(() => _error = res.message.isNotEmpty ? res.message : 'OTP request failed');
    }
  }

  Future<void> _handlePasswordLogin() async {
    final id = _passIdCtrl.text.trim(), pass = _passCtrl.text;
    if (id.isEmpty || pass.isEmpty) return setState(() => _error = 'Fill all fields');
    setState(() { _loading = true; _error = null; });
    final res = await _auth.login(identifier: id, password: pass);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.user != null) {
      _onSuccess(res.user!, res.token!);
    } else {
      setState(() => _error = res.message.isNotEmpty ? res.message : 'Invalid credentials');
    }
  }

  Future<void> _handleTelebirr() async {
    setState(() => _loading = true);
    final res = await _auth.telebirrLogin(phoneNumber: '+251911234567');
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.user != null) {
      _onSuccess(res.user!, res.token!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Telebirr auth failed'), backgroundColor: AppColors.error));
    }
  }

  void _showInfo(String t, String c) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(backgroundColor: AppColors.card, title: Text(t, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)), content: Text(c, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]),
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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const LoginHeader(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Carrier & Shipper Portal', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Sign in to coordinate loads and track fleet telemetry.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    AuthTabSwitcher(activeTab: _tab, onTabChanged: (t) => setState(() { _tab = t; _error = null; })),
                    const SizedBox(height: 18),
                    if (_tab == AuthTab.phone)
                      PhoneAuthView(controller: _phoneCtrl, onSubmit: _handlePhoneOtp)
                    else
                      PasswordAuthView(idController: _passIdCtrl, passController: _passCtrl, obscurePassword: _obscurePass, onToggleObscure: () => setState(() => _obscurePass = !_obscurePass), onSubmit: _handlePasswordLogin),
                    if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error))],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : (_tab == AuthTab.phone ? _handlePhoneOtp : _handlePasswordLogin),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(_tab == AuthTab.phone ? 'Request OTP Code' : 'Sign In', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 16),
                              ]),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TelebirrButton(loading: _loading, onTap: _handleTelebirr),
                  ]),
                ),
                const SizedBox(height: 20),
                LoginFooter(onShowInfo: _showInfo),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

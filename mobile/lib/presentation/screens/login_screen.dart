import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ethiopian_flag.dart';
import '../../data/models/user_model.dart';

enum AuthTab { phone, password }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  AuthTab _tab = AuthTab.phone;

  // Controllers
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.badgeGreenText),
          const SizedBox(width: 8),
          Text('Welcome, ${user.fullName}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        ]),
        content: Text('Authenticated as ${user.role} (${user.phoneNumber})',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark),
            child: const Text('Proceed'),
          )
        ],
      ),
    );
  }

  // --- Handlers ---
  Future<void> _handlePhoneOtp() async {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.length < 8) return setState(() => _error = 'Enter valid Ethiopian phone');
    setState(() { _loading = true; _error = null; });
    final fullPhone = raw.startsWith('+251') ? raw : '+251${raw.replaceFirst(RegExp(r'^0'), '')}';
    final res = await _auth.sendOtp(phoneNumber: fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      _showOtpSheet(fullPhone, res.demoOtp);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message.isNotEmpty ? res.message : 'Telebirr auth failed'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showOtpSheet(String phone, String? demoOtp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OtpSheet(phone: phone, demoOtp: demoOtp, auth: _auth, onDone: _onSuccess),
    );
  }

  // --- UI Components ---
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
                  _header(),
                  const SizedBox(height: 24),
                  _card(),
                  const SizedBox(height: 20),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: const Color(0xFF162137), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF263756))),
        child: const Icon(Icons.local_shipping_rounded, color: AppColors.gold, size: 24),
      ),
      const SizedBox(width: 10),
      RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700), children: const [
        TextSpan(text: 'Habesha ', style: TextStyle(color: Colors.white)),
        TextSpan(text: 'Freight', style: TextStyle(color: AppColors.gold)),
      ])),
    ]),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.badgeGreenBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.badgeGreenBorder)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.badgeGreenText, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('National Freight Network', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.badgeGreenText)),
      ]),
    ),
  ]);

  Widget _card() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Carrier & Shipper Portal', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 4),
      Text('Sign in to coordinate loads and track fleet telemetry.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      _tabs(),
      const SizedBox(height: 18),
      if (_tab == AuthTab.phone) _phoneView() else _passView(),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error)),
      ],
      const SizedBox(height: 16),
      _submitBtn(_tab == AuthTab.phone ? 'Request OTP Code' : 'Sign In', _tab == AuthTab.phone ? _handlePhoneOtp : _handlePasswordLogin),
      const SizedBox(height: 18),
      _telebirrBtn(),
    ]),
  );

  Widget _tabs() => Container(
    height: 40,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: const Color(0xFF0C1322), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1E2D48))),
    child: Row(children: [
      _tabItem('Phone OTP', Icons.phone_android_rounded, _tab == AuthTab.phone, () => setState(() { _tab = AuthTab.phone; _error = null; })),
      _tabItem('Password', Icons.lock_outline_rounded, _tab == AuthTab.password, () => setState(() { _tab = AuthTab.password; _error = null; })),
    ]),
  );

  Widget _tabItem(String t, IconData i, bool sel, VoidCallback tap) => Expanded(
    child: GestureDetector(
      onTap: tap,
      child: Container(
        decoration: BoxDecoration(color: sel ? const Color(0xFF1E2D48) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 14, color: sel ? AppColors.gold : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? Colors.white : AppColors.textMuted)),
        ]),
      ),
    ),
  );

  Widget _phoneView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Mobile Number', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
    const SizedBox(height: 6),
    Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
      child: Row(children: [
        const EthiopianFlag(width: 24, height: 16),
        const SizedBox(width: 8),
        Text('+251', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(width: 8),
        Container(width: 1, height: 18, color: AppColors.cardBorder),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _phoneCtrl, keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '91 234 5678', hintStyle: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      ]),
    ),
  ]);

  Widget _passView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Mobile / Email', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
    const SizedBox(height: 6),
    _fieldBox(_passIdCtrl, 'user@domain.com or +251...', Icons.person_outline_rounded, false),
    const SizedBox(height: 12),
    Text('Password', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
    const SizedBox(height: 6),
    _fieldBox(_passCtrl, '••••••••', Icons.lock_outline_rounded, _obscurePass, toggleObscure: () => setState(() => _obscurePass = !_obscurePass)),
  ]);

  Widget _fieldBox(TextEditingController c, String h, IconData i, bool obs, {VoidCallback? toggleObscure}) => Container(
    height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
    child: Row(children: [
      Icon(i, color: AppColors.textMuted, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: c, obscureText: obs,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: h, hintStyle: const TextStyle(color: AppColors.textMuted)),
        ),
      ),
      if (toggleObscure != null)
        IconButton(
          icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
          onPressed: toggleObscure, padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
    ]),
  );

  Widget _submitBtn(String label, VoidCallback fn) => SizedBox(
    width: double.infinity, height: 48,
    child: ElevatedButton(
      onPressed: _loading ? null : fn,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ]),
    ),
  );

  Widget _telebirrBtn() => Column(children: [
    Row(children: [
      const Expanded(child: Divider(color: AppColors.cardBorder)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OR CONTINUE WITH', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
      const Expanded(child: Divider(color: AppColors.cardBorder)),
    ]),
    const SizedBox(height: 12),
    InkWell(
      onTap: _loading ? null : _handleTelebirr,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: AppColors.telebirrButton, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.telebirrBorder)),
        child: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.telebirrBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.bolt_rounded, color: AppColors.telebirrBlue, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Auth with Telebirr', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('Instant SuperApp verification', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
        ]),
      ),
    ),
  ]);

  Widget _footer() => Column(children: [
    Wrap(alignment: WrapAlignment.center, children: [
      Text("Don't have an account? ", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      GestureDetector(
        onTap: () => _showDialog('Registration', 'Register as Driver, Fleet Carrier, or Cargo Shipper via ETA regulatory portal.'),
        child: Text('Register Now', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold, decoration: TextDecoration.underline)),
      ),
    ]),
    const SizedBox(height: 16),
    Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
      _link('Carrier Terms', 'Bilateral Djibouti-Ethiopia logistics treaties apply.'),
      _link('Support Desk', 'INSA Corridor Hotline: +251 11 551 2233'),
      _link('Port Corridors', 'Djibouti ⇄ Modjo (780km), Berbera ⇄ Dire Dawa (450km).'),
    ]),
    const SizedBox(height: 12),
    Text('Habesha Freight v1.0.0 • 256-bit TLS Encrypted', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
  ]);

  Widget _link(String t, String c) => GestureDetector(
    onTap: () => _showDialog(t, c),
    child: Text(t, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
  );

  void _showDialog(String t, String c) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(t, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
      content: Text(c, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ),
  );
}

// ============================================================================
// COMPACT OTP SHEET
// ============================================================================
class _OtpSheet extends StatefulWidget {
  final String phone;
  final String? demoOtp;
  final AuthService auth;
  final void Function(UserModel user, String token) onDone;

  const _OtpSheet({required this.phone, this.demoOtp, required this.auth, required this.onDone});
  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  int _timer = 60;
  Timer? _t;
  bool _verifying = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer > 0) setState(() => _timer--); else t.cancel();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    for (final c in _ctrls) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  Future<void> _verify([String? code]) async {
    final otp = code ?? _ctrls.map((c) => c.text).join();
    if (otp.length != 6) return setState(() => _err = 'Enter 6 digits');
    setState(() { _verifying = true; _err = null; });
    final res = await widget.auth.verifyOtp(phoneNumber: widget.phone, otpCode: otp);
    if (!mounted) return;
    setState(() => _verifying = false);
    if (res.success && res.user != null) {
      Navigator.pop(context);
      widget.onDone(res.user!, res.token!);
    } else {
      setState(() => _err = res.message.isNotEmpty ? res.message : 'Invalid OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
      decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Verify SMS Code', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Sent to ${widget.phone}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        if (widget.demoOtp != null) ...[
          const SizedBox(height: 10),
          ActionChip(
            label: Text('Fill Dev OTP: ${widget.demoOtp}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold)),
            backgroundColor: AppColors.badgeAmberBg,
            side: const BorderSide(color: AppColors.badgeAmberBorder),
            onPressed: () {
              for (int i = 0; i < 6 && i < widget.demoOtp!.length; i++) {
                _ctrls[i].text = widget.demoOtp![i];
              }
              _verify(widget.demoOtp);
            },
          ),
        ],
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => SizedBox(
          width: 42, height: 46,
          child: TextField(
            controller: _ctrls[i], focusNode: _nodes[i], keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            decoration: InputDecoration(counterText: '', filled: true, fillColor: AppColors.inputBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
              if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
              if (_ctrls.map((c) => c.text).join().length == 6) _verify();
            },
          ),
        ))),
        if (_err != null) ...[const SizedBox(height: 8), Text(_err!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error))],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 46,
          child: ElevatedButton(
            onPressed: _verifying ? null : () => _verify(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: _verifying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                : Text('Verify & Continue', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
        TextButton(
          onPressed: _timer == 0 ? () => widget.auth.sendOtp(phoneNumber: widget.phone) : null,
          child: Text(_timer > 0 ? 'Resend in ${_timer}s' : 'Resend Code', style: GoogleFonts.inter(fontSize: 12, color: _timer > 0 ? AppColors.textMuted : AppColors.gold)),
        ),
      ]),
    );
  }
}

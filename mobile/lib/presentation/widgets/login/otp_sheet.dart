import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';

class OtpSheet extends StatefulWidget {
  final String phone;
  final String? demoOtp;
  final AuthService auth;
  final void Function(UserModel user, String token) onDone;

  const OtpSheet({super.key, required this.phone, this.demoOtp, required this.auth, required this.onDone});
  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
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
      if (_timer > 0) {
        setState(() => _timer--);
      } else {
        t.cancel();
      }
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

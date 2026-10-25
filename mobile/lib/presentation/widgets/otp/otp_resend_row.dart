import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class OtpResendRow extends StatefulWidget {
  final Future<void> Function()? onResend;
  final int initialSeconds;

  const OtpResendRow({
    super.key,
    this.onResend,
    this.initialSeconds = 60,
  });

  @override
  State<OtpResendRow> createState() => _OtpResendRowState();
}

class _OtpResendRowState extends State<OtpResendRow> {
  late int _remaining;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleResend() async {
    if (_remaining > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      if (widget.onResend != null) {
        await widget.onResend!();
      }
      if (!mounted) return;
      setState(() {
        _remaining = 60;
        _isResending = false;
      });
      _startTimer();
    } catch (_) {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        InkWell(
          onTap: _remaining == 0 && !_isResending ? _handleResend : null,
          child: Text(
            _isResending
                ? 'Sending…'
                : (_remaining == 0 ? 'Resend' : 'Resend in ${_remaining}s'),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _remaining == 0 ? AppColors.gold : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2E4A), width: 1),
      ),
      child: Row(
        children: [
          // Gold Tag
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'PAGE 04: VERIFY OTP',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Secure 6-Digit Verification',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                color: const Color(0xFF94A3B8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Resend Button or Timer
          InkWell(
            onTap: _remaining == 0 && !_isResending ? _handleResend : null,
            child: Text(
              _isResending
                  ? 'Sending…'
                  : (_remaining == 0 ? 'Resend Now' : 'Resend (${_remaining}s)'),
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _remaining == 0 ? AppColors.gold : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

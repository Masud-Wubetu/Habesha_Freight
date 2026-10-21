import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpSecurityBadge extends StatelessWidget {
  const OtpSecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1527),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E2E4A), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 14,
            ),
            const SizedBox(width: 7),
            Text(
              'SECURED BY',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Ethio Telecom SMS Gateway',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2DD4BF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipientNumberCard extends StatelessWidget {
  final String? phone;
  final String? email;
  final VoidCallback? onEdit;

  const RecipientNumberCard({
    super.key,
    this.phone,
    this.email,
    this.onEdit,
  });

  String _formatPhone(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('+251') && clean.length == 13) {
      // +251 911 234 567
      return '${clean.substring(0, 4)} ${clean.substring(4, 7)} ${clean.substring(7, 10)} ${clean.substring(10)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = email != null && email!.trim().isNotEmpty;
    final displayValue = isEmail ? email!.trim() : _formatPhone(phone ?? '');
    final label = isEmail ? 'VERIFICATION EMAIL' : 'RECIPIENT NUMBER';
    final iconData = isEmail ? Icons.mark_email_read_outlined : Icons.phone_android_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2E4A), width: 1.2),
      ),
      child: Row(
        children: [
          // Device / Email Icon Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF141F36),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF223554), width: 1),
            ),
            child: Icon(
              iconData,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Edit Action Button
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF162238),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF243656), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

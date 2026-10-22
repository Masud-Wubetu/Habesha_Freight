import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class LiveTrackingHeader extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onProfileTap;
  final String waybillNumber;

  const LiveTrackingHeader({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onProfileTap,
    this.waybillNumber = '#HF-8841-ET',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Brand & Actions Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Logo & Title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Habesha',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Freight',
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LOGISTICS EXCHANGE',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Language & Profile Buttons
            Row(
              children: [
                // Language Dropdown Pill
                PopupMenuButton<String>(
                  initialValue: language,
                  onSelected: onLanguageChanged,
                  color: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1E293B)),
                  ),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'EN',
                      child: Text('EN · English', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                    ),
                    PopupMenuItem(
                      value: 'AM',
                      child: Text('AM · አማርኛ', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                    ),
                    PopupMenuItem(
                      value: 'OM',
                      child: Text('OM · Afaan Oromoo', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.translate_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Profile Avatar Button in gold circle
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF241C10),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Sub-Header Ribbon: ● LIVE TELEMETRY & WAYBILL: #HF-8841-ET
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: ● LIVE TELEMETRY
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6622C55E),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE TELEMETRY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),

              // Right: WAYBILL: #HF-8841-ET
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'WAYBILL: ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    waybillNumber,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

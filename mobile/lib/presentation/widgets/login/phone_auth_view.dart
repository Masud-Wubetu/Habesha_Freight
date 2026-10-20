import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ethiopian_flag.dart';

class PhoneAuthView extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const PhoneAuthView({super.key, required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              controller: controller, keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '91 234 5678', hintStyle: TextStyle(color: AppColors.textMuted)),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
        ]),
      ),
    ]);
  }
}

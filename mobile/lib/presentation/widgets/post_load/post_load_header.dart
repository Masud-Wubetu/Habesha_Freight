import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PostLoadHeader extends StatelessWidget {
  final VoidCallback onClose;

  const PostLoadHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('FREIGHT MARKETPLACE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.badgeAmberText, letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 4),
            Text('Post New Freight Load', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
          onPressed: onClose,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }
}

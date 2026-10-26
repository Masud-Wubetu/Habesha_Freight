import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class BroadcastTenderCard extends StatefulWidget {
  final int availableTrucksCount;
  final VoidCallback? onBroadcastTriggered;

  const BroadcastTenderCard({
    super.key,
    this.availableTrucksCount = 45,
    this.onBroadcastTriggered,
  });

  @override
  State<BroadcastTenderCard> createState() => _BroadcastTenderCardState();
}

class _BroadcastTenderCardState extends State<BroadcastTenderCard> {
  bool _isBroadcasting = false;

  void _handleBroadcast(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isBroadcasting = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isBroadcasting = false);
      widget.onBroadcastTriggered?.call();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF042F2E),
          content: Row(
            children: [
              const Icon(Icons.radar_rounded, color: Color(0xFF34D399), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tender broadcasted to ${widget.availableTrucksCount} verified line-haul trucks on Expressway A1!',
                  style: GoogleFonts.inter(color: const Color(0xFF34D399), fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2C44), width: 1.2),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2E1E05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB45309), width: 1),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need More Competitive Rates?',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Broadcast tender to ${widget.availableTrucksCount} verified trucks on this corridor.',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Broadcast Button
          ElevatedButton(
            onPressed: _isBroadcasting ? null : () => _handleBroadcast(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: AppColors.gold,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: _isBroadcasting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  )
                : Text(
                    'Broadcast',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

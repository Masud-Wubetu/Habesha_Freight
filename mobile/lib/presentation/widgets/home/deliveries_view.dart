import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DeliveriesView extends StatelessWidget {
  final List<Map<String, dynamic>> loads;
  final VoidCallback onPostNewLoad;

  const DeliveriesView({super.key, required this.loads, required this.onPostNewLoad});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Deliveries & Cargo', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Real-time database load manifests', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
          child: Text('${loads.length} Loads', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ),
      ]),
      const SizedBox(height: 16),
      if (loads.isEmpty) _emptyState() else ...loads.map((l) => _loadTile(l)),
      const SizedBox(height: 24),
    ]);
  }

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
    child: Column(children: [
      const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
      const SizedBox(height: 12),
      Text('No Cargo Deliveries Yet', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      const SizedBox(height: 6),
      Text('Broadcast cargo to verified carriers on Ethiopian national corridors.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 14),
      ElevatedButton.icon(
        onPressed: onPostNewLoad,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Post a Load Now'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    ]),
  );

  Widget _loadTile(Map<String, dynamic> load) {
    final origin = load['origin_city'] ?? 'Origin';
    final dest = load['destination_city'] ?? 'Destination';
    final weight = load['weight_tons'] ?? 0;
    final price = load['offered_price_etb'] ?? 0;
    final status = (load['status'] ?? 'POSTED').toString();
    final desc = load['cargo_description'] ?? 'General Cargo';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(desc, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
          _badge(status),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.route_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 6),
          Text('$origin ➔ $dest', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          Text('${price.toString()} ETB', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ]),
        const SizedBox(height: 4),
        Text('$weight metric tonnes • Verified Carrier Matching', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _badge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.badgeAmberBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.badgeAmberBorder)),
    child: Text(status, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.badgeAmberText)),
  );
}

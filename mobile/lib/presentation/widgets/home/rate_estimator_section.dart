import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_model.dart';

class RateEstimatorSection extends StatelessWidget {
  final EthiopianCorridor corridor;
  final double weightTons;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onRequestTrucks;
  final CorridorService corridorService;

  const RateEstimatorSection({
    super.key,
    required this.corridor,
    required this.weightTons,
    required this.onWeightChanged,
    required this.onRequestTrucks,
    required this.corridorService,
  });

  @override
  Widget build(BuildContext context) {
    final estimate = corridorService.calculateTariff(corridor: corridor, weightTons: weightTons);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.calculate_outlined, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Text('Corridor Rate Estimator', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
          child: Text('Live tariff data', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
      ]),
      const SizedBox(height: 10),

      // Card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _locationTile(icon: Icons.share_location_rounded, iconColor: AppColors.badgeGreenText, label: 'Origin Cargo Terminal', city: corridor.originCity, terminal: corridor.originTerminal),
          const Padding(padding: EdgeInsets.only(left: 18), child: SizedBox(height: 14, child: VerticalDivider(color: AppColors.cardBorder, thickness: 1.5))),
          _locationTile(icon: Icons.location_on_rounded, iconColor: AppColors.gold, label: 'Corridor Destination', city: corridor.destinationCity, terminal: corridor.destinationTerminal),
          const SizedBox(height: 16),
          _weightCounter(),
          const SizedBox(height: 16),
          _tariffResult(estimate),
          const SizedBox(height: 14),
          _requestBtn(),
        ]),
      ),
    ]);
  }

  Widget _locationTile({required IconData icon, required Color iconColor, required String label, required String city, required String terminal}) => Row(children: [
    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      Text(city, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
    ])),
    Text(terminal, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
  ]);

  Widget _weightCounter() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Cargo Weight', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      Text('Metric (tonnes)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
    ]),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 16, color: Colors.white),
          onPressed: weightTons > 1 ? () => onWeightChanged(weightTons - 1) : null,
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${weightTons.toInt()}', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          onPressed: weightTons < 45 ? () => onWeightChanged(weightTons + 1) : null,
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ]),
    ),
  ]);

  Widget _tariffResult(CorridorEstimate est) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ESTIMATED CORRIDOR TARIFF', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(est.estimatedPriceEtb.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
          const SizedBox(width: 4),
          Text('ETB', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold)),
        ]),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Corridor Distance', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        Text('${est.distanceKm.toInt()} km est. • Transit', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.badgeGreenText)),
      ]),
    ]),
  );

  Widget _requestBtn() => SizedBox(
    width: double.infinity, height: 46,
    child: ElevatedButton(
      onPressed: onRequestTrucks,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Request Available Trucks on this Route', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_forward_rounded, size: 16),
      ]),
    ),
  );
}

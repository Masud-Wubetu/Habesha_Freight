import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/corridor_model.dart';
import 'post_load_header.dart';

class PostLoadSheet extends StatefulWidget {
  final CorridorService corridorService;
  final VoidCallback onPosted;

  const PostLoadSheet({super.key, required this.corridorService, required this.onPosted});

  @override
  State<PostLoadSheet> createState() => _PostLoadSheetState();
}

class _PostLoadSheetState extends State<PostLoadSheet> {
  late EthiopianCorridor _corridor;
  double _weight = 15.0;
  final TextEditingController _descCtrl = TextEditingController(text: 'General Commercial Cargo');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _corridor = widget.corridorService.getCorridors().first;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final tariff = widget.corridorService.calculateTariff(corridor: _corridor, weightTons: _weight);
    final ok = await widget.corridorService.postRealLoad(
      originCity: _corridor.originCity,
      destinationCity: _corridor.destinationCity,
      weightTons: _weight,
      offeredPriceEtb: tariff.estimatedPriceEtb,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      widget.onPosted();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not broadcast load. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tariff = widget.corridorService.calculateTariff(corridor: _corridor, weightTons: _weight);

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          PostLoadHeader(onClose: () => Navigator.pop(context)),
          const SizedBox(height: 14),
          Text('Select Corridor Route', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<EthiopianCorridor>(
                value: _corridor,
                isExpanded: true,
                dropdownColor: AppColors.card,
                items: widget.corridorService.getCorridors().map((c) => DropdownMenuItem(value: c, child: Text('${c.originCity} ➔ ${c.destinationCity} (${c.distanceKm.toInt()} km)', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _corridor = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Cargo Description', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextField(controller: _descCtrl, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Weight: ${_weight.toInt()} Tonnes', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white)),
            Text('${tariff.estimatedPriceEtb.toInt()} ETB', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
          ]),
          Slider(value: _weight, min: 1, max: 45, divisions: 44, activeColor: AppColors.gold, onChanged: (v) => setState(() => _weight = v)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark),
              child: _submitting ? const CircularProgressIndicator(color: AppColors.textDark) : Text('Broadcast Load to Transporters', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

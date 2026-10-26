import 'package:flutter/material.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/home/home_header.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({
    super.key,
    required this.reference,
    required this.origin,
    required this.destination,
    required this.cargo,
    required this.pickup,
    required this.shipper,
    required this.rating,
    required this.price,
    required this.priceCaption,
    required this.distance,
    this.cargoNote,
    this.status,
  });

  final String reference;
  final String origin;
  final String destination;
  final String cargo;
  final String pickup;
  final String shipper;
  final String rating;
  final String price;
  final String priceCaption;
  final String distance;
  final String? cargoNote;
  final String? status;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  static const Color _background = Color(0xFF061426);
  static const Color _surface = Color(0xFF0E1C2F);
  static const Color _surfaceHigh = Color(0xFF13243A);
  static const Color _border = Color(0xFF1E3A5F);
  static const Color _gold = Color(0xFFFFB21A);
  static const Color _green = Color(0xFF32D6A0);
  static const Color _muted = Color(0xFF91A4BC);
  static const Color _white = Color(0xFFF4F7FC);

  late final TextEditingController _bidController = TextEditingController(
    text: widget.price.replaceAll(RegExp(r'[^0-9]'), ''),
  );

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _surfaceHigh),
    );
  }

  Future<void> _showBidForm() async {
    final submitted = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submit Your Bid',
              style: TextStyle(
                color: _white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bidController,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: _white),
              decoration: InputDecoration(
                labelText: 'Bid price (ETB)',
                labelStyle: const TextStyle(color: _muted),
                filled: true,
                fillColor: _surfaceHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _background,
              ),
              onPressed: () {
                final amount = int.tryParse(_bidController.text.trim());
                if (amount == null || amount <= 0) {
                  _showMessage('Enter a valid bid amount.');
                  return;
                }
                Navigator.pop(context, amount.toString());
              },
              child: const Text('Submit Bid'),
            ),
          ],
        ),
      ),
    );

    if (submitted != null && mounted) {
      _showMessage('Bid of $submitted ETB prepared for ${widget.reference}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: HomeHeader(
                language: 'EN',
                onLanguageChanged: (_) {},
                onProfileTap: () {},
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _buildRequestMeta(),
                  const SizedBox(height: 12),
                  _buildCorridorCard(),
                  const SizedBox(height: 12),
                  _buildRouteCard(),
                  const SizedBox(height: 14),
                  _buildSectionHeading(
                    'TECHNICAL SPECIFICATIONS',
                    'Standard ISO Transit',
                  ),
                  const SizedBox(height: 8),
                  _buildSpecifications(),
                  const SizedBox(height: 12),
                  _buildTransitProtocol(),
                  const SizedBox(height: 12),
                  _buildShipperCard(),
                  const SizedBox(height: 12),
                  _buildLanePulse(),
                  const SizedBox(height: 16),
                  _buildBidPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestMeta() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF8BCBFF),
                size: 15,
              ),
              SizedBox(width: 5),
              Text(
                'DRY BULK LOGISTICS',
                style: TextStyle(
                  color: Color(0xFF8BCBFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.access_time, color: _gold, size: 14),
        const SizedBox(width: 5),
        const Text(
          'Posted 14m ago',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCorridorCard() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(14),
      borderColor: _border,
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(Icons.alt_route_rounded, 'A2 Northern Highway', _gold),
              const Spacer(),
              _chip(Icons.verified_outlined, 'Customs Cleared', _green),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(painter: _CorridorPainter()),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'CORRIDOR DISTANCE',
                  widget.distance,
                  'via Ethiopian highway',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metric(
                  'EST. DRIVING WINDOW',
                  '21 Hours',
                  'Estimated transit',
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(14),
      borderColor: _border,
      radius: 16,
      child: Column(
        children: [
          _routeStop(
            title: 'ORIGIN POINT',
            place: widget.origin,
            subPlace: 'Addis Ababa Industrial Zone',
            time: 'Pickup: ${widget.pickup}',
            badge: 'Gate 04-B',
            icon: Icons.calendar_month_outlined,
            color: _gold,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              height: 18,
              width: 2,
              color: _green.withValues(alpha: 0.7),
            ),
          ),
          _routeStop(
            title: 'DELIVERY DESTINATION',
            place: widget.destination,
            subPlace: 'Delivery destination',
            time: 'Target Arrival: Oct 11, by 18:00 EAT',
            badge: 'Bay 12 South',
            icon: Icons.event_available_outlined,
            color: _green,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _routeStop({
    required String title,
    required String place,
    required String subPlace,
    required String time,
    required String badge,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            isLast ? Icons.radio_button_checked : Icons.adjust_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _smallTag(badge),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                place,
                style: const TextStyle(
                  color: _white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subPlace,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(color: color, fontSize: 11),
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

  Widget _buildSectionHeading(String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: _gold,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _specCard(
                icon: Icons.work_outline_rounded,
                tag: 'Heavy',
                title: 'CARGO',
                value: widget.cargo,
                detail: widget.cargoNote ?? 'Transit cargo',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _specCard(
                icon: Icons.local_shipping_outlined,
                tag: 'Rig Spec',
                title: 'VEHICLE',
                value: widget.cargoNote ?? 'Heavy freight rig',
                detail: 'FAW / Semi-Trailer',
                iconColor: const Color(0xFF8BCBFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _specCard(
                icon: Icons.account_balance_outlined,
                tag: 'Guaranteed',
                title: 'SETTLEMENT',
                value: 'CBE Birr Escrow',
                detail: widget.status ?? 'Institutional Vault Locked',
                iconColor: _green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _specCard(
                icon: Icons.policy_outlined,
                tag: 'TPL+',
                title: 'INSURANCE',
                value: 'Full Marine',
                detail: 'In-transit cargo covered',
                iconColor: _gold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _specCard({
    required IconData icon,
    required String tag,
    required String title,
    required String value,
    required String detail,
    Color iconColor = _gold,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: HfCard(
        color: _surface,
        padding: const EdgeInsets.all(11),
        borderColor: _border,
        radius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 17),
                const Spacer(),
                _smallTag(tag),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitProtocol() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(13),
      borderColor: const Color(0xFF8A5A14),
      radius: 14,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: _gold),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mandatory Transit Protocol',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cargo requires heavy-duty waterproof tarpaulin sheets and a certified GPS customs telemetry beacon paired directly to the Ethiopian Customs Commission corridor tracking system.',
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipperCard() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(14),
      borderColor: _border,
      radius: 14,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _surfaceHigh,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  widget.shipper.trim().isEmpty
                      ? 'S'
                      : widget.shipper.trim().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shipper,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '● FTA Tier 1 Certified Exporter',
                      style: TextStyle(
                        color: _green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: _gold, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        widget.rating.split(' ').first,
                        style: const TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '124 loads completed',
                    style: TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _contactButton(
                  icon: Icons.call_outlined,
                  label: 'Call Shipper',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _contactButton(
                  icon: Icons.chat_outlined,
                  label: 'Encrypted Chat',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactButton({required IconData icon, required String label}) {
    return OutlinedButton.icon(
      onPressed: () => _showMessage('$label is not available yet.'),
      icon: Icon(icon, size: 16, color: const Color(0xFF8BCBFF)),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _white, fontSize: 11),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLanePulse() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(14),
      borderColor: _border,
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: _green, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'LANE BIDDING PULSE',
                  style: TextStyle(
                    color: _white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _smallTag('3 Active Competitor Bids'),
            ],
          ),
          const SizedBox(height: 10),
          HfCard(
            color: _surfaceHigh,
            padding: const EdgeInsets.all(12),
            borderColor: _border.withValues(alpha: 0.7),
            radius: 11,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Shipper Target Budget',
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ),
                    Text(
                      _budgetRange(widget.price),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 7,
                    backgroundColor: _background,
                    valueColor: AlwaysStoppedAnimation<Color>(_green),
                  ),
                ),
                const SizedBox(height: 7),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Min: 68k ETB',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                    Text(
                      'Optimal Corridor Rate',
                      style: TextStyle(
                        color: _green,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Max: 90k ETB',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidPanel() {
    return HfCard(
      color: _surface,
      padding: const EdgeInsets.all(14),
      borderColor: _border,
      radius: 15,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SETTLEMENT GUARANTEE',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '♧ CBE Institutional Escrow Locked',
                      style: TextStyle(
                        color: _green,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'AVG AWARD TIME',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '~45 minutes',
                    style: TextStyle(
                      color: _white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showBidForm,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Submit Your Bid Price'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _background,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Submitting locks rate parameters. Cargo owner reviews immediately.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String label,
    String value,
    String subtitle, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: _white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _gold,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _budgetRange(String input) {
    final amount = int.tryParse(input.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null) return input;
    final lower = (amount * 1.15).round();
    final upper = (amount * 1.25).round();
    return '${_formatAmount(lower)} – ${_formatAmount(upper)} ETB';
  }

  String _formatAmount(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        result.write(',');
      }
      result.write(digits[index]);
    }
    return result.toString();
  }
}

class _CorridorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8A5A14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.88)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.36,
        size.width * 0.65,
        size.height * 0.1,
        size.width * 0.94,
        size.height * 0.35,
      );
    final metric = path.computeMetrics().first;
    for (var distance = 0.0; distance + 6 < metric.length; distance += 12) {
      canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
    }
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.35),
      5,
      Paint()..color = const Color(0xFF25766A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

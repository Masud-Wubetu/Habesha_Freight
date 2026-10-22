import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LiveTransitCard extends StatelessWidget {
  final String shipmentId;
  final String transitTag;
  final String origin;
  final String originHub;
  final String destination;
  final String destinationBay;
  final String speedText;
  final String etaText;
  final double progressPercent; // 0.0 to 1.0
  final String departedTime;
  final String corridorName;
  final String targetTime;
  final String driverName;
  final String truckModel;
  final VoidCallback? onViewAllTap;
  final VoidCallback? onDriverCallTap;
  final VoidCallback? onLiveTelemetryTap;
  final VoidCallback? onWaybillTap;

  const LiveTransitCard({
    super.key,
    this.shipmentId = 'SHIPMENT #HF-8841',
    this.transitTag = 'Export Transit',
    this.origin = 'Addis Ababa',
    this.originHub = 'Kality Hub',
    this.destination = 'Modjo Dry Port',
    this.destinationBay = 'Customs Bay 04',
    this.speedText = 'Cruising 72 km/h',
    this.etaText = 'ETA: 48 min',
    this.progressPercent = 0.65,
    this.departedTime = 'Departed 08:30',
    this.corridorName = 'A1 Express Corridor',
    this.targetTime = 'Target 11:45',
    this.driverName = 'Dawit Kebede',
    this.truckModel = 'Volvo FH16 (ET 3-48192)',
    this.onViewAllTap,
    this.onDriverCallTap,
    this.onLiveTelemetryTap,
    this.onWaybillTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Live Transit (Priority) | View all >
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Live Transit',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Priority',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onViewAllTap,
              child: Row(
                children: [
                  Text(
                    'View all',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.gold),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Main Transit Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0C1628),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E2E48), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top: ID + Badge
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shipmentId,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        transitTag,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Route Row: Addis Ababa ➔ Modjo Dry Port
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Origin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  origin,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 13, top: 1),
                            child: Text(
                              originHub,
                              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.gold),
                    ),

                    // Destination
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  destination,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 13, top: 1),
                            child: Text(
                              destinationBay,
                              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Progress Bar & Telemetry Strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF082E25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF0F5A47)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                speedText,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF34D399),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          etaText,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Linear Progress Bar matching screenshot
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 5,
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Progress detail points: Departed · Corridor · Target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(departedTime, style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF64748B))),
                        Text(corridorName, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                        Text(targetTime, style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Driver Contact Strip
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF18263E)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.person_pin_rounded, color: AppColors.gold, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver: $driverName',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            truckModel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: onDriverCallTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E36),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF223A5E)),
                        ),
                        child: const Icon(Icons.phone_rounded, color: Color(0xFF38BDF8), size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Dual Action Buttons: Live Telemetry | Waybill
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onLiveTelemetryTap,
                        icon: const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.gold),
                        label: Text(
                          'Live Telemetry',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E1A2D),
                          side: const BorderSide(color: Color(0xFF203350)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onWaybillTap,
                        icon: const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFF38BDF8)),
                        label: Text(
                          'Waybill',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E1A2D),
                          side: const BorderSide(color: Color(0xFF203350)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

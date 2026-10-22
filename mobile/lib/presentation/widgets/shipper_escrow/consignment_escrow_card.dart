import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

enum EscrowCardStatus {
  inTransit,
  pendingPodOtp,
  settled,
}

class ConsignmentEscrowItem {
  final String id;
  final String escrowProvider; // 'Telebirr Escrow' | 'CBE Birr Escrow'
  final double amountEtb;
  final EscrowCardStatus status;
  final String origin;
  final String destination;
  final String carrierName;
  final String telemetryText;
  final String cargoDetails;
  final String? taxInvoiceNo;

  const ConsignmentEscrowItem({
    required this.id,
    required this.escrowProvider,
    required this.amountEtb,
    required this.status,
    required this.origin,
    required this.destination,
    required this.carrierName,
    required this.telemetryText,
    required this.cargoDetails,
    this.taxInvoiceNo,
  });
}

class ConsignmentEscrowCard extends StatelessWidget {
  final ConsignmentEscrowItem item;
  final VoidCallback? onEnterPodOtp;
  final VoidCallback? onViewInvoice;
  final VoidCallback? onTapDetails;

  const ConsignmentEscrowCard({
    super.key,
    required this.item,
    this.onEnterPodOtp,
    this.onViewInvoice,
    this.onTapDetails,
  });

  String _formatCurrency(double val) {
    final parts = val.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isTelebirr = item.escrowProvider.contains('Telebirr');
    final isSettled = item.status == EscrowCardStatus.settled;
    final isPendingOtp = item.status == EscrowCardStatus.pendingPodOtp;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPendingOtp
              ? AppColors.gold.withValues(alpha: 0.5)
              : const Color(0xFF1E2E48),
          width: isPendingOtp ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPendingOtp
                ? AppColors.gold.withValues(alpha: 0.08)
                : const Color(0x22000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Provider Badge + Locked/Paid Amount
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      item.id,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTelebirr
                            ? const Color(0xFF0072BC).withValues(alpha: 0.18)
                            : const Color(0xFF9333EA).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isTelebirr
                              ? const Color(0xFF0072BC).withValues(alpha: 0.45)
                              : const Color(0xFF9333EA).withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTelebirr ? Icons.phone_android_rounded : Icons.account_balance_rounded,
                            size: 11,
                            color: isTelebirr ? const Color(0xFF60A5FA) : const Color(0xFFC084FC),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.escrowProvider,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isTelebirr ? const Color(0xFF93C5FD) : const Color(0xFFE9D5FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Amount Tag
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatCurrency(item.amountEtb)} ETB',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSettled ? const Color(0xFF10B981) : AppColors.gold,
                      ),
                    ),
                    Text(
                      isSettled ? 'PAID & SETTLED' : 'VAULTED ESCROW',
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isSettled ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF1A2840)),

          // Route & Cargo Details
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Visual
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.origin,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.destination,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Cargo description + Carrier info
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.cargoDetails} · Carrier: ${item.carrierName}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Telemetry status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF081220),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF19273D)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSettled
                              ? const Color(0xFF10B981)
                              : (isPendingOtp ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.telemetryText,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFCBD5E1),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Button Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _buildActionButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (item.status) {
      case EscrowCardStatus.pendingPodOtp:
        return SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: onEnterPodOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.key_rounded, size: 16, color: Color(0xFF0F172A)),
                const SizedBox(width: 8),
                Text(
                  'Enter POD OTP to Release →',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );

      case EscrowCardStatus.inTransit:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1322),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF182438)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock_outlined, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'Requires Driver Arrival OTP · In Transit',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );

      case EscrowCardStatus.settled:
        return InkWell(
          onTap: onViewInvoice,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1F1B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0E4D3E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Withholding Tax (2%) Remitted',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA7F3D0),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View Tax Invoice',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_outward_rounded, size: 12, color: Color(0xFF34D399)),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }
}

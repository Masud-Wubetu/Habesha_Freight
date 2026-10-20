import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// PAGE 32 — Fuel Voucher & Corridor Toll Pass Manager (stack shell).
class FuelTollScreen extends StatelessWidget {
  const FuelTollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Fuel Voucher & Corridor Toll Pass Manager',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: AppColors.onSurfaceVariant,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageRibbon(
                  page: '32',
                  title: 'FUEL & TOLL MANAGER',
                  status: 'Active Fleet: 24 Rigs',
                  dotColor: AppColors.primary,
                  textColor: AppColors.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pre-authorized digital diesel allocations and RFID express toll lane passes across Ethiopian transit arteries.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _FuelWalletCard(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('+ Issue Digital Fuel Voucher & Toll Token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHigh,
                foregroundColor: AppColors.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.tune, size: 18, color: AppColors.onSurfaceVariant),
              label: const Text('Manage Station Network & Pricing Index'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceBright.withValues(alpha: 0.5),
                  AppColors.surface,
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.satellite_alt, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Live Corridor Telemetry Grid',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'All Gates Clear',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active Vouchers & Passes',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '3 Queue',
                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Filter', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                    Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _VoucherCard(
            code: '#FL-7741-TOT',
            vehicle: 'SinoTruk ET-3-8821',
            driver: 'Driver: Kassahun T.',
            status: 'Redeemed • 100% CAN-Bus',
            statusColor: AppColors.secondary,
            statusIcon: Icons.check_circle,
            from: 'Addis Ababa',
            to: 'Djibouti Corridor',
            fuel: '420 Liters Diesel (ETB 34,500)',
            fuelDetail: ' • TotalEnergies Awash Hub',
            toll: 'Awash Arba & Modjo RFID FastPass Authorized',
            tollColor: AppColors.tertiary,
            footerLeft: 'Sync: 4m ago',
            footerIcon: Icons.cloud_download,
            footerAction: 'Audit Slip',
            actionPrimary: false,
          ),
          const SizedBox(height: 12),
          const _VoucherCard(
            code: '#FL-8902-NOC',
            vehicle: 'FAW J5P ET-3-4412',
            driver: 'Driver: Dawit W.',
            status: 'Active • QR Ready',
            statusColor: AppColors.primary,
            statusIcon: Icons.qr_code_2,
            from: 'Kaliti',
            to: 'Hawassa Industrial Corridor',
            fuel: '280 Liters Diesel (ETB 22,960)',
            fuelDetail: ' • NOC Adama Bypass',
            toll: 'Adama Expressway Gate 3 FastPass Active',
            tollColor: AppColors.tertiary,
            footerLeft: 'Transmitted to Driver App',
            footerIcon: Icons.cell_tower,
            footerLeftColor: AppColors.primary,
            footerAction: 'Show QR Token',
            actionPrimary: true,
          ),
          const SizedBox(height: 12),
          const _VoucherCard(
            code: '#FL-9114-TOT',
            vehicle: 'Scania R420 ET-3-9031',
            driver: 'Driver: Birhanu B.',
            status: 'Pending Inspection',
            statusColor: AppColors.onSurfaceVariant,
            statusIcon: Icons.pending_actions,
            from: 'Mojo Dry Port',
            to: 'Kombolcha',
            fuel: '350 Liters Diesel (ETB 28,700)',
            fuelDetail: ' • Mojo Depot Allocation',
            toll: 'Toll Pass Pending Vehicle Pre-Check',
            tollColor: AppColors.outline,
            footerLeft: 'Awaiting Departure Clearance',
            footerIcon: null,
            footerAction: 'Verify Checklist',
            actionPrimary: false,
          ),
          const SizedBox(height: 16),
          const _AntiSiphonCard(),
          const SizedBox(height: 12),
          const _TollGateCard(),
        ],
      ),
    );
  }
}

class _FuelWalletCard extends StatelessWidget {
  const _FuelWalletCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Total Corporate Fuel Balance',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ETB 485,000.00',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.32,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.contactless, size: 28, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, size: 18, color: AppColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TotalEnergies & NOC Enterprise Master Card',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _QuotaCell(label: 'Allocated Today', value: '112.4k')),
              SizedBox(width: 8),
              Expanded(
                child: _QuotaCell(
                  label: 'Available Quota',
                  value: '372.6k',
                  valueColor: AppColors.secondary,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _QuotaCell(
                  label: 'RFID Pass Credit',
                  value: '45.8k',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuotaCell extends StatelessWidget {
  const _QuotaCell({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const Text('ETB', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.code,
    required this.vehicle,
    required this.driver,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.from,
    required this.to,
    required this.fuel,
    required this.fuelDetail,
    required this.toll,
    required this.tollColor,
    required this.footerLeft,
    required this.footerAction,
    required this.actionPrimary,
    this.footerIcon,
    this.footerLeftColor = AppColors.onSurfaceVariant,
  });

  final String code;
  final String vehicle;
  final String driver;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String from;
  final String to;
  final String fuel;
  final String fuelDetail;
  final String toll;
  final Color tollColor;
  final String footerLeft;
  final IconData? footerIcon;
  final Color footerLeftColor;
  final String footerAction;
  final bool actionPrimary;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        Text(
                          code,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text('•', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        Text(
                          vehicle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(driver, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(fontSize: 10, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.route, size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(child: Text(from, overflow: TextOverflow.ellipsis)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('➔', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
                Flexible(child: Text(to, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_gas_station, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    children: [
                      TextSpan(
                        text: fuel,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                      TextSpan(text: fuelDetail),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.toll, size: 16, color: tollColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(toll, style: TextStyle(fontSize: 12, color: tollColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (footerIcon != null) ...[
                    Icon(footerIcon, size: 14, color: footerLeftColor),
                    const SizedBox(width: 4),
                  ],
                  Text(footerLeft, style: TextStyle(fontSize: 10, color: footerLeftColor)),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: actionPrimary ? AppColors.primaryContainer : AppColors.surfaceHigh,
                  foregroundColor: actionPrimary ? AppColors.onPrimaryContainer : AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  footerAction,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: actionPrimary ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AntiSiphonCard extends StatelessWidget {
  const _AntiSiphonCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Anti-Siphon Telemetry Guard',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Active • 24 Rigs',
                        style: TextStyle(fontSize: 10, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Real-time ultrasonic fuel tank sensors synced via CAN-Bus. Zero abnormal fuel drops or off-route siphoning incidents detected across active corridor operations in the past 48 hours.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.sensors, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'Tank Sensors 100% Operational',
                      style: TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.lock, size: 14, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4),
                    Text(
                      'Caps Sealed',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
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
}

class _TollGateCard extends StatelessWidget {
  const _TollGateCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Toll Gate Telemetry Station',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const Text(
                'Live RFID Beacon',
                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 128,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceBright.withValues(alpha: 0.4),
                  AppColors.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10),
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Modjo Expressway RFID Portal #2',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '0.4s FastPass Latency',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

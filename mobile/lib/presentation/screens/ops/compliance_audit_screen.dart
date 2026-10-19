import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';
import 'package:mobile/presentation/widgets/nocturne/stack_scaffold.dart';

/// Page 38 — Institutional Compliance Statutory Audit Suite
class ComplianceAuditScreen extends StatelessWidget {
  const ComplianceAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StackScaffold(
      title: 'Institutional Compliance Suite',
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          color: AppColors.onSurfaceVariant,
          onPressed: () {},
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              const Expanded(
                child: PageRibbon(
                  page: '38',
                  title: 'Institutional Compliance & Audit',
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'Gateway Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceLow,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enterprise Compliance',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '99.4%',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Tier-1 Platinum',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.corporate_fare,
                          size: 28, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Nile Trans-Ethiopia Logistics Corp',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'TIN: 00928374-B',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.verified_user,
                              size: 16, color: AppColors.secondary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Fully Certified for Bilateral Transit (Ethiopia – Djibouti – Kenya Corridor)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event,
                        size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Next Scheduled Federal Audit: ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'in 64 Days (Dec 2024)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.task_alt, size: 18, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Digital Statutory Seal • Cryptographically Verified',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        'v4.8-SYNC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Agency Telemetry Gateways',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Text(
                '4 / 4 Synced',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _AgencyCard(
            icon: Icons.account_balance,
            title: 'Ethiopian Customs Commission (ECC)',
            status: 'Integrated',
            statusColor: AppColors.secondary,
            lines: [
              'ASYCUDA XML API Live',
              '0 Pending Manifest Queries · RTT 34ms',
              'Active Port Clearance: Modjo Dry Port & Galafi',
              'Transit Declaration Code: T1-ET-2024-8841',
            ],
          ),
          const SizedBox(height: 8),
          const _AgencyCard(
            icon: Icons.receipt_long,
            title: 'Ministry of Revenues (MoR)',
            status: 'e-Tax Sync',
            statusColor: AppColors.tertiary,
            lines: [
              '100% Tax Withholding Compliant',
              'ETB 29,650 Pre-cleared Transit Escrow · Auto-Reconciled',
              'Tax Clearance Cert: MOR-TX-9902-ETH',
              'Audited Fiscal Cycle: 2023/24 Q3 Settled',
            ],
          ),
          const SizedBox(height: 8),
          const _AgencyCard(
            icon: Icons.commute,
            title: 'Federal Transport Authority (FTA)',
            status: 'Mandate Met',
            statusColor: AppColors.secondary,
            lines: [
              'All 28 Fleet Heavy Rigs Enrolled',
              'Continuous National GPS Telemetry Live · 28/28 Transponders',
              'Axle Load Telemetry Bridge: Awash & Mojo Weighlink OK',
              'Speed Governor Certification: 100% Calibrated',
            ],
          ),
          const SizedBox(height: 8),
          const _AgencyCard(
            icon: Icons.eco,
            title: 'Environmental & Emissions Guard',
            status: 'Ledger Active',
            statusColor: AppColors.secondary,
            lines: [
              'Euro III/IV Standard Verification',
              'Corridor Carbon Offset Credit Balance: +1,420 MT Credit',
              'Soot Level Diagnostics: < 0.18 g/kWh (Optimal)',
              'EPA Certificate Registry: ETH-ENV-2024-C3',
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.folder_special, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Statutory Document Vault',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              const Text(
                '4 Records',
                style: TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _VaultItem(
            icon: Icons.card_membership,
            title: 'Carrier Cross-Border Freight License',
            subtitle: '#FL-9021 • Federal MoT Endorsed',
            badge: 'Expires in 184 Days (Annual Renewal)',
            badgeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          const _VaultItem(
            icon: Icons.handshake,
            title: 'Bilateral Transit Goods Authorization',
            subtitle: 'Inter-Governmental Protocol (ET-DJ-KE)',
            badge: 'Active • Unlimited Corridor Passage',
            badgeColor: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          const _VaultItem(
            icon: Icons.security,
            title: 'Goods-in-Transit (GIT) Master Policy',
            subtitle: 'Nyala Insurance S.C. · Coverage: ETB 50,000,000',
            badge: '• Valid Q4',
            badgeColor: AppColors.tertiary,
          ),
          const SizedBox(height: 8),
          const _VaultItem(
            icon: Icons.medical_services,
            title: 'Commercial Driver Medical Clearances',
            subtitle: 'FTA Occupational Health Directorate',
            badge: '32 / 32 Drivers Fully Certified',
            badgeColor: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          HfCard(
            color: AppColors.surfaceHigh.withValues(alpha: 0.4),
            child: const Row(
              children: [
                Icon(Icons.location_searching,
                    size: 20, color: AppColors.tertiary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Corridors Under Cross-Agency Surveillance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Modjo • Awash • Dewele · ETH-DJI Km 428 Checkpoint Gate Pass',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                'Generate Unified Compliance Dossier (PDF) →',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                backgroundColor: AppColors.surfaceHigh,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.sync, color: AppColors.tertiary),
              label: const Text(
                'Sync Telemetry with Federal Ministry of Transport',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  const _AgencyCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color statusColor;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                color: AppColors.onSurfaceVariant,
                onPressed: () {},
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultItem extends StatelessWidget {
  const _VaultItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return HfCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.surfaceLow,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

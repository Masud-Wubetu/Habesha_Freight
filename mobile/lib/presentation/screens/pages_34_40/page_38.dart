import 'package:flutter/material.dart';
import 'ui.dart';

class Page38 extends StatelessWidget {
  const Page38({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 38, title: 'Institutional Compliance Suite', children: [
      const Intro(page: 38, heading: 'Institutional Compliance & Audit', description: 'Cross-agency regulatory compliance repository: Ministry of Transport, Ministry of Revenues, Customs Commission and Ethiopian Roads Administration.', status: 'Gateway Active'),

      const DashboardCard(title: 'Enterprise Compliance', children: [
        Text('99.4%', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: paleAmber)),
        Tag('Tier-1 Platinum', color: paleAmber), SizedBox(height: 12),
        DataLine('Nile Trans-Ethiopia Logistics Corp', 'ACTIVE', valueColor: mint),
        DataLine('Bilateral Transit', 'Certified'),
        DataLine('Next Scheduled Federal Audit', '64 Days', valueColor: paleAmber),
      ]),
      const SectionHeading('Agency Telemetry Gateways', Icons.account_balance_outlined),
      const DashboardCard(title: 'Ethiopian Customs Commission', children: [
        DataLine('ASYCUDA XML API', 'Integrated', valueColor: mint),
        DataLine('Pending Manifest Queries', '0'),
      ]),
      const DashboardCard(title: 'Ministry of Revenues (MoR)', children: [
        DataLine('Tax Withholding', '100% Compliant'),
        DataLine('Pre-cleared Transit Escrow', 'ETB 29,650'),
      ]),
      const DashboardCard(title: 'Federal Transport Authority', children: [
        DataLine('Fleet Heavy Rigs Enrolled', '28'),
        DataLine('GPS Telemetry', '28/28 Live', valueColor: mint),
      ]),
      const DashboardCard(title: 'Environmental & Emissions', children: [
        DataLine('Euro III/IV Verification', 'Active'),
        DataLine('Carbon Offset Credit', '+1,420 MT'),
      ]),
      const SectionHeading('Statutory Document Vault', Icons.folder_copy_outlined),
      const DashboardCard(children: [
        DataLine('Carrier Cross-Border Freight License', 'Verified'),
        DataLine('Bilateral Transit Authorization', 'Active'),
        DataLine('Goods-in-Transit Master Insurance', 'Valid'),
        DataLine('Commercial Driver Medical Clearance', '32/32'),
      ]),
      const PrimaryAction('Generate Unified Compliance Dossier (PDF)'),

    ],
  );
}

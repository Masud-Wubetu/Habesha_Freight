import 'package:flutter/material.dart';
import 'ui.dart';

class Page35 extends StatelessWidget {
  const Page35({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 35, title: 'Customs And Manifest Declaration', children: [
      const Intro(page: 35, heading: 'Customs & Manifest Declaration', description: 'Cross-border cargo manifest declarations, Single Customs Declaration (SCD), and digital seal serialization for Ethiopian trade corridors.', status: 'ASYCUDA World Synced'),

      const DashboardCard(title: 'GALAFI → PORT OF DJIBOUTI', children: [
        DataLine('Corridor Gate', '04'), DataLine('ASYCUDA ID', '084-GAL'),
      ]),
      const DashboardCard(title: 'Single Customs Declaration', children: [
        Text('SCD-ET-2024-88914', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), Tag('Pre-Cleared'), SizedBox(height: 12),
        DataLine('Consignment Ref', 'REQ-9912', valueColor: paleAmber),
        DataLine('Cargo', '36 MT Export Grade Sesame Seeds'),
        DataLine('Exporter Identity', 'Ethio-Agri Trading S.C.'),
        DataLine('Customs Value', 'ETB 3,420,000'),
        DataLine('Transit Bond Active', 'ETB 5,000,000'),
      ]),
      const DashboardCard(title: 'Digital E-Seal & IoT', children: [
        DataLine('Digital Seal', '#ES-9921-GAL', valueColor: paleAmber),
        DataLine('Container Serial', 'TGHU-882019-2'),
        DataLine('Telemetry Power', '98%', valueColor: mint),
        DataLine('Tamper-Proof', '100%', valueColor: mint),
        DataLine('Location', 'Galafi Inbound'),
      ]),
      const DashboardCard(title: 'Statutory Compliance', children: [
        Tag('3/3 Validated'), SizedBox(height: 10),
        DataLine('Commercial Invoice & Packing List', 'Verified', valueColor: mint),
        DataLine('Certificate of Origin (ECC)', 'Cleared', valueColor: mint),
        DataLine('Phyto-Sanitary Inspection', 'Passed', valueColor: mint),
        DataLine('ASYCUDA Routing', 'Green Channel', valueColor: mint),
      ]),
      const PrimaryAction('Transmit Manifest to Djibouti Customs'),
      const PrimaryAction('Download Certified ASYCUDA SCD Document'),

    ],
  );
}

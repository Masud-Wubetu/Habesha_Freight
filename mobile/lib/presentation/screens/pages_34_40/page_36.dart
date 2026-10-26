import 'package:flutter/material.dart';
import 'ui.dart';

class Page36 extends StatelessWidget {
  const Page36({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 36, title: 'Border Clearance And Checkpoint Pass', children: [
      const Intro(page: 36, heading: 'Border Clearance & Checkpoint Pass', description: 'Bilateral border crossing clearance, COMESA Yellow Card verification, customs gate pass, and multi-agency stamp ledger.', status: 'Checkpoint Live Stream: Galafi North'),

      const DashboardCard(title: 'Galafi International Post', children: [
        Tag('FastPass Validated'), SizedBox(height: 10),
        DataLine('Corridor Transit Zone', 'Ethiopia → Djibouti'),
        DataLine('Transit Permit', '#BP-77402-COMESA', valueColor: paleAmber),
        DataLine('Assigned Rig', 'ET-3-8821 AA'),
        DataLine('Manifest Driver', 'K. Tadesse'),
        DataLine('Express Gate 2 Queue', '14 Rigs'),
        DataLine('Clearance ETA', '~8 Min', valueColor: paleAmber),
      ]),
      const DashboardCard(title: 'Multi-Agency Stamp Ledger', children: [
        Tag('4 of 4 Ready'), SizedBox(height: 10),
        DataLine('Ethiopian Customs (ECC)', 'Passed', valueColor: mint),
        DataLine('Ministry of Health Quarantine', 'Valid', valueColor: mint),
        DataLine('COMESA Yellow Card Insurance', 'Active', valueColor: mint),
        DataLine('Federal Police Transit Escort', 'Waived', valueColor: mint),
      ]),
      DashboardCard(title: 'Border Scanner Token', children: [
        const Center(child: Icon(Icons.qr_code_2, color: Colors.white, size: 185)),
        const Center(child: Text('#GAL-GATE-02-EXP', style: TextStyle(color: paleAmber))),
        const SizedBox(height: 12), const Center(child: Tag('Optical NFC Scanners Active')),
      ]),
      const DashboardCard(title: 'Lane 2 Optical Barrier', children: [
        DataLine('Checkpoint Camera', 'Cam #04 Online', valueColor: mint),
      ]),
      const PrimaryAction('Display Full-Screen QR Pass'),

    ],
  );
}

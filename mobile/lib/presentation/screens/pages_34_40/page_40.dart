import 'package:flutter/material.dart';
import 'ui.dart';

class Page40 extends StatelessWidget {
  const Page40({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 40, title: 'Multi-Modal Rail & Inland Port', children: [
      const Intro(page: 40, heading: 'Multi-Modal Intermodal & Rail Port Hub', description: 'Ethio-Djibouti Railway freight train scheduling, Mojo/Indode dry port container transfer, rolling stock wagon assignment, and road-to-rail intermodal transfers.', status: 'EDR Rail Feed Synced · Mojo Dry Port'),

      const DashboardCard(title: 'Operational Mode', children: [
        DataLine('Line Frequency', 'Mojo Electric'),
        DataLine('Corridor Velocity', 'Express Class'),
      ]),
      const DashboardCard(title: 'Mojo Multi-Modal Inland Port', children: [
        Tag('ACTIVE YARD MATCH'), SizedBox(height: 10),
        DataLine('Terminal', '02 · Heavy Cargo Bay'),
        DataLine('Inbound Drayage', 'ET-3-8821'),
        DataLine('EDR Rolling Stock', 'EDR W14-DJ'),
        DataLine('Transfer Status', 'CONTAINER HOIST STAGED', valueColor: mint),
        DataLine('Custom Yard Allocation', 'Block B · Row 14 · Tier 3'),
        DataLine('Gantry Automated Pin Lock', 'Verified'),
        DataLine('Bay Queue', '#01 Next', valueColor: paleAmber),
      ]),
      const DashboardCard(title: 'EDR Express Train Service', children: [
        Tag('ON TIME'), SizedBox(height: 10),
        DataLine('Freight Train', '#TF-402'),
        DataLine('Origin Terminal', 'Mojo Hub (ET)'),
        DataLine('Maritime Port', 'Nagad / Doraleh (DJ)'),
        DataLine('Departure', 'Tonight 22:30 EAT'),
        DataLine('Platform', '3B'),
        DataLine('Wagon', '#EDR-W-4402'),
        DataLine('Transit Time', '14h', valueColor: paleAmber),
        DataLine('Cost Savings', '-34%', valueColor: mint),
        DataLine('Carbon Saved', '-2.8 MT', valueColor: mint),
      ]),
      const DashboardCard(title: 'Handover Checklist', children: [
        Tag('4 of 4 Ready'), SizedBox(height: 10),
        DataLine('Truck Scale Out Tare Weight', 'CLEARED', valueColor: mint),
        DataLine('Container Twist-Lock Inspection', 'LOCKED', valueColor: mint),
        DataLine('ASYCUDA Rail Waybill Transfer', 'STAMPED', valueColor: mint),
        DataLine('EDR Intermodal Escrow Release', 'SECURED', valueColor: mint),
      ]),
      const PrimaryAction('Confirm Road-to-Rail Handover & Seal Bill of Lading'),
      const PrimaryAction('Track EDR Train Telemetry'),

    ],
  );
}

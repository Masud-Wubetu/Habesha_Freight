import 'package:flutter/material.dart';
import 'ui.dart';

class Page37 extends StatelessWidget {
  const Page37({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 37, title: 'Weighbridge Telemetry And Axle Load', children: [
      const Intro(page: 37, heading: 'Weighbridge & Axle Load Telemetry', description: 'Automated dynamic weigh-in-motion (WIM), permissible gross vehicle weight (GVW), axle distribution telemetry, and statutory compliance certification.', status: 'ERA Synced'),

      const DashboardCard(title: 'Modjo Expressway · Station #WB-04', children: [
        Tag('LEGAL & COMPLIANT'), SizedBox(height: 12),
        DataLine('Vehicle Plate', 'ET-3-8821 AA', valueColor: paleAmber),
        DataLine('Scale Time', '15:42 EAT'),
        DataLine('Speed (WIM)', '8 km/h'),
        DataLine('Gross Vehicle Weight', '47,400 / 48,000 kg'),
        SizedBox(height: 9), Gauge(.9875), SizedBox(height: 8),
        DataLine('Within Statutory Allowance', '98.8%', valueColor: mint),
        DataLine('Weight Margin', '+600 kg Safe', valueColor: paleAmber),
      ]),
      const DashboardCard(title: 'Chassis Load Telemetry', children: [
        Center(child: Icon(Icons.local_shipping_outlined, color: mint, size: 95)),
        DataLine('Steer Single Axle', '6,200 kg', valueColor: mint),
        Gauge(.775), SizedBox(height: 12),
        DataLine('Drive Tandem Axles', '17,400 kg', valueColor: mint),
        Gauge(.966), SizedBox(height: 12),
        DataLine('Semi-Trailer Tridem Group', '23,800 kg', valueColor: mint),
        Gauge(.991),
      ]),
      const DashboardCard(title: 'Statutory Weight Certificate', children: [
        Tag('VALIDATED'), SizedBox(height: 10),
        DataLine('Digital ERA Slip', '#ERA-WB-2024-9941'),
        DataLine('Station Officer', 'Insp. Hailu Girma'),
        DataLine('Statutory Fine / Penalty', 'ETB 0.00', valueColor: mint),
        DataLine('ERA Electronic Seal', 'Active', valueColor: mint),
      ]),
      const PrimaryAction('Transmit Certificate to Rig Driver'),
      const PrimaryAction('Export Official ERA Weighbridge Slip'),

    ],
  );
}

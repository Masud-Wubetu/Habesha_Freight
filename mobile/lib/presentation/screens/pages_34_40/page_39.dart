import 'package:flutter/material.dart';
import 'ui.dart';

class Page39 extends StatelessWidget {
  const Page39({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 39, title: 'Cold Chain & Hazmat Telemetry', children: [
      const Intro(page: 39, heading: 'Cold Chain & Hazmat Telemetry', description: 'Real-time thermal monitoring, reefer compressor diagnostics, pharma/perishables threshold auditing, and hazardous materials containment compliance.', status: 'IoT Sensors Active · 24/24 Linked'),

      const DashboardCard(title: 'Reefer Cargo #CC-8842', children: [
        Text('Pharmaceutical Vaccines & Horticulture', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), DataLine('Route', 'Addis Ababa → Djibouti'),
        DataLine('Carrier', 'ET-3-9942'), DataLine('Security', 'Secured', valueColor: mint),
      ]),
      const DashboardCard(title: 'Optimal Range (Zone A)', children: [
        Center(child: Text('-19.4°C', style: TextStyle(fontSize: 42, color: mint, fontWeight: FontWeight.bold))),
        DataLine('Target', '-20.0°C ± 1.5°C'),
        DataLine('Excursion Margin', '+0.6°C Safe', valueColor: mint),
        DataLine('External Heat Index', '+34.2°C'),
        SizedBox(height: 12), Text('Continuous Modulated Compressor'), Gauge(.84),
        DataLine('Compressor Duty Cycle', '84%', valueColor: mint),
      ]),
      const DashboardCard(title: 'Multi-Zone Thermal Array', children: [
        DataLine('Zone 1 · Nose / Evaporator', '-19.8°C', valueColor: mint),
        DataLine('Zone 2 · Core Pallet Middle', '-19.4°C', valueColor: mint),
        DataLine('Zone 3 · Rear Door', '-18.7°C', valueColor: mint),
        DataLine('Humidity Level', '62% RH'),
        DataLine('Seal Integrity', '0 Open Events', valueColor: mint),
      ]),
      const DashboardCard(title: '6-Hour Micro-Thermal Trend', children: [
        Tag('Zero Excursions'), SizedBox(height: 12),
        Icon(Icons.show_chart, size: 95, color: mint),
        DataLine('WHO GDP & EFDA Verified', '0 Excursions', valueColor: mint),
      ]),
      const DashboardCard(title: 'Dangerous Goods / Hazmat', children: [
        DataLine('UN Classification', 'UN 1845'),
        DataLine('Class 9', 'Solid Carbon Dioxide'),
        DataLine('CO₂ Leak', '0.0 ppm', valueColor: mint),
        DataLine('Emergency Scrubbers', 'Armed & Ready', valueColor: paleAmber),
      ]),
      const PrimaryAction('Export Certified Cold Chain Audit Slip'),

    ],
  );
}

import 'package:flutter/material.dart';
import 'ui.dart';

class Page34 extends StatelessWidget {
  const Page34({super.key});
  @override
  Widget build(BuildContext context) => FreightShell(
    page: 34, title: 'Freight Company Analytics', children: [
      const Intro(page: 34, heading: 'Freight Analytics', description: 'Corridor profitability, fuel economy benchmarks, driver turnaround times, and revenue growth across federal transit arteries.', status: 'Monthly Report: Oct 2024'),

      DashboardCard(children: [
        const Text('MONTHLY FLEET REVENUE', style: TextStyle(fontSize: 11, color: muted, letterSpacing: 1)),
        const SizedBox(height: 8), const Text('ETB 4,820,500.00', style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
        const SizedBox(height: 7), const Tag('↗ +24.8% MoM'), const Divider(height: 26),
        const DataLine('Net Operating Margin', '38.6%', valueColor: mint),
        const DataLine('Net Contribution', 'ETB 1,860,700'),
        const SizedBox(height: 14), const Text('Operating Expense Allocation', style: TextStyle(fontSize: 12, color: muted)),
        const SizedBox(height: 9), const Gauge(.80, color: amber),
        const DataLine('Diesel · 42%  |  Wages · 18%', '80% Direct Cost'),
        const DataLine('Maintenance · 12%', 'Customs · 8%'),
      ]),
      const SectionHeading('Corridor Benchmarks', Icons.alt_route),
      const DashboardCard(title: 'Addis Ababa → Djibouti Port', children: [
        Tag('Highest Yield'), SizedBox(height: 10),
        DataLine('Djibouti Mainline Freight Pipeline', '42 Trips · 1,512 MT'),
        DataLine('Average Revenue / Trip', 'ETB 142,000', valueColor: paleAmber),
        DataLine('Corridor Fleet Speed', '62 km/h'),
        DataLine('Mean Turnaround', '54 Hours', valueColor: mint),
      ]),
      const DashboardCard(title: 'Addis Ababa → Mekelle', children: [
        DataLine('Northern Relief & Commercial Trunk', '28 Trips · 896 MT'),
        DataLine('Average Revenue', 'ETB 78,000', valueColor: paleAmber),
        DataLine('Turnaround', '42 hrs'),
      ]),
      const DashboardCard(title: 'Addis Ababa → Hawassa SEZ', children: [
        DataLine('Hawassa Industrial Park Expressway', '18 Trips · 576 MT'),
        DataLine('Average Revenue', 'ETB 44,500'),
        DataLine('Turnaround', '18 hrs', valueColor: mint),
      ]),
      const SectionHeading('Monthly Leaders', Icons.emoji_events_outlined),
      const DashboardCard(title: 'ET-3-8821 · Scania R500', children: [
        DataLine('Gross Yield', 'ETB 1.48M', valueColor: mint),
        DataLine('Completed Corridors', '12'),
        DataLine('Fleet Uptime', '99.4%'),
      ]),
      const DashboardCard(title: 'Kassahun Tadesse', children: [
        DataLine('Driver Score', '4.98', valueColor: paleAmber),
        DataLine('On-Time Deliveries', '100%'),
      ]),
      const PrimaryAction('Export Audited IFRS Financial Report (PDF/Excel)'),

    ],
  );
}

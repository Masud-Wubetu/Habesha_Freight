import 'package:flutter/material.dart';

const navy = Color(0xFF061426);
const surface = Color(0xFF132033);
const surfaceLow = Color(0xFF0E1C2F);
const surfaceDeep = Color(0xFF020E21);
const amber = Color(0xFFF59E0B);
const paleAmber = Color(0xFFFFC174);
const mint = Color(0xFF4EDEA3);
const muted = Color(0xFFD8C3AD);

class FreightShell extends StatelessWidget {
  final int page;
  final String title;
  final List<Widget> children;
  const FreightShell({super.key, required this.page, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: navy,
    appBar: AppBar(
      toolbarHeight: 66, backgroundColor: navy, foregroundColor: Colors.white,
      leading: const Padding(padding: EdgeInsets.all(12), child: DecoratedBox(
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Icon(Icons.local_shipping_outlined, color: amber))),
      titleSpacing: 0,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('NOCTURNE CORRIDOR', style: TextStyle(fontSize: 10, color: paleAmber, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ]),
      actions: [IconButton(onPressed: () => notice(context, 'Notifications demo'), icon: const Icon(Icons.notifications_none)),
        const Padding(padding: EdgeInsets.only(right: 12), child: CircleAvatar(radius: 17, backgroundColor: amber,
          child: Icon(Icons.verified_user_outlined, color: navy, size: 20)))],
    ),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 26), children: children,
    ))),
    bottomNavigationBar: SafeArea(top: false, child: Container(
      color: surfaceDeep, padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(children: [
        for (final n in [34, 35, 36, 37, 38, 39, 40]) Expanded(child: InkWell(
          onTap: () { if (n != page) Navigator.pushReplacementNamed(context, '/$n'); },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_icon(n), size: 21, color: n == page ? amber : muted),
            const SizedBox(height: 3), Text('$n', style: TextStyle(fontSize: 10, color: n == page ? amber : muted)),
          ]),
        )),
      ]),
    )),
  );
}
IconData _icon(int n) { switch (n) {
  case 34: return Icons.analytics_outlined;
  case 35: return Icons.description_outlined;
  case 36: return Icons.verified_user_outlined;
  case 37: return Icons.scale_outlined;
  case 38: return Icons.policy_outlined;
  case 39: return Icons.ac_unit;
  default: return Icons.train_outlined;
}}
void notice(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

class DashboardCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const DashboardCard({super.key, this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 13)],
      ...children,
    ]),
  );
}
class DataLine extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const DataLine(this.label, this.value, {super.key, this.valueColor = Colors.white});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
    Expanded(flex: 5, child: Text(label, style: const TextStyle(fontSize: 12, color: muted))),
    const SizedBox(width: 8), Expanded(flex: 5, child: Text(value, textAlign: TextAlign.right,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor))),
  ]));
}
class Tag extends StatelessWidget {
  final String text; final Color color;
  const Tag(this.text, {super.key, this.color = mint});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(30)),
    child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
  );
}
class Intro extends StatelessWidget {
  final int page; final String heading, description; final String? status;
  const Intro({super.key, required this.page, required this.heading, required this.description, this.status});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 6, children: [Tag('PAGE $page: ${heading.toUpperCase()}', color: paleAmber), if (status != null) Tag(status!)]),
      const SizedBox(height: 10), Text(description, style: const TextStyle(fontSize: 13, color: muted, height: 1.5)),
    ],
  ));
}
class PrimaryAction extends StatelessWidget {
  final String text;
  const PrimaryAction(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SizedBox(
    width: double.infinity, child: FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: amber, foregroundColor: navy, padding: const EdgeInsets.all(17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: () => notice(context, '$text — demonstration only'),
      icon: const Icon(Icons.arrow_forward), label: Text(text, textAlign: TextAlign.center),
    ),
  ));
}
class SectionHeading extends StatelessWidget {
  final String title; final IconData icon;
  const SectionHeading(this.title, this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(2, 12, 2, 12), child: Row(children: [
    Icon(icon, color: paleAmber, size: 21), const SizedBox(width: 8),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
  ]));
}
class Gauge extends StatelessWidget {
  final double value; final Color color;
  const Gauge(this.value, {super.key, this.color = mint});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(
    minHeight: 8, value: value.clamp(0, 1), backgroundColor: const Color(0xFF28354A), color: color,
  ));
}

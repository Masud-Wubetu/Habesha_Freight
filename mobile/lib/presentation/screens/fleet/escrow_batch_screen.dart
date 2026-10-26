import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/escrow_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/widgets/navigation/corridor_navigation_sheet.dart';
import 'package:mobile/presentation/widgets/nocturne/hf_card.dart';
import 'package:mobile/presentation/widgets/nocturne/page_ribbon.dart';

/// PAGE 31 — Fleet Escrow Settlements & Batch Disbursements (tab shell).
class EscrowBatchScreen extends StatefulWidget {
  const EscrowBatchScreen({super.key});

  @override
  State<EscrowBatchScreen> createState() => _EscrowBatchScreenState();
}

class _EscrowBatchScreenState extends State<EscrowBatchScreen> {
  final _escrow = EscrowService();
  int _filter = 0;
  final Set<String> _selected = {};
  bool _loading = true;
  bool _live = false;
  String? _error;
  EscrowLedgerSummary? _ledger;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ledger = await _escrow.getLedger();
      if (!mounted) return;
      setState(() {
        _ledger = ledger;
        _live = true;
        _loading = false;
        _selected
          ..clear()
          ..addAll(
            ledger.items
                .where((i) =>
                    i.status == 'LOCKED' ||
                    i.status == 'HELD' ||
                    i.status == 'PENDING')
                .take(2)
                .map((i) => i.id),
          );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _live = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to sync escrow ledger';
        _live = false;
        _loading = false;
      });
    }
  }

  String _etb(num n) =>
      NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2).format(n);

  bool _disbursing = false;

  Future<void> _disburseSelected() async {
    if (!_live || _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select ledger rows ready to settle first.'),
          backgroundColor: AppColors.surfaceBright,
        ),
      );
      return;
    }

    setState(() => _disbursing = true);
    final selectedItems = (_ledger?.items ?? const <EscrowItem>[])
        .where((i) => _selected.contains(i.id))
        .toList();
    var released = 0;
    var denied = 0;
    String? lastError;

    for (final item in selectedItems) {
      final shipmentId = item.shipmentId;
      if (shipmentId.isEmpty) continue;
      try {
        await _escrow.release(shipmentId);
        released++;
      } on ApiException catch (e) {
        lastError = e.message;
        if (e.statusCode == 403 || e.statusCode == 401) {
          denied++;
        }
      } catch (_) {
        lastError = 'Release failed';
      }
    }

    if (!mounted) return;
    setState(() => _disbursing = false);

    final sum = selectedItems.fold<double>(0, (a, b) => a + b.netPayout);
    final String message;
    if (released > 0) {
      message = 'Released $released escrow row(s) · ${_etb(sum)}.';
      await _load();
    } else if (denied > 0) {
      message =
          'Escrow release is shipper/admin-only. ${_etb(sum)} stays locked — fleet views the ledger; shipper releases payout.';
    } else {
      message = lastError ??
          '${_etb(sum)} queued for ${_selected.length} selected rows (simulated).';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceBright,
      ),
    );
  }

  List<EscrowItem> get _filteredItems {
    final items = _ledger?.items ?? const <EscrowItem>[];
    switch (_filter) {
      case 1:
        return items
            .where((i) =>
                i.status == 'LOCKED' ||
                i.status == 'HELD' ||
                i.status == 'PENDING')
            .toList();
      case 2:
        return items.where((i) => i.status == 'RELEASED').toList();
      case 3:
        return items.where((i) => i.status == 'REFUNDED').toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ledger = _ledger;
    final allCount = ledger?.items.length ?? 19;
    final readyCount = ledger?.items
            .where((i) =>
                i.status == 'LOCKED' ||
                i.status == 'HELD' ||
                i.status == 'PENDING')
            .length ??
        14;
    final releasedCount =
        ledger?.items.where((i) => i.status == 'RELEASED').length ?? 88;
    final refundedCount =
        ledger?.items.where((i) => i.status == 'REFUNDED').length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryContainer,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    PageRibbon(
                      page: '31',
                      title: 'FLEET ESCROW SETTLEMENTS',
                      status: _live
                          ? 'Ledger API • ${ledger!.items.length} entries'
                          : 'CBE & Telebirr Vault • Verified',
                      textColor: AppColors.primary,
                      dotColor: AppColors.secondary,
                    ),
                    if (_loading || _error != null) ...[
                      const SizedBox(height: 8),
                      _EscrowStatusBanner(
                        loading: _loading,
                        live: _live,
                        error: _error,
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Institutional multi-trip escrow disbursement ledger, automated withholding tax, and bulk driver payouts.',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _HeroEscrowCard(
                      totalLocked: ledger?.totalLocked ?? 1482500,
                      totalReleased: ledger?.totalReleased ?? 1120000,
                      totalRefunded: ledger?.totalRefunded ?? 0,
                      live: _live,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _disbursing
                            ? null
                            : () {
                                if (_live) {
                                  _disburseSelected();
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ETB 211,055 disbursed across selected drivers via CBE Birr Bulk API.',
                                    ),
                                    backgroundColor: AppColors.surfaceBright,
                                  ),
                                );
                              },
                        icon: _disbursing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.bolt, size: 20),
                        label: Text(
                          _disbursing
                              ? 'Submitting release…'
                              : _live
                                  ? 'Disburse Batch Payout (${_selected.length} selected) →'
                                  : 'Disburse Batch Payout (14 Completed Trips) →',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance, size: 15, color: AppColors.primary),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Instant settlement via CBE Birr Bulk API & Telebirr Business Wallet',
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(0, 'All ($allCount)'),
                          _filterChip(1, 'Ready to Settle ($readyCount)'),
                          _filterChip(2, 'Disbursed ($releasedCount)'),
                          _filterChip(3, 'Refunded ($refundedCount)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Active Settlement Queue',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            children: [
                              const TextSpan(text: 'Selected: '),
                              TextSpan(
                                text: '${_selected.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: ' of ${_filteredItems.isEmpty ? 3 : _filteredItems.length}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_live) ...[
                      if (_filteredItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No escrow rows for this filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        )
                      else
                        ..._filteredItems.map((item) {
                          final short = item.id.length > 6
                              ? item.id.substring(0, 6)
                              : item.id;
                          final route =
                              '${item.origin ?? '—'} ➔ ${item.destination ?? '—'}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SettlementCard(
                              id: item.id,
                              req: '#${item.shipmentId.isEmpty ? short : item.shipmentId.substring(0, item.shipmentId.length.clamp(0, 8))}',
                              statusLabel: '${item.status} • Escrow ledger',
                              statusColor: item.status == 'RELEASED'
                                  ? AppColors.secondary
                                  : AppColors.primaryContainer,
                              statusIcon: item.status == 'RELEASED'
                                  ? Icons.check_circle
                                  : Icons.lock,
                              route: route,
                              cargo: item.cargo ?? 'Freight',
                              driver: item.carrierName ?? 'Carrier',
                              rig: item.gatewayReference ?? '—',
                              gross: _etb(item.grossAmount),
                              lines: [
                                (
                                  'Platform commission',
                                  '-${_etb(item.commission)}',
                                ),
                              ],
                              net: _etb(item.netPayout),
                              payoutHint: item.status == 'RELEASED'
                                  ? 'Released'
                                  : 'Simulated escrow hold',
                              selected: _selected.contains(item.id),
                              onToggle: () => _toggle(item.id),
                            ),
                          );
                        }),
                    ] else ...[
                      _SettlementCard(
                        id: '9840',
                        req: '#REQ-9840',
                        statusLabel: 'e-POD Verified • Escrow Unlocked',
                        statusColor: AppColors.secondary,
                        statusIcon: Icons.check_circle,
                        route: 'Addis Ababa ➔ Mekelle',
                        cargo: '(32T Bulk)',
                        driver: 'Dawit Wolde',
                        rig: 'ET-3-4412',
                        gross: 'ETB 76,000.00',
                        lines: const [
                          ('Habesha 2.5% Commission', '-ETB 1,900.00'),
                          ('MoR Withholding Tax (2.0%)', '-ETB 1,520.00'),
                        ],
                        net: 'ETB 72,580.00',
                        payoutHint: 'Telebirr Wallet Ready',
                        selected: _selected.contains('9840'),
                        onToggle: () => _toggle('9840'),
                      ),
                      const SizedBox(height: 12),
                      _SettlementCard(
                        id: '9912',
                        req: '#REQ-9912',
                        statusLabel: 'Customs Gate Out Confirmed • Escrow Unlocked',
                        statusColor: AppColors.secondary,
                        statusIcon: Icons.verified,
                        route: 'Mojo ➔ Doraleh Port, DJ',
                        cargo: '(36T Sesame)',
                        driver: 'Kassahun Tadesse',
                        rig: 'ET-3-8821',
                        gross: 'ETB 145,000.00',
                        lines: const [
                          ('Platform & MoR Deductions', '-ETB 6,525.00'),
                        ],
                        net: 'ETB 138,475.00',
                        payoutHint: 'CBE Direct Account',
                        selected: _selected.contains('9912'),
                        onToggle: () => _toggle('9912'),
                      ),
                      const SizedBox(height: 12),
                      const _PendingSettlementCard(),
                    ],
                    const SizedBox(height: 16),
                    const _TaxAccrualCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Widget _header() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fleet Escrow Settlements & Batch Disbursements',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => CorridorNavigationSheet.show(context),
            icon: const Icon(Icons.grid_view_rounded, size: 20),
            color: AppColors.primaryContainer,
            tooltip: 'All Corridor Modules',
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            icon: const Icon(Icons.storefront_outlined, size: 20),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Shipper Portal',
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 20),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Refresh ledger',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 20),
            color: AppColors.onSurfaceVariant,
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 18, color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(int index, String label) {
    final selected = _filter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => _filter = index),
        label: Text(label),
        selectedColor: AppColors.primaryContainer,
        backgroundColor: AppColors.surfaceContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
        ),
        showCheckmark: false,
      ),
    );
  }
}

class _EscrowStatusBanner extends StatelessWidget {
  const _EscrowStatusBanner({
    required this.loading,
    required this.live,
    this.error,
  });

  final bool loading;
  final bool live;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LinearProgressIndicator(
        color: AppColors.primaryContainer,
        backgroundColor: AppColors.surfaceHigh,
      );
    }
    if (error == null) return const SizedBox.shrink();
    return HfCard(
      color: AppColors.surfaceLow,
      child: Text(
        live ? 'Live ledger' : 'Design preview — $error',
        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _HeroEscrowCard extends StatelessWidget {
  const _HeroEscrowCard({
    required this.totalLocked,
    required this.totalReleased,
    required this.totalRefunded,
    this.live = false,
  });

  final double totalLocked;
  final double totalReleased;
  final double totalRefunded;
  final bool live;

  String _fmt(num n) =>
      NumberFormat.currency(symbol: '', decimalDigits: 2).format(n);

  @override
  Widget build(BuildContext context) {
    return HfCard(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL UNSETTLED FLEET ESCROW',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      live ? Icons.cloud_done : Icons.trending_up,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      live ? 'Live ledger' : '+18.4% vs last week',
                      style: const TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'ETB ',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: _fmt(totalLocked),
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.26,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SplitMetric(
                  label: 'Ready for Instant Payout',
                  value: 'ETB ${_fmt(totalReleased > 0 ? totalReleased : totalLocked)}',
                  valueColor: AppColors.secondary,
                  hint: live ? 'From escrow ledger API' : '14 trips verified e-POD',
                  hintIcon: Icons.verified,
                  hintColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SplitMetric(
                  label: live ? 'Refunded / Held Back' : 'Pending Inspection',
                  value: 'ETB ${_fmt(live ? totalRefunded : 362500)}',
                  valueColor: AppColors.primary,
                  hint: live ? 'Refunded ledger total' : '5 trips in transit',
                  hintIcon: Icons.hourglass_top,
                  hintColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitMetric extends StatelessWidget {
  const _SplitMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.hint,
    required this.hintIcon,
    required this.hintColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String hint;
  final IconData hintIcon;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(hintIcon, size: 14, color: hintColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hint,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.id,
    required this.req,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.route,
    required this.cargo,
    required this.driver,
    required this.rig,
    required this.gross,
    required this.lines,
    required this.net,
    required this.payoutHint,
    required this.selected,
    required this.onToggle,
  });

  final String id;
  final String req;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final String route;
  final String cargo;
  final String driver;
  final String rig;
  final String gross;
  final List<(String, String)> lines;
  final String net;
  final String payoutHint;
  final bool selected;
  final VoidCallback onToggle;

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
                      runSpacing: 4,
                      children: [
                        Text(
                          req,
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 13, color: statusColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(fontSize: 10, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        children: [
                          TextSpan(text: route),
                          TextSpan(
                            text: ' $cargo',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 18, color: AppColors.onPrimaryContainer)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(driver, style: const TextStyle(fontSize: 12, color: AppColors.onSurface)),
              const SizedBox(width: 16),
              const Icon(Icons.local_shipping, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                rig,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _moneyRow('Gross Freight Rate', gross, AppColors.onSurface),
                ...lines.map((l) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _moneyRow(l.$1, l.$2, AppColors.error, small: true),
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Driver Payable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        net,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text('Settle Individual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
              Text(
                payoutHint,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(String label, String value, Color valueColor, {bool small = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: small ? 11 : 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 11 : 12,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _PendingSettlementCard extends StatelessWidget {
  const _PendingSettlementCard();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: HfCard(
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
                        runSpacing: 4,
                        children: [
                          Text(
                            '#REQ-9945',
                            style: GoogleFonts.robotoMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.navigation, size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'In Transit • Geofence Arrival 88%',
                                  style: TextStyle(fontSize: 10, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          children: const [
                            TextSpan(text: 'Kaliti ➔ Dire Dawa'),
                            TextSpan(
                              text: ' (40T Steel)',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock, size: 16, color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.onSurfaceVariant),
                SizedBox(width: 4),
                Text('Mekonnen Haile', style: TextStyle(fontSize: 12, color: AppColors.onSurface)),
                SizedBox(width: 16),
                Icon(Icons.local_shipping, size: 16, color: AppColors.onSurfaceVariant),
                SizedBox(width: 4),
                Text(
                  'ET-3-7714',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gross Freight Value', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      Text(
                        'ETB 115,000.00',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.shield, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Escrow locked until Destination Offloading Scan',
                          style: TextStyle(fontSize: 11, color: AppColors.primary),
                        ),
                      ),
                      Text(
                        'ETA: 2h 15m',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxAccrualCard extends StatelessWidget {
  const _TaxAccrualCard();

  @override
  Widget build(BuildContext context) {
    return HfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MOR TAX WITHHOLDING ACCRUAL',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'ETB 29,650.00',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Automated (2%)',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pre-cleared with Ethiopian Ministry of Revenues gateway. Compliant with Freight Haulage Tax Directive #882/2023.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('MoR Electronic e-Tax Withholding Slip downloaded successfully.'),
                    backgroundColor: AppColors.surfaceBright,
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceHigh,
                foregroundColor: AppColors.onSurface,
              ),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Electronic Tax Certificate (PDF)'),
            ),
          ),
        ],
      ),
    );
  }
}

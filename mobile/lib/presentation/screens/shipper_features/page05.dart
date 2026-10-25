import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipper_escrow/active_escrow_hero_card.dart';
import '../../widgets/shipper_escrow/consignment_escrow_card.dart';
import '../../widgets/shipper_escrow/escrow_status_filter_tabs.dart';
import '../../widgets/shipper_escrow/pod_otp_release_modal.dart';
import '../../widgets/shipper_escrow/shipper_escrow_header.dart';

class ShipperEscrowVaultScreen extends StatefulWidget {
  final List<ConsignmentEscrowItem>? initialConsignments;

  const ShipperEscrowVaultScreen({super.key, this.initialConsignments});

  @override
  State<ShipperEscrowVaultScreen> createState() => _ShipperEscrowVaultScreenState();
}

class _ShipperEscrowVaultScreenState extends State<ShipperEscrowVaultScreen> {
  final CorridorService _corridorService = CorridorService();
  String _selectedLanguage = 'EN';
  int _activeTabIndex = 0; // 0: Active Escrow, 1: Invoices, 2: Disputes
  double _activeLockedAmount = 0.0;
  double _releasedThisMonth = 0.0;
  List<ConsignmentEscrowItem> _consignments = [];
  bool _loading = false;
  String _userName = 'Shipper';

  @override
  void initState() {
    super.initState();
    if (widget.initialConsignments != null) {
      _consignments = List.from(widget.initialConsignments!);
      _recalculateBalances();
    } else {
      _loadEscrow();
    }
  }

  void _recalculateBalances() {
    double locked = 0.0;
    double released = 0.0;
    for (final c in _consignments) {
      if (c.status == EscrowCardStatus.settled) {
        released += c.amountEtb;
      } else {
        locked += c.amountEtb;
      }
    }
    setState(() {
      _activeLockedAmount = locked;
      _releasedThisMonth = released;
    });
  }

  Future<void> _loadEscrow() async {
    setState(() => _loading = true);
    final user = await StorageService.getUserName();
    final realShipments = await _corridorService.fetchRealShipments();

    final List<ConsignmentEscrowItem> items = [];
    double locked = 0.0;
    double released = 0.0;

    for (final s in realShipments) {
      final amt = (s['offered_price_etb'] is num)
          ? (s['offered_price_etb'] as num).toDouble()
          : 38000.0;
      final rawStatus = (s['status'] ?? 'IN_TRANSIT').toString().toUpperCase();
      final isSettled = rawStatus == 'DELIVERED';
      if (isSettled) {
        released += amt;
      } else {
        locked += amt;
      }
      final rawId = s['id']?.toString() ?? '1';
      final idSuffix = rawId.length > 4 ? rawId.substring(0, 4) : rawId.padLeft(4, '0');
      items.add(
        ConsignmentEscrowItem(
          id: '#HF-$idSuffix',
          escrowProvider: 'Telebirr Escrow',
          amountEtb: amt,
          status: isSettled ? EscrowCardStatus.settled : EscrowCardStatus.inTransit,
          origin: s['origin_city']?.toString() ?? 'Addis Ababa',
          destination: s['destination_city']?.toString() ?? 'Djibouti',
          carrierName: s['carrier_name']?.toString() ?? 'Assigned Carrier',
          telemetryText: isSettled ? 'Delivered & Settled' : 'Active Corridor Transit',
          cargoDetails: s['cargo_description']?.toString() ?? 'Commercial Freight',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _consignments = items;
        _activeLockedAmount = locked;
        _releasedThisMonth = released;
        _userName = user ?? 'Shipper';
        _loading = false;
      });
    }
  }

  void _handleLanguageTap(String lang) {
    setState(() => _selectedLanguage = lang);
  }

  void _onTabSelected(int idx) {
    setState(() => _activeTabIndex = idx);
  }

  void _showTaxInvoiceModal(ConsignmentEscrowItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Tax Invoice',
                            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          Text(
                            item.taxInvoiceNo ?? 'INV-2026-NBE-${item.id.replaceAll('#HF-', '')}',
                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ERCA CERTIFIED',
                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF6EE7B7)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF091220),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Column(
                  children: [
                    _invoiceRow('Carrier / Transporter', item.carrierName),
                    const Divider(height: 16, color: Color(0xFF1E2E48)),
                    _invoiceRow('Cargo Corridor Route', '${item.origin} ➔ ${item.destination}'),
                    const Divider(height: 16, color: Color(0xFF1E2E48)),
                    _invoiceRow('Gross Freight Amount', '${item.amountEtb.toStringAsFixed(0)} ETB'),
                    const Divider(height: 16, color: Color(0xFF1E2E48)),
                    _invoiceRow('Withholding Tax (2% MOR)', '-${(item.amountEtb * 0.02).toStringAsFixed(0)} ETB', valueColor: const Color(0xFFF59E0B)),
                    const Divider(height: 16, color: Color(0xFF1E2E48)),
                    _invoiceRow('Net Carrier Settlement Paid', '${(item.amountEtb * 0.98).toStringAsFixed(0)} ETB', isBold: true, valueColor: const Color(0xFF10B981)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tax invoice downloaded for tax filing.'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text('Download Certified PDF Invoice', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF0B1321),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleEnterPodOtp(ConsignmentEscrowItem item) {
    PodOtpReleaseModal.show(
      context,
      item: item,
      onConfirmedRelease: (otpCode) {
        setState(() {
          final idx = _consignments.indexWhere((c) => c.id == item.id);
          if (idx != -1) {
            _consignments[idx] = ConsignmentEscrowItem(
              id: item.id,
              escrowProvider: item.escrowProvider,
              amountEtb: item.amountEtb,
              status: EscrowCardStatus.settled,
              origin: item.origin,
              destination: item.destination,
              carrierName: item.carrierName,
              telemetryText: 'POD Verified with OTP ($otpCode) · Settled to Carrier',
              cargoDetails: item.cargoDetails,
              taxInvoiceNo: 'INV-2026-NBE-${item.id.replaceAll('#HF-', '')}',
            );
            _activeLockedAmount = (_activeLockedAmount - item.amountEtb).clamp(0.0, double.infinity);
            _releasedThisMonth += item.amountEtb;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.amountEtb.toStringAsFixed(0)} ETB released to ${item.carrierName}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  void _handleManageVaults() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settlement Vault Configurations',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Instant payout channels authorized under National Bank of Ethiopia directive.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Telebirr Business: Active · Auto-Release Ready', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Digital Escrow Auto-Settlement', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CBE Birr Transit: Active · Interbank Settlement', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Direct Commercial Bank of Ethiopia Integration', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPostLoadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostLoadSheet(
        corridorService: _corridorService,
        onPosted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Load Posted Successfully! Escrow reserved in vault.'),
              backgroundColor: AppColors.gold,
            ),
          );
          _loadEscrow();
        },
      ),
    );
  }

  void _handleProfileTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF0F172A), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Habesha Freight Logistics',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                title: Text('Shipper Dashboard', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined, color: AppColors.gold),
                title: Text('My Shipments', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.page08MyShipments);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text('Sign Out', style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await StorageService.clearAuthData();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (r) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsignmentsList() {
    List<ConsignmentEscrowItem> items;
    if (_activeTabIndex == 0) {
      items = _consignments.where((c) => c.status != EscrowCardStatus.settled).toList();
    } else if (_activeTabIndex == 1) {
      items = _consignments.where((c) => c.status == EscrowCardStatus.settled).toList();
    } else {
      items = [];
    }

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1628),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E2E48)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.badgeAmberBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.badgeAmberBorder),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.gold,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _activeTabIndex == 2
                  ? 'Zero Disputes'
                  : (_activeTabIndex == 1 ? 'No Settled Invoices' : 'No Active Escrow'),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _activeTabIndex == 2
                  ? 'All freight consignments are operating smoothly with no disputed settlements.'
                  : (_activeTabIndex == 1
                      ? 'Completed shipments with official tax invoices will appear here.'
                      : 'Funds are securely locked in CBE / Telebirr escrow when a carrier accepts your load.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
            if (_activeTabIndex == 0) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openPostLoadSheet,
                icon: const Icon(Icons.add_box_rounded, size: 16),
                label: const Text('Post Cargo Load'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return ConsignmentEscrowCard(
          item: item,
          onEnterPodOtp: () => _handleEnterPodOtp(item),
          onViewInvoice: () => _showTaxInvoiceModal(item),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _consignments.where((c) => c.status != EscrowCardStatus.settled).length;
    final settledCount = _consignments.where((c) => c.status == EscrowCardStatus.settled).length;

    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadEscrow,
          color: AppColors.gold,
          backgroundColor: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShipperEscrowHeader(
                  language: _selectedLanguage,
                  onLanguageChanged: _handleLanguageTap,
                  onProfileTap: _handleProfileTap,
                ),
                const SizedBox(height: 16),

                // Active Escrow Locked Hero Card
                ActiveEscrowHeroCard(
                  activeLockedAmount: _activeLockedAmount,
                  releasedThisMonth: _releasedThisMonth,
                  activeConsignmentsCount: activeCount,
                  onManageVaults: _handleManageVaults,
                ),
                const SizedBox(height: 16),

                // Status Filter Tabs (Active Escrow, Invoices, Disputes)
                EscrowStatusFilterTabs(
                  selectedIndex: _activeTabIndex,
                  onTabSelected: _onTabSelected,
                  activeEscrowCount: activeCount,
                  invoicesCount: settledCount,
                  disputesCount: 0,
                ),
                const SizedBox(height: 16),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else
                  _buildConsignmentsList(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 3,
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page08MyShipments);
          } else if (idx == 2) {
            _openPostLoadSheet();
          } else if (idx != 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
    );
  }
}

// Aliases for page 05/21/22 semantic naming
typedef Page05Screen = ShipperEscrowVaultScreen;
typedef Page5Screen = ShipperEscrowVaultScreen;
typedef Page21Screen = ShipperEscrowVaultScreen;
typedef Page22Screen = ShipperEscrowVaultScreen;

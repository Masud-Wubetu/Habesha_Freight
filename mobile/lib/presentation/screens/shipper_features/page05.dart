import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/corridor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../../widgets/navigation/corridor_navigation_sheet.dart';
import '../../widgets/post_load/post_load_sheet.dart';
import '../../widgets/shipper_escrow/shipper_escrow_header.dart';
import '../../widgets/shipper_escrow/active_escrow_hero_card.dart';
import '../../widgets/shipper_escrow/escrow_status_filter_tabs.dart';
import '../../widgets/shipper_escrow/consignment_escrow_card.dart';
import '../../widgets/shipper_escrow/multi_consignment_batch_card.dart';
import '../../widgets/shipper_escrow/pod_otp_release_modal.dart';

class ShipperEscrowVaultScreen extends StatefulWidget {
  const ShipperEscrowVaultScreen({super.key});

  @override
  State<ShipperEscrowVaultScreen> createState() => _ShipperEscrowVaultScreenState();
}

class _ShipperEscrowVaultScreenState extends State<ShipperEscrowVaultScreen> {
  final CorridorService _corridorService = CorridorService();
  String _selectedLanguage = 'EN';
  int _activeTabIndex = 0; // 0: Active Escrow, 1: Invoices, 2: Disputes
  double _activeLockedAmount = 150000.0;
  double _releasedThisMonth = 890000.0;

  final List<ConsignmentEscrowItem> _consignments = [
    const ConsignmentEscrowItem(
      id: '#HF-9012',
      escrowProvider: 'Telebirr Escrow',
      amountEtb: 38000.0,
      status: EscrowCardStatus.inTransit,
      origin: 'Addis Ababa',
      destination: 'Dire Dawa',
      carrierName: 'Abyssinia Haulage #881',
      telemetryText: 'Awash Corridor · 62 km/h · ETA 3h 15m',
      cargoDetails: '40ft Container · Heavy Equipment',
    ),
    const ConsignmentEscrowItem(
      id: '#HF-8841',
      escrowProvider: 'CBE Birr Escrow',
      amountEtb: 18500.0,
      status: EscrowCardStatus.pendingPodOtp,
      origin: 'Addis Ababa',
      destination: 'Adama Dry Port',
      carrierName: 'Ethio Express Trucking',
      telemetryText: 'At Adama Gate 3 · Offloading proof uploaded',
      cargoDetails: '28 Tons Industrial Steel',
    ),
    const ConsignmentEscrowItem(
      id: '#HF-7720',
      escrowProvider: 'Telebirr Escrow',
      amountEtb: 42000.0,
      status: EscrowCardStatus.settled,
      origin: 'Hawassa Industrial Park',
      destination: 'Modjo Dry Port',
      carrierName: 'Selam Logistics PLC',
      telemetryText: 'Delivered & Verified · Settled on Oct 19, 2026',
      cargoDetails: 'Export Textiles & Apparel (22 Tons)',
      taxInvoiceNo: 'INV-2026-NBE-7720',
    ),
  ];

  void _handleLanguageTap(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  void _onTabSelected(int idx) {
    setState(() {
      _activeTabIndex = idx;
    });
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
                            item.taxInvoiceNo ?? 'INV-2026-NBE-7720',
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
                    child: Text('ERCA CERTIFIED', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF6EE7B7))),
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
                        content: Text('Tax invoice ${item.taxInvoiceNo} downloaded for tax filing.'),
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
            content: Text('${item.amountEtb.toStringAsFixed(0)} ETB released to ${item.carrierName} via ${item.escrowProvider}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  void _handleBatchFundTap() {
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
                children: [
                  const Icon(Icons.layers_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 10),
                  Text('Batch Fund Corridor Convoy', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lock multi-consignments for 3 heavy-haul rigs running the Addis Ababa ➔ Djibouti corridor.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF070D18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Column(
                  children: [
                    _invoiceRow('Convoy Rigs', '3 Multi-axle Semi-Trailers'),
                    const SizedBox(height: 8),
                    _invoiceRow('Total Bulk Escrow', '228,000 ETB', isBold: true, valueColor: AppColors.gold),
                    const SizedBox(height: 8),
                    _invoiceRow('Vault Payout Channel', 'Telebirr Business Tier 1'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _activeLockedAmount += 228000.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Convoy Batch of 228,000 ETB vaulted in Escrow successfully!'),
                        backgroundColor: AppColors.gold,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Confirm Batch Escrow Lock', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                ),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E48).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _activeTabIndex == 2 ? Icons.gavel_rounded : Icons.folder_open_rounded,
                color: _activeTabIndex == 2 ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _activeTabIndex == 2 ? 'Zero Active Disputes' : 'No Records Found',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _activeTabIndex == 2
                  ? 'All corridor shipments are operating under standard verified escrow and cargo insurance conditions.'
                  : 'There are currently no items under this escrow filter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF94A3B8),
                height: 1.35,
              ),
            ),
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
                        'Shipper Enterprise Account',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'TIN: 0092837102 · Verified Tier 1',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
                title: Text('Telebirr Merchant Vault: 894,200 ETB Available', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grid_view_rounded, color: AppColors.badgeGreenText),
                title: Text('Corridor Modules Hub', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  CorridorNavigationSheet.show(context);
                },
              ),
            ],
          ),
        ),
      ),
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
                          Text('Telebirr Merchant: Active · Auto-Release Ready', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Daily Escrow Limit: 2,500,000 ETB', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
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
                          Text('Daily Escrow Limit: 5,000,000 ETB', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8))),
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                activeConsignmentsCount: _consignments.where((c) => c.status != EscrowCardStatus.settled).length,
                onManageVaults: _handleManageVaults,
              ),
              const SizedBox(height: 16),

              // Status Filter Tabs (Active Escrow, Invoices, Disputes)
              EscrowStatusFilterTabs(
                selectedIndex: _activeTabIndex,
                onTabSelected: _onTabSelected,
                activeEscrowCount: _consignments.where((c) => c.status != EscrowCardStatus.settled).length,
                invoicesCount: 45,
                disputesCount: 0,
              ),
              const SizedBox(height: 16),

              // Consignment Escrow Cards list
              _buildConsignmentsList(),
              const SizedBox(height: 16),

              // Multi-Consignment Batch Fund Banner
              MultiConsignmentBatchCard(
                onBatchFundTap: _handleBatchFundTap,
              ),
              const SizedBox(height: 100), // Spacing for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: HabeshaBottomNavBar(
        currentIndex: 3, // Bids / Escrow active
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.page24MyShipments);
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

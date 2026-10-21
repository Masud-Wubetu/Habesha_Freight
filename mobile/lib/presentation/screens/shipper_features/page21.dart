import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyBidPipelineApp());
}

/// Standalone runnable wrapper for testing & Chrome preview of Page 21
class MyBidPipelineApp extends StatelessWidget {
  const MyBidPipelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habesha Freight - My Bid Pipeline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MyBidPipelineScreen(),
    );
  }
}

// Convenient alias for Page 21
typedef Page21Screen = MyBidPipelineScreen;

class MyBidPipelineScreen extends StatefulWidget {
  final String initialLanguage;
  const MyBidPipelineScreen({super.key, this.initialLanguage = 'EN'});

  @override
  State<MyBidPipelineScreen> createState() => _MyBidPipelineScreenState();
}

class _MyBidPipelineScreenState extends State<MyBidPipelineScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###');

  // Navigation tab
  int _selectedBottomNavIndex = 3; // 'Bids' tab selected

  // Filter tabs: 'Active Bids', 'Awarded & Won', 'Past Archive'
  int _selectedFilterTabIndex = 0;

  // Language state
  late String _selectedLanguage;

  // Dynamic state for interactive cards
  bool _counterOfferAccepted = false;
  bool _counterOfferRejected = false;
  final double _counterOfferAmount = 74500;
  double _submittedBid1 = 78000;

  double _quoteBid2 = 36500;
  bool _bid2Withdrawn = false;

  final int _stageProgress = 2; // Stage 2 of 3

  String _formatEtb(num val) => _currencyFormat.format(val.round());

  String _t(String en, String am) => _selectedLanguage == 'አማ' ? am : en;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070F1C),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top App Bar
                        _buildHeader(),

                        // Top Contract Awarded Banner Card
                        _buildContractAwardedCard(),

                        // Title & Live Board
                        _buildTitleSection(),

                        // Metric / KPI Stat Cards
                        _buildKpiMetricsRow(),

                        // Filter Tabs (Active Bids, Awarded & Won, Past Archive)
                        _buildFilterTabs(),

                        const SizedBox(height: 8),

                        // Tab-dependent content
                        if (_selectedFilterTabIndex == 0) ...[
                          // Card 1: Action Required: Counter-Offer
                          if (!_counterOfferAccepted && !_counterOfferRejected)
                            _buildCounterOfferCard()
                          else if (_counterOfferAccepted)
                            _buildAcceptedNoticeCard(),

                          // Card 2: Under Shipper Review
                          if (!_bid2Withdrawn)
                            _buildUnderReviewCard()
                          else
                            _buildWithdrawnNoticeCard(),

                          // Card 3: Shipper Shortlisted
                          _buildShortlistedCard(),

                          // Expressway Toll Intel
                          _buildTollIntelCard(),
                        ] else if (_selectedFilterTabIndex == 1) ...[
                          _buildAwardedWonTabContent(),
                        ] else ...[
                          _buildPastArchiveTabContent(),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF132033),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Habesha',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Freight',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF59E0B),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _t('LOGISTICS EXCHANGE', 'የጭነት ልውውጥ'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions: Language switcher & Avatar
          Row(
            children: [
              // Language Switcher
              InkWell(
                onTap: _toggleLanguage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111D2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF22354E), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedLanguage,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.translate_rounded,
                        color: Colors.white70,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // User Profile Avatar
              InkWell(
                onTap: _showProfileModal,
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Contract Awarded Card (Top Notification)
  // ---------------------------------------------------------------------------
  Widget _buildContractAwardedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1D2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF134E5E).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teal verified check circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.verified_rounded,
                color: Color(0xFF2DD4BF),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top label & timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('CONTRACT AWARDED', 'ውል ተሰጥቷል'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2DD4BF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      _t('Today', 'ዛሬ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Waybill title
                Text(
                  'Waybill #HF-9012',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),

                // Route & Price subtext (Single Text with overflow handling)
                Text(
                  _t('Addis Ababa → Dire Dawa • 45,000 ETB', 'አዲስ አበባ → ድሬዳዋ • 45,000 ብር'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Action button & status (using Wrap to prevent overflow)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // View Dispatch Slip button
                    InkWell(
                      onTap: _showDispatchSlipModal,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _t('View Dispatch Slip', 'የመላኪያ ሰነድ ይመልከቱ'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF0F172A),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Departure Ready Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _t('Departure\nReady', 'ለመነሳት\nዝግጁ'),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Title & Live Board Section
  // ---------------------------------------------------------------------------
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('My Bid Pipeline', 'የእኔ ጨረታ ዝርዝር'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // LIVE BOARD pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF042F2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF065F46),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _t('LIVE BOARD', 'ቀጥታ ሰሌዳ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            _t(
              'Track active proposals, negotiations, and awarded freight contracts across corridor routes.',
              'ንቁ የዋጋ ጥያቄዎችን፣ ድርድሮችን እና የተሰጡ የጭነት ውሎችን በኮሪደሮች ይከታተሉ።',
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Metrics Row (3 cards)
  // ---------------------------------------------------------------------------
  Widget _buildKpiMetricsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // Card 1: ACTIVE CAP
          Expanded(
            child: _buildMetricCard(
              label: _t('ACTIVE CAP', 'ንቁ ጨረታ'),
              value: '146.5k',
              valueColor: const Color(0xFFF59E0B),
              subtext: _t('3 bids open', '3 ክፍት ጨረታ'),
            ),
          ),
          const SizedBox(width: 8),

          // Card 2: WIN RATE
          Expanded(
            child: _buildMetricCard(
              label: _t('WIN RATE', 'የማሸነፍ ምጣኔ'),
              value: '68.2%',
              valueColor: const Color(0xFF10B981),
              subtext: _t('Top 5% Carrier', 'ከፍተኛ 5% አጓጓዥ'),
            ),
          ),
          const SizedBox(width: 8),

          // Card 3: AVG LEAD
          Expanded(
            child: _buildMetricCard(
              label: _t('AVG LEAD', 'አማካይ ጊዜ'),
              value: '42m',
              valueColor: const Color(0xFF38BDF8),
              subtext: _t('Shipper reply', 'የላኪ ምላሽ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color valueColor,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D42), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valueColor,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter Tabs (Active Bids 3, Awarded & Won 1, Past Archive 18)
  // ---------------------------------------------------------------------------
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Active Bids (3)
          Expanded(
            child: _buildFilterTabItem(
              index: 0,
              title: _t('Active\nBids', 'ንቁ\nጨረታዎች'),
              count: 3,
            ),
          ),
          const SizedBox(width: 8),

          // Awarded & Won (1)
          Expanded(
            child: _buildFilterTabItem(
              index: 1,
              title: _t('Awarded &\nWon', 'ያሸነፉ\nውሎች'),
              count: 1,
            ),
          ),
          const SizedBox(width: 8),

          // Past Archive (18)
          Expanded(
            child: _buildFilterTabItem(
              index: 2,
              title: _t('Past\nArchive', 'ያለፉ\nማህደር'),
              count: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabItem({
    required int index,
    required String title,
    required int count,
  }) {
    final isSelected = _selectedFilterTabIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterTabIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF111D2E),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF1E2D42), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD97706)
                    : const Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : (index == 1
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF94A3B8)),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 1: ACTION REQUIRED: COUNTER-OFFER
  // ---------------------------------------------------------------------------
  Widget _buildCounterOfferCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with status & swap icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ACTION REQUIRED: COUNTER-OFFER',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D42),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route row (Flexible to prevent RenderFlex overflow)
          Row(
            children: [
              Flexible(
                child: Text(
                  'Modjo Dry P...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Dire Dawa F...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Specs
          Text(
            _t('28T Wheat Bulk • Hopper Trailer • 440 km', '28 ቶን የስንዴ ጭነት • ሆፐር ተሳቢ • 440 ኪ.ሜ'),
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Comparison box (Expanded columns to prevent overflow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF09121D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A283B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Your Submitted Bid
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('Your Submitted Bid', 'ያቀረቡት ዋጋ'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_formatEtb(_submittedBid1)} ETB',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle downward trend arrow
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.trending_down_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),

                // Right: Shipper Counter-Offer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            color: Color(0xFFF59E0B),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _t('Shipper Counter-Offer', 'የላኪው ዋጋ'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF59E0B),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_formatEtb(_counterOfferAmount)} ETB',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFF59E0B),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Shipper and Expiry row (Expanded on company name to avoid overflow)
          Row(
            children: [
              const Icon(
                Icons.apartment_rounded,
                color: Color(0xFF94A3B8),
                size: 15,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Ethio-Grains Logistics Plc',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.timer_outlined,
                color: Color(0xFFF59E0B),
                size: 15,
              ),
              const SizedBox(width: 4),
              Text(
                _t('Expires in 18m', 'በ 18 ደቂቃ ውስጥ ያበቃል'),
                style: GoogleFonts.inter(
                  color: const Color(0xFFF59E0B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons row: Accept & Re-Counter
          Row(
            children: [
              // Accept button
              Expanded(
                flex: 6,
                child: InkWell(
                  onTap: _acceptCounterOffer,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF0F172A),
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _t('Accept ${_formatEtb(_counterOfferAmount)} ETB', '${_formatEtb(_counterOfferAmount)} ብር ይቀበሉ'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0F172A),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Re-Counter button
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: _showReCounterModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF28354A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _t('Re-Counter', 'ዳግም አቅርብ'),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Reject link
          Center(
            child: InkWell(
              onTap: _showRejectConfirmation,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _t('Reject Counter-Offer', 'አጸፋዊ ውድቅ አድርግ'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 2: UNDER SHIPPER REVIEW
  // ---------------------------------------------------------------------------
  Widget _buildUnderReviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D42), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with status & price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'UNDER SHIPPER REVIEW',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatEtb(_quoteBid2),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' ETB',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Target: 35,000 ETB',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Route row (Flexible to prevent overflow)
          Row(
            children: [
              Flexible(
                child: Text(
                  'Addis Aba...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Hawas...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Specs
          Text(
            '22T Export Coffee Bags • 218 km',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Competitor Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF09121D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A283B)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132033),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.leaderboard_outlined,
                    color: Color(0xFF38BDF8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2 Competitor Bids Logged',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your quote is within top 10% preference',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF063327),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF065F46)),
                  ),
                  child: Text(
                    'Competitive',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF34D399),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Footer row: time submitted & buttons (Flexible to prevent 0.25px overflow)
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF94A3B8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _t('Submitted 22 mins\nago', 'ከ 22 ደቂቃ በፊት\nቀረበ'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),

              // Modify Bid button
              InkWell(
                onTap: _showModifyBidModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132033),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF28354A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _t('Modify\nBid', 'ዋጋ\nአሻሽል'),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Withdraw button
              InkWell(
                onTap: _showWithdrawModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132033),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF28354A)),
                  ),
                  child: Text(
                    _t('Withdraw', 'ሰርዝ'),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 3: SHIPPER SHORTLISTED
  // ---------------------------------------------------------------------------
  Widget _buildShortlistedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D42), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with status & price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SHIPPER SHORTLISTED',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '32,000',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'ETB ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Matched rate',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Route row (Flexible to prevent overflow)
          Row(
            children: [
              Flexible(
                child: Text(
                  'Kaliti D...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFCBD5E1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Adama Ind...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Specs
          Text(
            '20T Portland Cement • Flatbed 3-Axle',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Stage & Progress Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF09121D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A283B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _t('Awaiting Final Allocation', 'የመጨረሻ ምደባ በመጠባበቅ ላይ'),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _t('Stage $_stageProgress of 3', 'ደረጃ $_stageProgress ከ 3'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Linear progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _stageProgress / 3.0,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF132033),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4EDEA3)),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Shipper selected your fleet profile. Gate pass & Insurance verification running in background.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Footer row: Truck tag & Message Shipper button
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF94A3B8),
                size: 15,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Truck: ET-3-84920',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Message Shipper button
              InkWell(
                onTap: _showMessageShipperModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132033),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF28354A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF38BDF8),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _t('Message Shipper', 'ለላኪው መልእክት'),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expressway Toll Intel Card (Bottom intel)
  // ---------------------------------------------------------------------------
  Widget _buildTollIntelCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D42), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF132033),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.alt_route_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adama Expressway Toll Intel',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Flow rate normal • Toll booths clear',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Live GPS',
            style: GoogleFonts.inter(
              color: const Color(0xFFF59E0B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Alternative Tab Contents: Awarded & Won / Past Archive
  // ---------------------------------------------------------------------------
  Widget _buildAwardedWonTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAwardedItemCard(
            waybillId: '#HF-9012',
            route: 'Addis Ababa → Dire Dawa',
            amount: '45,000 ETB',
            cargo: 'Wheat Bulk 28T',
            status: 'Departure Ready',
            statusColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          if (_counterOfferAccepted)
            _buildAwardedItemCard(
              waybillId: '#HF-9013',
              route: 'Modjo Dry Port → Dire Dawa FTZ',
              amount: '${_formatEtb(_counterOfferAmount)} ETB',
              cargo: '28T Wheat Bulk',
              status: 'Escrow Allocated',
              statusColor: const Color(0xFF38BDF8),
            ),
        ],
      ),
    );
  }

  Widget _buildAwardedItemCard({
    required String waybillId,
    required String route,
    required String amount,
    required String cargo,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waybill $waybillId',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF59E0B),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$route • $cargo',
            style: GoogleFonts.inter(
              color: const Color(0xFFCBD5E1),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                status,
                style: GoogleFonts.inter(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _showDispatchSlipModal,
                child: Text(
                  'View Slip →',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastArchiveTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (index) {
          final pastRoutes = [
            'Djibouti Port → Modjo Dry Port',
            'Nazret → Addis Ababa Industrial Hub',
            'Kombolcha → Mekelle Logistics Base',
            'Hawassa Agro Park → Kaliti Freight Station',
          ];
          final pastAmounts = ['112,000 ETB', '38,500 ETB', '89,000 ETB', '44,200 ETB'];
          final dates = ['Oct 14, 2026', 'Oct 09, 2026', 'Sep 28, 2026', 'Sep 19, 2026'];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111D2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E2D42)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pastRoutes[index],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Completed on ${dates[index]}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  pastAmounts[index],
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notice Cards for Interacted States
  // ---------------------------------------------------------------------------
  Widget _buildAcceptedNoticeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF063327),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF065F46)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF34D399),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Counter-offer of ${_formatEtb(_counterOfferAmount)} ETB accepted! Waybill issued.',
              style: GoogleFonts.inter(
                color: const Color(0xFF34D399),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawnNoticeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF261A1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5E2B30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFF8B8B),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bid on Addis Ababa → Hawassa has been withdrawn.',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF8B8B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF08121E),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2D42), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _buildBottomNavItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            label: _t('Home', 'ዋና'),
          ),

          // Shipments
          _buildBottomNavItem(
            index: 1,
            icon: Icons.inventory_2_outlined,
            label: _t('Shipments', 'ጭነቶች'),
          ),

          // Center: Post Load Floating Button
          InkWell(
            onTap: _showPostLoadModal,
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Color(0xFF0F172A),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _t('Post Load', 'ጭነት መዝግብ'),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Bids (Active Tab!)
          _buildBottomNavItem(
            index: 3,
            icon: Icons.swap_calls_rounded,
            label: _t('Bids', 'ጨረታዎች'),
            isActiveOverride: true,
          ),

          // Tracking
          _buildBottomNavItem(
            index: 4,
            icon: Icons.location_on_outlined,
            label: _t('Tracking', 'ክትትል'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isActiveOverride = false,
  }) {
    final isSelected = isActiveOverride || (_selectedBottomNavIndex == index);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // User Interaction Modals & Bottom Sheets
  // ---------------------------------------------------------------------------

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = (_selectedLanguage == 'EN') ? 'አማ' : 'EN';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF132033),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        content: Text(
          _selectedLanguage == 'EN'
              ? 'Language changed to English'
              : 'ቋንቋ ወደ አማርኛ ተቀይሯል (Amharic)',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F172A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dawit Transport Fleet',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tier 1 Certified Carrier • Addis Ababa Hub',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E2D42)),
              const SizedBox(height: 8),
              _buildModalRow(Icons.badge_outlined, 'License ID: ETH-TRANS-84920'),
              _buildModalRow(Icons.local_shipping_outlined, 'Active Rigs: 14 Trucks'),
              _buildModalRow(Icons.verified_outlined, 'Escrow Trust Score: 99.4%'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showDispatchSlipModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dispatch Slip HF-9012',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Departure Ready',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildModalRow(Icons.route_rounded, 'Corridor: Addis Ababa → Dire Dawa'),
              _buildModalRow(Icons.payments_outlined, 'Awarded Fares: 45,000 ETB (Escrow Locked)'),
              _buildModalRow(Icons.qr_code_2_rounded, 'Gate Pass Token: #GPT-772910'),
              _buildModalRow(Icons.lock_clock_outlined, 'Scheduled Departure: Today 17:00 PM'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Download Official PDF Slip',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _acceptCounterOffer() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111D2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF1E2D42)),
          ),
          title: Text(
            'Accept Counter-Offer?',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You are accepting Ethio-Grains Logistics Plc’s counter-offer of ${_formatEtb(_counterOfferAmount)} ETB. Escrow deposit will be immediately locked in your carrier account.',
            style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _counterOfferAccepted = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF064E3B),
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Counter-offer accepted! Contract awarded and waybill issued.',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                );
              },
              child: Text(
                'Confirm & Lock',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReCounterModal() {
    double tempVal = _counterOfferAmount + 1500;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Re-Counter Shipper Proposal',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Propose a revised quote between 74,500 ETB and 78,000 ETB for 28T Wheat Bulk.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      '${_formatEtb(tempVal)} ETB',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF59E0B),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Slider(
                    value: tempVal,
                    min: 74500,
                    max: 78000,
                    divisions: 7,
                    activeColor: const Color(0xFFF59E0B),
                    inactiveColor: const Color(0xFF1A283B),
                    onChanged: (val) {
                      setModalState(() {
                        tempVal = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _submittedBid1 = tempVal;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF132033),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Re-counter of ${_formatEtb(tempVal)} ETB transmitted to Ethio-Grains!',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Submit Re-Counter (${_formatEtb(tempVal)} ETB)',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRejectConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111D2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF1E2D42)),
          ),
          title: Text(
            'Reject Counter-Offer?',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Rejecting this proposal will release the lock and notify Ethio-Grains Logistics Plc.',
            style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _counterOfferRejected = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Counter-offer rejected.',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                );
              },
              child: Text(
                'Reject Offer',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModifyBidModal() {
    double modifiedBid = _quoteBid2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Modify Submitted Quote',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Route: Addis Ababa → Hawassa (Target: 35,000 ETB)',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_formatEtb(modifiedBid)} ETB',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Slider(
                    value: modifiedBid,
                    min: 34000,
                    max: 38000,
                    divisions: 8,
                    activeColor: const Color(0xFF38BDF8),
                    inactiveColor: const Color(0xFF1A283B),
                    onChanged: (val) {
                      setModalState(() {
                        modifiedBid = val;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _quoteBid2 = modifiedBid;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF132033),
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Bid updated to ${_formatEtb(modifiedBid)} ETB!',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Update Bid to ${_formatEtb(modifiedBid)} ETB',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111D2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF1E2D42)),
          ),
          title: Text(
            'Withdraw Bid?',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to withdraw your 36,500 ETB bid on Addis Ababa → Hawassa? This cannot be undone.',
            style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Active',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _bid2Withdrawn = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Bid withdrawn successfully.',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                );
              },
              child: Text(
                'Withdraw Bid',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessageShipperModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message Shipper: Adama Industrial',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Regarding Kaliti → Adama Ind. (20T Cement, Truck ET-3-84920)',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type your dispatch query or estimated arrival...',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF09121D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E2D42)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF132033),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Message sent to Adama Industrial dispatch desk.',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    'Send Message',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostLoadModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Color(0xFF1E2D42)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF0F172A),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Post New Freight Cargo Load',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Publish freight requirements to the Habesha Logistics Exchange live network.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Create Load Listing',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
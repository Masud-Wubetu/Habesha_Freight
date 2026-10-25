import 'package:flutter/material.dart';

class CorridorBidItem {
  final String id;
  final String driverName;
  final String driverInitials;
  final double rating;
  final int reviewsCount;
  final String truckSpec;
  final String locationText;
  final String availabilityText;
  final double bidAmountEtb;
  final String badgeLabel;
  final Color badgeColor;
  final bool isTopMatch;
  final bool isEscrowGuaranteed;
  final String? submittedAgo;
  final String? estTransit;
  final String? gpsStatus;
  final String? fuelIncluded;
  final bool isAccepted;
  final double? counterOfferEtb;

  const CorridorBidItem({
    required this.id,
    required this.driverName,
    required this.driverInitials,
    required this.rating,
    required this.reviewsCount,
    required this.truckSpec,
    required this.locationText,
    required this.availabilityText,
    required this.bidAmountEtb,
    required this.badgeLabel,
    required this.badgeColor,
    this.isTopMatch = false,
    this.isEscrowGuaranteed = false,
    this.submittedAgo,
    this.estTransit,
    this.gpsStatus,
    this.fuelIncluded,
    this.isAccepted = false,
    this.counterOfferEtb,
  });

  CorridorBidItem copyWith({
    bool? isAccepted,
    double? counterOfferEtb,
  }) {
    return CorridorBidItem(
      id: id,
      driverName: driverName,
      driverInitials: driverInitials,
      rating: rating,
      reviewsCount: reviewsCount,
      truckSpec: truckSpec,
      locationText: locationText,
      availabilityText: availabilityText,
      bidAmountEtb: bidAmountEtb,
      badgeLabel: badgeLabel,
      badgeColor: badgeColor,
      isTopMatch: isTopMatch,
      isEscrowGuaranteed: isEscrowGuaranteed,
      submittedAgo: submittedAgo,
      estTransit: estTransit,
      gpsStatus: gpsStatus,
      fuelIncluded: fuelIncluded,
      isAccepted: isAccepted ?? this.isAccepted,
      counterOfferEtb: counterOfferEtb ?? this.counterOfferEtb,
    );
  }

  factory CorridorBidItem.fromMap(Map<String, dynamic> map) {
    final driverName = map['driver_name']?.toString() ?? 'Carrier Driver';
    final parts = driverName.trim().split(' ');
    final initials = parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join();

    final amt = (map['bid_amount_etb'] is num)
        ? (map['bid_amount_etb'] as num).toDouble()
        : double.tryParse(map['bid_amount_etb']?.toString() ?? '35000') ?? 35000.0;

    return CorridorBidItem(
      id: map['id']?.toString() ?? 'bid-${DateTime.now().millisecondsSinceEpoch}',
      driverName: driverName,
      driverInitials: initials.isNotEmpty ? initials : 'CD',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.8,
      reviewsCount: (map['reviews_count'] is num) ? (map['reviews_count'] as num).toInt() : 42,
      truckSpec: map['truck_spec']?.toString() ?? 'Heavy Commercial Truck',
      locationText: map['location']?.toString() ?? 'Addis Ababa Corridor',
      availabilityText: map['availability']?.toString() ?? 'Available Immediately',
      bidAmountEtb: amt,
      badgeLabel: map['badge_label']?.toString() ?? 'VERIFIED CARRIER',
      badgeColor: const Color(0xFF10B981),
      isTopMatch: map['is_top_match'] == true,
      isEscrowGuaranteed: true,
      estTransit: map['est_transit']?.toString() ?? '8h 30m',
      gpsStatus: 'Live GPS Active',
      fuelIncluded: 'Yes',
      isAccepted: map['status'] == 'ACCEPTED',
    );
  }

  static List<CorridorBidItem> mockBids() {
    return [
      const CorridorBidItem(
        id: 'bid-girma',
        driverName: 'Girma Tadesse',
        driverInitials: 'GT',
        rating: 4.9,
        reviewsCount: 142,
        truckSpec: 'Sinotruk HOWO 371 • Dry Bulk Grain Spec',
        locationText: 'Kality Depot (11 km away)',
        availabilityText: 'Ready 2:00 PM today',
        bidAmountEtb: 38000,
        badgeLabel: 'TOP MATCH • VERIFIED PRO',
        badgeColor: Color(0xFFF59E0B),
        isTopMatch: true,
        isEscrowGuaranteed: true,
        estTransit: '9h 45m',
        gpsStatus: 'Live Active',
        fuelIncluded: 'Yes (Full)',
      ),
      const CorridorBidItem(
        id: 'bid-solomon',
        driverName: 'Solomon Tekle',
        driverInitials: 'ST',
        rating: 4.8,
        reviewsCount: 85,
        truckSpec: 'FAW J6P 32T Heavy Semi-Trailer',
        locationText: 'Akaki Dry Port (15 km away)',
        availabilityText: 'Ready 4:30 PM',
        bidAmountEtb: 36500,
        badgeLabel: 'Lowest Fare Offered',
        badgeColor: Color(0xFF10B981),
        isTopMatch: false,
        submittedAgo: 'Submitted 18m ago',
      ),
      const CorridorBidItem(
        id: 'bid-bekele',
        driverName: 'Bekele Wolde',
        driverInitials: 'BW',
        rating: 4.7,
        reviewsCount: 64,
        truckSpec: 'Mercedes Actros 3340 • Tarpaulin Covered',
        locationText: 'Dukem Corridor (22 km away)',
        availabilityText: 'Ready 8:00 AM tomorrow',
        bidAmountEtb: 39200,
        badgeLabel: 'High-Capacity Heavy Rig',
        badgeColor: Color(0xFF38BDF8),
        isTopMatch: false,
        submittedAgo: 'Submitted 41m ago',
      ),
    ];
  }
}

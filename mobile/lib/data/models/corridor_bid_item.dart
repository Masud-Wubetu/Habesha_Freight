import 'package:flutter/material.dart';

class CorridorBidItem {
  final String id;
  final String? loadId;
  final String originCity;
  final String destinationCity;
  final String cargoDescription;
  final double offeredPriceEtb;
  final String? driverPhone;
  final String status;
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
    this.loadId,
    this.originCity = 'Addis Ababa',
    this.destinationCity = 'Dire Dawa',
    this.cargoDescription = '28 MT Dry Bulk (Teff & Grain)',
    this.offeredPriceEtb = 0.0,
    this.driverPhone,
    this.status = 'PENDING',
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
    String? status,
  }) {
    return CorridorBidItem(
      id: id,
      loadId: loadId,
      originCity: originCity,
      destinationCity: destinationCity,
      cargoDescription: cargoDescription,
      offeredPriceEtb: offeredPriceEtb,
      driverPhone: driverPhone,
      status: status ?? this.status,
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
    final rawName = map['driver_name']?.toString() ?? map['carrier_name']?.toString();
    final phone = map['driver_phone']?.toString();
    final driverName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (phone != null && phone.isNotEmpty ? 'Driver ($phone)' : 'Transporter');
    final parts = driverName.trim().split(' ');
    final initials = parts.map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join();

    final amt = (map['bid_amount_etb'] is num)
        ? (map['bid_amount_etb'] as num).toDouble()
        : double.tryParse(map['bid_amount_etb']?.toString() ?? '0') ?? 0.0;

    final targetPrice = (map['offered_price_etb'] is num)
        ? (map['offered_price_etb'] as num).toDouble()
        : double.tryParse(map['offered_price_etb']?.toString() ?? '0') ?? 0.0;

    final isAccepted = map['status'] == 'ACCEPTED';
    final vehicle = map['vehicle_type']?.toString();
    final plate = map['plate_number']?.toString();
    final trips = (map['completed_trips'] is num)
        ? (map['completed_trips'] as num).toInt()
        : int.tryParse(map['completed_trips']?.toString() ?? '0') ?? 0;
    final rating = double.tryParse(map['driver_rating']?.toString() ?? '5.0') ?? 5.0;

    String truckText = plate != null && plate.isNotEmpty ? 'Plate $plate' : 'Commercial Freight Carrier';
    if (vehicle != null && vehicle.isNotEmpty) {
      final formattedVehicle = vehicle.replaceAll('_', ' ');
      truckText = plate != null && plate.isNotEmpty ? '$formattedVehicle • $plate' : formattedVehicle;
    } else if (map['capacity_tons'] != null) {
      truckText = '${map['capacity_tons']}T Heavy Carrier';
    }

    final origin = map['origin_city']?.toString() ?? 'Addis Ababa';
    final destination = map['destination_city']?.toString() ?? 'Dire Dawa';
    final cargo = map['cargo_description']?.toString() ?? 'General Cargo';

    return CorridorBidItem(
      id: map['id']?.toString() ?? 'bid-${DateTime.now().millisecondsSinceEpoch}',
      loadId: map['load_id']?.toString(),
      originCity: origin,
      destinationCity: destination,
      cargoDescription: cargo,
      offeredPriceEtb: targetPrice,
      driverPhone: phone,
      status: map['status']?.toString() ?? (isAccepted ? 'ACCEPTED' : 'PENDING'),
      driverName: driverName,
      driverInitials: initials.isNotEmpty ? initials : 'DR',
      rating: rating,
      reviewsCount: trips,
      truckSpec: truckText,
      locationText: phone != null && phone.isNotEmpty ? 'Phone: $phone' : '$origin Corridor',
      availabilityText: isAccepted ? 'Contract Awarded • Escrow Active' : 'Available for Dispatch',
      bidAmountEtb: amt,
      badgeLabel: isAccepted ? 'AWARDED CONTRACT' : 'VERIFIED CARRIER',
      badgeColor: isAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
      isTopMatch: map['is_top_match'] == true,
      isEscrowGuaranteed: true,
      estTransit: map['est_transit']?.toString(),
      gpsStatus: 'Live GPS Active',
      fuelIncluded: 'Yes',
      isAccepted: isAccepted,
    );
  }
}


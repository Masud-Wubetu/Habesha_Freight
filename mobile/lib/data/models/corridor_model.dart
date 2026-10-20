// ============================================================================
// ETHIOPIAN FREIGHT CORRIDORS, TELEMETRY & TARIFF MODELS
// All related freight logistics models are consolidated in this file.
// ============================================================================

class EthiopianCorridor {
  final String id;
  final String originCity;
  final String originTerminal;
  final String destinationCity;
  final String destinationTerminal;
  final double distanceKm;
  final String status;
  final double baseRatePerTonKm;
  final double fixedHandlingFeeEtb;

  const EthiopianCorridor({
    required this.id,
    required this.originCity,
    required this.originTerminal,
    required this.destinationCity,
    required this.destinationTerminal,
    required this.distanceKm,
    required this.status,
    this.baseRatePerTonKm = 6.45,
    this.fixedHandlingFeeEtb = 1800.0,
  });

  /// Predefined standard Ethiopian freight corridors matching national logistics infrastructure
  static const List<EthiopianCorridor> standardCorridors = [
    EthiopianCorridor(
      id: 'corridor-addis-diredawa',
      originCity: 'Addis Ababa',
      originTerminal: 'Kality Dry Port',
      destinationCity: 'Dire Dawa',
      destinationTerminal: 'Free Trade Zone',
      distanceKm: 452,
      status: 'Active',
      baseRatePerTonKm: 6.45,
      fixedHandlingFeeEtb: 1800,
    ),
    EthiopianCorridor(
      id: 'corridor-modjo-djibouti',
      originCity: 'Modjo Dry Port',
      originTerminal: 'Main Inland Container Depot',
      destinationCity: 'Djibouti',
      destinationTerminal: 'Doraleh Container Terminal (DCT)',
      distanceKm: 780,
      status: 'Active',
      baseRatePerTonKm: 7.20,
      fixedHandlingFeeEtb: 2500,
    ),
    EthiopianCorridor(
      id: 'corridor-adama-hawassa',
      originCity: 'Adama',
      originTerminal: 'Logistics Hub',
      destinationCity: 'Hawassa',
      destinationTerminal: 'Industrial Park Terminal',
      distanceKm: 170,
      status: 'Active',
      baseRatePerTonKm: 6.10,
      fixedHandlingFeeEtb: 1200,
    ),
    EthiopianCorridor(
      id: 'corridor-addis-djibouti',
      originCity: 'Addis Ababa',
      originTerminal: 'Kality Inland Terminal',
      destinationCity: 'Djibouti',
      destinationTerminal: 'Port of Djibouti',
      distanceKm: 865,
      status: 'Active',
      baseRatePerTonKm: 7.50,
      fixedHandlingFeeEtb: 3000,
    ),
    EthiopianCorridor(
      id: 'corridor-addis-bahirdar',
      originCity: 'Addis Ababa',
      originTerminal: 'North Terminal (Gohatsion)',
      destinationCity: 'Bahir Dar',
      destinationTerminal: 'Amhara Logistics Hub',
      distanceKm: 565,
      status: 'Active',
      baseRatePerTonKm: 6.30,
      fixedHandlingFeeEtb: 1500,
    ),
    EthiopianCorridor(
      id: 'corridor-diredawa-djibouti',
      originCity: 'Dire Dawa',
      originTerminal: 'Free Trade Zone',
      destinationCity: 'Djibouti',
      destinationTerminal: 'Doraleh DCT',
      distanceKm: 310,
      status: 'Active',
      baseRatePerTonKm: 6.80,
      fixedHandlingFeeEtb: 1500,
    ),
  ];
}

class ActiveTransit {
  final String transitNumber;
  final String carrierName;
  final String vehicleType;
  final String status;
  final double speedKmH;
  final int etaMinutes;
  final String originCity;
  final String originTime;
  final String destinationCity;
  final String destinationTerminal;
  final double progressPercent; // 0.0 - 1.0

  const ActiveTransit({
    required this.transitNumber,
    required this.carrierName,
    required this.vehicleType,
    required this.status,
    required this.speedKmH,
    required this.etaMinutes,
    required this.originCity,
    required this.originTime,
    required this.destinationCity,
    required this.destinationTerminal,
    required this.progressPercent,
  });

  static const ActiveTransit defaultTransit = ActiveTransit(
    transitNumber: '004',
    carrierName: "HILINA'S Heavy Cargo",
    vehicleType: 'Sino Truck Heavy Flatbed',
    status: 'Moving',
    speedKmH: 72.0,
    etaMinutes: 78,
    originCity: 'Addis Ababa',
    originTime: '02:40 PM',
    destinationCity: 'Modjo Dry Port',
    destinationTerminal: 'Customs Yard 2',
    progressPercent: 0.65,
  );
}

class RegionalTelemetry {
  final int activeTrucks;
  final int trucksOnHighway;
  final double dispatchLatencyMinutes;
  final String corridorGate;
  final double transitProtectionGuaranteePercent;

  const RegionalTelemetry({
    required this.activeTrucks,
    required this.trucksOnHighway,
    required this.dispatchLatencyMinutes,
    required this.corridorGate,
    this.transitProtectionGuaranteePercent = 100.0,
  });

  static const RegionalTelemetry defaultTelemetry = RegionalTelemetry(
    activeTrucks: 342,
    trucksOnHighway: 14,
    dispatchLatencyMinutes: 8.4,
    corridorGate: 'Addis - Djibouti gate',
    transitProtectionGuaranteePercent: 100.0,
  );
}

class CorridorEstimate {
  final double estimatedPriceEtb;
  final double distanceKm;
  final int transitHoursEstimate;

  const CorridorEstimate({
    required this.estimatedPriceEtb,
    required this.distanceKm,
    required this.transitHoursEstimate,
  });
}

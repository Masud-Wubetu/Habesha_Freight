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

  /// Sample initial state matching live transit telemetry in UI
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

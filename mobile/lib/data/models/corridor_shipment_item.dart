enum ShipmentStatus {
  inTransit,
  bidding,
  awaitingDispatch,
  delivered,
}

class CorridorShipmentItem {
  final String id;
  final String cargoType;
  final ShipmentStatus status;
  final String origin;
  final String originDetail;
  final String destination;
  final String destinationDetail;
  final String viaRoute;
  final int distanceKm;

  // In Transit fields
  final String? fleetRig;
  final String? plateNumber;
  final String? telemetrySpeed;
  final String? gpsLock;
  final String? eta;
  final String? etaStatus;
  final String? driverName;
  final String? driverInitials;
  final double? driverRating;

  // Bidding fields
  final int? lowestOfferEtb;
  final int? avgMarketEtb;
  final int? bidsCount;
  final String? auctionEndsIn;
  final List<String>? bidderInitials;

  // Awaiting Dispatch fields
  final String? carrierAssigned;
  final String? gatePassStatus;
  final String? targetDeparture;
  final double? loadingProgress; // 0.0 - 1.0

  // Delivered fields
  final String? signedBy;
  final String? deliveredDate;

  const CorridorShipmentItem({
    required this.id,
    required this.cargoType,
    required this.status,
    required this.origin,
    required this.originDetail,
    required this.destination,
    required this.destinationDetail,
    required this.viaRoute,
    required this.distanceKm,
    this.fleetRig,
    this.plateNumber,
    this.telemetrySpeed,
    this.gpsLock,
    this.eta,
    this.etaStatus,
    this.driverName,
    this.driverInitials,
    this.driverRating,
    this.lowestOfferEtb,
    this.avgMarketEtb,
    this.bidsCount,
    this.auctionEndsIn,
    this.bidderInitials,
    this.carrierAssigned,
    this.gatePassStatus,
    this.targetDeparture,
    this.loadingProgress,
    this.signedBy,
    this.deliveredDate,
  });

  static const List<CorridorShipmentItem> demoShipments = [
    // 1. In Transit (#HF-9012)
    CorridorShipmentItem(
      id: '#HF-9012',
      cargoType: 'Dry Bulk • Grain',
      status: ShipmentStatus.inTransit,
      origin: 'Addis Ababa',
      originDetail: 'Kality Terminal',
      destination: 'Dire Dawa',
      destinationDetail: 'Dry Port Yard',
      viaRoute: 'Via Awash',
      distanceKm: 452,
      fleetRig: 'Sino 30T Heavy',
      plateNumber: 'ET-3-89412',
      telemetrySpeed: '68 km/h',
      gpsLock: 'GPS Lock 100%',
      eta: '3h 15m',
      etaStatus: 'On Schedule',
      driverName: 'Tewodros Kassaye',
      driverInitials: 'TK',
      driverRating: 4.9,
    ),

    // 2. Bidding (#HF-8841)
    CorridorShipmentItem(
      id: '#HF-8841',
      cargoType: 'General Cargo • FMCG',
      status: ShipmentStatus.bidding,
      origin: 'Addis Ababa',
      originDetail: 'Akaki Depot',
      destination: 'Adama',
      destinationDetail: 'Industrial Park',
      viaRoute: 'Expressway A1',
      distanceKm: 85,
      lowestOfferEtb: 18500,
      avgMarketEtb: 21000,
      bidsCount: 5,
      auctionEndsIn: '01h 42m',
      bidderInitials: ['DA', 'DG', 'YM'],
    ),

    // 3. Awaiting Dispatch (#HF-7720)
    CorridorShipmentItem(
      id: '#HF-7720',
      cargoType: 'Agricultural • Coffee Bags',
      status: ShipmentStatus.awaitingDispatch,
      origin: 'Hawassa',
      originDetail: 'Sidama Warehouse',
      destination: 'Modjo',
      destinationDetail: 'Dry Port Export',
      viaRoute: 'A7 Corridor',
      distanceKm: 215,
      carrierAssigned: 'Selam Logistics PLC',
      gatePassStatus: 'Gate Pass Generated',
      targetDeparture: 'Today @ 16:30',
      loadingProgress: 0.80,
    ),

    // 4. Delivered (#HF-6504)
    CorridorShipmentItem(
      id: '#HF-6504',
      cargoType: 'Construction • Rebar 40T',
      status: ShipmentStatus.delivered,
      origin: 'Addis Ababa',
      originDetail: 'CMC Yard',
      destination: 'Bahir Dar',
      destinationDetail: 'Lake Depot',
      viaRoute: 'Route 3 Corridor',
      distanceKm: 560,
      signedBy: 'Girma Worku (Yard B)',
      deliveredDate: 'Yesterday',
    ),
  ];
}

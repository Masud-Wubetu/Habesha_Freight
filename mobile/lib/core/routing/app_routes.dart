class AppRoutes {
  static const login = '/login';
  static const fleetHub = '/fleet';
  //Phase 2: Shipper
  static const page11FreightHistory = '/shipper/history';
  static const page12PreferredFleet = '/shipper/fleet';
  static const page13EscrowInvoices = '/shipper/escrow';
  static const page14CompanyProfile = '/shipper/profile';
  static const page15RateDriver = '/shipper/rate-driver';
  //Phase 3: Driver & Carrier Operations Suite (pages 16–19)
  static const page16DriverHome = '/driver/home';
  static const page17AvailableLoads = '/driver/loads';
  static const page18DirectOffers = '/driver/offers';
  static const page19RequestDetails = '/driver/request';
  // Phase 5 — Fleet Enterprise (27–34)
  static const page27FleetCommand = '/fleet/command';
  static const page28RigTelemetry = '/fleet/rigs';
  static const page29DriverRoster = '/fleet/drivers';
  static const page30DispatchMatrix = '/fleet/dispatch';
  static const page31EscrowBatch = '/fleet/settlements';
  static const page32FuelToll = '/fleet/fuel-toll';
  static const page33Maintenance = '/fleet/maintenance';
  static const page34Analytics = '/fleet/analytics';

  // Phase 6 — Customs & Intermodal (35–40)
  static const page35Customs = '/ops/customs';
  static const page36BorderPass = '/ops/border-pass';
  static const page37Weighbridge = '/ops/weighbridge';
  static const page38Compliance = '/ops/compliance';
  static const page39ColdChain = '/ops/cold-chain';
  static const page40Intermodal = '/ops/intermodal';
}

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const page04VerifyOtp = '/auth/verify-otp';
  static const page05EscrowVault = '/shipper/escrow';
  static const page06ShipperHub = '/shipper/active-hub';
  static const page07PostCargo = '/shipper/post-cargo';
  static const page08MyShipments = '/shipper/shipments';
  static const page09ReviewBids = '/shipper/review-bids';
  static const page08ReviewBids = page09ReviewBids;
  static const page23PostCargo = '/shipper/post-cargo-wizard';
  static const page24MyShipments = '/shipper/my-shipments';
  static const home = '/home';
  static const fleetHub = '/fleet';
  static const page20SubmitBid = '/shipper/bid';
  static const page21EscrowVault = '/shipper/escrow-vault';

static const String shipperHome = '/shipper/home';
static const String page11FreightHistory = '/shipper/history';
static const String page12PreferredFleet = '/shipper/preferred-fleet';
static const String page13EscrowInvoices = '/shipper/escrow-invoices';
static const String page14CompanyProfile = '/shipper/company-profile';
static const String page15RateDriver = '/shipper/rate-driver';

  static const String page16DriverHome = '/driver/home';
  static const String page17AvailableLoads = '/driver/loads';
  static const String page18DirectOffers = '/driver/offers';
  static const String page19RequestDetails = '/driver/request';
  static const String shipperHub = '/shipper';
  static const String driverHub = '/driver';
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

import 'api_client.dart';
import '../config/api_config.dart';

class CompanyStats {
  CompanyStats({
    required this.vehiclesTotal,
    required this.vehiclesActive,
    required this.driversTotal,
    required this.driversActive,
    required this.shipmentsTotal,
    required this.shipmentsInTransit,
    required this.shipmentsDelivered,
    required this.totalEarnings,
    required this.averageRating,
  });

  final int vehiclesTotal;
  final int vehiclesActive;
  final int driversTotal;
  final int driversActive;
  final int shipmentsTotal;
  final int shipmentsInTransit;
  final int shipmentsDelivered;
  final double totalEarnings;
  final double averageRating;

  factory CompanyStats.fromJson(Map<String, dynamic> json) {
    final vehicles = (json['vehicles'] as Map?)?.cast<String, dynamic>() ?? {};
    final drivers = (json['drivers'] as Map?)?.cast<String, dynamic>() ?? {};
    final shipments = (json['shipments'] as Map?)?.cast<String, dynamic>() ?? {};
    return CompanyStats(
      vehiclesTotal: _asInt(vehicles['total']),
      vehiclesActive: _asInt(vehicles['active']),
      driversTotal: _asInt(drivers['total']),
      driversActive: _asInt(drivers['active']),
      shipmentsTotal: _asInt(shipments['total']),
      shipmentsInTransit: _asInt(shipments['in_transit']),
      shipmentsDelivered: _asInt(shipments['delivered']),
      totalEarnings: _asDouble(json['earnings'] ?? json['total_earnings']),
      averageRating: _asDouble(
        (json['rating'] as Map?)?['average'] ??
            (json['rating'] as Map?)?['average_rating'] ??
            json['average_rating'],
      ),
    );
  }
}

class FleetVehicle {
  FleetVehicle({
    required this.id,
    required this.plateNumber,
    required this.makeModel,
    required this.isActive,
    required this.verificationStatus,
    this.capacityTons,
    this.driverId,
  });

  final String id;
  final String plateNumber;
  final String makeModel;
  final bool isActive;
  final String verificationStatus;
  final double? capacityTons;
  final String? driverId;

  factory FleetVehicle.fromJson(Map<String, dynamic> json) {
    final make = json['make']?.toString() ?? '';
    final model = json['model']?.toString() ?? '';
    final combined = [make, model].where((s) => s.isNotEmpty).join(' ');
    return FleetVehicle(
      id: json['id']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ??
          json['license_plate']?.toString() ??
          'N/A',
      makeModel: combined.isEmpty
          ? (json['vehicle_type']?.toString() ?? 'Truck')
          : combined,
      isActive: json['is_active'] == true,
      verificationStatus:
          (json['verification_status']?.toString() ?? 'PENDING').toUpperCase(),
      capacityTons: _asDoubleOrNull(json['capacity_tons'] ?? json['max_weight_tons']),
      driverId: json['driver_id']?.toString(),
    );
  }
}

class FleetDriver {
  FleetDriver({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.status,
    required this.kycStatus,
    this.email,
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final String phone;
  final String status;
  final String kycStatus;
  final String? email;
  final bool isVerified;

  factory FleetDriver.fromJson(Map<String, dynamic> json) {
    return FleetDriver(
      id: json['driver_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Driver',
      phone: json['phone_number']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
      kycStatus: (json['kyc_status']?.toString() ?? 'PENDING').toUpperCase(),
      email: json['email']?.toString(),
      isVerified: json['is_verified'] == true,
    );
  }
}

class FleetDelivery {
  FleetDelivery({
    required this.id,
    required this.status,
    required this.origin,
    required this.destination,
    required this.cargo,
  });

  final String id;
  final String status;
  final String origin;
  final String destination;
  final String cargo;

  factory FleetDelivery.fromJson(Map<String, dynamic> json) {
    return FleetDelivery(
      id: json['id']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'ASSIGNED').toUpperCase(),
      origin: json['origin_city']?.toString() ?? '—',
      destination: json['destination_city']?.toString() ?? '—',
      cargo: json['cargo_description']?.toString() ?? 'Freight',
    );
  }
}

class CompanyProfile {
  CompanyProfile({
    required this.name,
    this.tin,
    this.phone,
    this.email,
  });

  final String name;
  final String? tin;
  final String? phone;
  final String? email;

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['company_name']?.toString() ??
          json['full_name']?.toString() ??
          'Fleet Company',
      tin: json['tin']?.toString() ?? json['tax_id']?.toString(),
      phone: json['phone_number']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class FleetService {
  FleetService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<CompanyStats> getStats() async {
    final res = await _api.get(ApiConfig.companyStats);
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return CompanyStats.fromJson(data);
  }

  Future<CompanyProfile> getProfile() async {
    final res = await _api.get(ApiConfig.companyProfile);
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return CompanyProfile.fromJson(data);
  }

  Future<List<FleetVehicle>> getVehicles() async {
    final res = await _api.get(ApiConfig.companyVehicles);
    return _asList(res['data']).map(FleetVehicle.fromJson).toList();
  }

  Future<List<FleetDriver>> getDrivers() async {
    final res = await _api.get(ApiConfig.companyDrivers);
    return _asList(res['data']).map(FleetDriver.fromJson).toList();
  }

  Future<List<FleetDelivery>> getDeliveries() async {
    final res = await _api.get(ApiConfig.companyDeliveries);
    return _asList(res['data']).map(FleetDelivery.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getFleetRequests() async {
    final res = await _api.get(ApiConfig.companyFleetRequests);
    return _asList(res['data']);
  }

  Future<Map<String, dynamic>> acceptFleetRequest(String requestId) async {
    final res = await _api.patch(ApiConfig.companyFleetRequestAccept(requestId));
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> declineFleetRequest(String requestId) async {
    final res = await _api.patch(ApiConfig.companyFleetRequestDecline(requestId));
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> assignDriverToRequest({
    required String requestId,
    required String driverId,
  }) async {
    final res = await _api.post(
      ApiConfig.companyFleetRequestAssign(requestId),
      body: {'driver_id': driverId},
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
  }
}

List<Map<String, dynamic>> _asList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  if (raw is Map && raw['items'] is List) {
    return _asList(raw['items']);
  }
  return const [];
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  return _asDouble(v);
}

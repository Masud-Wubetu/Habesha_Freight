class ShipmentModel {
  ShipmentModel({
    required this.id,
    required this.loadId,
    required this.carrierId,
    required this.status,
    this.vehicleId,
    this.originCity,
    this.destinationCity,
    this.cargoDescription,
  });

  final String id;
  final String loadId;
  final String carrierId;
  final String status;
  final String? vehicleId;
  final String? originCity;
  final String? destinationCity;
  final String? cargoDescription;

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id']?.toString() ?? '',
      loadId: json['load_id']?.toString() ?? '',
      carrierId: json['carrier_id']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'ASSIGNED').toUpperCase(),
      vehicleId: json['vehicle_id']?.toString(),
      originCity: json['origin_city']?.toString(),
      destinationCity: json['destination_city']?.toString(),
      cargoDescription: json['cargo_description']?.toString(),
    );
  }
}

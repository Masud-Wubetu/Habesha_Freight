class LoadModel {
  LoadModel({
    required this.id,
    required this.cargoDescription,
    required this.weightTons,
    required this.originCity,
    required this.destinationCity,
    required this.status,
    required this.offeredPriceEtb,
    this.shipperId,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
  });

  final String id;
  final String cargoDescription;
  final double weightTons;
  final String originCity;
  final String destinationCity;
  final String status;
  final double offeredPriceEtb;
  final String? shipperId;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;

  factory LoadModel.fromJson(Map<String, dynamic> json) {
    return LoadModel(
      id: json['id']?.toString() ?? '',
      cargoDescription: json['cargo_description']?.toString() ?? 'Freight',
      weightTons: _asDouble(json['weight_tons']),
      originCity: json['origin_city']?.toString() ?? '—',
      destinationCity: json['destination_city']?.toString() ?? '—',
      status: (json['status']?.toString() ?? 'POSTED').toUpperCase(),
      offeredPriceEtb: _asDouble(json['offered_price_etb']),
      shipperId: json['shipper_id']?.toString(),
      originLat: _asDoubleOrNull(json['origin_lat']),
      originLng: _asDoubleOrNull(json['origin_lng']),
      destinationLat: _asDoubleOrNull(json['destination_lat']),
      destinationLng: _asDoubleOrNull(json['destination_lng']),
    );
  }
}

double _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  return _asDouble(v);
}

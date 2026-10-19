import 'api_client.dart';
import '../config/api_config.dart';

class EscrowItem {
  EscrowItem({
    required this.id,
    required this.shipmentId,
    required this.status,
    required this.grossAmount,
    required this.netPayout,
    required this.commission,
    this.gatewayReference,
    this.cargo,
    this.origin,
    this.destination,
    this.carrierName,
    this.createdAt,
  });

  final String id;
  final String shipmentId;
  final String status;
  final double grossAmount;
  final double netPayout;
  final double commission;
  final String? gatewayReference;
  final String? cargo;
  final String? origin;
  final String? destination;
  final String? carrierName;
  final DateTime? createdAt;

  factory EscrowItem.fromJson(Map<String, dynamic> json) {
    return EscrowItem(
      id: json['id']?.toString() ?? '',
      shipmentId: json['shipment_id']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      grossAmount: _num(json['gross_amount_etb'] ?? json['amount_etb']),
      netPayout: _num(json['net_payout_amount_etb'] ?? json['gross_amount_etb']),
      commission: _num(json['commission_amount_etb']),
      gatewayReference: json['gateway_reference']?.toString(),
      cargo: json['cargo_description']?.toString(),
      origin: json['origin_city']?.toString(),
      destination: json['destination_city']?.toString(),
      carrierName: json['carrier_name']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class EscrowLedgerSummary {
  EscrowLedgerSummary({
    required this.totalLocked,
    required this.totalReleased,
    required this.totalRefunded,
    required this.items,
  });

  final double totalLocked;
  final double totalReleased;
  final double totalRefunded;
  final List<EscrowItem> items;
}

class EscrowService {
  EscrowService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<EscrowLedgerSummary> getLedger() async {
    final res = await _api.get(ApiConfig.escrowLedger);
    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawItems = data['items'];
    final items = <EscrowItem>[];
    if (rawItems is List) {
      for (final row in rawItems) {
        if (row is Map) {
          items.add(EscrowItem.fromJson(row.cast<String, dynamic>()));
        }
      }
    }
    return EscrowLedgerSummary(
      totalLocked: _num(data['totalLocked']),
      totalReleased: _num(data['totalReleased']),
      totalRefunded: _num(data['totalRefunded']),
      items: items,
    );
  }
}

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

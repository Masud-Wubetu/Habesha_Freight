import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/escrow_service.dart';
import 'package:mobile/core/services/fleet_service.dart';

void main() {
  group('FleetService parsers', () {
    test('CompanyStats.fromJson maps nested company stats payload', () {
      final stats = CompanyStats.fromJson({
        'vehicles': {'total': 4, 'active': 3},
        'drivers': {'total': 2, 'active': 2},
        'shipments': {'total': 1, 'in_transit': 0, 'delivered': 0},
        'earnings': 125000.5,
        'rating': {'average': 4.5},
      });
      expect(stats.vehiclesTotal, 4);
      expect(stats.vehiclesActive, 3);
      expect(stats.driversTotal, 2);
      expect(stats.totalEarnings, 125000.5);
      expect(stats.averageRating, 4.5);
    });

    test('FleetVehicle.fromJson accepts plate + type fields', () {
      final v = FleetVehicle.fromJson({
        'id': 'v1',
        'plate_number': 'ET-3-FLEET1',
        'vehicle_type': 'SINO_TRUCK',
        'is_active': true,
        'verification_status': 'VERIFIED',
        'capacity_tons': 40,
      });
      expect(v.plateNumber, 'ET-3-FLEET1');
      expect(v.makeModel, 'SINO_TRUCK');
      expect(v.isActive, isTrue);
      expect(v.capacityTons, 40);
    });

    test('FleetDriver.fromJson maps company_drivers join shape', () {
      final d = FleetDriver.fromJson({
        'driver_id': 'd1',
        'full_name': 'Abebe Kebede',
        'phone_number': '+251911222333',
        'status': 'ACTIVE',
        'kyc_status': 'APPROVED',
        'is_verified': true,
      });
      expect(d.id, 'd1');
      expect(d.fullName, 'Abebe Kebede');
      expect(d.status, 'ACTIVE');
      expect(d.isVerified, isTrue);
    });

    test('CompanyProfile.fromJson prefers company_name then full_name', () {
      final p = CompanyProfile.fromJson({
        'full_name': 'Ethio Logistics PLC',
        'email': 'fleet@habeshafreight.et',
      });
      expect(p.name, 'Ethio Logistics PLC');
    });
  });

  group('EscrowService parsers', () {
    test('EscrowItem.fromJson maps ledger row', () {
      final item = EscrowItem.fromJson({
        'id': 'e1',
        'shipment_id': 's1',
        'status': 'LOCKED',
        'gross_amount_etb': 50000,
        'net_payout_amount_etb': 47500,
        'commission_amount_etb': 2500,
        'origin_city': 'Addis Ababa',
        'destination_city': 'Hawassa',
        'cargo_description': 'Cement',
        'carrier_name': 'Abebe Kebede',
      });
      expect(item.grossAmount, 50000);
      expect(item.netPayout, 47500);
      expect(item.origin, 'Addis Ababa');
      expect(item.status, 'LOCKED');
    });
  });
}

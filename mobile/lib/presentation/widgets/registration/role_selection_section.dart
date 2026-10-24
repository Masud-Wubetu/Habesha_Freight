import 'package:flutter/material.dart';
import 'role_selection_card.dart';

class RoleSelectionSection extends StatelessWidget {
  final UserRegistrationRole selectedRole;
  final ValueChanged<UserRegistrationRole> onRoleChanged;

  const RoleSelectionSection({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  static const List<RoleCardData> roles = [
    RoleCardData(
      role: UserRegistrationRole.shipper,
      title: 'Cargo Shipper',
      icon: Icons.inventory_2_outlined,
    ),
    RoleCardData(
      role: UserRegistrationRole.driver,
      title: 'Truck Carrier / Driver',
      icon: Icons.local_shipping_outlined,
    ),
    RoleCardData(
      role: UserRegistrationRole.fleetEnterprise,
      title: 'Fleet Enterprise',
      icon: Icons.domain_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: roles.map((data) {
        return RoleSelectionCard(
          data: data,
          isSelected: selectedRole == data.role,
          onSelect: () => onRoleChanged(data.role),
        );
      }).toList(),
    );
  }
}

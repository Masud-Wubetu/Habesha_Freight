import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
      badgeText: 'Direct Booking',
      badgeTextColor: Color(0xFF38BDF8),
      badgeBgColor: Color(0xFF0C243B),
      badgeBorderColor: Color(0xFF0369A1),
      icon: Icons.devices_rounded,
      description:
          'Post regional freight, compare lane rates, and track cargo dispatched from major depots to ports.',
    ),
    RoleCardData(
      role: UserRegistrationRole.driver,
      title: 'Truck Carrier / Driver',
      badgeText: 'Instant Bids',
      badgeTextColor: AppColors.badgeGreenText,
      badgeBgColor: AppColors.badgeGreenBg,
      badgeBorderColor: AppColors.badgeGreenBorder,
      icon: Icons.local_shipping_outlined,
      description:
          'Access high-demand road manifests, lock in verified shipments, and get fast payout clearance.',
    ),
    RoleCardData(
      role: UserRegistrationRole.fleetEnterprise,
      title: 'Fleet Enterprise',
      badgeText: 'Multi-Asset',
      badgeTextColor: AppColors.badgeAmberText,
      badgeBgColor: AppColors.badgeAmberBg,
      badgeBorderColor: AppColors.badgeAmberBorder,
      icon: Icons.domain_outlined,
      description:
          'Command line-haul fleet telematics, assign multiple operators, and reconcile automated invoicing.',
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

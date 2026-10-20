import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/registration/registration_step_header.dart';
import '../widgets/registration/role_selection_card.dart';
import '../widgets/registration/role_selection_section.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  UserRegistrationRole _selectedRole = UserRegistrationRole.shipper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RegistrationStepHeader(),
                const SizedBox(height: 20),
                RoleSelectionSection(
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) => setState(() => _selectedRole = role),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../widgets/registration/primary_contact_details_card.dart';
import '../widgets/registration/registration_step_header.dart';
import '../widgets/registration/role_selection_card.dart';
import '../widgets/registration/role_selection_section.dart';
import '../widgets/navigation/corridor_navigation_sheet.dart';
import 'verify_otp_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  UserRegistrationRole _selectedRole = UserRegistrationRole.shipper;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onVerificationSuccess(UserModel user, String token) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account registered & verified as ${user.role}!'),
        backgroundColor: AppColors.card,
      ),
    );

    if (_selectedRole == UserRegistrationRole.fleetEnterprise) {
      Navigator.pushReplacementNamed(context, AppRoutes.fleetHub);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _handleContinue() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Attempt to register
    final regRes = await _auth.register(
      fullName: name,
      email: email,
      password: password,
      role: _selectedRole.backendRole,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    // If already registered or error, display clear error message to user
    if (!regRes.success) {
      setState(() {
        _error = regRes.message.isNotEmpty
            ? regRes.message
            : 'Registration failed. An account with this email may already exist.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: AppColors.errorStrong,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to $email'),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to dedicated Page 04: Verify OTP Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyOtpScreen(
          email: email,
          demoOtp: regRes.demoOtp,
          role: _selectedRole.backendRole,
          fullName: name,
          onVerified: _onVerificationSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                        tooltip: 'Back',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.card,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      Text(
                        'Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => CorridorNavigationSheet.show(context),
                        icon: const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.gold),
                        tooltip: 'All Corridor Modules',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.card,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const RegistrationStepHeader(),
                  const SizedBox(height: 20),
                  RoleSelectionSection(
                    selectedRole: _selectedRole,
                    onRoleChanged: (role) => setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 16),
                  PrimaryContactDetailsCard(
                    fullNameController: _nameCtrl,
                    emailController: _emailCtrl,
                    passwordController: _passwordCtrl,
                    errorText: _error,
                  ),
                  const SizedBox(height: 24),

                  // Continue to Verification Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textDark,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue to Verification',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Footer: Already have a carrier profile? Log In
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            }
                          },
                          child: Text(
                            'Log In',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

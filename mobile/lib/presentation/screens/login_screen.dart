import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/login_header.dart';
import '../widgets/password_auth_view.dart';
import '../widgets/phone_auth_view.dart';
import '../widgets/telebirr_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  AuthTab _activeTab = AuthTab.phone;

  @override
  void initState() {
    super.initState();
    _activeTab = AuthTab.phone;
  }

  void _onAuthenticated(UserModel user, String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Authenticated!',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.fullName}',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Role: ${user.role}',
                style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
            Text('Phone: ${user.phoneNumber}',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            Text('Status: ${user.status} (KYC: ${user.kycStatus})',
                style: GoogleFonts.inter(color: AppColors.badgeGreenText, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.gold)),
          ),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Header & Badge
                  const LoginHeader(),
                  const SizedBox(height: 28),

                  // Main Login Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Title
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Card Subtitle
                        Text(
                          'Sign in to coordinate loads and track fleet telemetry.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tab Switcher
                        AuthTabSwitcher(
                          activeTab: _activeTab,
                          onTabChanged: (tab) {
                            setState(() => _activeTab = tab);
                          },
                        ),
                        const SizedBox(height: 22),

                        // Active Tab Content
                        if (_activeTab == AuthTab.phone)
                          PhoneAuthView(
                            authService: _authService,
                            onAuthenticated: _onAuthenticated,
                          )
                        else
                          PasswordAuthView(
                            authService: _authService,
                            onAuthenticated: _onAuthenticated,
                          ),
                        const SizedBox(height: 22),
                        TelebirrAuthButton(
                          authService: _authService,
                          onAuthenticated: _onAuthenticated,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


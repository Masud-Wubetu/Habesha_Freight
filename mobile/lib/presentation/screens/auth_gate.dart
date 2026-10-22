import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/screens/driver/driver_home_screen.dart';
import 'package:mobile/presentation/screens/fleet/fleet_shell_screen.dart';
import 'package:mobile/presentation/screens/home_screen.dart';
import 'package:mobile/presentation/screens/login_screen.dart';
import 'package:mobile/presentation/screens/shipper/shipper_shell_screen.dart';
import 'package:mobile/presentation/widgets/navigation/corridor_navigation_sheet.dart';

/// Restores a backend session via `/auth/me`, or shows login.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _api = ApiClient();

  bool _loading = true;
  bool _backendUp = false;
  bool _authenticated = false;
  String? _status;
  String? _userLabel;
  String? _role;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _status = 'Connecting to API…';
    });

    final healthy = await _api.pingHealth();
    var authed = false;
    String? label;
    String? role;

    if (healthy) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        setState(() => _status = 'Restoring session…');
        final me = await _auth.getMe();
        if (me != null) {
          authed = true;
          role = me.role;
          label = '${me.fullName} · ${me.role}';
        } else {
          await StorageService.clearAuthData();
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _backendUp = healthy;
      _authenticated = authed;
      _userLabel = label;
      _role = role;
      _loading = false;
      _status = healthy
          ? (authed ? 'Session restored' : 'Sign in to continue')
          : 'Backend unreachable — check API on :5000 or :5001';
    });
  }

  Future<void> _onAuthenticated() async {
    final role = await StorageService.getUserRole();
    final name = await StorageService.getUserName();
    if (!mounted) return;
    setState(() {
      _authenticated = true;
      _loading = false;
      _role = role;
      _userLabel = [
        if (name != null && name.isNotEmpty) name,
        if (role != null && role.isNotEmpty) role,
      ].join(' · ');
      _status = 'Authenticated';
    });
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
      _status = 'Signing out…';
    });
    await _auth.logout();
    if (!mounted) return;
    setState(() {
      _authenticated = false;
      _userLabel = null;
      _role = null;
      _loading = false;
      _status = 'Signed out';
    });
  }

  Widget _homeForRole() {
    final role = (_role ?? '').toUpperCase();
    switch (role) {
      case 'SHIPPER':
        return const ShipperShellScreen();
      case 'DRIVER':
        return const DriverHomeScreen();
      case 'FLEET_OWNER':
        return FleetShellScreen(
          userLabel: _userLabel,
          onLogout: _logout,
        );
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) {
      return _homeForRole();
    }

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryContainer),
              const SizedBox(height: 16),
              Text(
                _status ?? 'Loading…',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        LoginScreen(
          backendUp: _backendUp,
          statusMessage: _status,
          onAuthenticated: _onAuthenticated,
          onRetryConnection: _bootstrap,
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: SafeArea(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.register),
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () => CorridorNavigationSheet.show(context),
                  child: const Text('Explore modules'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

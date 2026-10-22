import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/screens/driver/driver_home_screen.dart';
import 'package:mobile/presentation/screens/fleet/fleet_shell_screen.dart';
import 'package:mobile/presentation/screens/home_screen.dart';
import 'package:mobile/presentation/screens/login_screen.dart';

/// Authentication gate:
/// - Boots into LoginScreen on unauthenticated launch (NO automatic login bypass).
/// - If a valid active session exists, routes dynamically to the user's role interface:
///   * SHIPPER ➔ HomeScreen (Pages 01–15, Loads & Telemetry)
///   * DRIVER ➔ DriverHomeScreen (Pages 16–19, Carrier Actions)
///   * FLEET_OWNER / ADMIN ➔ FleetShellScreen (Pages 27–34, Fleet Command)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _api = ApiClient();

  bool _loading = true;
  bool _authenticated = false;
  String? _userRole;
  String? _status = 'Checking backend…';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _status = 'Checking backend…';
    });

    try {
      final token = await StorageService.getToken();
      final role = await StorageService.getUserRole();
      final authed = token != null && token.isNotEmpty;

      if (authed) {
        final healthy = await _api.pingHealth();
        if (healthy) {
          final me = await _auth.getMe();
          if (me != null) {
            if (!mounted) return;
            setState(() {
              _authenticated = true;
              _userRole = me.role;
              _loading = false;
              _status = 'Authenticated as ${me.fullName}';
            });
            return;
          } else {
            // Token expired or invalid
            await StorageService.clearAuthData();
          }
        } else {
          // Backend offline: restore session with cached role
          if (!mounted) return;
          setState(() {
            _authenticated = true;
            _userRole = role;
            _loading = false;
            _status = 'Restored cached session';
          });
          return;
        }
      }
    } catch (_) {
      // Silently fall back to LoginScreen
    }

    if (!mounted) return;
    setState(() {
      _authenticated = false;
      _userRole = null;
      _loading = false;
      _status = 'Ready to sign in';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_shipping,
                size: 48,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(height: 12),
              Text(
                'HabeshaFreight Mobile',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status ?? 'Checking backend…',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_authenticated) {
      switch (_userRole?.toUpperCase()) {
        case 'SHIPPER':
          return const HomeScreen();
        case 'DRIVER':
          return const DriverHomeScreen();
        case 'FLEET_OWNER':
        case 'ADMIN':
        default:
          return const FleetShellScreen();
      }
    }

    return const LoginScreen();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/storage_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/presentation/screens/fleet/fleet_shell_screen.dart';
import 'package:mobile/presentation/screens/login_screen.dart';

/// Boots into fleet shell when a session exists; otherwise login.
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

    final healthy = await _api.pingHealth();
    final token = await StorageService.getToken();
    var authed = token != null && token.isNotEmpty;

    if (authed && healthy) {
      final me = await _auth.getMe();
      authed = me != null;
      if (!authed) await StorageService.clearAuthData();
    }

    if (!mounted) return;

    // Web / local demo: when API is up and no session, sign in as fleet owner
    // so integrated screens are immediately visible in the browser.
    if (healthy && !authed) {
      setState(() {
        _backendUp = true;
        _loading = true;
        _status = 'Signing in as fleet owner…';
      });
      final res = await _auth.login(
        identifier: 'fleet@habeshafreight.et',
        password: 'Password123!',
      );
      if (!mounted) return;
      if (res.success) {
        setState(() {
          _authenticated = true;
          _loading = false;
          _status = 'Authenticated as ${res.user?.fullName ?? 'Fleet'}';
        });
        return;
      }
      setState(() {
        _backendUp = true;
        _authenticated = false;
        _loading = false;
        _status = res.message;
      });
      return;
    }

    setState(() {
      _backendUp = healthy;
      _authenticated = authed;
      _loading = false;
      _status = healthy
          ? (authed ? 'Session restored' : 'Ready to sign in')
          : 'Backend unreachable — demo UI still available';
    });
  }

  Future<void> _demoFleetLogin() async {
    setState(() {
      _loading = true;
      _status = 'Signing in as fleet owner…';
    });
    final res = await _auth.login(
      identifier: 'fleet@habeshafreight.et',
      password: 'Password123!',
    );
    if (!mounted) return;
    if (res.success) {
      setState(() {
        _authenticated = true;
        _loading = false;
        _status = 'Authenticated as ${res.user?.fullName ?? 'Fleet'}';
      });
    } else {
      setState(() {
        _loading = false;
        _status = res.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) {
      return const FleetShellScreen();
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

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.local_shipping,
                size: 48,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(height: 12),
              Text(
                'HabeshaFreight Mobile',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _backendUp ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: _backendUp ? AppColors.secondary : AppColors.errorStrong,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _backendUp ? 'API online' : 'API offline',
                    style: TextStyle(
                      color: _backendUp ? AppColors.secondary : AppColors.errorStrong,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _backendUp ? _demoFleetLogin : null,
                child: const Text('Continue as Fleet Owner (demo)'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) => _bootstrap());
                },
                child: const Text('Sign in manually'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() => _authenticated = true);
                },
                child: const Text(
                  'Browse UI without API',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: _bootstrap,
                child: const Text('Retry connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ethiopian_flag.dart';
import '../../data/models/user_model.dart';

// ============================================================================
// AUTH TABS ENUM
// ============================================================================
enum AuthTab { phone, password }

// ============================================================================
// MAIN LOGIN SCREEN
// ============================================================================
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
            const Icon(Icons.check_circle_rounded, color: AppColors.badgeGreenText, size: 24),
            const SizedBox(width: 10),
            Text(
              'Authenticated',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.fullName}!',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            _infoRow('Role', user.role),
            _infoRow('Phone', user.phoneNumber),
            _infoRow('Status', user.status),
            _infoRow('KYC', user.kycStatus),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Proceed to Fleet'),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Brand Header
                  const _LoginHeader(),
                  const SizedBox(height: 28),

                  // 2. Card Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Title
                        Text(
                          'Carrier & Shipper Portal',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
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
                        _AuthTabSwitcher(
                          activeTab: _activeTab,
                          onTabChanged: (tab) {
                            setState(() => _activeTab = tab);
                          },
                        ),
                        const SizedBox(height: 22),

                        // Active Tab Content
                        if (_activeTab == AuthTab.phone)
                          _PhoneAuthView(
                            authService: _authService,
                            onAuthenticated: _onAuthenticated,
                          )
                        else
                          _PasswordAuthView(
                            authService: _authService,
                            onAuthenticated: _onAuthenticated,
                          ),
                        const SizedBox(height: 22),

                        _TelebirrAuthButton(
                          authService: _authService,
                          onAuthenticated: _onAuthenticated,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Footer
                  const _LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. LOGIN HEADER WIDGET
// ============================================================================
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        // Brand Logo Row (Squircle Truck + "Habesha Freight")
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF162137),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF263756),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.gold,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                children: const [
                  TextSpan(
                    text: 'Habesha ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Freight',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // National Freight Network Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.badgeGreenBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.badgeGreenBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.badgeGreenText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'National Freight Network',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeGreenText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 2. AUTH TAB SWITCHER
// ============================================================================
class _AuthTabSwitcher extends StatelessWidget {
  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;

  const _AuthTabSwitcher({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E2D48),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Phone OTP',
              icon: Icons.phone_android_rounded,
              isSelected: activeTab == AuthTab.phone,
              onTap: () => onTabChanged(AuthTab.phone),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              title: 'Password',
              icon: Icons.lock_outline_rounded,
              isSelected: activeTab == AuthTab.password,
              onTap: () => onTabChanged(AuthTab.password),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E2D48) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? AppColors.gold : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. PHONE AUTH VIEW
// ============================================================================
class _PhoneAuthView extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;

  const _PhoneAuthView({
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<_PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<_PhoneAuthView> {
  final TextEditingController _phoneController =
      TextEditingController(text: '92 265 4321');
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _formattedFullPhone {
    final raw = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (raw.startsWith('+251')) return raw;
    if (raw.startsWith('09') || raw.startsWith('07')) {
      return '+251${raw.substring(1)}';
    }
    if (raw.startsWith('9') || raw.startsWith('7')) {
      return '+251$raw';
    }
    return '+251$raw';
  }

  Future<void> _handleRequestOtp() async {
    final rawNumber = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (rawNumber.length < 8) {
      setState(() => _errorMessage = 'Please enter a valid Ethiopian mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = _formattedFullPhone;
    final response = await widget.authService.sendOtp(phoneNumber: fullPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _OtpVerificationSheet(
          phoneNumber: fullPhone,
          initialDemoOtp: response.demoOtp,
          authService: widget.authService,
          onVerified: widget.onAuthenticated,
        ),
      );
    } else {
      setState(() {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to request OTP code. Please check your number.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorMessage != null
                  ? AppColors.error
                  : (_isFocused ? AppColors.gold : AppColors.cardBorder),
              width: _isFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const EthiopianFlag(width: 26, height: 17),
              const SizedBox(width: 10),
              Text(
                '+251',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 22, color: const Color(0xFF263756)),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '91 234 5678',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (_) => _handleRequestOtp(),
                ),
              ),
            ],
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRequestOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textDark,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Request OTP Code',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 4. PASSWORD AUTH VIEW
// ============================================================================
class _PasswordAuthView extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;

  const _PasswordAuthView({
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<_PasswordAuthView> createState() => _PasswordAuthViewState();
}

class _PasswordAuthViewState extends State<_PasswordAuthView> {
  final TextEditingController _identifierController =
      TextEditingController(text: '+251922654321');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Password123!');

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();

  bool _idFocused = false;
  bool _passFocused = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _idFocusNode.addListener(() {
      if (mounted) setState(() => _idFocused = _idFocusNode.hasFocus);
    });
    _passFocusNode.addListener(() {
      if (mounted) setState(() => _passFocused = _passFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number or email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.authService.login(
      identifier: identifier,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success && response.user != null && response.token != null) {
      widget.onAuthenticated(response.user!, response.token!);
    } else {
      setState(() {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Invalid credentials. Please verify your phone/email and password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number or Email',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _idFocused ? AppColors.gold : AppColors.cardBorder,
              width: _idFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _identifierController,
                  focusNode: _idFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '+251 92 265 4321 or user@email.com',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (_) => _passFocusNode.requestFocus(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please use OTP login to recover access.'),
                    backgroundColor: AppColors.card,
                  ),
                );
              },
              child: Text(
                'Forgot?',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _passFocused ? AppColors.gold : AppColors.cardBorder,
              width: _passFocused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  focusNode: _passFocusNode,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ],
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textDark),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sign In', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 5. OTP VERIFICATION BOTTOM SHEET
// ============================================================================
class _OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;
  final String? initialDemoOtp;
  final AuthService authService;
  final void Function(UserModel user, String token) onVerified;

  const _OtpVerificationSheet({
    required this.phoneNumber,
    this.initialDemoOtp,
    required this.authService,
    required this.onVerified,
  });

  @override
  State<_OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<_OtpVerificationSheet> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;
  String? _errorMessage;
  String? _currentDemoOtp;

  @override
  void initState() {
    super.initState();
    _currentDemoOtp = widget.initialDemoOtp;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _applyOtp(String code) {
    final clean = code.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < _otpLength; i++) {
      if (i < clean.length) {
        _controllers[i].text = clean[i];
      } else {
        _controllers[i].clear();
      }
    }
    if (clean.length >= _otpLength) {
      _handleVerify();
    } else {
      _focusNodes[clean.length.clamp(0, _otpLength - 1)].requestFocus();
    }
  }

  Future<void> _handleVerify() async {
    final otp = _enteredOtp;
    if (otp.length != _otpLength) {
      setState(() => _errorMessage = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final response = await widget.authService.verifyOtp(
      phoneNumber: widget.phoneNumber,
      otpCode: otp,
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (response.success && response.user != null && response.token != null) {
      Navigator.pop(context);
      widget.onVerified(response.user!, response.token!);
    } else {
      setState(() {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Invalid or expired OTP code. Please try again.';
      });
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    setState(() {
      _errorMessage = null;
    });

    final response = await widget.authService.sendOtp(
      phoneNumber: widget.phoneNumber,
    );

    if (!mounted) return;
    if (response.success) {
      setState(() => _currentDemoOtp = response.demoOtp);
      _startCountdown();
    } else {
      setState(() => _errorMessage = response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Enter Verification Code',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit SMS code to ${widget.phoneNumber}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          if (_currentDemoOtp != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.badgeAmberBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.badgeAmberBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dev OTP Code: $_currentDemoOtp',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.badgeAmberText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _applyOtp(_currentDemoOtp!),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Auto-Fill',
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
            const SizedBox(height: 18),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 44,
                height: 52,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.gold, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < _otpLength - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (_enteredOtp.length == _otpLength) {
                      _handleVerify();
                    }
                  },
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                    )
                  : Text(
                      'Verify & Sign In',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: _resendCountdown == 0 ? _handleResend : null,
              child: Text(
                _resendCountdown > 0
                    ? 'Resend SMS in ${_resendCountdown}s'
                    : 'Resend Code',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _resendCountdown > 0 ? AppColors.textMuted : AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. TELEBIRR AUTH BUTTON
// ============================================================================
class _TelebirrAuthButton extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;

  const _TelebirrAuthButton({
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<_TelebirrAuthButton> createState() => _TelebirrAuthButtonState();
}

class _TelebirrAuthButtonState extends State<_TelebirrAuthButton> {
  bool _isLoading = false;

  Future<void> _handleTelebirrAuth() async {
    const phoneNumber = '+251911234567';
    setState(() => _isLoading = true);

    final response = await widget.authService.telebirrLogin(
      phoneNumber: phoneNumber,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success && response.user != null && response.token != null) {
      widget.onAuthenticated(response.user!, response.token!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Telebirr authentication failed. Please try again.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleTelebirrAuth,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.telebirrButton,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.telebirrBorder),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.telebirrBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.bolt_rounded, color: AppColors.telebirrBlue, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Auth with Telebirr',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instant SuperApp verification',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.telebirrBlue),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 7. LOGIN FOOTER WIDGET
// ============================================================================
class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 22),
            const SizedBox(width: 10),
            Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        content: Text(
          content,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.person_add_rounded, color: AppColors.gold, size: 22),
            const SizedBox(width: 10),
            Text('Create Carrier Account', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your enterprise role to begin registration with the Ethiopian Transport Authority:',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            _roleTile(
              context,
              icon: Icons.local_shipping_rounded,
              title: 'Heavy Truck Driver',
              subtitle: 'Dry port corridor & cross-border freight',
              content: 'Driver registration requires Grade 4 or Grade 5 Ethiopian driving license, cross-border permit, and vehicle GPS telemetry unit registration.',
            ),
            const SizedBox(height: 10),
            _roleTile(
              context,
              icon: Icons.business_rounded,
              title: 'Fleet Carrier / Operator',
              subtitle: 'Multi-truck dispatch & cargo telemetry management',
              content: 'Carrier registration requires Ethiopian Commercial Registration Certificate, TIN number, and fleet size verification (minimum 3 heavy commercial trucks).',
            ),
            const SizedBox(height: 10),
            _roleTile(
              context,
              icon: Icons.inventory_2_rounded,
              title: 'Cargo Shipper / Importer',
              subtitle: 'Container booking & shipment tracking',
              content: 'Shippers can book container loads from Djibouti Doraleh Port, Modjo Dry Port, and regional dry terminals with automatic customs declaration linkage.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _roleTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required String content}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showInfoDialog(context, title: title, icon: icon, content: content);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Don't have an enterprise account? ", style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => _showRegistrationDialog(context),
              child: Text(
                'Register Now',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _footerLink('Carrier Terms', () {
              _showInfoDialog(
                context,
                title: 'Carrier Terms of Service',
                icon: Icons.gavel_rounded,
                content: 'All logistics operations conform to Ethiopian Transport Authority regulations.',
              );
            }),
            _dot(),
            _footerLink('Support Desk', () {
              _showInfoDialog(
                context,
                title: 'Dispatch Support Center',
                icon: Icons.headset_mic_rounded,
                content: 'INSA & Habesha Freight 24/7 Logistics Command:\n\n• Corridor Hotline: +251 11 551 2233\n• Email: dispatch@habeshafreight.et',
              );
            }),
            _dot(),
            _footerLink('Port Corridors', () {
              _showInfoDialog(
                context,
                title: 'Active Freight Corridors',
                icon: Icons.alt_route_rounded,
                content: '1. Djibouti (Doraleh) ⇄ Modjo Dry Port (780 km)\n2. Djibouti ⇄ Galafi (210 km)\n3. Berbera ⇄ Dire Dawa (450 km)',
              );
            }),
          ],
        ),
        const SizedBox(height: 14),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 13, color: AppColors.badgeGreenText),
            const SizedBox(width: 6),
            Text('Habesha Freight v1.0.0 • 256-bit TLS Encrypted Telemetry', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(color: AppColors.cardBorder, shape: BoxShape.circle),
    );
  }
}

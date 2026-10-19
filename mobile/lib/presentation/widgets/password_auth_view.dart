import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';

class PasswordAuthView extends StatefulWidget {
  final AuthService authService;
  final void Function(UserModel user, String token) onAuthenticated;

  const PasswordAuthView({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<PasswordAuthView> createState() => _PasswordAuthViewState();
}

class _PasswordAuthViewState extends State<PasswordAuthView> {
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
        // Identifier Label
        Text(
          'Mobile Number or Email',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Identifier Input
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
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '+251 92 265 4321 or user@email.com',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onFieldSubmitted: (_) => _passFocusNode.requestFocus(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Password Label & Forgot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
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

        // Password Input
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
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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

        // Error
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

        // Sign In Button
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

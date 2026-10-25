import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PrimaryContactDetailsCard extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? errorText;

  const PrimaryContactDetailsCard({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    this.errorText,
  });

  @override
  State<PrimaryContactDetailsCard> createState() => _PrimaryContactDetailsCardState();
}

class _PrimaryContactDetailsCardState extends State<PrimaryContactDetailsCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Account Credentials',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Field 1: Full Name
          Text(
            'Full Name',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: TextField(
              controller: widget.fullNameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                hintText: 'Enter your full name',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 2: Email Address
          Text(
            'Email Address',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: TextField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                hintText: 'name@example.com',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 3: Password
          Text(
            'Password',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: TextField(
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              autocorrect: false,
              enableSuggestions: false,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
                hintText: 'At least 6 characters',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),

          if (widget.errorText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorStrong.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorStrong.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.errorStrong),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.errorStrong,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

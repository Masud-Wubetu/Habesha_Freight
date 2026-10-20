import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class OtpNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onMessageAction;

  const OtpNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onMessageAction,
  });

  static const List<Map<String, String>> _keys = [
    {'digit': '1', 'sub': '---'},
    {'digit': '2', 'sub': 'ABC'},
    {'digit': '3', 'sub': 'DEF'},
    {'digit': '4', 'sub': 'GHI'},
    {'digit': '5', 'sub': 'JKL'},
    {'digit': '6', 'sub': 'MNO'},
    {'digit': '7', 'sub': 'PQRS'},
    {'digit': '8', 'sub': 'TUV'},
    {'digit': '9', 'sub': 'WXYZ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rows 1 to 3: 1 through 9
        for (int r = 0; r < 3; r++) ...[
          Row(
            children: [
              for (int c = 0; c < 3; c++) ...[
                if (c > 0) const SizedBox(width: 8),
                Expanded(
                  child: _keyButton(
                    digit: _keys[r * 3 + c]['digit']!,
                    sub: _keys[r * 3 + c]['sub']!,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Row 4: SMS action, 0, Backspace
        Row(
          children: [
            // Bottom Left: SMS / Message Icon
            Expanded(
              child: _specialButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.gold,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (onMessageAction != null) {
                    onMessageAction!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification code delivered via Ethio Telecom Shortcode 8820'),
                        backgroundColor: Color(0xFF0F1A2D),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),

            // Bottom Center: 0 (+)
            Expanded(
              child: _keyButton(digit: '0', sub: '+'),
            ),
            const SizedBox(width: 8),

            // Bottom Right: Backspace
            Expanded(
              child: _specialButton(
                icon: Icons.backspace_outlined,
                iconColor: const Color(0xFFCBD5E1),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onBackspace();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keyButton({required String digit, required String sub}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onDigit(digit);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E2E4A), width: 1.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specialButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E2E4A), width: 1.1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

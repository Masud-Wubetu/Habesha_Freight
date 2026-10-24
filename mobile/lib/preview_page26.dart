import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/shipper_features/instant_escrow_payout_settlement_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Page26PreviewApp());
}

class Page26PreviewApp extends StatelessWidget {
  const Page26PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page 26 Preview - Instant Escrow Payout Settlement',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const InstantEscrowPayoutSettlementScreen(),
    );
  }
}

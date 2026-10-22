import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/shipper_features/incident_route_sos_report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Page25PreviewApp());
}

class Page25PreviewApp extends StatelessWidget {
  const Page25PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page 25 Preview - Incident & Route SOS Report',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const IncidentRouteSosReportScreen(),
    );
  }
}

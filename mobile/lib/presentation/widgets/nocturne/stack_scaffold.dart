import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';

import 'package:mobile/core/routing/app_routes.dart';
import 'package:mobile/presentation/widgets/navigation/corridor_navigation_sheet.dart';

/// Stack shell: AppBar with back, title, optional actions — no bottom nav.
class StackScaffold extends StatelessWidget {
  const StackScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor = AppColors.surface,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.onSurface,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, size: 20),
            color: AppColors.primaryContainer,
            tooltip: 'All Corridor Modules',
            onPressed: () => CorridorNavigationSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined, size: 20),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Shipper Portal',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
          ),
          ...?actions,
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

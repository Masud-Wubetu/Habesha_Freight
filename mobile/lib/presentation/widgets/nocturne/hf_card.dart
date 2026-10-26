import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Rounded-xl surface card using AppColors.surfaceContainer.
class HfCard extends StatelessWidget {
  const HfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = AppColors.surfaceContainer,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
    this.radius = 12,
    this.gradient,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final Gradient? gradient;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

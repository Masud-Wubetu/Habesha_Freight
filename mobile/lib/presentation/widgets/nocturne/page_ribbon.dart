import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Pill badge: "PAGE XX: TITLE | status" with green ping dot.
class PageRibbon extends StatefulWidget {
  const PageRibbon({
    super.key,
    required this.page,
    required this.title,
    this.status,
    this.dotColor = AppColors.secondary,
    this.textColor = AppColors.secondary,
  });

  final String page;
  final String title;
  final String? status;
  final Color dotColor;
  final Color textColor;

  @override
  State<PageRibbon> createState() => _PageRibbonState();
}

class _PageRibbonState extends State<PageRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ping;

  @override
  void initState() {
    super.initState();
    _ping = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ping,
              builder: (context, child) {
                final t = _ping.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 1 + t,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.dotColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                    child!,
                  ],
                );
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.dotColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'PAGE ${widget.page}: ${widget.title}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: widget.textColor,
                      ),
                    ),
                    if (widget.status != null) ...[
                      TextSpan(
                        text: ' | ${widget.status}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

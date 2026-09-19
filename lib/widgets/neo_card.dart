import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Flat Neo-brutalist / SaaS card with bold 2px black outline,
/// soft pastel fill, and zero gradients/shadows.
class NeoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final double borderWidth;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor = AppTheme.bgSurface,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = AppTheme.radiusMedium,
    this.onTap,
    this.borderWidth = AppTheme.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.strokeBlack,
          width: borderWidth,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

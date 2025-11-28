import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';

/// Minimal Card Widget - Regain Style
/// Clean white card with soft shadow and rounded corners
class MinimalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;

  const MinimalCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusLarge,
        ),
        boxShadow: hasShadow ? AppTheme.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusLarge,
        ),
        child: card,
      );
    }

    return card;
  }
}

import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';

/// Stat Card Widget - Regain Style
/// Small square card displaying a statistic with label
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.value,
    required this.label,
    this.icon,
    this.accentColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
            ],
            Text(
              value,
              style: AppTheme.h2.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

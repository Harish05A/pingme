import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';

/// Tag Chip Widget - Regain Style
/// Small rounded pill for categories/tags
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.accent;
    final backgroundColor =
        isSelected ? chipColor : chipColor.withValues(alpha: 0.1);
    final textColor = isSelected ? AppTheme.textLight : chipColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: textColor,
              ),
              const SizedBox(width: AppTheme.spacing4),
            ],
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

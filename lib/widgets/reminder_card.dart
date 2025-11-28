import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:intl/intl.dart';

/// Reminder Card Widget - Regain Style
/// Clean swipeable card for reminders with tag chip
class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const ReminderCard({
    Key? key,
    required this.reminder,
    this.onTap,
    this.onComplete,
    this.onDelete,
  }) : super(key: key);

  Color _getCategoryColor() {
    switch (reminder.category.toLowerCase()) {
      case 'assignment':
        return AppTheme.info;
      case 'exam':
        return AppTheme.error;
      case 'event':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDeadline() {
    final now = DateTime.now();
    final deadline = reminder.deadline;
    final difference = deadline.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('h:mm a').format(deadline)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${DateFormat('h:mm a').format(deadline)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE h:mm a').format(deadline);
    } else {
      return DateFormat('MMM d, h:mm a').format(deadline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.success,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.check, color: AppTheme.textLight),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: AppTheme.textLight),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
        } else {
          onDelete?.call();
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: AppTheme.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      _formatDeadline(),
                      style: AppTheme.body2,
                    ),
                    const SizedBox(height: AppTheme.spacing8),

                    // Tag chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        reminder.category,
                        style: AppTheme.caption.copyWith(
                          color: _getCategoryColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Priority indicator
              if (reminder.priority == 'high')
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: AppTheme.error,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/services/live_update_service.dart';
import 'package:pingme/screens/student/student_main_screen.dart';

/// DistractionPopup - Full-screen popup shown when distracting app is detected
/// Displays high-priority tasks and provides navigation options
class DistractionPopup extends StatefulWidget {
  final String appName;
  final VoidCallback onDismiss;

  const DistractionPopup({
    super.key,
    required this.appName,
    required this.onDismiss,
  });

  @override
  State<DistractionPopup> createState() => _DistractionPopupState();

  /// Show the popup as a dialog
  static Future<void> show(
    BuildContext context, {
    required String appName,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Distraction Alert',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DistractionPopup(
          appName: appName,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Slide up animation
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}

class _DistractionPopupState extends State<DistractionPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final LiveUpdateService _liveUpdate = LiveUpdateService.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _liveUpdate.getTopPriorityTasks(limit: 3);
    final hasOverdue = _liveUpdate.hasOverdueTasks;
    final hasDueToday = _liveUpdate.hasTasksDueToday;

    return Material(
      type: MaterialType.transparency,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildContent(tasks, hasOverdue, hasDueToday),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '👀',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'Stay Focused',
            style: AppTheme.h2.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You opened ${widget.appName}',
            style: AppTheme.body1.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    List<ReminderModel> tasks,
    bool hasOverdue,
    bool hasDueToday,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            if (hasOverdue || hasDueToday) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasOverdue)
                    _buildStatusBadge(
                      '🔴 Overdue Tasks',
                      AppTheme.error,
                    ),
                  if (hasDueToday)
                    _buildStatusBadge(
                      '⏰ Due Today',
                      Colors.orange,
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // High priority tasks
            if (tasks.isNotEmpty) ...[
              Text(
                '📌 High Priority Tasks',
                style: AppTheme.h4.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...tasks.map((task) => _buildTaskItem(task)),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: AppTheme.success.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All caught up!',
                        style: AppTheme.h4.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No urgent tasks right now',
                        style: AppTheme.body2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTaskItem(ReminderModel task) {
    final now = DateTime.now();
    final isOverdue = task.deadline.isBefore(now);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final isDueToday =
        task.deadline.isAfter(now) && task.deadline.isBefore(tomorrow);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : task.priority.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOverdue ? AppTheme.error : task.priority.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isOverdue ? AppTheme.error : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDeadline(task.deadline, isOverdue, isDueToday),
                style: AppTheme.caption.copyWith(
                  color: isOverdue ? AppTheme.error : AppTheme.textSecondary,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priority.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.typeDisplayName,
                  style: AppTheme.caption.copyWith(
                    color: task.priority.color,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline, bool isOverdue, bool isDueToday) {
    if (isOverdue) {
      final diff = DateTime.now().difference(deadline);
      if (diff.inDays > 0) {
        return 'Overdue by ${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
      } else if (diff.inHours > 0) {
        return 'Overdue by ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
      } else {
        return 'Overdue';
      }
    } else if (isDueToday) {
      return 'Due today at ${_formatTime(deadline)}';
    } else {
      final diff = deadline.difference(DateTime.now());
      if (diff.inDays > 0) {
        return 'Due in ${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
      } else if (diff.inHours > 0) {
        return 'Due in ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
      } else {
        return 'Due soon';
      }
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleContinue,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side:
                    BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue Anyway',
                style: AppTheme.button.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleReviewNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Review Now',
                style: AppTheme.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    widget.onDismiss();
  }

  void _handleReviewNow() {
    // Close popup
    widget.onDismiss();

    // Navigate to student home (reminders tab)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const StudentMainScreen(initialTab: 1), // Reminders tab
      ),
      (route) => false,
    );
  }
}

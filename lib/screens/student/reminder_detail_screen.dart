import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:intl/intl.dart';

class ReminderDetailScreen extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderDetailScreen({
    Key? key,
    required this.reminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPriorityColor(reminder.priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getPriorityColor(reminder.priority),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getPriorityColor(reminder.priority),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${reminder.priority.name.toUpperCase()} PRIORITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(reminder.priority),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              reminder.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Type
            Row(
              children: [
                Icon(
                  _getTypeIcon(reminder.type),
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  reminder.typeDisplayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Deadline Card
            Card(
              color: reminder.isOverdue
                  ? Colors.red.withOpacity(0.1)
                  : AppTheme.primaryPurple.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: reminder.isOverdue
                              ? Colors.red
                              : AppTheme.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deadline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(reminder.deadline),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: reminder.isOverdue
                            ? Colors.red.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            reminder.isOverdue ? Icons.warning : Icons.timer,
                            size: 20,
                            color: reminder.isOverdue
                                ? Colors.red
                                : AppTheme.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimeUntilDeadline(reminder.deadline),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: reminder.isOverdue
                                  ? Colors.red
                                  : AppTheme.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reminder.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Faculty Info
            Text(
              'Created By',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  reminder.createdByName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Created Date
            Text(
              'Created On',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(reminder.createdAt),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Mark as Complete Button
            if (!reminder.isCompleted)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: reminderProvider.isLoading
                      ? null
                      : () async {
                          await reminderProvider
                              .markReminderComplete(reminder.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Reminder marked as complete!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (reminder.completedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${DateFormat('MMM dd').format(reminder.completedAt!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.low:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.assignment:
        return Icons.assignment;
      case ReminderType.exam:
        return Icons.school;
      case ReminderType.event:
        return Icons.event;
      case ReminderType.meeting:
        return Icons.people;
    }
  }

  String _formatTimeUntilDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final overdueDays = now.difference(deadline).inDays;
      if (overdueDays > 0) {
        return 'Overdue by $overdueDays ${overdueDays == 1 ? "day" : "days"}';
      } else {
        final overdueHours = now.difference(deadline).inHours;
        return 'Overdue by $overdueHours ${overdueHours == 1 ? "hour" : "hours"}';
      }
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days remaining';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours remaining';
    } else {
      return '${difference.inMinutes} minutes remaining';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/reminder_provider.dart';

class FacultyAnalyticsScreen extends StatelessWidget {
  const FacultyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final totalReminders = reminderProvider.reminders.length;
    final activeReminders = reminderProvider.pendingReminders.length;
    final completedReminders = reminderProvider.completedReminders.length;
    final overdueReminders = reminderProvider.overdueReminders.length;

    final completionRate = totalReminders > 0
        ? (completedReminders / totalReminders * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Sent',
                    value: totalReminders.toString(),
                    icon: Icons.send,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Completion',
                    value: '$completionRate%',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Status Distribution
            const Text(
              'Reminder Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _StatusCard(
                'Active', activeReminders, totalReminders, Colors.orange),
            const SizedBox(height: 12),
            _StatusCard(
                'Completed', completedReminders, totalReminders, Colors.green),
            const SizedBox(height: 12),
            _StatusCard(
                'Overdue', overdueReminders, totalReminders, Colors.red),
            const SizedBox(height: 32),

            // Reminder Type Breakdown
            const Text(
              'Reminder Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTypeBreakdown(reminderProvider.reminders, totalReminders),
            const SizedBox(height: 32),

            // Priority Breakdown
            const Text(
              'Priority Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriorityBreakdown(reminderProvider.reminders, totalReminders),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBreakdown(List reminders, int total) {
    final assignmentCount =
        reminders.where((r) => r.type.name == 'assignment').length;
    final examCount = reminders.where((r) => r.type.name == 'exam').length;
    final eventCount = reminders.where((r) => r.type.name == 'event').length;
    final meetingCount =
        reminders.where((r) => r.type.name == 'meeting').length;

    return Column(
      children: [
        _TypeBar('Assignment', assignmentCount, total, Colors.blue,
            Icons.assignment),
        const SizedBox(height: 12),
        _TypeBar('Exam', examCount, total, Colors.purple, Icons.school),
        const SizedBox(height: 12),
        _TypeBar('Event', eventCount, total, Colors.green, Icons.event),
        const SizedBox(height: 12),
        _TypeBar('Meeting', meetingCount, total, Colors.orange, Icons.people),
      ],
    );
  }

  Widget _buildPriorityBreakdown(List reminders, int total) {
    final highCount = reminders.where((r) => r.priority.name == 'high').length;
    final mediumCount =
        reminders.where((r) => r.priority.name == 'medium').length;
    final lowCount = reminders.where((r) => r.priority.name == 'low').length;

    return Column(
      children: [
        _TypeBar(
            'High Priority', highCount, total, Colors.red, Icons.priority_high),
        const SizedBox(height: 12),
        _TypeBar(
            'Medium Priority', mediumCount, total, Colors.orange, Icons.remove),
        const SizedBox(height: 12),
        _TypeBar(
            'Low Priority', lowCount, total, Colors.blue, Icons.low_priority),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusCard(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% of total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _TypeBar(this.label, this.count, this.total, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

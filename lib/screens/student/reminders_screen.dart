import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/screens/student/reminder_detail_screen.dart';
import 'package:pingme/screens/student/add_reminder_screen.dart';
import 'package:pingme/widgets/reminder_card.dart';
import 'package:pingme/widgets/tag_chip.dart';
import 'package:pingme/widgets/minimal_card.dart';

/// Regain-Style Reminders Screen
/// Clean list of reminders with category filters
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Assignment', 'Exam', 'Event', 'Other'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reminderProvider =
          Provider.of<ReminderProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        reminderProvider.fetchStudentReminders(authProvider.currentUser!.uid);
      }
    });
  }

  List<ReminderModel> _filterReminders(List<ReminderModel> reminders) {
    if (_selectedFilter == 'All') {
      return reminders.where((r) => !r.isCompleted).toList();
    }
    return reminders
        .where((r) => !r.isCompleted && r.category == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final filteredReminders = _filterReminders(reminderProvider.reminders);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('Reminders', style: AppTheme.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReminderScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.currentUser != null) {
            await reminderProvider.fetchStudentReminders(
              authProvider.currentUser!.uid,
            );
          }
        },
        color: AppTheme.accent,
        child: Column(
          children: [
            // Category filters
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacing8),
                      child: TagChip(
                        label: filter,
                        color: AppTheme.accent,
                        isSelected: _selectedFilter == filter,
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Reminders list
            Expanded(
              child: filteredReminders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacing20),
                      itemCount: filteredReminders.length,
                      itemBuilder: (context, index) {
                        final reminder = filteredReminders[index];
                        return ReminderCard(
                          reminder: reminder,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReminderDetailScreen(
                                  reminder: reminder,
                                ),
                              ),
                            );
                          },
                          onComplete: () {
                            reminderProvider
                                .toggleReminderCompletion(reminder.id);
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, reminder);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'No reminders',
              style: AppTheme.h3.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Tap + to add a new reminder',
              style: AppTheme.body2,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder', style: AppTheme.h4),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"?',
          style: AppTheme.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.button.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final reminderProvider =
                  Provider.of<ReminderProvider>(context, listen: false);
              reminderProvider.deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTheme.button.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/providers/focus_provider.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/screens/student/reminder_detail_screen.dart';
import 'package:pingme/screens/student/focus_mode_screen.dart';
import 'package:pingme/screens/student/achievements_screen.dart';
import 'package:pingme/widgets/minimal_card.dart';
import 'package:pingme/widgets/minimal_button.dart';
import 'package:pingme/widgets/stat_card.dart';
import 'package:pingme/widgets/reminder_card.dart';
import 'package:intl/intl.dart';

/// Regain-Style Home Screen
/// Clean, minimal, spacious layout with focus card, stats, and reminders
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reminderProvider =
          Provider.of<ReminderProvider>(context, listen: false);
      final focusProvider = Provider.of<FocusProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        reminderProvider.fetchStudentReminders(authProvider.currentUser!.uid);
        focusProvider.fetchFocusSessions(authProvider.currentUser!.uid);
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  List<ReminderModel> _getUpcomingReminders(List<ReminderModel> reminders) {
    final now = DateTime.now();
    return reminders
        .where((r) => !r.isCompleted && r.deadline.isAfter(now))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final focusProvider = Provider.of<FocusProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          'PingMe',
          style: AppTheme.h3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
            },
            tooltip: 'Achievements',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 24),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Logout',
          ),
          const SizedBox(width: AppTheme.spacing8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.currentUser != null) {
            await Future.wait([
              reminderProvider
                  .fetchStudentReminders(authProvider.currentUser!.uid),
              focusProvider.fetchFocusSessions(authProvider.currentUser!.uid),
            ]);
          }
        },
        color: AppTheme.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(authProvider),
              const SizedBox(height: AppTheme.spacing24),

              // Main Focus Card
              _buildMainFocusCard(
                  reminderProvider, focusProvider, authProvider),
              const SizedBox(height: AppTheme.spacing32),

              // Today's Progress Stats
              _buildStatsSection(focusProvider),
              const SizedBox(height: AppTheme.spacing32),

              // Upcoming Reminders
              _buildRemindersSection(reminderProvider),
              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()} 👋',
          style: AppTheme.h2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          authProvider.currentUser?.name ?? 'Student',
          style: AppTheme.body1.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainFocusCard(
    ReminderProvider reminderProvider,
    FocusProvider focusProvider,
    AuthProvider authProvider,
  ) {
    final upcomingReminders = _getUpcomingReminders(reminderProvider.reminders);
    final nextReminder =
        upcomingReminders.isNotEmpty ? upcomingReminders.first : null;

    return MinimalCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: AppTheme.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'TODAY\'S MAIN FOCUS',
                style: AppTheme.overline.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),

          if (nextReminder != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.book_outlined,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    nextReminder.title,
                    style: AppTheme.h3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Due: ${DateFormat('MMM d, h:mm a').format(nextReminder.deadline)}',
                  style: AppTheme.body2,
                ),
              ],
            ),
          ] else ...[
            Text(
              'No upcoming tasks',
              style: AppTheme.h4.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'You\'re all caught up! 🎉',
              style: AppTheme.body2,
            ),
          ],

          const SizedBox(height: AppTheme.spacing24),

          // Start Focus Button
          MinimalButton(
            text: 'Start Focus Session',
            icon: Icons.play_arrow,
            width: double.infinity,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusModeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(FocusProvider focusProvider) {
    final totalMinutes = focusProvider.totalFocusTime ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeDisplay = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    final successRate = focusProvider.sessions.isEmpty
        ? 0
        : (focusProvider.sessions.where((s) => s.wasSuccessful).length /
                focusProvider.sessions.length *
                100)
            .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Today\'s Progress',
          style: AppTheme.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: timeDisplay,
                label: 'Focus Time',
                icon: Icons.timer_outlined,
                accentColor: AppTheme.accent,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: StatCard(
                value: '$successRate%',
                label: 'Success Rate',
                icon: Icons.trending_up,
                accentColor: AppTheme.success,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: StatCard(
                value: '🔥 ${focusProvider.currentStreak}',
                label: 'Day Streak',
                icon: Icons.local_fire_department,
                accentColor: AppTheme.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRemindersSection(ReminderProvider reminderProvider) {
    final upcomingReminders =
        _getUpcomingReminders(reminderProvider.reminders).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📋 Upcoming Reminders',
              style: AppTheme.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (upcomingReminders.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to reminders tab (will be implemented with bottom nav)
                },
                child: Text(
                  'View All',
                  style: AppTheme.body2.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),
        if (upcomingReminders.isEmpty)
          MinimalCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      'No upcoming reminders',
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...upcomingReminders.map((reminder) {
            return ReminderCard(
              reminder: reminder,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReminderDetailScreen(reminder: reminder),
                  ),
                );
              },
              onComplete: () {
                // Mark as complete
                final reminderProvider =
                    Provider.of<ReminderProvider>(context, listen: false);
                reminderProvider.toggleReminderCompletion(reminder.id);
              },
              onDelete: () {
                // Show delete confirmation
                _showDeleteConfirmation(context, reminder);
              },
            );
          }).toList(),
      ],
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

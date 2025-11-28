import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/models/reminder_model.dart';

class ViewRemindersScreen extends StatefulWidget {
  const ViewRemindersScreen({Key? key}) : super(key: key);

  @override
  State<ViewRemindersScreen> createState() => _ViewRemindersScreenState();
}

class _ViewRemindersScreenState extends State<ViewRemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ReminderModel> _filterReminders(List<ReminderModel> reminders) {
    if (_searchQuery.isEmpty) return reminders;
    return reminders.where((reminder) {
      return reminder.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          reminder.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Reminders
                _buildReminderList(
                  _filterReminders(reminderProvider.reminders),
                  reminderProvider,
                  authProvider,
                ),
                // Active Reminders
                _buildReminderList(
                  _filterReminders(reminderProvider.pendingReminders),
                  reminderProvider,
                  authProvider,
                ),
                // Completed Reminders
                _buildReminderList(
                  _filterReminders(reminderProvider.completedReminders),
                  reminderProvider,
                  authProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(
    List<ReminderModel> reminders,
    ReminderProvider reminderProvider,
    AuthProvider authProvider,
  ) {
    if (reminderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (authProvider.currentUser != null) {
          await reminderProvider
              .fetchFacultyReminders(authProvider.currentUser!.uid);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Dismissible(
            key: Key(reminder.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Reminder'),
                  content: const Text(
                      'Are you sure you want to delete this reminder?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              await reminderProvider.deleteReminder(reminder.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder deleted')),
                );
              }
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPriorityColor(reminder.priority),
                  child: Icon(
                    _getTypeIcon(reminder.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      reminder.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDeadline(reminder.deadline),
                          style: TextStyle(
                            fontSize: 11,
                            color: reminder.isOverdue
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight: reminder.isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.targetStudents.contains('all')
                              ? 'All Students'
                              : '${reminder.targetStudents.length} students',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  reminder.isCompleted ? Icons.check_circle : Icons.pending,
                  color: reminder.isCompleted ? Colors.green : Colors.orange,
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
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

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inMinutes} minutes left';
    }
  }
}

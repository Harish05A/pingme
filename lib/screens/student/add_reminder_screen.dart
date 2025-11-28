import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/models/reminder_model.dart';

/// Add Reminder Screen for Students
/// Allows students to create personal reminders
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReminderType _selectedType = ReminderType.assignment;
  ReminderPriority _selectedPriority = ReminderPriority.medium;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reminderProvider =
        Provider.of<ReminderProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      priority: _selectedPriority,
      deadline: _selectedDeadline,
      createdAt: DateTime.now(),
      createdBy: authProvider.currentUser!.uid,
      createdByName: authProvider.currentUser!.name,
      targetStudents: [
        authProvider.currentUser!.uid
      ], // Student creates for themselves
      isCompleted: false,
    );

    final success = await reminderProvider.createReminder(reminder);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder created successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create reminder')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('Add Reminder', style: AppTheme.h3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text('Title', style: AppTheme.h4),
                    const SizedBox(height: AppTheme.spacing8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter reminder title',
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing20),

                    // Description
                    Text('Description', style: AppTheme.h4),
                    const SizedBox(height: AppTheme.spacing8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter description (optional)',
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing20),

                    // Type
                    Text('Type', style: AppTheme.h4),
                    const SizedBox(height: AppTheme.spacing8),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      children: ReminderType.values.map((type) {
                        return ChoiceChip(
                          label: Text(type.displayName),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                          selectedColor: AppTheme.accent.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedType == type
                                ? AppTheme.accent
                                : AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacing20),

                    // Priority
                    Text('Priority', style: AppTheme.h4),
                    const SizedBox(height: AppTheme.spacing8),
                    Wrap(
                      spacing: AppTheme.spacing8,
                      children: ReminderPriority.values.map((priority) {
                        return ChoiceChip(
                          label: Text(priority.displayName),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedPriority = priority);
                            }
                          },
                          selectedColor: priority.color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedPriority == priority
                                ? priority.color
                                : AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacing20),

                    // Deadline
                    Text('Deadline', style: AppTheme.h4),
                    const SizedBox(height: AppTheme.spacing8),
                    InkWell(
                      onTap: _selectDeadline,
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: AppTheme.accent, size: 20),
                            const SizedBox(width: AppTheme.spacing12),
                            Text(
                              '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year} at ${_selectedDeadline.hour}:${_selectedDeadline.minute.toString().padLeft(2, '0')}',
                              style: AppTheme.body1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing32),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createReminder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: Text(
                          'Create Reminder',
                          style: AppTheme.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

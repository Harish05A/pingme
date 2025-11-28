import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/services/firestore_service.dart';
import 'package:pingme/models/user_model.dart';
import 'package:pingme/widgets/custom_text_field.dart';
import 'package:pingme/widgets/custom_button.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReminderType _selectedType = ReminderType.assignment;
  ReminderPriority _selectedPriority = ReminderPriority.medium;
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedTime;
  bool _targetAllStudents = true;
  final List<String> _selectedStudentIds = [];
  List<UserModel> _allStudents = [];
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    try {
      final students = await FirestoreService().getAllStudents();
      setState(() {
        _allStudents = students;
        _isLoadingStudents = false;
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    if (!_targetAllStudents && _selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reminderProvider =
        Provider.of<ReminderProvider>(context, listen: false);

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      priority: _selectedPriority,
      deadline: _selectedDeadline!,
      createdAt: DateTime.now(),
      createdBy: authProvider.currentUser!.uid,
      createdByName: authProvider.currentUser!.name,
      targetStudents: _targetAllStudents ? ['all'] : _selectedStudentIds,
    );

    final success = await reminderProvider.createReminder(reminder);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reminder created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                reminderProvider.errorMessage ?? 'Failed to create reminder'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter reminder title',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length > 100) {
                  return 'Title must be less than 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter reminder description',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.trim().length > 500) {
                  return 'Description must be less than 500 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type Dropdown
            DropdownButtonFormField<ReminderType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 16),

            // Priority Dropdown
            DropdownButtonFormField<ReminderPriority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: ReminderPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getPriorityColor(priority),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.name.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPriority = value!);
              },
            ),
            const SizedBox(height: 16),

            // Deadline Selector
            InkWell(
              onTap: _selectDeadline,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDeadline == null
                          ? 'Select Deadline'
                          : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} ${_selectedTime!.format(context)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDeadline == null
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Student Targeting
            Text(
              'Target Students',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('All Students'),
              value: _targetAllStudents,
              onChanged: (value) {
                setState(() => _targetAllStudents = value);
              },
            ),

            if (!_targetAllStudents) ...[
              const SizedBox(height: 8),
              if (_isLoadingStudents)
                const Center(child: CircularProgressIndicator())
              else if (_allStudents.isEmpty)
                const Text('No students found')
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _allStudents.length,
                    itemBuilder: (context, index) {
                      final student = _allStudents[index];
                      final isSelected =
                          _selectedStudentIds.contains(student.uid);
                      return CheckboxListTile(
                        title: Text(student.name),
                        subtitle: Text(student.email),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedStudentIds.add(student.uid);
                            } else {
                              _selectedStudentIds.remove(student.uid);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],

            const SizedBox(height: 32),

            // Create Button
            CustomButton(
              text: 'Create Reminder',
              onPressed: reminderProvider.isLoading ? null : _createReminder,
              isLoading: reminderProvider.isLoading,
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
}

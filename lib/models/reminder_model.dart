import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReminderType {
  assignment,
  event,
  exam,
  meeting,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.assignment:
        return 'Assignment';
      case ReminderType.event:
        return 'Event';
      case ReminderType.exam:
        return 'Exam';
      case ReminderType.meeting:
        return 'Meeting';
    }
  }
}

enum ReminderPriority {
  low,
  medium,
  high,
}

extension ReminderPriorityExtension on ReminderPriority {
  String get displayName {
    switch (this) {
      case ReminderPriority.low:
        return 'Low';
      case ReminderPriority.medium:
        return 'Medium';
      case ReminderPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case ReminderPriority.low:
        return Colors.blue;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
    }
  }
}

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderPriority priority;
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy; // Faculty UID
  final String createdByName; // Faculty Name
  final List<String> targetStudents; // UIDs or 'all'
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isArchived;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    required this.targetStudents,
    this.isCompleted = false,
    this.completedAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'targetStudents': targetStudents,
      'isCompleted': isCompleted,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isArchived': isArchived,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.assignment,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      deadline: (map['deadline'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      targetStudents: List<String>.from(map['targetStudents'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      isArchived: map['isArchived'] ?? false,
    );
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderPriority? priority,
    DateTime? deadline,
    DateTime? createdAt,
    String? createdBy,
    String? createdByName,
    List<String>? targetStudents,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isArchived,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      targetStudents: targetStudents ?? this.targetStudents,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  bool get isPending => !isCompleted && deadline.isAfter(DateTime.now());
  bool get isOverdue => !isCompleted && deadline.isBefore(DateTime.now());

  Duration get timeUntilDeadline => deadline.difference(DateTime.now());

  String get typeDisplayName {
    switch (type) {
      case ReminderType.assignment:
        return 'Assignment';
      case ReminderType.event:
        return 'Event';
      case ReminderType.exam:
        return 'Exam';
      case ReminderType.meeting:
        return 'Meeting';
    }
  }

  // Alias for category (used in UI)
  String get category => typeDisplayName;
}

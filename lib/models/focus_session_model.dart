import 'package:cloud_firestore/cloud_firestore.dart';

class FocusSessionModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes; // Planned duration
  final int actualDurationMinutes; // Actual duration
  final int distractionCount;
  final List<String> distractingApps; // Apps opened during session
  final bool isCompleted;
  final bool wasSuccessful; // Completed without breaking

  FocusSessionModel({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.actualDurationMinutes = 0,
    this.distractionCount = 0,
    this.distractingApps = const [],
    this.isCompleted = false,
    this.wasSuccessful = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'actualDurationMinutes': actualDurationMinutes,
      'distractionCount': distractionCount,
      'distractingApps': distractingApps,
      'isCompleted': isCompleted,
      'wasSuccessful': wasSuccessful,
    };
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      durationMinutes: map['durationMinutes'] ?? 0,
      actualDurationMinutes: map['actualDurationMinutes'] ?? 0,
      distractionCount: map['distractionCount'] ?? 0,
      distractingApps: List<String>.from(map['distractingApps'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      wasSuccessful: map['wasSuccessful'] ?? false,
    );
  }

  FocusSessionModel copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? actualDurationMinutes,
    int? distractionCount,
    List<String>? distractingApps,
    bool? isCompleted,
    bool? wasSuccessful,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      distractionCount: distractionCount ?? this.distractionCount,
      distractingApps: distractingApps ?? this.distractingApps,
      isCompleted: isCompleted ?? this.isCompleted,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
    );
  }

  Duration get remainingTime {
    if (endTime != null) return Duration.zero;
    final plannedEnd = startTime.add(Duration(minutes: durationMinutes));
    final remaining = plannedEnd.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

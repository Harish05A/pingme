class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetValue;
  final AchievementType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? targetValue,
    AchievementType? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'targetValue': targetValue,
      'type': type.toString(),
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      targetValue: map['targetValue'] ?? 0,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => AchievementType.sessions,
      ),
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

enum AchievementType {
  sessions, // Total sessions completed
  streak, // Consecutive days
  focusTime, // Total focus minutes
  perfectDay, // No distractions
  earlyBird, // Morning sessions
  nightOwl, // Evening sessions
}

// Predefined achievements
class Achievements {
  static final List<Achievement> all = [
    // Session achievements
    Achievement(
      id: 'first_session',
      title: 'First Step',
      description: 'Complete your first focus session',
      icon: '🎯',
      targetValue: 1,
      type: AchievementType.sessions,
    ),
    Achievement(
      id: 'ten_sessions',
      title: 'Getting Started',
      description: 'Complete 10 focus sessions',
      icon: '⭐',
      targetValue: 10,
      type: AchievementType.sessions,
    ),
    Achievement(
      id: 'fifty_sessions',
      title: 'Dedicated',
      description: 'Complete 50 focus sessions',
      icon: '🌟',
      targetValue: 50,
      type: AchievementType.sessions,
    ),
    Achievement(
      id: 'hundred_sessions',
      title: 'Focus Master',
      description: 'Complete 100 focus sessions',
      icon: '💎',
      targetValue: 100,
      type: AchievementType.sessions,
    ),

    // Streak achievements
    Achievement(
      id: 'three_day_streak',
      title: 'On a Roll',
      description: 'Maintain a 3-day streak',
      icon: '🔥',
      targetValue: 3,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'week_streak',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥🔥',
      targetValue: 7,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'month_streak',
      title: 'Unstoppable',
      description: 'Maintain a 30-day streak',
      icon: '🔥🔥🔥',
      targetValue: 30,
      type: AchievementType.streak,
    ),

    // Focus time achievements
    Achievement(
      id: 'ten_hours',
      title: 'Time Investor',
      description: 'Accumulate 10 hours of focus time',
      icon: '⏰',
      targetValue: 600, // minutes
      type: AchievementType.focusTime,
    ),
    Achievement(
      id: 'fifty_hours',
      title: 'Time Master',
      description: 'Accumulate 50 hours of focus time',
      icon: '⏱️',
      targetValue: 3000,
      type: AchievementType.focusTime,
    ),
    Achievement(
      id: 'hundred_hours',
      title: 'Time Legend',
      description: 'Accumulate 100 hours of focus time',
      icon: '⌛',
      targetValue: 6000,
      type: AchievementType.focusTime,
    ),

    // Perfect day achievement
    Achievement(
      id: 'perfect_day',
      title: 'Perfect Focus',
      description: 'Complete a session with zero distractions',
      icon: '✨',
      targetValue: 1,
      type: AchievementType.perfectDay,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

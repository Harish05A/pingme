import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/models/achievement_model.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/focus_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, dynamic>? _stats;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final focusProvider = Provider.of<FocusProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final stats =
          await focusProvider.getFocusStats(authProvider.currentUser!.uid);
      setState(() {
        _stats = stats;
        _achievements = _checkAchievements(stats, focusProvider.sessions);
      });
    }
  }

  List<Achievement> _checkAchievements(
      Map<String, dynamic> stats, List sessions) {
    final achievements = <Achievement>[];

    for (var achievement in Achievements.all) {
      bool isUnlocked = false;

      switch (achievement.type) {
        case AchievementType.sessions:
          isUnlocked = (stats['totalSessions'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementType.streak:
          isUnlocked =
              (stats['currentStreak'] ?? 0) >= achievement.targetValue ||
                  (stats['longestStreak'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementType.focusTime:
          isUnlocked = (stats['totalMinutes'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementType.perfectDay:
          isUnlocked =
              sessions.any((s) => s.distractionCount == 0 && s.wasSuccessful);
          break;
        default:
          isUnlocked = false;
      }

      achievements.add(achievement.copyWith(
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked ? DateTime.now() : null,
      ));
    }

    return achievements;
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('Achievements', style: AppTheme.h3),
      ),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAchievements,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryPurple.withOpacity(0.2),
                            AppTheme.primaryPurple.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🏆',
                                style: TextStyle(fontSize: 48),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$unlockedCount / $totalCount',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Achievements Unlocked',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalCount > 0
                                  ? unlockedCount / totalCount
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryPurple,
                              ),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Achievements Grid
                    const Text(
                      'All Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _achievements[index];
                        return _AchievementCard(
                          achievement: achievement,
                          currentValue: _getCurrentValue(achievement),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  int _getCurrentValue(Achievement achievement) {
    if (_stats == null) return 0;

    switch (achievement.type) {
      case AchievementType.sessions:
        return _stats!['totalSessions'] ?? 0;
      case AchievementType.streak:
        return (_stats!['currentStreak'] ?? 0) > (_stats!['longestStreak'] ?? 0)
            ? _stats!['currentStreak']
            : _stats!['longestStreak'];
      case AchievementType.focusTime:
        return _stats!['totalMinutes'] ?? 0;
      case AchievementType.perfectDay:
        return achievement.isUnlocked ? 1 : 0;
      default:
        return 0;
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int currentValue;

  const _AchievementCard({
    required this.achievement,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked;
    final progress = achievement.targetValue > 0
        ? (currentValue / achievement.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 2,
      color: isLocked ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppTheme.textSecondary.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: isLocked ? Colors.grey[400] : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Progress
            if (!achievement.isUnlocked) ...[
              Text(
                '$currentValue / ${achievement.targetValue}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryPurple,
                  ),
                  minHeight: 6,
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Unlocked!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

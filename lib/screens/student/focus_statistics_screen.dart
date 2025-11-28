import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/focus_provider.dart';
import 'package:pingme/widgets/stat_card.dart';

class FocusStatisticsScreen extends StatefulWidget {
  const FocusStatisticsScreen({super.key});

  @override
  State<FocusStatisticsScreen> createState() => _FocusStatisticsScreenState();
}

class _FocusStatisticsScreenState extends State<FocusStatisticsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final focusProvider = Provider.of<FocusProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final stats =
          await focusProvider.getFocusStats(authProvider.currentUser!.uid);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = Provider.of<FocusProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('Statistics', style: AppTheme.h3),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppTheme.accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Section
                    Text('Overview', style: AppTheme.h3),
                    const SizedBox(height: AppTheme.spacing16),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.access_time,
                            label: 'Total Time',
                            value: '${_stats?['totalMinutes'] ?? 0}m',
                            accentColor: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.event_note,
                            label: 'Sessions',
                            value: '${_stats?['totalSessions'] ?? 0}',
                            accentColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: 'Success Rate',
                            value: '${_stats?['successRate'] ?? 0}%',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            label: 'Current Streak',
                            value: '${_stats?['currentStreak'] ?? 0} days',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Productivity Score
                    const Text(
                      'Productivity Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProductivityScoreCard(
                      score:
                          _calculateProductivityScore(focusProvider.sessions),
                    ),
                    const SizedBox(height: 32),

                    // Recent Sessions
                    const Text(
                      'Recent Sessions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentSessions(focusProvider.sessions),
                    const SizedBox(height: 32),

                    // Session Breakdown
                    const Text(
                      'Session Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSessionBreakdown(focusProvider.sessions),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRecentSessions(List sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No sessions yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sessions.take(5).map((session) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: session.wasSuccessful
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              child: Icon(
                session.wasSuccessful ? Icons.check : Icons.warning,
                color: session.wasSuccessful ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              '${session.actualDurationMinutes} minutes',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_formatDate(session.startTime)} • ${session.distractionCount} distractions',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: session.wasSuccessful
                ? const Icon(Icons.emoji_events, color: Colors.amber)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionBreakdown(List sessions) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final successful = sessions.where((s) => s.wasSuccessful).length;
    final total = sessions.length;
    final successRate = total > 0 ? (successful / total) : 0.0;

    return Column(
      children: [
        _BreakdownBar(
          label: 'Successful',
          count: successful,
          total: total,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _BreakdownBar(
          label: 'Incomplete',
          count: total - successful,
          total: total,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Completion Rate',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(successRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: successRate > 0.7 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateProductivityScore(List sessions) {
    if (sessions.isEmpty) return 0;

    final recentSessions = sessions.take(10).toList();
    final successCount = recentSessions.where((s) => s.wasSuccessful).length;
    final avgDistractions = recentSessions.fold<num>(
          0,
          (sum, s) => sum + s.distractionCount,
        ) /
        recentSessions.length;

    // Score based on success rate and low distractions
    final successScore = (successCount / recentSessions.length) * 70;
    final distractionScore = (1 - (avgDistractions / 10).clamp(0, 1)) * 30;

    return (successScore + distractionScore).toInt();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

// Productivity Score Card
class _ProductivityScoreCard extends StatelessWidget {
  final int score;

  const _ProductivityScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? Colors.green
        : score >= 40
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScoreLabel(score),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(score),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Excellent! 🎉';
    if (score >= 40) return 'Good 👍';
    return 'Keep Trying 💪';
  }

  String _getScoreDescription(int score) {
    if (score >= 70) return 'You\'re crushing it! Keep up the great work.';
    if (score >= 40) return 'You\'re doing well. Try to reduce distractions.';
    return 'Focus on completing sessions with fewer distractions.';
  }
}

// Breakdown Bar Widget
class _BreakdownBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BreakdownBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

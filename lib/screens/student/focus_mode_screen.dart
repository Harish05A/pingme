import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/focus_provider.dart';
import 'package:pingme/screens/student/focus_statistics_screen.dart';
import 'package:pingme/utils/motivational_quotes.dart';
import 'package:pingme/widgets/minimal_button.dart';
import 'package:pingme/widgets/minimal_card.dart';
import 'package:pingme/widgets/circular_timer.dart';
import 'package:pingme/widgets/tag_chip.dart';

/// Regain-Style Focus Mode Screen
/// Minimal circular timer with clean preset selection
class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _uiUpdateTimer;
  final Map<String, String> _currentQuote = MotivationalQuotes.getRandomQuote();
  int _selectedDuration = 25; // Default Pomodoro

  final List<Map<String, dynamic>> _presets = [
    {'label': '25m', 'minutes': 25, 'name': 'Pomodoro'},
    {'label': '5m', 'minutes': 5, 'name': 'Short Break'},
    {'label': '15m', 'minutes': 15, 'name': 'Long Break'},
    {'label': '90m', 'minutes': 90, 'name': 'Deep Work'},
  ];

  @override
  void initState() {
    super.initState();

    // Update UI every second when timer is active
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final focusProvider = Provider.of<FocusProvider>(context);

    return Scaffold(
      backgroundColor: focusProvider.isFocusModeActive
          ? AppTheme.backgroundDark
          : AppTheme.background,
      appBar: focusProvider.isFocusModeActive
          ? null
          : AppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              title: Text('Focus Mode', style: AppTheme.h3),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_outlined, size: 24),
                  tooltip: 'Statistics',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusStatisticsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppTheme.spacing8),
              ],
            ),
      body: focusProvider.isFocusModeActive
          ? _buildActiveSession(focusProvider, authProvider)
          : _buildSetupScreen(focusProvider, authProvider),
    );
  }

  Widget _buildSetupScreen(
    FocusProvider focusProvider,
    AuthProvider authProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppTheme.spacing32),

          // Circular Timer Display
          CircularTimer(
            totalSeconds: _selectedDuration * 60,
            remainingSeconds: _selectedDuration * 60,
            isActive: false,
            size: 280,
          ),

          const SizedBox(height: AppTheme.spacing48),

          // Start Button
          MinimalButton(
            text: 'Start Session',
            icon: Icons.play_arrow,
            width: double.infinity,
            height: 56,
            onPressed: () async {
              if (authProvider.currentUser != null) {
                await focusProvider.startFocusSession(
                  userId: authProvider.currentUser!.uid,
                  durationMinutes: _selectedDuration,
                );
              }
            },
          ),

          const SizedBox(height: AppTheme.spacing32),

          // Quick Presets
          _buildPresets(),

          const SizedBox(height: AppTheme.spacing32),

          // Session Stats
          _buildSessionStats(focusProvider),

          const SizedBox(height: AppTheme.spacing24),

          // View Statistics Link
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FocusStatisticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights, size: 20),
            label: Text(
              'View Statistics',
              style: AppTheme.button.copyWith(
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: AppTheme.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Wrap(
          spacing: AppTheme.spacing12,
          runSpacing: AppTheme.spacing12,
          children: _presets.map((preset) {
            final isSelected = _selectedDuration == preset['minutes'];
            return TagChip(
              label: preset['label'],
              color: AppTheme.accent,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedDuration = preset['minutes'];
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSessionStats(FocusProvider focusProvider) {
    final todayMinutes = focusProvider.totalFocusTime ~/ 60;
    final todayHours = todayMinutes ~/ 60;
    final todayMins = todayMinutes % 60;
    final todayDisplay =
        todayHours > 0 ? '${todayHours}h ${todayMins}m' : '${todayMins}m';

    return MinimalCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', todayDisplay),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          _buildStatItem('Streak', '${focusProvider.currentStreak} days'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }

  Widget _buildActiveSession(
    FocusProvider focusProvider,
    AuthProvider authProvider,
  ) {
    final session = focusProvider.currentSession!;
    final elapsed = DateTime.now().difference(session.startTime).inSeconds;
    final totalSeconds = session.durationMinutes * 60;
    final remainingSeconds = (totalSeconds - elapsed).clamp(0, totalSeconds);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.backgroundDark,
            AppTheme.primary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textLight),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const Spacer(),

            // Circular Timer
            CircularTimer(
              totalSeconds: totalSeconds,
              remainingSeconds: remainingSeconds,
              isActive: !focusProvider.isPaused,
              size: 280,
            ),

            const SizedBox(height: AppTheme.spacing32),

            // Motivational Quote
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
              child: Column(
                children: [
                  Text(
                    _currentQuote['quote']!,
                    style: AppTheme.body1.copyWith(
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    '— ${_currentQuote['author']}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textLight.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                children: [
                  // Session info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Session: ${elapsed ~/ 60} min',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textLight.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing24),
                      Text(
                        'Distractions: ${focusProvider.distractionCount}',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textLight.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Control buttons
                  Row(
                    children: [
                      Expanded(
                        child: MinimalButton(
                          text: focusProvider.isPaused ? 'Resume' : 'Pause',
                          icon: focusProvider.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                          isOutlined: true,
                          color: AppTheme.textLight,
                          onPressed: () {
                            if (focusProvider.isPaused) {
                              focusProvider.resumeFocusSession();
                            } else {
                              focusProvider.pauseFocusSession();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: MinimalButton(
                          text: 'End',
                          icon: Icons.stop,
                          color: AppTheme.error,
                          onPressed: () => _showEndSessionDialog(
                            context,
                            focusProvider,
                            authProvider,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndSessionDialog(
    BuildContext context,
    FocusProvider focusProvider,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Session?', style: AppTheme.h4),
        content: Text(
          'Are you sure you want to end this focus session?',
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
            onPressed: () async {
              if (authProvider.currentUser != null) {
                await focusProvider.endFocusSession(
                  wasSuccessful: true,
                );
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'End Session',
              style: AppTheme.button.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

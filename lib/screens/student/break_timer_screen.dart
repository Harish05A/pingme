import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';

class BreakTimerScreen extends StatefulWidget {
  final int breakDuration; // in minutes

  const BreakTimerScreen({
    Key? key,
    this.breakDuration = 5,
  }) : super(key: key);

  @override
  State<BreakTimerScreen> createState() => _BreakTimerScreenState();
}

class _BreakTimerScreenState extends State<BreakTimerScreen> {
  late Duration _remainingTime;
  Timer? _timer;
  bool _isPaused = false;

  final List<String> _breakActivities = [
    '💧 Drink water',
    '🚶 Take a short walk',
    '🧘 Stretch your body',
    '👀 Rest your eyes (20-20-20 rule)',
    '🌬️ Deep breathing exercises',
    '🪟 Look outside the window',
    '🎵 Listen to calming music',
    '📝 Jot down your thoughts',
  ];

  @override
  void initState() {
    super.initState();
    _remainingTime = Duration(minutes: widget.breakDuration);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
      if (_remainingTime.inSeconds == 0) {
        _timer?.cancel();
        _showBreakCompleteDialog();
      }
    });
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Break Complete! 🎉'),
        content: const Text(
          'Your break is over. Ready to start another focus session?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close break screen
            },
            child: const Text('Back to Focus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    final progress =
        1 - (_remainingTime.inSeconds / (widget.breakDuration * 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Time'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Skip Break?'),
                content: const Text(
                  'Are you sure you want to skip your break? Taking breaks is important for productivity!',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Break'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close break screen
                    },
                    child: const Text(
                      'Skip Break',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Timer Circle
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '☕',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPaused ? 'PAUSED' : 'BREAK TIME',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isPaused)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isPaused = true);
                    },
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isPaused = false);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 48),

            // Break Activity Suggestions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Break Activity Suggestions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._breakActivities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                activity,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Motivational Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '"Taking breaks is not a luxury, it\'s a necessity for sustained productivity."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

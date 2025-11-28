import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/screens/student/student_home_screen.dart';
import 'package:pingme/screens/student/reminders_screen.dart';
import 'package:pingme/screens/student/focus_mode_screen.dart';

/// Main screen with 3-tab bottom navigation
/// Home | Reminders | Focus
class StudentMainScreen extends StatefulWidget {
  final int initialTab;

  const StudentMainScreen({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const RemindersScreen(),
    const FocusModeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing8,
              vertical: AppTheme.spacing8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Reminders',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.timer_outlined,
                  activeIcon: Icons.timer,
                  label: 'Focus',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pingme/config/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.backgroundDark,
                    AppTheme.darkPurple,
                    AppTheme.primaryPurple,
                  ]
                : [
                    AppTheme.primaryPurple,
                    AppTheme.secondaryBlue,
                    AppTheme.lightPurple,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5))
                  .then()
                  .shake(duration: 1000.ms, hz: 2, curve: Curves.easeInOut),

              const SizedBox(height: 32),

              // App Name
              Text(
                'PingMe',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // Tagline
              Text(
                'Smart Academic Reminder',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms),

              const SizedBox(height: 60),

              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

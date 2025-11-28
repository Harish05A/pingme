import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:pingme/config/firebase_options.dart';
import 'package:pingme/providers/auth_provider.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/providers/focus_provider.dart';
import 'package:pingme/screens/common/splash_screen.dart';
import 'package:pingme/screens/auth/login_screen.dart';
import 'package:pingme/screens/student/student_main_screen.dart';
import 'package:pingme/screens/faculty/faculty_home_screen.dart';
import 'package:pingme/models/user_model.dart';
import 'package:pingme/screens/overlay/overlay_widget.dart';
import 'package:pingme/services/notification_service.dart';
import 'package:pingme/services/background_service.dart';
import 'package:pingme/services/live_update_service.dart';
import 'package:pingme/services/distraction_service.dart';
import 'package:pingme/widgets/distraction_popup.dart';

// Overlay Entry Point
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayWidget());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Background Service
  await BackgroundService().initialize();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PingMeApp());
}

class PingMeApp extends StatefulWidget {
  const PingMeApp({Key? key}) : super(key: key);

  @override
  State<PingMeApp> createState() => _PingMeAppState();
}

class _PingMeAppState extends State<PingMeApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupDistractionMonitoring();
  }

  void _setupDistractionMonitoring() {
    // Setup distraction service with popup callback
    DistractionService.instance.startMonitoring(
      onShowPopup: (context, appName) {
        // Get current context from navigator
        final navContext = _navigatorKey.currentContext;
        if (navContext != null) {
          DistractionPopup.show(navContext, appName: appName);
        }
      },
    );
  }

  @override
  void dispose() {
    DistractionService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'PingMe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/student-home': (context) => const StudentMainScreen(),
          '/faculty-home': (context) => const FacultyHomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (authProvider.currentUser == null) {
          // User logged out - cleanup services
          LiveUpdateService.instance.dispose();
          DistractionService.instance.stopMonitoring();
          return const LoginScreen();
        }

        // Route based on user role
        if (authProvider.currentUser!.role == UserRole.faculty) {
          // Faculty - no distraction monitoring
          LiveUpdateService.instance.dispose();
          DistractionService.instance.stopMonitoring();
          return const FacultyHomeScreen();
        } else {
          // Student - initialize live updates
          _initializeStudentServices(authProvider.currentUser!.uid);
          return const StudentMainScreen();
        }
      },
    );
  }

  void _initializeStudentServices(String studentUid) {
    // Initialize LiveUpdateService for real-time data
    if (!LiveUpdateService.instance.isInitialized) {
      LiveUpdateService.instance.initialize(studentUid);
      debugPrint('AuthWrapper: Initialized LiveUpdateService for $studentUid');
    }

    // Distraction monitoring is already started in PingMeApp
    // It will automatically use LiveUpdateService data
  }
}

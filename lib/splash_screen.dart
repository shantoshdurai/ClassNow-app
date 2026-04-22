import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_test/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/widget_service.dart';
import 'package:flutter_firebase_test/app_launcher.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      await Future.wait([
        _initNotifications(),
        _initWidgetService(),
        _initAuth(),
        UserService.updateAndGetStreak(),
      ]);

      if (mounted) {
        await Provider.of<UserSelectionProvider>(
          context,
          listen: false,
        ).loadSelection();
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }

    await minDelay;

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AppLauncher(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  Future<void> _initNotifications() async {
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  Future<void> _initWidgetService() async {
    try {
      await WidgetService.initialize();
    } catch (e) {
      debugPrint('Widget service init failed: $e');
    }
  }

  Future<void> _initAuth() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint('Auth init failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      body: Stack(
        children: [
          const AuroraBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.glassAccent.withOpacity(0.1)
                          : AppTheme.paperAccent.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppTheme.glassAccent.withOpacity(0.2)
                            : AppTheme.paperAccent.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 64,
                      color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Class Now',
                        style: AppTextStyles.interTitle.copyWith(
                          color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                          fontSize: 32,
                          letterSpacing: -1.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YOUR ACADEMIC COMPANION',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


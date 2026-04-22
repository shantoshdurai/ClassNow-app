import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/onboarding_screen.dart';

import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'dart:ui';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _isLoading = false;

  Future<void> _handleGetStarted() async {
    setState(() => _isLoading = true);

    try {
      // 1. Request Notification Permissions
      final granted = await NotificationService.requestPermissions();

      if (!mounted) return;

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications are recommended for class alerts'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 2. Mark intro as shown
      final provider = Provider.of<UserSelectionProvider>(
        context,
        listen: false,
      );
      await provider.setIntroShown();

      // 3. Navigate to Onboarding (Class Selection)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      print('Error in intro: $e');
      // Fallback navigation
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          const AuroraBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/dsu_logo.png',
                      ),
                    ),
                  ).animate().scale(
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 48),

                  // Title
                  Text(
                    'Welcome to\nClass Now',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.interTitle.copyWith(
                      fontSize: 40,
                      color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your smart academic companion.\nStay updated with your timetable and never miss a class.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.interSmall.copyWith(
                        color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),

                  const Spacer(),

                  // Get Started Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                              : [AppTheme.paperAccent, AppTheme.paperAccentInk],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _isLoading ? null : _handleGetStarted,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'GET STARTED',
                                    style: AppTextStyles.monoLabel.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).moveY(begin: 40, end: 0),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

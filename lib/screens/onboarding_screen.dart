import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/screens/profile_setup_screen.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A screen that guides the user through the key features of the application.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.schedule_rounded,
      title: 'Welcome to\nClass Now',
      description:
          'Your smart companion for managing class schedules and staying on top of your academic life.',
      accent: AppTheme.primaryBlue,
    ),
    OnboardingPageData(
      icon: Icons.notifications_active_rounded,
      title: 'Never Miss\na Class',
      description:
          'Get timely notifications before each class starts. Customize reminder timing in settings.',
      accent: AppTheme.accentOrange,
    ),
    OnboardingPageData(
      icon: Icons.widgets_rounded,
      title: 'Home Screen\nWidgets',
      description:
          'Add widgets to your home screen to see your current and upcoming classes at a glance.',
      accent: AppTheme.accentPurple,
    ),
    OnboardingPageData(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Assistant',
      description:
          'Ask our AI chatbot about your schedule, classes, and staff. It\'s like having a personal academic assistant!',
      accent: AppTheme.paperAccent,
    ),
    OnboardingPageData(
      icon: Icons.check_circle_outline_rounded,
      title: 'All Set!',
      description:
          'Select your department, year, and section to get started. Your schedule will sync automatically.',
      accent: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await Provider.of<UserSelectionProvider>(
      context,
      listen: false,
    ).setIntroShown();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfileSetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await NotificationService.init();
      final plugin = NotificationService.getNotificationPlugin();
      if (plugin != null) {
        await plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  Future<void> _handleNextButton() async {
    if (_currentPage == 1) {
      await _requestNotificationPermission();
    }

    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
        body: Stack(
          children: [
            if (isDark) const AuroraBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'SKIP',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: mutedColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index], isDark, inkColor, mutedColor);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage, isDark),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: _buildActionButton(isDark),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    final isLast = _currentPage == _pages.length - 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.glassAccent, AppTheme.glassAccent2]
              : [AppTheme.paperAccent, AppTheme.paperAccentInk],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _handleNextButton,
          child: Center(
            child: Text(
              isLast ? 'GET STARTED' : 'CONTINUE',
              style: AppTextStyles.monoLabel.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page, bool isDark, Color inkColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassCard(
            blur: 30,
            opacity: isDark ? 0.08 : 0.6,
            padding: const EdgeInsets.all(40),
            borderRadius: BorderRadius.circular(32),
            child: Icon(
              page.icon,
              size: 80,
              color: isDark ? page.accent.withOpacity(0.9) : page.accent,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
          const SizedBox(height: 56),
          Text(
            page.title,
            style: AppTextStyles.interTitle.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: inkColor,
              height: 1.1,
              letterSpacing: -1.0,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              page.description,
              style: AppTextStyles.interSmall.copyWith(
                color: mutedColor,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
            : (isDark ? Colors.white24 : Colors.black12),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });
}


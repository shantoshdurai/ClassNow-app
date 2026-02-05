import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/onboarding_screen.dart';
import 'package:flutter_firebase_test/theme_provider.dart';
import 'package:flutter_firebase_test/notification_settings_page.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _widgetsEnabled = true;
  bool _retroDisplayEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _widgetsEnabled = prefs.getBool('widgets_enabled') ?? true;
      _retroDisplayEnabled = prefs.getBool('retro_display_enabled') ?? true;
    });
  }

  Future<void> _setRetroDisplayEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('retro_display_enabled', value);
    if (!mounted) return;
    setState(() {
      _retroDisplayEnabled = value;
    });
    // Update the global notifier to trigger immediate UI update
    retroDisplayEnabledNotifier.value = value;
  }

  Future<void> _setWidgetsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widgets_enabled', value);
    if (!mounted) return;
    setState(() {
      _widgetsEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Widgets enabled' : 'Widgets disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 45, 16, 0),
          child: GlassCard(
            blur: 25,
            opacity: 0.1,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.interTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      height: 1.0,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF000000)
                    : const Color(0xFFF2F2F7),
              ),
            ),
          ),
          if (isDark)
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                _buildSettingsGroup(
                  context,
                  title: 'Display',
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'A comfortable view for nighttime',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: theme.colorScheme.primary,
                      secondary: Icon(
                        Icons.brightness_6_outlined,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsGroup(
                  context,
                  title: 'Account',
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.school_outlined,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Change My Class',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Select a different section or year',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsGroup(
                  context,
                  title: 'Notifications',
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Manage Alerts',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Select classes and test notifications',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationSettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsGroup(
                  context,
                  title: 'Extras',
                  children: [
                    SwitchListTile(
                      title: Text(
                        '90s Retro Display',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Show pixel-style class tracker display',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      value: _retroDisplayEnabled,
                      onChanged: _setRetroDisplayEnabled,
                      activeColor: theme.colorScheme.primary,
                      secondary: Icon(
                        Icons.computer_outlined,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: Colors.white10,
                    ),
                    SwitchListTile(
                      title: Text(
                        'Widgets Auto-Update',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Keep home screen widgets updated automatically',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      value: _widgetsEnabled,
                      onChanged: _setWidgetsEnabled,
                      activeColor: theme.colorScheme.primary,
                      secondary: Icon(
                        Icons.autorenew_rounded,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: Colors.white10,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.widgets_outlined,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Home Screen Widgets',
                        style: AppTextStyles.interMentor.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Learn how to add widgets',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      onTap: () => _showWidgetInfoDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.interBadge.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          opacity: 0.05,
          borderRadius: BorderRadius.circular(24),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showWidgetInfoDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Home Screen Widgets'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('On Android:', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '1. Long-press on a blank space on your home screen.\n'
                '2. Tap on "Widgets".\n'
                '3. Find "Class Now" in the list.\n'
                '4. Drag the widget to your desired location.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('On iOS:', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '1. Long-press on a blank space on your home screen until the apps jiggle.\n'
                '2. Tap the "+" button in the top-left corner.\n'
                '3. Search for "Class Now".\n'
                '4. Choose a widget size and tap "Add Widget".',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

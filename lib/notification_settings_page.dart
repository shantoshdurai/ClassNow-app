import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'dart:ui';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _allSubjects = true;
  List<String> _subjects = [];
  List<String> _selectedSubjects = [];
  int _leadTimeMinutes = 15; // Default 15 minutes before class

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final all = prefs.getBool('notifications_all_subjects') ?? true;
    final selected =
        prefs.getStringList('notification_selected_subjects') ?? [];
    final leadTime = prefs.getInt('notifications_lead_time') ?? 15;

    final uniqueSubjects = await NotificationService.getUniqueSubjects();

    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _allSubjects = all;
        _selectedSubjects = selected;
        _subjects = uniqueSubjects;
        // Snap to nearest 5 minutes to avoid weird numbers like 13 or 21
        _leadTimeMinutes = (leadTime / 5).round() * 5;
        if (_leadTimeMinutes < 5) _leadTimeMinutes = 5;
        if (_leadTimeMinutes > 30) _leadTimeMinutes = 30;

        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('notifications_all_subjects', _allSubjects);
    await prefs.setStringList(
      'notification_selected_subjects',
      _selectedSubjects,
    );
    await prefs.setInt('notifications_lead_time', _leadTimeMinutes);

    await NotificationService.scheduleTimetableNotifications();
  }

  void _toggleSubject(String subject, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        if (!_selectedSubjects.contains(subject)) {
          _selectedSubjects.add(subject);
        }
      } else {
        _selectedSubjects.remove(subject);
      }
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
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
                    'Notifications',
                    style: AppTextStyles.interTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
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
          if (isDark)
            Positioned(
              top: -80,
              left: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildExperimentCard(theme),
                      const SizedBox(height: 24),

                      GlassCard(
                        blur: 15,
                        opacity: 0.08,
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: Text(
                            'Enable Notifications',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Turn on/off all class reminders',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            setState(() => _notificationsEnabled = val);
                            _saveSettings();
                          },
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),

                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 16),
                        // Premium Glassmorphism Notification Timing Card
                        GlassCard(
                          blur: 15,
                          opacity: 0.08,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue,
                                          AppTheme.accentPurple,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue
                                              .withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Timing',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                                height: 1.0,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Remind me before class starts',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.hintColor
                                                    .withOpacity(0.8),
                                                height: 1.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Premium Slider
                              Row(
                                children: [
                                  Text(
                                    '5m',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: AppTheme.primaryBlue,
                                        inactiveTrackColor: theme.hintColor
                                            .withOpacity(0.2),
                                        thumbColor: Colors.white,
                                        overlayColor: AppTheme.primaryBlue
                                            .withOpacity(0.2),
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10,
                                          elevation: 4,
                                        ),
                                        trackHeight: 4,
                                      ),
                                      child: Slider(
                                        value: _leadTimeMinutes.toDouble(),
                                        min: 5,
                                        max: 30,
                                        divisions:
                                            5, // (30-5)/5 = 5 steps: 5, 10, 15, 20, 25, 30
                                        label: '$_leadTimeMinutes min',
                                        onChanged: (value) {
                                          setState(() {
                                            _leadTimeMinutes = value.toInt();
                                          });
                                        },
                                        onChangeEnd: (value) {
                                          _saveSettings();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '30m',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Glowing Badge
                              Center(
                                child: GlowingCard(
                                  glowColor: AppTheme.primaryBlue,
                                  glowRadius: 8,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 18,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_leadTimeMinutes minutes before',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: AppTheme.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              height: 1.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GlassCard(
                          blur: 15,
                          opacity: 0.08,
                          padding: EdgeInsets.zero,
                          child: SwitchListTile(
                            title: Text(
                              'All Classes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Get notified for every class in your schedule',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                            value: _allSubjects,
                            onChanged: (val) {
                              setState(() => _allSubjects = val);
                              _saveSettings();
                            },
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.select_all_rounded,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),

                        if (!_allSubjects) ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 12),
                            child: Text(
                              'SELECT SPECIFIC CLASSES',
                              style: AppTextStyles.interBadge.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (_subjects.isEmpty)
                            GlassCard(
                              blur: 10,
                              opacity: 0.05,
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No classes found in schedule.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                          ..._subjects.map((subject) {
                            final isSelected = _selectedSubjects.contains(
                              subject,
                            );
                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              blur: 10,
                              opacity: 0.05,
                              padding: EdgeInsets.zero,
                              child: CheckboxListTile(
                                title: Text(
                                  subject,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: isSelected,
                                onChanged: (val) =>
                                    _toggleSubject(subject, val),
                                activeColor: AppTheme.primaryBlue,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentCard(ThemeData theme) {
    return GlassCard(
      blur: 20,
      opacity: 0.12,
      border: Border.all(
        color: theme.primaryColor.withOpacity(0.3),
        width: 1.5,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.science_rounded, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Send a test alert to check if working.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await NotificationService.showTestNotification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      content: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Colors.green.withOpacity(0.8),
                        child: const Text(
                          'Test notification sent!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

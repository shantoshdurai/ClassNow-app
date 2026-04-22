import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _hasPermission = false;
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
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final all = prefs.getBool('notifications_all_subjects') ?? true;
    final selected =
        prefs.getStringList('notification_selected_subjects') ?? [];
    final leadTime = prefs.getInt('notifications_lead_time') ?? 15;

    // Check actual OS permission
    final hasPermission = await NotificationService.hasPermission();

    final uniqueSubjects = await NotificationService.getUniqueSubjects();

    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        // Only enable if both preference AND permission are true
        _notificationsEnabled = enabled && hasPermission;
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
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 45, 16, 0),
          child: GlassCard(
            blur: 40,
            opacity: isDark ? 0.05 : 0.7,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'NOTIFICATIONS',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.monoLabel.copyWith(
                      color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.primaryColor,
                        size: 18,
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
          const AuroraBackground(),

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
                        blur: 40,
                        opacity: isDark ? 0.05 : 0.7,
                        padding: EdgeInsets.zero,
                        child: SwitchListTile(
                          title: Text(
                            'Enable Notifications',
                            style: AppTextStyles.interTitle.copyWith(
                              fontSize: 18,
                              color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                            ),
                          ),
                          subtitle: Text(
                            _hasPermission
                                ? 'Turn on/off all class reminders'
                                : 'Permission required - tap to enable',
                            style: AppTextStyles.interSmall.copyWith(
                              color: _hasPermission
                                  ? (isDark ? AppTheme.glassMuted : AppTheme.paperMuted)
                                  : Colors.orange,
                              fontWeight: _hasPermission ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          value: _notificationsEnabled,
                          onChanged: (val) async {
                            if (val && !_hasPermission) {
                              // User wants to enable but doesn't have permission
                              final granted = await NotificationService.requestPermissions();
                              if (!mounted) return;
                              if (granted) {
                                setState(() {
                                  _hasPermission = true;
                                  _notificationsEnabled = true;
                                });
                                await _saveSettings();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✓ Notification permission granted'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✗ Permission denied. Enable in Settings > Apps > ClassNow > Notifications'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            } else {
                              setState(() => _notificationsEnabled = val);
                              await _saveSettings();
                            }
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
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                      ),

                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 16),
                        // Premium Glassmorphism Notification Timing Card
                        GlassCard(
                          blur: 40,
                          opacity: isDark ? 0.05 : 0.7,
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
                                        colors: isDark 
                                          ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                                          : [AppTheme.paperAccent, AppTheme.paperAccentInk],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.3),
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
                                          style: AppTextStyles.interTitle.copyWith(
                                            fontSize: 20,
                                            color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Remind me before class starts',
                                          style: AppTextStyles.interSmall.copyWith(
                                            color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
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
                          blur: 40,
                          opacity: isDark ? 0.05 : 0.7,
                          padding: EdgeInsets.zero,
                          child: SwitchListTile(
                            title: Text(
                              'All Classes',
                              style: AppTextStyles.interTitle.copyWith(
                                fontSize: 18,
                                color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                              ),
                            ),
                            subtitle: Text(
                              'Get notified for every class in your schedule',
                              style: AppTextStyles.interSmall.copyWith(
                                color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
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
                              horizontal: 20,
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
                              blur: 40,
                              opacity: isDark ? 0.03 : 0.6,
                              padding: EdgeInsets.zero,
                              child: CheckboxListTile(
                                title: Text(
                                  subject,
                                  style: AppTextStyles.interSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                                  ),
                                ),
                                value: isSelected,
                                onChanged: (val) =>
                                    _toggleSubject(subject, val),
                                activeColor: theme.primaryColor,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
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
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      blur: 40,
      opacity: isDark ? 0.05 : 0.7,
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
                      style: AppTextStyles.interTitle.copyWith(
                        fontSize: 18,
                        color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Send a test alert to check if working.',
                      style: AppTextStyles.interSmall.copyWith(
                        color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
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

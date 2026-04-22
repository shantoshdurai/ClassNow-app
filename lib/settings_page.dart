import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/onboarding_screen.dart';
import 'package:flutter_firebase_test/theme_provider.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_firebase_test/screens/mycamu_sync_screen.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _hasNotificationPermission = false;
  bool _widgetsEnabled = false;
  bool _showAdvancedSettings = false;

  UserData? _userData;
  int _streak = 0;
  String? _attendancePercent;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    attendanceUpdateNotifier.addListener(_loadPrefs);
  }

  @override
  void dispose() {
    attendanceUpdateNotifier.removeListener(_loadPrefs);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = await UserService.getUserData();
    final streak = await UserService.getStreak();
    final hasPermission = await NotificationService.hasPermission();
    if (!mounted) return;
    setState(() {
      _hasNotificationPermission = hasPermission;
      _notificationsEnabled = (prefs.getBool('notifications_enabled') ?? false) && hasPermission;
      _widgetsEnabled = prefs.getBool('widgets_enabled') ?? false;
      _userData = userData;
      _streak = streak;
      _attendancePercent = prefs.getString('mycamu_attendance_percent');
    });
  }

  Future<void> _setWidgetsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widgets_enabled', value);
    if (!mounted) return;
    setState(() => _widgetsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value ? 'Widgets enabled' : 'Widgets disabled'),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null && mounted) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        await themeProvider.setCustomBackground(pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom background applied!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _clearBackgroundImage() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.clearCustomBackground();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background reset to default')),
      );
    }
  }

  Future<void> _launchFeedback() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSeZlo_8A2e8DT-JcwobElZPlYOA8vQpAuueoGtJjqKDe0kdtw/viewform?usp=preview',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch feedback form')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bg       = isDark ? AppTheme.glassBg       : AppTheme.paperBg;
    final surface  = isDark ? AppTheme.glassBg2      : AppTheme.paperSurface;
    final inkColor = isDark ? AppTheme.glassInk      : AppTheme.paperInk;
    final ink2     = isDark ? AppTheme.glassInk2     : AppTheme.paperInk2;
    final mutedColor = isDark ? AppTheme.glassMuted  : AppTheme.paperMuted;
    final accent   = isDark ? AppTheme.glassAccent   : AppTheme.paperAccent;
    final border   = isDark ? AppTheme.glassBorder   : AppTheme.paperLine;
    final border2  = isDark ? AppTheme.glassBorder2  : AppTheme.paperLine;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Background ─────────────────────────────────────────────────
            if (isDark) ...[
              Container(color: AppTheme.glassBg),
              const AuroraBackground(),
            ] else
              Container(color: AppTheme.paperBg),

            // ── Content ────────────────────────────────────────────────────
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 48),
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                    child: Row(
                      children: [
                        _iconBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          color: inkColor,
                          border: border2,
                          surface: surface,
                          onTap: () => Navigator.pop(context),
                          isDark: isDark,
                        ),
                        const Spacer(),
                        Text(
                          'PROFILE',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.monoLabel.copyWith(
                            color: mutedColor,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const Spacer(),
                        // Theme Toggle Button
                        _iconBtn(
                          icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: isDark ? Colors.orangeAccent : accent,
                          border: border2,
                          surface: surface,
                          onTap: () => themeProvider.toggleTheme(!isDark),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _iconBtn(
                          icon: Icons.ios_share_rounded,
                          color: inkColor,
                          border: border2,
                          surface: surface,
                          onTap: () async {
                            final Uri url = Uri.parse('https://github.com/shantoshdurai/ClassNow-app');
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open GitHub link')),
                                );
                              }
                            }
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Profile hero card ─────────────────────────────────────
                  _profileHero(
                    isDark: isDark,
                    inkColor: inkColor,
                    ink2: ink2,
                    mutedColor: mutedColor,
                    accent: accent,
                    surface: surface,
                    border: border,
                    border2: border2,
                    themeProvider: themeProvider,
                  ),

                  const SizedBox(height: 24),

                  // ── Schedule section ──────────────────────────────────────
                  _sectionLabel('SCHEDULE', mutedColor),
                  _settingsGroup(
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    children: [
                      _settingsRow(
                        icon: Icons.notifications_outlined,
                        iconColor: accent,
                        title: 'Class Alerts',
                        meta: _hasNotificationPermission
                            ? '15 min before each class'
                            : 'Permission required',
                        inkColor: inkColor,
                        mutedColor: _hasNotificationPermission ? mutedColor : Colors.orange,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        trailing: _toggle(on: _notificationsEnabled, accent: accent, isDark: isDark, onChanged: (v) async {
                          if (v && !_hasNotificationPermission) {
                            final granted = await NotificationService.requestPermissions();
                            if (!mounted) return;
                            if (granted) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('notifications_enabled', true);
                              if (mounted) {
                                setState(() {
                                  _hasNotificationPermission = true;
                                  _notificationsEnabled = true;
                                });
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enable notifications in Settings > Apps > ClassNow > Notifications'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notifications_enabled', v);
                            if (mounted) setState(() => _notificationsEnabled = v);
                          }
                        }),
                      ),
                      _divider(border),
                      _settingsRow(
                        icon: Icons.school_outlined,
                        iconColor: accent,
                        title: 'My Class',
                        meta: 'Change section or year',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                          (r) => false,
                        ),
                      ),
                      _divider(border),
                      _settingsRow(
                        icon: Icons.sync_rounded,
                        iconColor: const Color(0xFF9B59FF),
                        title: 'Sign in Camu',
                        meta: 'Link attendance data',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        isLast: true,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const MyCamuSyncScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Appearance section ────────────────────────────────────
                  _sectionLabel('APPEARANCE', mutedColor),
                  _settingsGroup(
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    children: [
                      _settingsRow(
                        icon: Icons.widgets_outlined,
                        iconColor: accent,
                        title: 'Home Widget',
                        meta: 'Next class · Medium',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        trailing: _toggle(on: _widgetsEnabled, accent: accent, isDark: isDark, onChanged: _setWidgetsEnabled),
                      ),
                      _divider(border),
                      _settingsRow(
                        icon: Icons.image_outlined,
                        iconColor: accent,
                        title: 'Custom Background',
                        meta: themeProvider.customBackgroundPath != null
                            ? 'Tap to change'
                            : 'Personalize your dashboard',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        isLast: true,
                        onTap: _pickBackgroundImage,
                        trailing: themeProvider.customBackgroundPath != null
                            ? GestureDetector(
                                onTap: _clearBackgroundImage,
                                child: Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent, size: 18),
                              )
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Advanced (collapsible) ────────────────────────────────
                  _settingsGroup(
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          child: Row(
                            children: [
                              _iconTile(
                                icon: _showAdvancedSettings
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: accent,
                                surface: surface,
                                border: border,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Advanced Features',
                                        style: AppTextStyles.interMentor.copyWith(
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Text(
                                      _showAdvancedSettings
                                          ? 'Hide additional options'
                                          : 'Blur, widgets & more',
                                      style: AppTextStyles.interSmall
                                          .copyWith(color: mutedColor, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showAdvancedSettings) ...[
                        _divider(border),
                        // Glass blur slider
                        _blurSlider(
                          icon: Icons.blur_on,
                          title: 'UI Glass Blur',
                          subtitle: 'Frostiness of cards',
                          value: themeProvider.glassBlur,
                          max: 50,
                          accent: accent,
                          inkColor: inkColor,
                          mutedColor: mutedColor,
                          onChanged: themeProvider.setGlassBlur,
                        ),
                        _divider(border),
                        // Background blur slider
                        _blurSlider(
                          icon: Icons.blur_circular,
                          title: 'Background Blur',
                          subtitle: 'Blur custom background image',
                          value: themeProvider.backgroundBlur,
                          max: 20,
                          accent: accent,
                          inkColor: inkColor,
                          mutedColor: mutedColor,
                          onChanged: themeProvider.setBackgroundBlur,
                        ),
                        _divider(border),
                        _settingsRow(
                          icon: Icons.info_outline_rounded,
                          iconColor: accent,
                          title: 'Widget Setup Guide',
                          meta: 'Learn how to add home widgets',
                          inkColor: inkColor,
                          mutedColor: mutedColor,
                          surface: surface,
                          border: border,
                          isDark: isDark,
                          isLast: true,
                          onTap: () => _showWidgetInfoDialog(context),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Support section ───────────────────────────────────────
                  _sectionLabel('SUPPORT', mutedColor),
                  _settingsGroup(
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    children: [
                      _settingsRow(
                        icon: Icons.feedback_outlined,
                        iconColor: accent,
                        title: 'Feedback & Contributions',
                        meta: 'Report issues or share materials',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        isLast: true,
                        onTap: _launchFeedback,
                        trailing: Icon(Icons.open_in_new_rounded, size: 14, color: mutedColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Experimental section ──────────────────────────────────
                  _sectionLabel('EXPERIMENTAL', mutedColor),
                  _settingsGroup(
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    children: [
                      _settingsRow(
                        icon: Icons.delete_sweep_outlined,
                        iconColor: Colors.redAccent,
                        title: 'Clear Attendance Data',
                        meta: 'Remove synced attendance data',
                        inkColor: inkColor,
                        mutedColor: mutedColor,
                        surface: surface,
                        border: border,
                        isDark: isDark,
                        isLast: true,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('mycamu_attendance_percent');
                          await prefs.remove('mycamu_subject_attendance');
                          await prefs.remove('mycamu_last_sync');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Attendance data cleared!')),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Footer ────────────────────────────────────────────────
                  Center(
                    child: Text(
                      'ClassNow · v3.2.1',
                      style: AppTextStyles.monoLabel.copyWith(color: mutedColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _profileHero({
    required bool isDark,
    required Color inkColor,
    required Color ink2,
    required Color mutedColor,
    required Color accent,
    required Color surface,
    required Color border,
    required Color border2,
    required ThemeProvider themeProvider,
  }) {
    return GlassCard(
      blur: 40,
      opacity: isDark ? 0.1 : 0.6,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          // Avatar + name row
          Row(
            children: [
              // Avatar tile
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.glassAccent, const Color(0xFF2979FF)]
                        : [AppTheme.paperAccent, AppTheme.paperAccentInk],
                  ),
                  boxShadow: isDark
                      ? [
                        BoxShadow(
                          color: AppTheme.glassAccentGlow.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: AppTheme.paperAccent.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                ),
                child: Center(
                  child: Text(
                    _userData?.initials ?? 'ME',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?.name ?? 'DSU Student',
                      style: AppTextStyles.interTitle.copyWith(
                        fontSize: 20,
                        color: inkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _userData?.branch != null ? _userData!.branch : 'DSU · Student',
                      style: AppTextStyles.monoLabel.copyWith(
                        color: ink2,
                        letterSpacing: 0.4,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : AppTheme.paperAccentSoft,
                        border: Border.all(
                          color: accent.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isDark ? 'GLASS · DARK' : 'PAPER · LIGHT',
                        style: AppTextStyles.monoLabel.copyWith(
                          color: accent,
                          letterSpacing: 1.2,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats strip
          Container(
            padding: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : AppTheme.paperLine,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _statCell(
                  label: 'STREAK',
                  value: '$_streak',
                  unit: 'd',
                  inkColor: inkColor,
                  mutedColor: mutedColor,
                ),
                _statDivider(isDark ? Colors.white10 : AppTheme.paperLine),
                _statCell(
                  label: 'ATTENDANCE',
                  value: _attendancePercent ?? '--',
                  unit: _attendancePercent != null ? '%' : '',
                  inkColor:
                      isDark ? AppTheme.glassAccent2 : AppTheme.paperAccentInk,
                  mutedColor: mutedColor,
                ),
                _statDivider(isDark ? Colors.white10 : AppTheme.paperLine),
                _statCell(
                  label: 'YEAR',
                  value: _userData?.year ?? '--',
                  unit: '',
                  inkColor: inkColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required String label,
    required String value,
    required String unit,
    required Color inkColor,
    required Color mutedColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: inkColor,
                    letterSpacing: -0.4,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              color: mutedColor, fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(Color border) {
    return Container(width: 1, height: 36, color: border);
  }

  Widget _sectionLabel(String text, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: AppTextStyles.monoLabel.copyWith(color: mutedColor, letterSpacing: 1.5),
      ),
    );
  }

  Widget _settingsGroup({
    required bool isDark,
    required Color surface,
    required Color border,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : AppTheme.paperSurface,
            border: Border.all(color: border, width: 1),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String meta,
    required Color inkColor,
    required Color mutedColor,
    required Color surface,
    required Color border,
    required bool isDark,
    bool isLast = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _iconTile(icon: icon, color: iconColor, surface: surface, border: border),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.interMentor.copyWith(
                        color: inkColor, fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(meta,
                      style: AppTextStyles.interSmall.copyWith(
                        color: mutedColor, fontSize: 12,
                      )),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _iconTile({
    required IconData icon,
    required Color color,
    required Color surface,
    required Color border,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: surface,
        border: Border.all(color: border, width: 1),
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }

  Widget _toggle({
    required bool on,
    required Color accent,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: on
              ? accent
              : (isDark ? Colors.white.withOpacity(0.10) : AppTheme.paperFaint),
          boxShadow: on && isDark
              ? [BoxShadow(color: AppTheme.glassAccentGlow, blurRadius: 10)]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(Color border) {
    return Divider(height: 1, color: border, indent: 60, endIndent: 14);
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color border,
    required Color surface,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.white.withOpacity(0.04) : surface,
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  Widget _blurSlider({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double max,
    required Color accent,
    required Color inkColor,
    required Color mutedColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.interMentor.copyWith(
                          color: inkColor, fontWeight: FontWeight.w600,
                        )),
                    Text(subtitle,
                        style: AppTextStyles.interSmall
                            .copyWith(color: mutedColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accent,
              inactiveTrackColor: accent.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: accent.withOpacity(0.15),
              trackHeight: 3.5,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: max.toInt(),
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
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
                '1. Long-press on a blank space on your home screen.\n'
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

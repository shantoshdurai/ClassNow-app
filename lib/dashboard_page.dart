import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/widgets/skeleton_loader.dart';
import 'package:flutter_firebase_test/notification_service.dart';
import 'package:flutter_firebase_test/widget_service.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/subject_utils.dart';
import 'package:flutter_firebase_test/notifiers.dart';
import 'package:flutter_firebase_test/widgets/chatbot_interface.dart';
import 'package:flutter_firebase_test/theme_provider.dart';
import 'package:flutter_firebase_test/widgets/class_selection_widget.dart';
import 'package:flutter_firebase_test/login_screen.dart';
import 'package:flutter_firebase_test/settings_page.dart';
import 'package:flutter_firebase_test/announcements_page.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/screens/profile_page.dart';

class DashboardPage extends StatefulWidget {
  final bool forceSelectionMode;

  const DashboardPage({super.key, this.forceSelectionMode = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  String selectedDay = DateFormat('EEEE').format(DateTime.now());
  bool isAdmin = false;
  bool isLoggedInViaMyCamu = false;
  bool notificationsEnabled = true;
  bool widgetsEnabled = true;
  bool isOnline = true;
  Timer? _connectivityTimer;
  Timer? _widgetUpdateTimer;
  Timer? _notificationTimer;
  Timer? _duringClassTimer;
  Timer? _classScheduleTimer;

  String? _scheduleCacheKey;
  bool? _showSelectionOverlay;
  List<Map<String, dynamic>> _cachedSchedule = [];
  DateTime? _cachedScheduleUpdatedAt;
  DateTime? _lastAnnouncementReadTime;

  // Performance tracking variables
  int _updateCount = 0;
  DateTime? _lastUpdate;
  DateTime? _lastSuccessfulUpdate;
  int _errorCount = 0;
  final List<String> _updateHistory = [];
  StreamSubscription<QuerySnapshot>? _announcementSubscription;

  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('🚀 DashboardPage initState - Setting up timers and observers');

    _loadSettings().then((_) {
      if (!mounted) return;
      if (widgetsEnabled) {
        WidgetService.updateWidget(forceRefresh: true);
      }
    });
    _loadAnnouncementStatus();
    _checkMyCamuLogin();
    NotificationService.scheduleTimetableNotifications();
    _startConnectivityMonitoring();
    _startWidgetUpdateTimer();
    _scheduleNextClassUpdate();
    _listenForAnnouncements();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;
      if (user == null) {
        setState(() {
          isAdmin = false;
        });
      } else {
        _checkAdminStatus(user);
      }
    });
  }

  @override
  void dispose() {
    print('🗑️ DashboardPage dispose - Canceling all timers');
    WidgetsBinding.instance.removeObserver(this);

    _connectivityTimer?.cancel();
    _widgetUpdateTimer?.cancel();
    _notificationTimer?.cancel();
    _duringClassTimer?.cancel();
    _classScheduleTimer?.cancel();
    _announcementSubscription?.cancel();

    super.dispose();
  }

  void _listenForAnnouncements() {
    print('📢 Starting announcement listener');
    final appStartTime = DateTime.now();

    _announcementSubscription?.cancel();
    _announcementSubscription = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

      if (timestamp != null &&
          timestamp.isAfter(appStartTime.add(const Duration(seconds: 2)))) {
        final message = data['message'] ?? 'New Announcement';
        final author = data['author'] ?? 'Mentor';

        print('🔔 New Announcement detected! Triggering notification.');
        NotificationService.showAnnouncementNotification(
          '$author',
          '"$message"',
        );
      }
    });
  }

  void _startConnectivityMonitoring() {
    print('🌐 Starting connectivity monitoring');
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(minutes: 5), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _checkConnectivity();
    });

    _checkConnectivity();
  }

  Future<void> _checkMyCamuLogin() async {
    final loggedIn = await UserService.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedInViaMyCamu = loggedIn;
      });
    }
  }

  Future<void> _loadAnnouncementStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = prefs.getString('last_announcement_read_time');
    if (lastRead != null && mounted) {
      setState(() {
        _lastAnnouncementReadTime = DateTime.parse(lastRead);
      });
    }
  }

  void _scheduleNextClassUpdate() {
    print('📅 [Schedule] Scheduling next class update...');

    _classScheduleTimer?.cancel();

    final now = DateTime.now();
    DateTime? nextUpdateTime;
    String? nextUpdateReason;

    for (var classData in _cachedSchedule) {
      try {
        final dayOfWeek =
            (classData['day'] ?? classData['dayOfWeek']) as String?;
        final currentDay = DateFormat('EEEE').format(now);

        if (dayOfWeek != currentDay) continue;

        final startTimeStr = classData['startTime'] as String;
        final endTimeStr = classData['endTime'] as String;

        final startTime = _parseTime(startTimeStr);
        final endTime = _parseTime(endTimeStr);

        final startDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          startTime.hour,
          startTime.minute,
        );

        final endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          endTime.hour,
          endTime.minute,
        );

        if (startDateTime.isAfter(now)) {
          if (nextUpdateTime == null ||
              startDateTime.isBefore(nextUpdateTime)) {
            nextUpdateTime = startDateTime;
            nextUpdateReason = 'Class Start: ${classData['subject']}';
          }
        }

        if (endDateTime.isAfter(now)) {
          if (nextUpdateTime == null || endDateTime.isBefore(nextUpdateTime)) {
            nextUpdateTime = endDateTime;
            nextUpdateReason = 'Class End: ${classData['subject']}';
          }
        }
      } catch (e) {
        print('⚠️ [Schedule] Error processing class: $e');
      }
    }

    if (nextUpdateTime != null) {
      final delay = nextUpdateTime.difference(now);
      final delayMinutes = delay.inMinutes;
      final delaySeconds = delay.inSeconds % 60;

      print(
        '⏰ [Schedule] Next update scheduled in ${delayMinutes}m ${delaySeconds}s',
      );
      print('📍 [Schedule] Reason: $nextUpdateReason');
      print(
        '🕐 [Schedule] Time: ${DateFormat('HH:mm').format(nextUpdateTime)}',
      );

      _classScheduleTimer = Timer(delay, () {
        print('🔔 [Schedule] Scheduled update triggered: $nextUpdateReason');
        _updateHomeScreenWidget();
        _scheduleNextClassUpdate();
      });
    } else {
      print('ℹ️ [Schedule] No more classes today, will check again tomorrow');
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final untilMidnight = tomorrow.difference(now);

      _classScheduleTimer = Timer(untilMidnight, () {
        print('🌅 [Schedule] New day - rescheduling updates');
        _scheduleNextClassUpdate();
      });
    }
  }

  void _printDiagnosticInfo() {
    print('🔍 [Diagnostic] Widget Update System Status');
    print('   Total Updates: $_updateCount');
    print('   Error Count: $_errorCount');
    print(
      '   Last Update: ${_lastUpdate != null ? DateFormat('HH:mm:ss').format(_lastUpdate!) : 'Never'}',
    );
    print(
      '   Last Success: ${_lastSuccessfulUpdate != null ? DateFormat('HH:mm:ss').format(_lastSuccessfulUpdate!) : 'Never'}',
    );
    print('   Widgets Enabled: $widgetsEnabled');
    print('   Cached Classes: ${_cachedSchedule.length}');

    if (_updateHistory.isNotEmpty) {
      print('📋 [Diagnostic] Recent Update History:');
      for (int i = 0; i < _updateHistory.length; i++) {
        print('   ${i + 1}. ${_updateHistory[i]}');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('🔄 [Lifecycle] App state changed to: $state');

    if (state == AppLifecycleState.resumed) {
      print('▶️ [Lifecycle] App resumed - updating widget');
      WidgetService.updateWidget(forceRefresh: true);
      _scheduleNextClassUpdate();
      _printDiagnosticInfo();
    }
  }

  Future<void> _checkConnectivity() async {
    bool wasOnline = isOnline;

    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          isOnline = true;
        });
      }

      if (!wasOnline && mounted) {
        await NotificationService.refreshNotificationsWhenOnline();
        if (widgetsEnabled) {
          _updateHomeScreenWidget();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Back online. Syncing latest timetable…'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isOnline = false;
        });
      }

      if (wasOnline && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You’re offline. Showing saved timetable.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadScheduleCache(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    final updatedRaw = prefs.getString('${cacheKey}_updatedAt');
    if (!mounted) return;

    if (raw == null) {
      setState(() {
        _scheduleCacheKey = cacheKey;
        _cachedSchedule = [];
        _cachedScheduleUpdatedAt = null;
      });
      return;
    }

    final decoded = jsonDecode(raw);
    final list = (decoded is List)
        ? decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    setState(() {
      _scheduleCacheKey = cacheKey;
      _cachedSchedule = list;
      _cachedScheduleUpdatedAt = updatedRaw != null
          ? DateTime.tryParse(updatedRaw)
          : null;
    });
  }

  Future<void> _saveScheduleCache(
    String cacheKey,
    List<QueryDocumentSnapshot> docs, {
    required bool fromServer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {'id': d.id, ...data};
    }).toList();
    await prefs.setString(cacheKey, jsonEncode(payload));
    if (fromServer) {
      await prefs.setString(
        '${cacheKey}_updatedAt',
        DateTime.now().toIso8601String(),
      );
    }
  }

  List<_ScheduleItem> _itemsFromMaps(List<Map<String, dynamic>> all) {
    return all
        .map((e) => _ScheduleItem(data: Map<String, dynamic>.from(e)))
        .toList();
  }

  Widget _buildExamModeBanner() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GlassCard(
        blur: 20,
        opacity: 0.15,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(24),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_document,
                size: 48,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exams are going on!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Regular classes are temporarily suspended. Best of luck with your exams!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner({
    required String title,
    String? subtitle,
    IconData icon = Icons.info_outline,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatUpdatedAt(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('MMM dd, hh:mm a').format(dt);
  }

  DateTime _parseTime(String timeStr) {
    try {
      final cleanTime = timeStr.trim().toUpperCase();
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        return DateFormat('hh:mm a').parse(cleanTime);
      }
      DateTime parsed = DateFormat('HH:mm').parse(cleanTime);
      if (parsed.hour >= 1 && parsed.hour <= 7) {
        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour + 12,
          parsed.minute,
        );
      }
      return parsed;
    } catch (e) {
      return DateTime(2000, 1, 1, 0, 0);
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        widgetsEnabled = prefs.getBool('widgets_enabled') ?? true;
      });
    }
  }

  Future<void> _checkAdminStatus(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          isAdmin = doc.exists && doc.data()?['role'] == 'mentor';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isAdmin = false;
        });
      }
    }
  }

  void _startWidgetUpdateTimer() {
    print('⏰ [Timer] Starting foreground update timer (30 mins)');

    _widgetUpdateTimer?.cancel();
    _widgetUpdateTimer = Timer.periodic(const Duration(minutes: 30), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widgetsEnabled) {
        await _updateHomeScreenWidget();
      }
    });
  }

  Future<void> _updateHomeScreenWidget() async {
    _updateCount++;
    if (widgetsEnabled) {
      await WidgetService.updateWidget();
      if (mounted) {
        setState(() {
          _lastUpdate = DateTime.now();
          _lastSuccessfulUpdate = DateTime.now();
          if (_updateHistory.length > 10) _updateHistory.removeAt(0);
          _updateHistory.add(
            '${DateFormat('HH:mm:ss').format(_lastUpdate!)} - SUCCESS',
          );
        });
      }
    }
  }

  String _friendlyFirestoreError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "Can’t refresh right now. Showing saved timetable.";
        case 'unavailable':
        case 'network-request-failed':
          return "You’re offline. Showing saved timetable.";
        default:
          return "We couldn’t load the latest timetable. Showing saved data.";
      }
    }
    return "We couldn’t load the latest timetable. Showing saved data.";
  }

  Future<void> _postAnnouncement(
    String message, {
    bool isSystemMessage = false,
  }) async {
    try {
      final userSelection = Provider.of<UserSelectionProvider>(
        context,
        listen: false,
      );
      if (!userSelection.hasSelection) return;

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(userSelection.departmentId)
          .collection('years')
          .doc(userSelection.yearId)
          .collection('sections')
          .doc(userSelection.sectionId)
          .collection('announcements')
          .add({
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'isSystemMessage': isSystemMessage,
            'author': isAdmin
                ? FirebaseAuth.instance.currentUser?.email
                : 'System',
          });

      print('📢 [Announcement] Posted: $message');
    } catch (e) {
      print('❌ [Announcement] Error posting announcement: $e');
    }
  }

  Future<void> _manualRefresh() async {
    print('🔄 [Dashboard] Manual refresh triggered');
    try {
      await _checkConnectivity().timeout(const Duration(seconds: 7));
    } catch (_) {
      isOnline = false;
    }

    if (!mounted) return;

    if (isOnline) {
      if (widgetsEnabled) {
        await _updateHomeScreenWidget();
      }
      await NotificationService.refreshNotificationsWhenOnline();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timetable updated successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline: Displaying cached timetable'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userSelection = Provider.of<UserSelectionProvider>(context);
    _showSelectionOverlay ??= widget.forceSelectionMode;

    if (_showSelectionOverlay == true || !userSelection.hasSelection) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
        body: Stack(
          children: [
            Container(
              color: isDark ? AppTheme.glassBg : AppTheme.paperBg,
            ),
            SafeArea(
              child: Center(
                child: ClassSelectionWidget(
                  onSelectionComplete: () {
                    if (mounted) {
                      setState(() {
                        _showSelectionOverlay = false;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 45, 16, 0),
          child: GlassCard(
            blur: 40,
            opacity: 0.25,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isAdmin ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      color: isAdmin ? AppTheme.accentPurple : theme.hintColor,
                    ),
                    onPressed: _showLoginDialog,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Class Now',
                          style: AppTextStyles.interTitle.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: 22,
                            height: 1.1,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          isAdmin ? "MENTOR MODE" : "STUDENT VIEW",
                          style: AppTextStyles.monoLabel.copyWith(
                            color: isAdmin
                                ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
                                : theme.hintColor.withOpacity(0.8),
                            letterSpacing: 1.5,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoggedInViaMyCamu)
                        IconButton(
                          icon: Icon(
                            Icons.person_rounded,
                            color: theme.primaryColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),
                      if (isAdmin)
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: theme.primaryColor,
                          ),
                          onPressed: () => _showClassDialog(context),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Base background ─────────────────────────────────────────────
          Positioned.fill(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final customPath = themeProvider.customBackgroundPath;
                if (customPath != null && File(customPath).existsSync()) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: themeProvider.backgroundBlur,
                      sigmaY: themeProvider.backgroundBlur,
                      tileMode: TileMode.decal,
                    ),
                    child: Image.file(File(customPath), fit: BoxFit.cover),
                  );
                }
                return Container(
                  color: isDark ? AppTheme.glassBg : AppTheme.paperBg,
                );
              },
            ),
          ),
          // ── Ambient background layer (Aurora / Paper blobs) ──────────────
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final hasCustomBg = themeProvider.customBackgroundPath != null &&
                  File(themeProvider.customBackgroundPath!).existsSync();
              if (hasCustomBg) return const SizedBox.shrink();

              return const AuroraBackground();
            },
          ),
          SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 500) {
                  final currentIndex = weekDays.indexOf(selectedDay);
                  if (currentIndex > 0) {
                    setState(() {
                      selectedDay = weekDays[currentIndex - 1];
                    });
                  }
                } else if (details.primaryVelocity! < -500) {
                  final currentIndex = weekDays.indexOf(selectedDay);
                  if (currentIndex < weekDays.length - 1) {
                    setState(() {
                      selectedDay = weekDays[currentIndex + 1];
                    });
                  }
                }
              },
              child: RefreshIndicator(
                onRefresh: _manualRefresh,
                displacement: 80,
                backgroundColor: theme.primaryColor,
                color: Colors.white,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 100),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 100,
                          ),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('departments')
                                .doc(userSelection.departmentId)
                                .collection('years')
                                .doc(userSelection.yearId)
                                .collection('settings')
                                .doc('mode')
                                .snapshots(),
                            builder: (context, modeSnapshot) {
                              bool isExamMode = false;
                              if (modeSnapshot.hasData && modeSnapshot.data!.exists) {
                                final data = modeSnapshot.data!.data() as Map<String, dynamic>?;
                                isExamMode = data?['isExamMode'] ?? false;
                              }
                              return Column(
                                children: [
                                  _buildAttendanceCard(),
                                  if (isExamMode) ...[
                                    _buildExamModeBanner(),
                                  ] else ...[
                                    _buildDaySelector(),
                                    const SizedBox(height: 10),
                                    _buildClassList(),
                                  ],
                                  if (isAdmin && selectedDay == 'Saturday' && !isExamMode) ...[
                                    const SizedBox(height: 20),
                                    _MentorSaturdayControlPanel(),
                                  ],
                                  if (isAdmin) ...[
                                    const SizedBox(height: 20),
                                    _MentorExamModeControlPanel(isExamMode: isExamMode),
                                  ],
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return GlassCard(
                  blur: themeProvider.glassBlur,
                  opacity: isDark ? 0.2 : 0.5,
                  borderRadius: BorderRadius.circular(30),
                  padding: EdgeInsets.zero,
                  child: FloatingActionButton(
                    heroTag: 'ai_assistant',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ChatbotInterface(),
                      );
                    },
                    child: Icon(
                      Icons.psychology_rounded,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return GlassCard(
                  blur: themeProvider.glassBlur,
                  opacity: isDark ? 0.2 : 0.5,
                  borderRadius: BorderRadius.circular(30),
                  padding: EdgeInsets.zero,
                  child: FloatingActionButton(
                    heroTag: 'announcements',
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () async {
                      final now = DateTime.now();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'last_announcement_read_time',
                        now.toIso8601String(),
                      );
                      if (mounted) {
                        setState(() {
                          _lastAnnouncementReadTime = now;
                        });
                      }
                      Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AnnouncementsPage(isAdmin: isAdmin),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                    },
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('announcements')
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool hasUnread = false;
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          final latestDoc = snapshot.data!.docs.first;
                          final data = latestDoc.data() as Map<String, dynamic>;
                          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                          if (timestamp != null) {
                            if (_lastAnnouncementReadTime == null || timestamp.isAfter(_lastAnnouncementReadTime!)) {
                              hasUnread = true;
                            }
                          }
                        }
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.campaign_rounded,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                            if (hasUnread)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.error.withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 72,
      child: GlassCard(
        blur: themeProvider.glassBlur,
        opacity: isDark ? 0.2 : 0.4,
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: weekDays.length,
          itemBuilder: (context, index) {
            final day = weekDays[index];
            final isSelected = day == selectedDay;

            final daysFromMonday = index;
            final currentDayOfWeek = now.weekday - 1; 
            final daysUntilDay = (daysFromMonday - currentDayOfWeek);
            final dayDate = now.add(Duration(days: daysUntilDay));
            final dateStr = DateFormat('d').format(dayDate);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutExpo,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: isDark 
                                ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                                : [AppTheme.paperAccent, AppTheme.paperAccent.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !isSelected && !isDark ? Colors.black.withOpacity(0.03) : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.substring(0, 3).toUpperCase(),
                          style: AppTextStyles.monoLabel.copyWith(
                            letterSpacing: 1.0,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassList() {
    final theme = Theme.of(context);
    return Consumer<UserSelectionProvider>(
      builder: (context, userSelection, child) {
        if (!userSelection.hasSelection) {
          return const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: ClassSelectionWidget(),
          );
        }

        final cacheKey =
            'cache_schedule_${userSelection.departmentId}_${userSelection.yearId}_${userSelection.sectionId}';
        if (_scheduleCacheKey != cacheKey) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _loadScheduleCache(cacheKey);
          });
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('departments')
              .doc(userSelection.departmentId)
              .collection('years')
              .doc(userSelection.yearId)
              .collection('sections')
              .doc(userSelection.sectionId)
              .collection('schedule')
              .snapshots(includeMetadataChanges: true),
          builder: (context, snapshot) {
            final hasCached = _scheduleCacheKey == cacheKey && _cachedSchedule.isNotEmpty;
            final fromCache = snapshot.data?.metadata.isFromCache == true;

            if (snapshot.hasData) {
              final docs = snapshot.data!.docs.whereType<QueryDocumentSnapshot>().toList();
              _saveScheduleCache(cacheKey, docs, fromServer: !fromCache);
            }

            if (snapshot.connectionState == ConnectionState.waiting && !hasCached && !snapshot.hasData) {
              return const ClassListSkeleton();
            }

            List<Map<String, dynamic>> all;
            if (snapshot.hasData) {
              all = snapshot.data!.docs.map((d) => Map<String, dynamic>.from(d.data() as Map)).toList();
            } else {
              all = _scheduleCacheKey == cacheKey ? _cachedSchedule : [];
            }

            final items = snapshot.hasData
                ? snapshot.data!.docs
                    .whereType<QueryDocumentSnapshot>()
                    .map((d) => _ScheduleItem(doc: d, data: Map<String, dynamic>.from(d.data() as Map)))
                    .toList()
                : _itemsFromMaps(all);

            if (snapshot.hasError && hasCached) {
              final title = _friendlyFirestoreError(snapshot.error!);
              final updated = _formatUpdatedAt(_cachedScheduleUpdatedAt);
              return Column(
                children: [
                  _buildInfoBanner(
                    title: title,
                    subtitle: updated.isNotEmpty ? 'Last updated: $updated' : null,
                    icon: Icons.wifi_off_outlined,
                  ),
                  _buildFilteredScheduleList(theme, items),
                ],
              );
            }

            final shouldShowOfflineBanner = fromCache && hasCached && !isOnline && snapshot.connectionState != ConnectionState.waiting;
            if (shouldShowOfflineBanner) {
              return _buildFilteredScheduleList(theme, items);
            }

            if (snapshot.hasError && !hasCached) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 48, color: theme.hintColor),
                      const SizedBox(height: 12),
                      Text("Can’t load timetable", style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(_friendlyFirestoreError(snapshot.error!), style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return _buildFilteredScheduleList(theme, items);
          },
        );
      },
    );
  }

  Widget _buildFilteredScheduleList(ThemeData theme, List<_ScheduleItem> all) {
    final docs = all.where((e) => (e.data['day'] ?? '') == selectedDay).toList();
    docs.sort((a, b) {
      final startA = _parseTime(a.data['startTime'] ?? '00:00');
      final startB = _parseTime(b.data['startTime'] ?? '00:00');
      return startA.compareTo(startB);
    });

    if (docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Icon(Icons.event_available_outlined, size: 44, color: theme.hintColor),
                const SizedBox(height: 10),
                Text('No classes on $selectedDay', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Enjoy your time. Pull down to refresh when you\'re online.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE', 'en_US').format(now);
    final int currentDayIndex = weekDays.indexOf(currentDay);
    final int selectedDayIndex = weekDays.indexOf(selectedDay);

    _ScheduleItem? currentClass;
    final List<_ScheduleItem> upcomingClasses = [];
    final List<_ScheduleItem> completedClasses = [];

    for (var doc in docs) {
      final startTime = doc.data['startTime'] ?? '';
      final endTime = doc.data['endTime'] ?? '';

      if (selectedDayIndex > currentDayIndex) {
        upcomingClasses.add(doc);
      } else if (selectedDayIndex < currentDayIndex) {
        completedClasses.add(doc);
      } else {
        if (_isTimeInRange(currentTime, startTime, endTime)) {
          currentClass = doc;
        } else if (_isTimeBefore(currentTime, startTime)) {
          upcomingClasses.add(doc);
        } else {
          completedClasses.add(doc);
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: (currentClass != null ? 1 : 0) + upcomingClasses.length + completedClasses.length,
      itemBuilder: (context, index) {
        if (currentClass != null && index == 0) {
          return _buildCurrentClassCard(currentClass!);
        } else {
          final adjustedIndex = currentClass != null ? index - 1 : index;
          if (adjustedIndex < upcomingClasses.length) {
            return _buildUpcomingClassCard(
              upcomingClasses[adjustedIndex],
              adjustedIndex == 0 && currentClass == null && selectedDayIndex == currentDayIndex,
            );
          } else {
            final completedIndex = adjustedIndex - upcomingClasses.length;
            return _buildCompletedClassCard(completedClasses[completedIndex]);
          }
        }
      },
    );
  }

  bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    try {
      final current = DateFormat('HH:mm').parse(currentTime);
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      return (current.isAfter(start) || current.isAtSameMomentAs(start)) &&
          (current.isBefore(end) || current.isAtSameMomentAs(end));
    } catch (e) {
      return false;
    }
  }

  bool _isTimeBefore(String currentTime, String startTime) {
    try {
      final current = DateFormat('HH:mm').parse(currentTime);
      final start = _parseTime(startTime);
      return current.isBefore(start);
    } catch (e) {
      return false;
    }
  }

  Widget _buildCurrentClassCard(_ScheduleItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = item.data;
    final start = data['startTime'] ?? '--:--';
    final end = data['endTime'] ?? '--:--';

    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    double progress = 0.0;
    try {
      final current = DateFormat('HH:mm').parse(currentTime);
      final classStart = _parseTime(start);
      final classEnd = _parseTime(end);
      final totalDuration = classEnd.difference(classStart).inMinutes;
      final elapsedDuration = current.difference(classStart).inMinutes;
      if (totalDuration > 0) {
        progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
      }
    } catch (e) {
      progress = 0.0;
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 20),
          blur: themeProvider.glassBlur + 15,
          opacity: 0.4,
          borderRadius: BorderRadius.circular(28),
          padding: EdgeInsets.zero,
          border: Border.all(
            color: theme.primaryColor.withOpacity(isDark ? 0.4 : 0.2),
            width: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.18),
                      theme.primaryColor.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 16, height: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.7),
                                blurRadius: 8,
                                spreadRadius: 3,
                              )
                            ],
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: 800.ms)
                     .shimmer(delay: 400.ms, duration: 1200.ms, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text('LIVE NOW', style: AppTextStyles.interLiveNow.copyWith(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$start - $end",
                        style: AppTextStyles.interProgress.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: Icon(SubjectUtils.getSubjectIcon(data['subject']), color: theme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['subject'] ?? 'No Subject', style: AppTextStyles.interSubject.copyWith(color: theme.colorScheme.onSurface)),
                              const SizedBox(height: 4),
                              Text(data['mentor'] ?? 'Unknown Mentor', style: AppTextStyles.interMentor.copyWith(color: isDark ? Colors.white60 : theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Session Progress', style: AppTextStyles.interProgress.copyWith(color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.7))),
                        Text('${(progress * 100).toInt()}%', style: AppTextStyles.interProgress.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: progress, backgroundColor: theme.primaryColor.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor), minHeight: 6),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 6),
                        Text("Room ${data['room'] ?? 'TBD'}", style: AppTextStyles.interSmall.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        const Spacer(),
                        if (isAdmin)
                          IconButton(icon: const Icon(Icons.edit_note_rounded), onPressed: () => _showEditOptions(item.doc!), color: theme.primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingClassCard(_ScheduleItem item, bool isFirst) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = item.data;
    final start = data['startTime'] ?? '--:--';
    final end = data['endTime'] ?? '--:--';

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          blur: themeProvider.glassBlur,
          opacity: isDark ? 0.2 : 0.4,
          borderRadius: BorderRadius.circular(22),
          padding: EdgeInsets.zero,
          child: InkWell(
            onLongPress: (isAdmin && item.doc != null) ? () => _showEditOptions(item.doc!) : null,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isFirst)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                          ),
                          child: Text('UP NEXT', style: AppTextStyles.interLiveNow.copyWith(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$start - $end", 
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8), 
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(SubjectUtils.getSubjectIcon(data['subject']), size: 22, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          data['subject'] ?? 'No Subject', 
                          style: AppTextStyles.interNext.copyWith(
                            color: theme.colorScheme.onSurface, 
                            fontSize: 19,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        IconButton(icon: const Icon(Icons.edit_note_rounded), onPressed: () => _showEditOptions(item.doc!), color: theme.primaryColor, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(data['mentor'] ?? 'Unknown', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Icon(Icons.location_on_outlined, size: 14, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text("Room ${data['room'] ?? 'TBD'}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedClassCard(_ScheduleItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = item.data;
    final start = data['startTime'] ?? '--:--';
    final end = data['endTime'] ?? '--:--';
    final Color mutedColor = isDark ? Colors.white24 : Colors.black26;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          blur: themeProvider.glassBlur * 0.75,
          opacity: 0.15,
          borderRadius: BorderRadius.circular(12),
          padding: EdgeInsets.zero,
          child: InkWell(
            onLongPress: (isAdmin && item.doc != null) ? () => _showEditOptions(item.doc!) : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('FINISHED', style: theme.textTheme.labelSmall?.copyWith(color: mutedColor, letterSpacing: 1.5, fontWeight: FontWeight.w900, fontSize: 9)),
                      const Spacer(),
                      Text("$start - $end", style: theme.textTheme.bodySmall?.copyWith(color: mutedColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: mutedColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['subject'] ?? 'No Subject',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: mutedColor.withOpacity(0.5),
                            decorationThickness: 2,
                            color: mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        IconButton(icon: const Icon(Icons.edit_note_rounded), onPressed: () => _showEditOptions(item.doc!), color: theme.primaryColor.withOpacity(0.5), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLoginDialog() {
    if (isAdmin) {
      FirebaseAuth.instance.signOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  void _showEditOptions(DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Edit Class'),
            onTap: () {
              Navigator.pop(context);
              _showClassDialog(context, doc: doc);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Class'),
            onTap: () {
              Navigator.pop(context);
              final data = doc.data() as Map<String, dynamic>;
              doc.reference.delete();
              _postAnnouncement("Class deleted: ${data['subject']} (${data['day']} ${data['startTime']})", isSystemMessage: true);
              if (widgetsEnabled) _updateHomeScreenWidget();
              NotificationService.scheduleTimetableNotifications();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showClassDialog(BuildContext context, {DocumentSnapshot? doc}) async {
    final prefs = await SharedPreferences.getInstance();
    final departmentId = prefs.getString('departmentId');
    final yearId = prefs.getString('yearId');
    final sectionId = prefs.getString('sectionId');
    final data = doc?.data() as Map<String, dynamic>?;
    final oldData = Map<String, dynamic>.from(data ?? {});
    final subjectController = TextEditingController(text: data?['subject']);
    final mentorController = TextEditingController(text: data?['mentor']);
    final roomController = TextEditingController(text: data?['room']);
    String addDay = data?['day'] ?? selectedDay;
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 30);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 20);
    if (data != null) {
      final s = data['startTime'].split(':');
      final e = data['endTime'].split(':');
      startTime = TimeOfDay(hour: int.parse(s[0]), minute: int.parse(s[1]));
      endTime = TimeOfDay(hour: int.parse(e[0]), minute: int.parse(e[1]));
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(doc == null ? 'Add Class' : 'Edit Class', style: AppTextStyles.interTitle.copyWith(fontSize: 22)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: addDay,
                  dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  decoration: InputDecoration(labelText: 'Day', filled: true, fillColor: theme.colorScheme.onSurface.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  items: weekDays.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setDialogState(() => addDay = v!),
                ),
                const SizedBox(height: 16),
                _buildDialogField(subjectController, 'Subject', Icons.book_rounded, isDark),
                const SizedBox(height: 16),
                _buildDialogField(mentorController, 'Staff Name', Icons.person_rounded, isDark),
                const SizedBox(height: 16),
                _buildDialogField(roomController, 'Room No', Icons.room_rounded, isDark),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: startTime);
                          if (t != null) setDialogState(() => startTime = t);
                        },
                        child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text('Start', style: theme.textTheme.labelSmall), Text(startTime.format(context), style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold))])),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: endTime);
                          if (t != null) setDialogState(() => endTime = t);
                        },
                        child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text('End', style: theme.textTheme.labelSmall), Text(endTime.format(context), style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold))])),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: theme.hintColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final startStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
                final endStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
                final payload = {'subject': subjectController.text, 'mentor': mentorController.text, 'room': roomController.text, 'day': addDay, 'startTime': startStr, 'endTime': endStr};
                if (doc == null) {
                  if (departmentId != null && yearId != null && sectionId != null) {
                    FirebaseFirestore.instance.collection('departments').doc(departmentId).collection('years').doc(yearId).collection('sections').doc(sectionId).collection('schedule').add(payload);
                    _postAnnouncement("New class added: ${payload['subject']} (${payload['day']} ${payload['startTime']})", isSystemMessage: true);
                  }
                } else {
                  doc.reference.update(payload);
                  List<String> changes = [];
                  if (oldData['room'] != payload['room']) changes.add("Room: ${oldData['room']} → ${payload['room']}");
                  if (oldData['startTime'] != payload['startTime']) changes.add("Time: ${oldData['startTime']} → ${payload['startTime']}");
                  if (oldData['mentor'] != payload['mentor']) changes.add("Staff changed");
                  if (changes.isNotEmpty) _postAnnouncement("${payload['subject']} updated: ${changes.join(', ')}", isSystemMessage: true);
                }
                if (widgetsEnabled) _updateHomeScreenWidget();
                NotificationService.scheduleTimetableNotifications();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, bool isDark) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: theme.primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor)),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ValueListenableBuilder<int>(
      valueListenable: attendanceUpdateNotifier,
      builder: (context, _, child) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final prefs = snapshot.data!;
            final percentStr = prefs.getString('mycamu_attendance_percent');
            final subjectsStr = prefs.getString('mycamu_subject_attendance');
            final countStr = prefs.getString('mycamu_attendance_count');
            if (percentStr == null && subjectsStr == null) return const SizedBox.shrink();
            final double percent = double.tryParse(percentStr ?? '0') ?? 0;
            final theme = Theme.of(context);
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GlassCard(
                opacity: 0.1, blur: 20, borderRadius: BorderRadius.circular(16), padding: EdgeInsets.zero,
                child: InkWell(
                  onTap: () {
                    if (subjectsStr != null) {
                      _showDetailedAttendance(context, subjectsStr);
                    } else {
                      final message = countStr != null ? 'Classes Attended: $countStr' : 'No detailed breakdown available. Sync again!';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(value: percent / 100, backgroundColor: theme.canvasColor.withOpacity(0.2), color: percent < 75 ? Colors.redAccent : Colors.greenAccent, strokeWidth: 6),
                            Text('${percent.toInt()}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Overall Attendance', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text('$percentStr%', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: percent < 75 ? Colors.redAccent : Colors.greenAccent, fontSize: 24)),
                              if (countStr != null) Text('$countStr periods', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (subjectsStr != null) Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailedAttendance(BuildContext context, String subjectsJson) {
    try {
      final List<dynamic> subjects = jsonDecode(subjectsJson);
      final theme = Theme.of(context);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
              Text('Subject Breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sub = subjects[index];
                    final p = sub['percent'] ?? 0;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor.withOpacity(0.1))),
                      child: Row(
                        children: [
                          Container(
                            width: 50, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: (p < 75 ? Colors.red : Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('$p%', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: p < 75 ? Colors.red : Colors.green)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sub['code'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)), Text('Attended: ${sub['attended'] ?? 0} / ${sub['total'] ?? 0}', style: TextStyle(color: theme.hintColor, fontSize: 12))])),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print("Error parsing subjects: $e");
    }
  }
}

class _ScheduleItem {
  final DocumentSnapshot? doc;
  final Map<String, dynamic> data;

  const _ScheduleItem({this.doc, required this.data});
}

class _MentorSaturdayControlPanel extends StatefulWidget {
  @override
  __MentorSaturdayControlPanelState createState() => __MentorSaturdayControlPanelState();
}

class __MentorSaturdayControlPanelState extends State<_MentorSaturdayControlPanel> {
  String? _selectedSourceDay;
  bool _isLoading = false;
  final List<String> _sourceDays = ['None', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  Future<void> _applySchedule() async {
    if (_selectedSourceDay == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to replace the entire Saturday schedule for ALL sections with the schedule from $_selectedSourceDay? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm & Apply')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      final userSelection = Provider.of<UserSelectionProvider>(context, listen: false);
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final sectionsRef = db.collection('departments').doc(userSelection.departmentId).collection('years').doc(userSelection.yearId).collection('sections');
      final sectionsSnapshot = await sectionsRef.get();
      if (sectionsSnapshot.docs.isEmpty) throw Exception("No sections found to update.");
      for (final sectionDoc in sectionsSnapshot.docs) {
        final scheduleRef = sectionDoc.reference.collection('schedule');
        final saturdaySnapshot = await scheduleRef.where('day', isEqualTo: 'Saturday').get();
        for (final doc in saturdaySnapshot.docs) batch.delete(doc.reference);
        if (_selectedSourceDay != 'None') {
          final sourceDaySnapshot = await scheduleRef.where('day', isEqualTo: _selectedSourceDay).get();
          for (final doc in sourceDaySnapshot.docs) {
            final classData = doc.data();
            batch.set(scheduleRef.doc(), {...classData, 'day': 'Saturday'});
          }
        }
      }
      await batch.commit();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saturday schedule updated for all sections!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e'), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      margin: const EdgeInsets.all(16), blur: 20, opacity: 0.1, borderRadius: BorderRadius.circular(24), padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.orange, size: 20)),
            const SizedBox(width: 12),
            Text('Saturday Setup', style: AppTextStyles.interTitle.copyWith(fontSize: 18, color: theme.colorScheme.onSurface)),
          ]),
          const SizedBox(height: 12),
          Text('Clone a weekday timetable to Saturday for all sections.', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white60 : theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedSourceDay, dropdownColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            decoration: InputDecoration(labelText: 'Select Source Day', labelStyle: TextStyle(color: theme.primaryColor), filled: true, fillColor: theme.colorScheme.onSurface.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            items: _sourceDays.map((day) => DropdownMenuItem(value: day, child: Text(day, style: TextStyle(color: theme.colorScheme.onSurface)))).toList(),
            onChanged: (value) => setState(() => _selectedSourceDay = value),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), onPressed: _selectedSourceDay == null || _isLoading ? null : _applySchedule, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Apply to Saturday', style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}

class _MentorExamModeControlPanel extends StatefulWidget {
  final bool isExamMode;
  const _MentorExamModeControlPanel({required this.isExamMode});

  @override
  __MentorExamModeControlPanelState createState() => __MentorExamModeControlPanelState();
}

class __MentorExamModeControlPanelState extends State<_MentorExamModeControlPanel> {
  bool _isLoading = false;

  Future<void> _toggleExamMode() async {
    setState(() => _isLoading = true);
    try {
      final userSelection = Provider.of<UserSelectionProvider>(context, listen: false);
      final docRef = FirebaseFirestore.instance.collection('departments').doc(userSelection.departmentId).collection('years').doc(userSelection.yearId).collection('settings').doc('mode');
      final newMode = !widget.isExamMode;
      await docRef.set({'isExamMode': newMode}, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newMode ? 'Exam Mode Enabled!' : 'Exam Mode Disabled!'), backgroundColor: newMode ? Colors.green : Colors.orange));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16), blur: 20, opacity: 0.1, borderRadius: BorderRadius.circular(24), padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (widget.isExamMode ? Colors.red : Colors.green).withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.edit_document, color: widget.isExamMode ? Colors.red : Colors.green, size: 20)),
            const SizedBox(width: 12),
            Text('Exam Mode Control', style: AppTextStyles.interTitle.copyWith(fontSize: 18, color: theme.colorScheme.onSurface)),
          ]),
          const SizedBox(height: 12),
          Text(widget.isExamMode ? 'Exam Mode is currently ACTIVE. Regular classes are hidden.' : 'Turn on Exam Mode to suspend regular classes and show the Exam banner.', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white60 : theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: widget.isExamMode ? Colors.red : theme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), onPressed: _isLoading ? null : _toggleExamMode, child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text(widget.isExamMode ? 'Disable Exam Mode' : 'Enable Exam Mode', style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}

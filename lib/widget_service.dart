import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';

class WidgetService {
  static const String _scheduleCacheKey = 'widget_schedule_cache';
  static const String _scheduleCacheUpdateKey = 'widget_schedule_cache_updated';
  static const int _alarmId = 777;

  /// entrypoint for background work
  static Future<void> updateWidget({bool forceRefresh = false}) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (e) {
      print('⚠️ [WidgetService] Firebase init error: $e');
    }

    print(
      '🔄 [WidgetService] Starting widget update (Force: $forceRefresh)...',
    );
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Get User Selection
      final departmentId = prefs.getString('departmentId');
      final yearId = prefs.getString('yearId');
      final sectionId = prefs.getString('sectionId');

      if (departmentId == null || yearId == null || sectionId == null) {
        print('⚠️ [WidgetService] No user selection found.');
        await _renderEmpty();
        return;
      }

      // 2. Fetch Data
      List<Map<String, dynamic>> scheduleData = [];
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(departmentId)
            .collection('years')
            .doc(yearId)
            .collection('sections')
            .doc(sectionId)
            .collection('schedule')
            .get(
              GetOptions(
                source: forceRefresh ? Source.server : Source.serverAndCache,
              ),
            );

        scheduleData = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          if (data['day'] == null && data['dayOfWeek'] != null) {
            data['day'] = data['dayOfWeek'];
          }
          return data;
        }).toList();

        await prefs.setString(_scheduleCacheKey, jsonEncode(scheduleData));
        await prefs.setString(
          _scheduleCacheUpdateKey,
          DateTime.now().toIso8601String(),
        );
        print('✅ [WidgetService] Fetched data from Firestore');
      } catch (e) {
        print('⚠️ [WidgetService] Firestore fetch failed ($e). Using cache.');
        final cachedString = prefs.getString(_scheduleCacheKey);
        if (cachedString != null) {
          final List<dynamic> decoded = jsonDecode(cachedString);
          scheduleData = decoded
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      if (scheduleData.isEmpty) {
        await _renderEmpty();
        return;
      }

      // 3. Process Data
      final now = DateTime.now();
      final currentDay = DateFormat('EEEE').format(now);
      final currentTime = DateFormat('HH:mm').format(now);

      Map<String, dynamic>? currentClass;
      Map<String, dynamic>? nextClass;
      String? timeRemaining;
      double progress = 0.0;

      final todaysClasses = scheduleData
          .where((c) => (c['day'] ?? c['dayOfWeek']) == currentDay)
          .toList();

      todaysClasses.sort(
        (a, b) =>
            (a['startTime'] as String).compareTo(b['startTime'] as String),
      );

      for (var classData in todaysClasses) {
        final startTime = classData['startTime'] as String;
        final endTime = classData['endTime'] as String;

        try {
          final start = DateFormat('HH:mm').parse(startTime);
          final end = DateFormat('HH:mm').parse(endTime);
          final current = DateFormat('HH:mm').parse(currentTime);

          if (current.isAfter(start) && current.isBefore(end)) {
            currentClass = classData;
            final totalMinutes = end.difference(start).inMinutes;
            final elapsedMinutes = current.difference(start).inMinutes;
            progress = totalMinutes > 0 ? elapsedMinutes / totalMinutes : 0.0;
            final remaining = end.difference(current);
            timeRemaining = remaining.inHours > 0
                ? '${remaining.inHours}h ${remaining.inMinutes % 60}m'
                : '${remaining.inMinutes}m';
            break;
          } else if (current.isBefore(start)) {
            nextClass = classData;
            break;
          }
        } catch (e) {
          print('⚠️ [WidgetService] Error parsing time: $e');
        }
      }

      // 4. Render with refresh angle
      double currentAngle = prefs.getDouble('widget_refresh_angle') ?? 0.0;
      currentAngle += (3.14159 / 2); // Rotate 90 degrees for clear change
      await prefs.setDouble(
        'widget_refresh_angle',
        currentAngle % (3.14159 * 2),
      );

      await _renderWidgets(
        currentClass,
        nextClass,
        timeRemaining,
        progress,
        currentAngle,
      );

      // 5. Schedule Next (Battery Optimized: No Wakeup)
      await _scheduleNextUpdate(todaysClasses);
    } catch (e) {
      print('❌ [WidgetService] Silent update failure: $e');
      // No longer calling _renderError to avoid showing error screens on home screen
    }
  }

  static Future<void> _renderWidgets(
    Map<String, dynamic>? currentClass,
    Map<String, dynamic>? nextClass,
    String? timeRemaining,
    double progress,
    double rotationAngle,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('widget_error');

    // Determine which class to display
    final displayClass = currentClass ?? nextClass;
    final isCurrent = currentClass != null;
    final hasClass = displayClass != null;

    // Save data to SharedPreferences for native widget
    await HomeWidget.saveWidgetData<bool>('has_class', hasClass);
    await HomeWidget.saveWidgetData<bool>('is_current', isCurrent);

    if (hasClass) {
      await HomeWidget.saveWidgetData<String>(
        'subject',
        displayClass['subject'] ?? 'Unknown',
      );
      await HomeWidget.saveWidgetData<String>(
        'start_time',
        displayClass['startTime'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'end_time',
        displayClass['endTime'] ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'room',
        displayClass['room']?.toString() ?? '',
      );

      if (isCurrent && timeRemaining != null) {
        await HomeWidget.saveWidgetData<String>(
          'time_remaining',
          timeRemaining,
        );
        await HomeWidget.saveWidgetData<int>(
          'progress',
          (progress * 100).toInt(),
        );
      } else if (!isCurrent && nextClass != null) {
        // Calculate time until start
        final now = DateTime.now();
        final start = _parseTime(nextClass['startTime']);
        final diff = start.difference(now);
        final remaining = diff.inHours > 0
            ? '${diff.inHours}h ${diff.inMinutes % 60}m'
            : '${diff.inMinutes}m';
        await HomeWidget.saveWidgetData<String>('time_remaining', remaining);
        await HomeWidget.saveWidgetData<int>('progress', 0);
      }
    } else {
      // Clear data when no class
      await HomeWidget.saveWidgetData<String>('subject', 'No Classes');
      await HomeWidget.saveWidgetData<String>('start_time', '');
      await HomeWidget.saveWidgetData<String>('end_time', '');
      await HomeWidget.saveWidgetData<String>('room', '');
      await HomeWidget.saveWidgetData<String>('time_remaining', '');
      await HomeWidget.saveWidgetData<int>('progress', 0);
    }

    await _updateProvider();
  }

  static Future<void> _renderEmpty() async {
    await HomeWidget.saveWidgetData<String>('timetable_widget', null);
    await HomeWidget.saveWidgetData<String>('robot_widget', null);
    await _updateProvider();
  }

  static Future<void> _updateProvider() async {
    await HomeWidget.updateWidget(
      name: 'TimetableWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.TimetableWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'RobotWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.RobotWidgetProvider',
    );
  }

  static Future<void> updateFromForeground() async {
    print('📱 [WidgetService] Foreground update triggered...');
    await updateWidget();
  }

  @pragma('vm:entry-point')
  static Future<void> alarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    print("⏰ [WidgetService] Alarm fired!");
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (_) {}
    await updateWidget();
  }

  static Future<void> initialize() async {
    try {
      await AndroidAlarmManager.initialize();
      print("✅ [WidgetService] AlarmManager initialized");
    } catch (e) {
      print("❌ [WidgetService] AlarmManager init failed: $e");
    }
  }

  static Future<void> _scheduleNextUpdate(
    List<Map<String, dynamic>> todaysClasses,
  ) async {
    final now = DateTime.now();
    DateTime? nextEvent;

    for (var c in todaysClasses) {
      final start = _parseTime(c['startTime']);
      final end = _parseTime(c['endTime']);
      if (start.isAfter(now)) {
        if (nextEvent == null || start.isBefore(nextEvent)) nextEvent = start;
      }
      if (end.isAfter(now)) {
        if (nextEvent == null || end.isBefore(nextEvent)) nextEvent = end;
      }
    }

    if (nextEvent != null) {
      final trigger = nextEvent.add(const Duration(seconds: 5));
      print("📅 [WidgetService] Next update: $trigger");
      await AndroidAlarmManager.oneShotAt(
        trigger,
        _alarmId,
        alarmCallback,
        exact: true,
        wakeup: false, // BATTERY OPTIMIZED
        rescheduleOnReboot: true,
      );
    }
  }

  static DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parsed = DateFormat('HH:mm').parse(timeStr);
    return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
  }
}

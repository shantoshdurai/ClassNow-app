import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_firebase_test/static_widget.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';

class WidgetService {
  static const String _scheduleCacheKey = 'widget_schedule_cache';
  static const String _scheduleCacheUpdateKey = 'widget_schedule_cache_updated';

  /// entrypoint for background work
  static Future<void> updateWidget() async {
    print('🔄 [WidgetService] Starting widget update...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Get User Selection (Corrected keys)
      final departmentId = prefs.getString('departmentId');
      final yearId = prefs.getString('yearId');
      final sectionId = prefs.getString('sectionId');

      if (departmentId == null || yearId == null || sectionId == null) {
        print(
          '⚠️ [WidgetService] No user selection found. Rendering empty state.',
        );
        await _renderEmpty();
        return;
      }

      // 2. Fetch Data (Try Online -> Fallback to Cache)
      List<Map<String, dynamic>> scheduleData = [];
      try {
        // We can't easily check connectivity in background without extra plugins,
        // so we try Firestore and catch error.
        // Note: Firestore offline persistence might handle this automatically if enabled,
        // but 'Source.server' forces online. We'll try server first, then cache.
        final snapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(departmentId)
            .collection('years')
            .doc(yearId)
            .collection('sections')
            .doc(sectionId)
            .collection('schedule')
            .get(
              const GetOptions(source: Source.serverAndCache),
            ); // Improved fetching

        scheduleData = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          // Support both 'day' and 'dayOfWeek' formats
          if (data['day'] == null && data['dayOfWeek'] != null) {
            data['day'] = data['dayOfWeek'];
          }
          return data;
        }).toList();

        // Update Cache
        await prefs.setString(_scheduleCacheKey, jsonEncode(scheduleData));
        await prefs.setString(
          _scheduleCacheUpdateKey,
          DateTime.now().toIso8601String(),
        );
        print('✅ [WidgetService] Fetched fresh data from Firestore');
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
        print('⚠️ [WidgetService] No schedule data found.');
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

      // Filter for today
      final todaysClasses = scheduleData
          .where((c) => (c['day'] ?? c['dayOfWeek']) == currentDay)
          .toList();

      // Sort by start time just in case
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
            if (remaining.inHours > 0) {
              timeRemaining =
                  '${remaining.inHours}h ${remaining.inMinutes % 60}m';
            } else {
              timeRemaining = '${remaining.inMinutes}m';
            }
            break; // Found current, stop
          } else if (current.isBefore(start)) {
            nextClass = classData;
            break; // Found next (first one starting after now), stop
          }
        } catch (e) {
          print('⚠️ [WidgetService] Error parsing time: $e');
        }
      }

      // 4. Render Widget
      await _renderWidgets(currentClass, nextClass, timeRemaining, progress);

      // 5. Schedule Next Alarm (Exact Trigger)
      await _scheduleNextUpdate(todaysClasses);
    } catch (e) {
      print('❌ [WidgetService] Critical error: $e');
      // Render something even on error so it's not invisible
      await _renderError(e.toString());
    }
  }

  static Future<void> _renderError(String error) async {
    // Optional: Render a "Error loading" view if you want
    print('⚠️ [WidgetService] Rendering error state');
  }

  static Future<void> _renderEmpty() async {
    await HomeWidget.saveWidgetData<String>('filename', null);
    await HomeWidget.updateWidget(
      name: 'TimetableWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.TimetableWidgetProvider',
      iOSName: 'TimetableWidget',
    );
    await HomeWidget.updateWidget(
      name: 'RobotWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.RobotWidgetProvider',
      iOSName: 'RobotWidget',
    );
  }

  static Future<void> _renderWidgets(
    Map<String, dynamic>? currentClass,
    Map<String, dynamic>? nextClass,
    String? timeRemaining,
    double progress,
  ) async {
    // Render Timetable Widget
    try {
      await HomeWidget.renderFlutterWidget(
        StaticTimetableWidget(
          currentClass: currentClass,
          nextClass: nextClass,
          timeRemaining: timeRemaining,
          progress: progress,
        ),
        key: 'timetable_widget',
        logicalSize: const Size(320, 160),
      );
    } catch (e) {
      print('❌ [WidgetService] Render Timetable failed: $e');
    }

    // Render Robot Widget
    try {
      await HomeWidget.renderFlutterWidget(
        SmallRobotWidget(currentClass: currentClass, nextClass: nextClass),
        key: 'robot_widget',
        logicalSize: const Size(160, 160),
      );
    } catch (e) {
      print('❌ [WidgetService] Render Robot failed: $e');
    }

    // Update Platform Widgets
    await HomeWidget.updateWidget(
      name: 'TimetableWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.TimetableWidgetProvider',
    );

    await HomeWidget.updateWidget(
      name: 'RobotWidgetProvider',
      androidName: 'com.example.flutter_firebase_test.RobotWidgetProvider',
    );

    print('✅ [WidgetService] Widgets updated successfully');
  }

  /// Special method to update widgets from foreground ONLY (Reliable Rendering)
  static Future<void> updateFromForeground() async {
    print('📱 [WidgetService] Foreground update triggered...');
    await updateWidget();
  }

  // --- Alarm Manager Support ---

  static const int _alarmId = 777;

  @pragma('vm:entry-point')
  static Future<void> alarmCallback() async {
    print("⏰ [WidgetService] Alarm fired! Updating widget...");
    // Initialize Firebase if necessary (it might be needed here too)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print("⚠️ [WidgetService] Firebase init warning: $e");
    }
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

    // We want to find the NEXT event (start or end of a class)
    DateTime? nextEventTime;

    for (var classData in todaysClasses) {
      final startTimeStr = classData['startTime'] as String;
      final endTimeStr = classData['endTime'] as String;

      try {
        final start = _parseTime(startTimeStr);
        final end = _parseTime(endTimeStr);

        if (start.isAfter(now)) {
          if (nextEventTime == null || start.isBefore(nextEventTime)) {
            nextEventTime = start;
          }
        }
        if (end.isAfter(now)) {
          if (nextEventTime == null || end.isBefore(nextEventTime)) {
            nextEventTime = end;
          }
        }
      } catch (e) {
        print("⚠️ Error parsing time: $e");
      }
    }

    if (nextEventTime != null) {
      // Add a small buffer (e.g., 5 seconds) to ensure we don't fire slightly before the minute changes
      final triggerTime = nextEventTime.add(const Duration(seconds: 5));
      print("📅 [WidgetService] Scheduling next update for: $triggerTime");

      try {
        await AndroidAlarmManager.oneShotAt(
          triggerTime,
          _alarmId,
          alarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
        );
      } catch (e) {
        print("❌ [WidgetService] Failed to schedule alarm: $e");
      }
    } else {
      print("📅 [WidgetService] No more events today.");
      // Schedule a check for tomorrow morning?
      // Workmanager handles long-term periodic updates, so we might not need this.
      // But to be safe, let's schedule one for 8 AM the next day if we want to be super proactive.
    }
  }

  static DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parsed = DateFormat('HH:mm').parse(timeStr);
    return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
  }
}

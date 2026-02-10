import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.flutter_firebase_test/notifications',
  );

  // Getter to access notification plugin
  static FlutterLocalNotificationsPlugin? getNotificationPlugin() {
    return _notifications;
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped logic here
      },
    );
  }

  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? granted = await androidImplementation
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  static Future<void> scheduleTimetableNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('notifications_enabled')) {
      await prefs.setBool('notifications_enabled', true);
    }

    final bool enabled = prefs.getBool('notifications_enabled') ?? true;

    if (!enabled) {
      // Cancel all notifications if disabled
      try {
        await _methodChannel.invokeMethod('cancelNotifications');
      } catch (e) {
        print('Error cancelling notifications: $e');
      }
      return;
    }

    // Get schedule data with offline fallback
    List<Map<String, dynamic>> scheduleData =
        await _getScheduleDataWithOffline();

    // Cache the schedule data for the native service to use
    await _cacheScheduleData(scheduleData);

    // Call native service to schedule notifications
    try {
      await _methodChannel.invokeMethod('scheduleNotifications');
      print('Successfully scheduled notifications via native service');
    } catch (e) {
      print('Error scheduling notifications via native service: $e');
    }
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'classnow_test',
          'Test Notifications',
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notifications.show(
      88888,
      'Test Notification',
      'This is a test notification from Class Now!',
      platformChannelSpecifics,
      payload: 'test_payload',
    );
  }

  static Future<void> showAnnouncementNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'classnow_announcements', // Separate channel
          'Announcements',
          channelDescription: 'Important announcements from mentors',
          importance: Importance.max, // Popup
          priority: Priority.high,
          ticker: 'announcement',
          styleInformation: BigTextStyleInformation(''), // For long text
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'announcement_payload',
    );
  }

  static Future<List<Map<String, dynamic>>>
  _getScheduleDataWithOffline() async {
    final prefs = await SharedPreferences.getInstance();

    final deptId = prefs.getString('departmentId');
    final yearId = prefs.getString('yearId');
    final sectionId = prefs.getString('sectionId');

    if (deptId == null || yearId == null || sectionId == null) {
      return await _getCachedScheduleData();
    }

    try {
      // Try online first
      final snapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(deptId)
          .collection('years')
          .doc(yearId)
          .collection('sections')
          .doc(sectionId)
          .collection('schedule')
          .get(const GetOptions(source: Source.server));

      final scheduleData = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        // Make sure dayOfWeek field is present (mapping from 'day' if needed)
        if (data['dayOfWeek'] == null && data['day'] != null) {
          data['dayOfWeek'] = data['day'];
        }
        return data;
      }).toList();

      // Cache the data for offline use
      await _cacheScheduleData(scheduleData);
      return scheduleData;
    } catch (e) {
      print('Error fetching schedule online: $e');
      // Fallback to cached data
      return await _getCachedScheduleData();
    }
  }

  static Future<void> _cacheScheduleData(
    List<Map<String, dynamic>> scheduleData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(scheduleData);
    await prefs.setString('cached_schedule_data', jsonString);
    await prefs.setString(
      'schedule_cache_updated',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<List<Map<String, dynamic>>> _getCachedScheduleData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_schedule_data');

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// Check if the app can schedule exact alarms (Android 12+)
  static Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return result ?? true;
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return true; // Assume permission granted on error
    }
  }

  /// Request exact alarm permission (Android 12+)
  static Future<void> requestExactAlarmPermission() async {
    try {
      await _methodChannel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
    }
  }

  static Future<void> refreshNotificationsWhenOnline() async {
    try {
      // Just check if we can reach Firestore in general
      await FirebaseFirestore.instance.disableNetwork();
      await FirebaseFirestore.instance.enableNetwork();

      // If successful (no exception), refresh notifications with latest data
      await scheduleTimetableNotifications();
    } catch (e) {
      // Still offline, keep using cached data
      print('Still offline, using cached notification data');
    }
  }

  static Future<String> getCacheStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTime = prefs.getString('schedule_cache_updated');

    if (cachedTime != null) {
      final cacheTime = DateTime.parse(cachedTime);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      if (difference.inHours < 1) {
        return 'Cached: ${difference.inMinutes} min ago';
      } else if (difference.inDays < 1) {
        return 'Cached: ${difference.inHours} hours ago';
      } else {
        return 'Cached: ${difference.inDays} days ago';
      }
    }

    return 'No cache';
  }

  static Future<List<String>> getUniqueSubjects() async {
    final scheduleData = await _getScheduleDataWithOffline();
    final subjects = scheduleData
        .map((e) => e['subject'] as String)
        .toSet()
        .toList();
    subjects.sort();
    return subjects;
  }
}

// ========================================
// COMPLETE WIDGET UPDATE FIX IMPLEMENTATION
// ========================================
// This file contains all necessary fixes for proper widget updating
// Integrates: Timer lifecycle, WorkManager, class scheduling, and lifecycle monitoring

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

// ========================================
// 1. BACKGROUND CALLBACK DISPATCHER
// ========================================
// This MUST be a top-level function (outside any class)
// Place this at the TOP of your main.dart file, before the main() function

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 [WorkManager] Background task started: $task');
    
    try {
      // Initialize Firebase if needed
      await _performWidgetUpdate();
      print('✅ [WorkManager] Widget update completed successfully');
      return Future.value(true);
    } catch (e) {
      print('❌ [WorkManager] Error updating widget: $e');
      return Future.value(false);
    }
  });
}

// Background update function
Future<void> _performWidgetUpdate() async {
  print('📱 [Background] Performing widget update...');
  
  try {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE').format(now);
    
    // Get stored user selection from shared preferences if needed
    // For now, using a simple approach - you may need to adapt this
    
    Map<String, dynamic>? currentClass;
    Map<String, dynamic>? nextClass;
    String? timeRemaining;
    double progress = 0.0;
    
    // Fetch schedule data - adapt this to your data structure
    // You might need to store department/year/section IDs in SharedPreferences
    
    // Render widgets
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
    
    await HomeWidget.renderFlutterWidget(
      SmallRobotWidget(
        currentClass: currentClass,
        nextClass: nextClass,
      ),
      key: 'robot_widget',
      logicalSize: const Size(160, 160),
    );
    
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
    
    print('✅ [Background] Widget rendered and updated');
  } catch (e) {
    print('❌ [Background] Error: $e');
    rethrow;
  }
}

// ========================================
// 2. MAIN FUNCTION INITIALIZATION
// ========================================
// Replace or modify your existing main() function

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 [Main] Initializing app...');
  
  // Initialize WorkManager for background updates
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false in production
  );
  
  print('⚙️ [Main] Registering periodic widget update task...');
  
  // Register periodic task - runs every 15 minutes (minimum on Android)
  await Workmanager().registerPeriodicTask(
    "widget_update_task",
    "widgetUpdateTask",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.not_required, // Works offline
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
  
  print('✅ [Main] WorkManager initialized and task registered');
  
  // Initialize Firebase and other services
  // ... your existing Firebase initialization
  
  runApp(MyApp());
}

// ========================================
// 3. DASHBOARD PAGE WITH LIFECYCLE FIXES
// ========================================
// This is your modified DashboardPageState class
// Add WidgetsBindingObserver mixin for lifecycle monitoring

class DashboardPageState extends State<DashboardPage> 
    with WidgetsBindingObserver {  // ADD THIS MIXIN
  
  // ========================================
  // INSTANCE VARIABLES
  // ========================================
  Timer? _widgetUpdateTimer;  // Store timer reference
  Timer? _classScheduleTimer;  // For class-based updates
  
  // Your existing variables
  List<Map<String, dynamic>> _cachedSchedule = [];
  String? _scheduleCacheKey;
  bool widgetsEnabled = true;
  
  // ========================================
  // LIFECYCLE METHODS
  // ========================================
  
  @override
  void initState() {
    super.initState();
    print('🎬 [Lifecycle] DashboardPage initState called');
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Start widget update mechanisms
    _startWidgetUpdateTimer();
    _scheduleNextClassUpdate();
    
    // Initial update
    _updateHomeScreenWidget();
    
    print('✅ [Lifecycle] All update mechanisms started');
  }
  
  @override
  void dispose() {
    print('🛑 [Lifecycle] DashboardPage dispose called');
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Cancel all timers
    _widgetUpdateTimer?.cancel();
    _classScheduleTimer?.cancel();
    
    print('✅ [Lifecycle] All timers cancelled and observers removed');
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 [Lifecycle] App state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('▶️ [Lifecycle] App resumed - triggering widget update');
        _updateHomeScreenWidget();
        _scheduleNextClassUpdate(); // Reschedule in case times changed
        break;
      case AppLifecycleState.paused:
        print('⏸️ [Lifecycle] App paused');
        break;
      case AppLifecycleState.inactive:
        print('💤 [Lifecycle] App inactive');
        break;
      case AppLifecycleState.detached:
        print('🔌 [Lifecycle] App detached');
        break;
      case AppLifecycleState.hidden:
        print('🙈 [Lifecycle] App hidden');
        break;
    }
  }
  
  // ========================================
  // TIMER-BASED UPDATES (Every Minute)
  // ========================================
  
  void _startWidgetUpdateTimer() {
    print('⏰ [Timer] Starting 1-minute periodic update timer');
    
    // Cancel existing timer if any
    _widgetUpdateTimer?.cancel();
    
    // Create new timer that updates every minute
    _widgetUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        print('⏰ [Timer] Periodic update triggered (${DateTime.now()})');
        
        // Check if widget is still mounted
        if (!mounted) {
          print('⚠️ [Timer] Widget not mounted, cancelling timer');
          timer.cancel();
          return;
        }
        
        // Check if widgets are enabled
        if (!widgetsEnabled) {
          print('⚠️ [Timer] Widgets disabled, skipping update');
          return;
        }
        
        // Perform update
        await _updateHomeScreenWidget();
      },
    );
    
    print('✅ [Timer] Periodic timer started successfully');
  }
  
  // ========================================
  // CLASS-BASED SCHEDULED UPDATES
  // ========================================
  
  void _scheduleNextClassUpdate() {
    print('📅 [Schedule] Scheduling next class-based update...');
    
    // Cancel existing scheduled update
    _classScheduleTimer?.cancel();
    
    final now = DateTime.now();
    DateTime? nextUpdateTime;
    String? nextUpdateReason;
    
    // Find the next class start or end time
    for (var classData in _cachedSchedule) {
      try {
        final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
        final currentDay = DateFormat('EEEE').format(now);
        
        // Only schedule for today's classes
        if (dayOfWeek != currentDay) continue;
        
        final startTime = DateFormat('HH:mm').parse(classData['startTime']);
        final endTime = DateFormat('HH:mm').parse(classData['endTime']);
        
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
        
        // Check if start time is in the future and closer than current nextUpdateTime
        if (startDateTime.isAfter(now)) {
          if (nextUpdateTime == null || startDateTime.isBefore(nextUpdateTime)) {
            nextUpdateTime = startDateTime;
            nextUpdateReason = 'Class Start: ${classData['subject']}';
          }
        }
        
        // Check if end time is in the future and closer than current nextUpdateTime
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
      
      print('⏰ [Schedule] Next update scheduled in ${delayMinutes}m ${delaySeconds}s');
      print('📍 [Schedule] Reason: $nextUpdateReason');
      print('🕐 [Schedule] Time: ${DateFormat('HH:mm').format(nextUpdateTime)}');
      
      // Schedule the update
      _classScheduleTimer = Timer(delay, () {
        print('🔔 [Schedule] Scheduled update triggered: $nextUpdateReason');
        _updateHomeScreenWidget();
        
        // Schedule the next update after this one
        _scheduleNextClassUpdate();
      });
    } else {
      print('ℹ️ [Schedule] No more classes today, will check again tomorrow');
      
      // Schedule a check at midnight to set up tomorrow's schedule
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final untilMidnight = tomorrow.difference(now);
      
      _classScheduleTimer = Timer(untilMidnight, () {
        print('🌅 [Schedule] New day - rescheduling updates');
        _scheduleNextClassUpdate();
      });
    }
  }
  
  // ========================================
  // MAIN WIDGET UPDATE FUNCTION (FIXED)
  // ========================================
  
  Future<void> _updateHomeScreenWidget() async {
    print('🔄 [Update] Starting widget update...');
    final updateStartTime = DateTime.now();
    
    try {
      final userSelection = Provider.of<UserSelectionProvider>(
        context,
        listen: false,
      );
      
      if (!userSelection.hasSelection) {
        print('⚠️ [Update] No user selection found, skipping update');
        return;
      }
      
      print('👤 [Update] User selection: ${userSelection.departmentId} / ${userSelection.yearId} / ${userSelection.sectionId}');
      
      final now = DateTime.now();
      final currentTime = DateFormat('HH:mm').format(now);
      final currentDay = DateFormat('EEEE').format(now);
      
      print('📅 [Update] Current: $currentDay $currentTime');
      
      Map<String, dynamic>? currentClass;
      Map<String, dynamic>? nextClass;
      String? timeRemaining;
      double progress = 0.0;
      
      // ========================================
      // FETCH SCHEDULE DATA
      // ========================================
      List<Map<String, dynamic>> scheduleData = [];
      
      // Try to use cached data first
      if (_scheduleCacheKey != null && _cachedSchedule.isNotEmpty) {
        print('💾 [Update] Using cached schedule data (${_cachedSchedule.length} classes)');
        scheduleData = _cachedSchedule;
      } else {
        print('🌐 [Update] Fetching schedule from Firestore...');
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('departments')
              .doc(userSelection.departmentId)
              .collection('years')
              .doc(userSelection.yearId)
              .collection('sections')
              .doc(userSelection.sectionId)
              .collection('schedule')
              .orderBy('startTime')
              .get(const GetOptions(source: Source.server));
          
          scheduleData = snapshot.docs
              .map((doc) => Map<String, dynamic>.from(doc.data()))
              .toList();
          
          print('✅ [Update] Fetched ${scheduleData.length} classes from Firestore');
          
          // Update cache
          _cachedSchedule = scheduleData;
          _scheduleCacheKey = '${userSelection.departmentId}_${userSelection.yearId}_${userSelection.sectionId}';
        } catch (e) {
          print('❌ [Update] Firestore fetch error: $e');
          
          // Fall back to cached data if available
          if (_cachedSchedule.isNotEmpty) {
            print('💾 [Update] Using cached data as fallback');
            scheduleData = _cachedSchedule;
          } else {
            print('⚠️ [Update] No cached data available');
          }
        }
      }
      
      // ========================================
      // FIND CURRENT AND NEXT CLASS
      // ========================================
      print('🔍 [Update] Searching for current/next class...');
      
      for (var i = 0; i < scheduleData.length; i++) {
        final classData = scheduleData[i];
        final startTime = classData['startTime'] as String;
        final endTime = classData['endTime'] as String;
        final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
        
        if (dayOfWeek == null) {
          print('⚠️ [Update] Class ${i + 1} missing day information');
          continue;
        }
        
        if (dayOfWeek == currentDay) {
          try {
            final start = DateFormat('HH:mm').parse(startTime);
            final end = DateFormat('HH:mm').parse(endTime);
            final current = DateFormat('HH:mm').parse(currentTime);
            
            // Check if currently in class
            if (current.isAfter(start) && current.isBefore(end)) {
              currentClass = classData;
              
              // Calculate progress
              final totalMinutes = end.difference(start).inMinutes;
              final elapsedMinutes = current.difference(start).inMinutes;
              progress = elapsedMinutes / totalMinutes;
              
              // Calculate time remaining
              final remaining = end.difference(current);
              if (remaining.inHours > 0) {
                timeRemaining = '${remaining.inHours}h ${remaining.inMinutes % 60}m';
              } else {
                timeRemaining = '${remaining.inMinutes}m';
              }
              
              print('✅ [Update] Found CURRENT class: ${classData['subject']}');
              print('📊 [Update] Progress: ${(progress * 100).toStringAsFixed(1)}%');
              print('⏱️ [Update] Time remaining: $timeRemaining');
              break;
            }
            // Check if this is the next upcoming class
            else if (current.isBefore(start)) {
              nextClass = classData;
              print('✅ [Update] Found NEXT class: ${classData['subject']} at $startTime');
              break;
            }
          } catch (e) {
            print('⚠️ [Update] Error parsing times for class ${i + 1}: $e');
          }
        }
      }
      
      if (currentClass == null && nextClass == null) {
        print('ℹ️ [Update] No current or upcoming classes found');
      }
      
      // ========================================
      // RENDER WIDGETS
      // ========================================
      print('🎨 [Update] Rendering widgets...');
      
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
      
      print('✅ [Update] Timetable widget rendered');
      
      await HomeWidget.renderFlutterWidget(
        SmallRobotWidget(
          currentClass: currentClass,
          nextClass: nextClass,
        ),
        key: 'robot_widget',
        logicalSize: const Size(160, 160),
      );
      
      print('✅ [Update] Robot widget rendered');
      
      // ========================================
      // UPDATE WIDGETS ON HOME SCREEN
      // ========================================
      print('📲 [Update] Updating home screen widgets...');
      
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
      
      final updateDuration = DateTime.now().difference(updateStartTime);
      print('✅ [Update] Widget update completed in ${updateDuration.inMilliseconds}ms');
      
    } catch (e, stackTrace) {
      print('❌ [Update] Error updating widget: $e');
      print('📚 [Update] Stack trace: $stackTrace');
    }
  }
  
  // ========================================
  // YOUR BUILD METHOD (UNCHANGED)
  // ========================================
  
  @override
  Widget build(BuildContext context) {
    // Your existing build implementation
    return Scaffold(
      // ... your UI code
    );
  }
}

// ========================================
// 4. ANDROID CONFIGURATION FILES
// ========================================

/*
FILE: android/app/src/main/res/xml/timetable_widget_info.xml

<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider 
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="320dp"
    android:minHeight="160dp"
    android:updatePeriodMillis="900000"
    android:initialLayout="@layout/timetable_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:configure="com.example.flutter_firebase_test.MainActivity" />
*/

/*
FILE: android/app/src/main/res/xml/robot_widget_info.xml

<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider 
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="160dp"
    android:minHeight="160dp"
    android:updatePeriodMillis="900000"
    android:initialLayout="@layout/robot_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:configure="com.example.flutter_firebase_test.MainActivity" />
*/

/*
FILE: android/app/build.gradle

Add to dependencies:
implementation 'androidx.work:work-runtime:2.8.1'
*/

// ========================================
// 5. PUBSPEC.YAML DEPENDENCIES
// ========================================

/*
dependencies:
  flutter:
    sdk: flutter
  home_widget: ^0.6.0
  workmanager: ^0.5.2
  cloud_firestore: ^4.0.0
  provider: ^6.0.0
  intl: ^0.18.0
*/

// ========================================
// 6. WIDGET COMPONENTS (YOUR EXISTING CODE)
// ========================================

// Import your existing StaticTimetableWidget and SmallRobotWidget classes here
// They remain unchanged from your original implementation

// ========================================
// 7. USAGE INSTRUCTIONS
// ========================================

/*
INTEGRATION STEPS:

1. Add dependencies to pubspec.yaml:
   - workmanager: ^0.5.2

2. Copy the callbackDispatcher() function to the TOP of your main.dart
   (before the main() function, as a top-level function)

3. Modify your main() function to initialize WorkManager:
   - Add WidgetsFlutterBinding.ensureInitialized()
   - Call Workmanager().initialize()
   - Call Workmanager().registerPeriodicTask()

4. Add WidgetsBindingObserver mixin to your DashboardPageState class

5. Add the following instance variables to DashboardPageState:
   - Timer? _widgetUpdateTimer
   - Timer? _classScheduleTimer

6. Replace your existing lifecycle methods:
   - initState()
   - dispose()
   - Add didChangeAppLifecycleState()

7. Add the new methods:
   - _startWidgetUpdateTimer()
   - _scheduleNextClassUpdate()
   - Replace your existing _updateHomeScreenWidget() with the fixed version

8. Update Android widget XML files with proper configuration

9. Test thoroughly:
   - Widget updates when app is open
   - Widget updates when app is in background
   - Widget updates at class start/end times
   - Widget updates when app resumes from background

DEBUGGING:
- Check logs with prefix [WorkManager], [Timer], [Schedule], [Update], [Lifecycle]
- Use 'flutter logs' to see background task execution
- Verify WorkManager is registered: adb shell dumpsys activity service WorkManagerService
*/

// ========================================
// 8. TROUBLESHOOTING GUIDE
// ========================================

/*
COMMON ISSUES AND SOLUTIONS:

Issue: Widget doesn't update in background
Solution: 
- Verify WorkManager is initialized in main()
- Check Android battery optimization settings
- Ensure updatePeriodMillis is set in widget XML
- Check logs for [WorkManager] entries

Issue: Widget shows old data
Solution:
- Clear app cache and reinstall
- Remove and re-add widget to home screen
- Check Firebase connectivity
- Verify cache is being updated

Issue: Timer stops working
Solution:
- Ensure Timer is cancelled in dispose()
- Check if widget is still mounted before updating
- Verify WidgetsBindingObserver is added
- Check for memory leaks

Issue: Updates not happening at class times
Solution:
- Verify _scheduleNextClassUpdate() is being called
- Check time parsing for classes
- Ensure day matching is correct
- Look for [Schedule] logs

Issue: WorkManager not executing
Solution:
- Check if task is registered (look for logs)
- Verify callbackDispatcher is top-level function
- Check @pragma annotation is present
- Ensure constraints are not too restrictive
*/

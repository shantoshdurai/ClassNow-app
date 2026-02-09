import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

/// Builds context information for the chatbot from user's schedule
class ChatbotContextBuilder {
  /// Build comprehensive context for the AI
  static Future<String> buildContext() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Get user's selection
    final departmentId = prefs.getString('departmentId') ?? 'Unknown';
    final yearId = prefs.getString('yearId') ?? 'Unknown';
    final sectionId = prefs.getString('sectionId') ?? 'Unknown';

    // Get student's schedule data
    final scheduleData = await _getScheduleData();

    // Get ALL schedules from database for global staff tracking
    final allSchedules = await _getAllSchedulesData();

    // Find current and next class for student
    final currentClass = _getCurrentClass(scheduleData, now);
    final nextClass = _getNextClass(scheduleData, now);

    // Build the context string with global data
    return _buildContextString(
      now: now,
      departmentId: departmentId,
      yearId: yearId,
      sectionId: sectionId,
      scheduleData: scheduleData,
      currentClass: currentClass,
      nextClass: nextClass,
      allSchedules: allSchedules,
    );
  }

  static Future<List<Map<String, dynamic>>> _getScheduleData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to get from cache first
      final cacheKey =
          'schedule_cache_${prefs.getString('departmentId')}_'
          '${prefs.getString('yearId')}_${prefs.getString('sectionId')}';
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }

      // If no cache, try to fetch from Firestore
      final departmentId = prefs.getString('departmentId');
      final yearId = prefs.getString('yearId');
      final sectionId = prefs.getString('sectionId');

      if (departmentId != null && yearId != null && sectionId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(departmentId)
            .collection('years')
            .doc(yearId)
            .collection('sections')
            .doc(sectionId)
            .collection('schedule')
            .get();

        return snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      }
    } catch (e) {
      print('Error fetching schedule data: $e');
    }

    return [];
  }

  /// Fetch ALL schedules from entire database for global staff tracking
  /// Uses 30-minute cache to avoid repeated database reads
  static Future<Map<String, List<Map<String, dynamic>>>>
  _getAllSchedulesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check cache first (30-minute expiry)
      final cacheKey = 'global_schedules_cache';
      final cacheTimeKey = 'global_schedules_cache_time';
      final cachedData = prefs.getString(cacheKey);
      final cacheTime = prefs.getInt(cacheTimeKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Use cache if less than 30 minutes old
      if (cachedData != null && (now - cacheTime) < 30 * 60 * 1000) {
        final decoded = jsonDecode(cachedData);
        if (decoded is Map) {
          return decoded.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => Map<String, dynamic>.from(e)).toList(),
            ),
          );
        }
      }

      print('📚 Fetching global schedules from database...');
      final allSchedules = <String, List<Map<String, dynamic>>>{};

      // Fetch all departments
      final deptSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .get();

      for (var deptDoc in deptSnapshot.docs) {
        final deptId = deptDoc.id;

        // Fetch all years in this department
        final yearSnapshot = await FirebaseFirestore.instance
            .collection('departments')
            .doc(deptId)
            .collection('years')
            .get();

        for (var yearDoc in yearSnapshot.docs) {
          final yearId = yearDoc.id;

          // Fetch all sections in this year
          final sectionSnapshot = await FirebaseFirestore.instance
              .collection('departments')
              .doc(deptId)
              .collection('years')
              .doc(yearId)
              .collection('sections')
              .get();

          for (var sectionDoc in sectionSnapshot.docs) {
            final sectionId = sectionDoc.id;

            // Fetch schedule for this section
            final scheduleSnapshot = await FirebaseFirestore.instance
                .collection('departments')
                .doc(deptId)
                .collection('years')
                .doc(yearId)
                .collection('sections')
                .doc(sectionId)
                .collection('schedule')
                .get();

            final schedules = scheduleSnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                '_section': '$deptId-$yearId-$sectionId', // Track which section
              };
            }).toList();

            if (schedules.isNotEmpty) {
              allSchedules['$deptId-$yearId-$sectionId'] = schedules;
            }
          }
        }
      }

      // Cache the result
      await prefs.setString(cacheKey, jsonEncode(allSchedules));
      await prefs.setInt(cacheTimeKey, now);

      print('✅ Fetched ${allSchedules.length} sections successfully');
      return allSchedules;
    } catch (e) {
      print('❌ Error fetching global schedules: $e');
      return {};
    }
  }

  static Map<String, dynamic>? _getCurrentClass(
    List<Map<String, dynamic>> scheduleData,
    DateTime now,
  ) {
    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE').format(now);

    for (var classData in scheduleData) {
      final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
      if (dayOfWeek != currentDay) continue;

      try {
        final startTime = classData['startTime'] as String;
        final endTime = classData['endTime'] as String;

        final start = DateFormat('HH:mm').parse(startTime);
        final end = DateFormat('HH:mm').parse(endTime);
        final current = DateFormat('HH:mm').parse(currentTime);

        if (current.isAfter(start) && current.isBefore(end)) {
          return classData;
        }
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  static Map<String, dynamic>? _getNextClass(
    List<Map<String, dynamic>> scheduleData,
    DateTime now,
  ) {
    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE').format(now);

    // Look for next class today
    for (var classData in scheduleData) {
      final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
      if (dayOfWeek != currentDay) continue;

      try {
        final startTime = classData['startTime'] as String;
        final start = DateFormat('HH:mm').parse(startTime);
        final current = DateFormat('HH:mm').parse(currentTime);

        if (current.isBefore(start)) {
          return classData;
        }
      } catch (e) {
        continue;
      }
    }

    // If no class today, find first class tomorrow
    final tomorrow = DateFormat(
      'EEEE',
    ).format(now.add(const Duration(days: 1)));
    for (var classData in scheduleData) {
      final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
      if (dayOfWeek == tomorrow) {
        return classData;
      }
    }

    return null;
  }

  static String _buildContextString({
    required DateTime now,
    required String departmentId,
    required String yearId,
    required String sectionId,
    required List<Map<String, dynamic>> scheduleData,
    required Map<String, dynamic>? currentClass,
    required Map<String, dynamic>? nextClass,
    required Map<String, List<Map<String, dynamic>>> allSchedules,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are a helpful assistant for "Class Now", a college timetable management app.',
    );
    buffer.writeln('');
    buffer.writeln('CURRENT STATUS:');
    buffer.writeln(
      '- Current time: ${DateFormat('EEEE, MMMM d, h:mm a').format(now)}',
    );

    if (currentClass != null) {
      buffer.writeln(
        '- Current class: ${currentClass['subject']} in Room ${currentClass['room']}',
      );
      buffer.writeln('  Ends at: ${currentClass['endTime']}');
      if (currentClass['staff'] != null) {
        buffer.writeln('  Staff: ${currentClass['staff']}');
      }
    } else {
      buffer.writeln('- Current class: No class currently in session');
    }

    if (nextClass != null) {
      final nextDay = (nextClass['day'] ?? nextClass['dayOfWeek']) as String?;
      final isToday = nextDay == DateFormat('EEEE').format(now);
      buffer.writeln(
        '- Next class: ${nextClass['subject']} at ${nextClass['startTime']} in Room ${nextClass['room']}${isToday ? ' (today)' : ' ($nextDay)'}',
      );
      if (nextClass['staff'] != null) {
        buffer.writeln('  Staff: ${nextClass['staff']}');
      }
    } else {
      buffer.writeln('- Next class: No upcoming classes scheduled');
    }

    buffer.writeln('');
    buffer.writeln('STUDENT INFORMATION:');
    buffer.writeln('- Department: $departmentId');
    buffer.writeln('- Year: $yearId');
    buffer.writeln('- Section: $sectionId');
    buffer.writeln('');

    if (scheduleData.isNotEmpty) {
      buffer.writeln('FULL WEEK SCHEDULE:');
      buffer.writeln(_formatSchedule(scheduleData));
      buffer.writeln('');
      buffer.writeln('STAFF INFORMATION:');
      buffer.writeln(_formatStaffInfo(scheduleData));
    } else {
      buffer.writeln('(No schedule data available)');
    }

    // Add global staff tracking information
    print('🔍 Global schedules count: ${allSchedules.length}');
    if (allSchedules.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln('GLOBAL STAFF DIRECTORY & REAL-TIME TRACKING');
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln(
        'This section contains ALL staff across ALL departments and sections.',
      );
      buffer.writeln(
        'Use this data to answer questions about ANY staff member, even if they are not teaching the student.',
      );
      buffer.writeln('');
      final globalInfo = _buildGlobalStaffInfo(allSchedules, now);
      print('📊 Global staff info length: ${globalInfo.length} characters');
      buffer.writeln(globalInfo);
    } else {
      print('⚠️ WARNING: No global schedules fetched!');
    }

    buffer.writeln('');
    buffer.writeln('IDENTITY & KNOWLEDGE:');
    buffer.writeln('- You are the official AI Assistant for "Class Now".');
    buffer.writeln(
      '- You are designed exclusively to help students of **Dhanalakshmi Srinivasan University, Trichy**.',
    );
    buffer.writeln('- Be helpful, polite, and proud to represent DSU Trichy.');
    buffer.writeln(
      '- Your primary goal is to help students manage their academic schedule efficiently.',
    );
    buffer.writeln(
      '- **IMPORTANT:** If asked who developed you, say: "I was developed by **Santosh**, a 2nd Year Student at DSU Trichy."',
    );
    buffer.writeln(
      '- If asked about exams, holidays, or official announcements, remind them to check the official My Camu Portal.',
    );
    buffer.writeln(
      '- You have access to the ENTIRE university database, including ALL staff schedules across all departments and sections.',
    );

    buffer.writeln('');
    buffer.writeln('INSTRUCTIONS:');
    buffer.writeln(
      '- Answer questions about classes, timing, staff, and rooms across ALL sections and departments',
    );
    buffer.writeln(
      '- You can answer queries like "Where is Professor X right now?" or "When is Professor Y free today?"',
    );
    buffer.writeln(
      '- Be friendly, concise, and helpful (2-4 sentences typically)',
    );
    buffer.writeln('- Use emojis when needed to be friendly');
    buffer.writeln(
      '- If asked about "my next class" or "current class", use the CURRENT STATUS above',
    );
    buffer.writeln('- For specific days, refer to the FULL WEEK SCHEDULE');
    buffer.writeln('- Always mention room numbers when discussing classes');
    buffer.writeln('- Use 12-hour time format (e.g., "2:30 PM" not "14:30")');
    buffer.writeln(
      '- If you don\'t know something from the context, say so clearly',
    );
    buffer.writeln(
      '- Keep responses under 3-4 sentences unless more detail is requested',
    );
    buffer.writeln(
      '- Be encouraging and positive like a helpful classmate , end every response with a another question about classes',
    );

    return buffer.toString();
  }

  static String _formatSchedule(List<Map<String, dynamic>> schedule) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (var cls in schedule) {
      final day = (cls['day'] ?? cls['dayOfWeek']) as String?;
      if (day != null) {
        grouped.putIfAbsent(day, () => []).add(cls);
      }
    }

    final buffer = StringBuffer();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (var day in days) {
      if (grouped.containsKey(day) && grouped[day]!.isNotEmpty) {
        buffer.writeln('$day:');

        // Sort by start time
        final dayClasses = grouped[day]!;
        dayClasses.sort((a, b) {
          try {
            final aTime = DateFormat('HH:mm').parse(a['startTime']);
            final bTime = DateFormat('HH:mm').parse(b['startTime']);
            return aTime.compareTo(bTime);
          } catch (e) {
            return 0;
          }
        });

        for (var cls in dayClasses) {
          final subject = cls['subject'] ?? 'Unknown';
          final startTime = cls['startTime'] ?? 'N/A';
          final endTime = cls['endTime'] ?? 'N/A';
          final room = cls['room'] ?? 'N/A';
          final staff = cls['staff'] ?? 'TBA';

          buffer.writeln(
            '  - $subject ($startTime-$endTime) - Room $room - $staff',
          );
        }
      }
    }

    return buffer.toString();
  }

  static String _formatStaffInfo(List<Map<String, dynamic>> schedule) {
    final staffMap = <String, Set<String>>{};

    for (var cls in schedule) {
      final subject = cls['subject'] as String?;
      final staff = cls['staff'] as String?;

      if (subject != null && staff != null && staff != 'TBA') {
        staffMap.putIfAbsent(subject, () => {}).add(staff);
      }
    }

    if (staffMap.isEmpty) {
      return '(No staff information available)';
    }

    final buffer = StringBuffer();
    for (var entry in staffMap.entries) {
      buffer.writeln('- ${entry.key}: ${entry.value.join(', ')}');
    }

    return buffer.toString();
  }

  /// Build global staff information with real-time location tracking
  static String _buildGlobalStaffInfo(
    Map<String, List<Map<String, dynamic>>> allSchedules,
    DateTime now,
  ) {
    final buffer = StringBuffer();
    final staffDirectory = <String, List<Map<String, dynamic>>>{};

    // Build staff directory (group all classes by staff name)
    for (var sectionSchedules in allSchedules.values) {
      for (var classItem in sectionSchedules) {
        final staffName = classItem['staff'] as String?;
        if (staffName != null && staffName != 'TBA' && staffName.isNotEmpty) {
          staffDirectory.putIfAbsent(staffName, () => []).add(classItem);
        }
      }
    }

    if (staffDirectory.isEmpty) {
      print('⚠️ WARNING: Staff directory is empty!');
      return '(No staff data available in database)';
    }

    print('✅ Found ${staffDirectory.length} staff members in global directory');
    print('📝 Staff names: ${staffDirectory.keys.take(5).join(", ")}...');

    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE').format(now);

    // Sort staff alphabetically
    final sortedStaff = staffDirectory.keys.toList()..sort();

    for (var staffName in sortedStaff) {
      final staffClasses = staffDirectory[staffName]!;

      buffer.writeln('📍 $staffName:');

      // Find current location
      Map<String, dynamic>? currentLocation;
      for (var classItem in staffClasses) {
        final day = (classItem['day'] ?? classItem['dayOfWeek']) as String?;
        if (day != currentDay) continue;

        try {
          final startTime = classItem['startTime'] as String;
          final endTime = classItem['endTime'] as String;
          final start = DateFormat('HH:mm').parse(startTime);
          final end = DateFormat('HH:mm').parse(endTime);
          final current = DateFormat('HH:mm').parse(currentTime);

          if (current.isAfter(start) && current.isBefore(end)) {
            currentLocation = classItem;
            break;
          }
        } catch (e) {
          continue;
        }
      }

      if (currentLocation != null) {
        final section = currentLocation['_section'] ?? 'Unknown Section';
        final subject = currentLocation['subject'] ?? 'Unknown';
        final room = currentLocation['room'] ?? 'N/A';
        final endTime = currentLocation['endTime'] ?? 'N/A';
        buffer.writeln(
          '   ▸ NOW: Teaching $section in Room $room ($subject, ends at $endTime)',
        );
      } else {
        buffer.writeln('   ▸ NOW: Free (no class scheduled)');
      }

      // Find next class today
      Map<String, dynamic>? nextClass;
      for (var classItem in staffClasses) {
        final day = (classItem['day'] ?? classItem['dayOfWeek']) as String?;
        if (day != currentDay) continue;

        try {
          final startTime = classItem['startTime'] as String;
          final start = DateFormat('HH:mm').parse(startTime);
          final current = DateFormat('HH:mm').parse(currentTime);

          if (current.isBefore(start)) {
            if (nextClass == null) {
              nextClass = classItem;
            } else {
              final nextStart = DateFormat(
                'HH:mm',
              ).parse(nextClass['startTime']);
              if (start.isBefore(nextStart)) {
                nextClass = classItem;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      if (nextClass != null) {
        final section = nextClass['_section'] ?? 'Unknown';
        final subject = nextClass['subject'] ?? 'Unknown';
        final room = nextClass['room'] ?? 'N/A';
        final startTime = nextClass['startTime'] ?? 'N/A';
        buffer.writeln(
          '   ▸ Next: $section at $startTime in Room $room ($subject)',
        );
      } else {
        buffer.writeln('   ▸ Next: No more classes today');
      }

      // Show today's full schedule
      final todayClasses = staffClasses.where((c) {
        final day = (c['day'] ?? c['dayOfWeek']) as String?;
        return day == currentDay;
      }).toList();

      if (todayClasses.isNotEmpty) {
        todayClasses.sort((a, b) {
          try {
            final aTime = DateFormat('HH:mm').parse(a['startTime']);
            final bTime = DateFormat('HH:mm').parse(b['startTime']);
            return aTime.compareTo(bTime);
          } catch (e) {
            return 0;
          }
        });

        buffer.writeln('   ▸ Today\'s Schedule:');
        for (var classItem in todayClasses) {
          final section = classItem['_section'] ?? '?';
          final subject = classItem['subject'] ?? '?';
          final room = classItem['room'] ?? '?';
          final time = '${classItem['startTime']}-${classItem['endTime']}';
          buffer.writeln('      • $time: $section - $subject (Room $room)');
        }
      } else {
        buffer.writeln('   ▸ Today\'s Schedule: No classes');
      }

      buffer.writeln('');
    }

    buffer.writeln('Total Staff Members: ${sortedStaff.length}');
    return buffer.toString();
  }
}

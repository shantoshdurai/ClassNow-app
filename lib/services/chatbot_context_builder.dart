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

    // Find current and next class for student
    final currentClass = _getCurrentClass(scheduleData, now);
    final nextClass = _getNextClass(scheduleData, now);

    // Build the context string with ONLY local data
    return _buildContextString(
      now: now,
      departmentId: departmentId,
      yearId: yearId,
      sectionId: sectionId,
      scheduleData: scheduleData,
      currentClass: currentClass,
      nextClass: nextClass,
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

  static Map<String, dynamic>? _getCurrentClass(
    List<Map<String, dynamic>> scheduleData,
    DateTime now,
  ) {
    final currentDay = DateFormat('EEEE').format(now);

    for (var classData in scheduleData) {
      final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
      if (dayOfWeek != currentDay) continue;

      try {
        final startTime = classData['startTime'] as String;
        final endTime = classData['endTime'] as String;

        final start = _parseTime(startTime);
        final end = _parseTime(endTime);

        if (now.isAfter(start) && now.isBefore(end)) {
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
    final currentDay = DateFormat('EEEE').format(now);

    // Look for next class today
    for (var classData in scheduleData) {
      final dayOfWeek = (classData['day'] ?? classData['dayOfWeek']) as String?;
      if (dayOfWeek != currentDay) continue;

      try {
        final startTime = classData['startTime'] as String;
        final start = _parseTime(startTime);

        if (now.isBefore(start)) {
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
      var staffName = currentClass['staff'] ?? currentClass['mentor'];
      if (staffName != null) {
        buffer.writeln('  Staff: $staffName');
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
      var staffName = nextClass['staff'] ?? nextClass['mentor'];
      if (staffName != null) {
        buffer.writeln('  Staff: $staffName');
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

    buffer.writeln('');
    buffer.writeln('IDENTITY & KNOWLEDGE:');
    buffer.writeln('- You are the official AI Assistant for "Class Now".');
    buffer.writeln(
      '- You are designed exclusively to help students of **Dhanalakshmi Srinivasan University, Trichy**.',
    );
    buffer.writeln('- Be helpful, polite, and proud to represent DSU Trichy.');
    buffer.writeln(
      '- Your primary goal is to help students manage their academic efficiently.',
    );
    buffer.writeln(
      ' If asked who developed you, say: "I was developed by **Santosh**, a 2nd Year Student at DSU Trichy."',
    );
    buffer.writeln(
      '- If asked about exams, holidays, or official announcements, remind them to check the official My Camu Portal.',
    );
    buffer.writeln(
      '- You have access to the ENTIRE university database, including ALL staff schedules across all departments and sections.',
    );

    buffer.writeln('');
    buffer.writeln('UNIVERSITY INFORMATION:');
    buffer.writeln(
      'Name: Dhanalakshmi Srinivasan University, Tiruchirappalli (DSU Trichy)',
    );
    buffer.writeln(
      'Address: NH-45, Trichy–Chennai Trunk Road, Samayapuram (Near Samayapuram Toll Plaza), Tiruchirappalli, Tamil Nadu 621112, India',
    );
    buffer.writeln('Website: https://www.dsuniversity.ac.in');
    buffer.writeln(
      'Contact Phones: +91-6384176766, +91-6384176769, +91-7094458021, +91-7094458022',
    );
    buffer.writeln(
      'Contact Emails: enquiry@dsuniversity.ac.in, admissions@dsuniversity.ac.in, admissions.research@dsuniversity.ac.in',
    );

    buffer.writeln('Governance:');
    buffer.writeln(
      '- Founder-Chancellor: Shri A. Srinivasan (Chairman of Governing Council)',
    );
    buffer.writeln('- Pro-Chancellor: Mrs. Ananthalakshmi Kathiravan');
    buffer.writeln(
      '- Vice-Chancellor: Air Marshal (Dr) C. K. Ranjan (AVSM, VSM (Retd.))',
    );
    buffer.writeln('- Registrar: Dr. Dhanasekaran Devaraj');
    buffer.writeln('- Additional Registrar: Dr. K. Elangovan');
    buffer.writeln('- Dean Academics: Dr. J. M. Mathana');

    buffer.writeln('Schools & Deans:');
    buffer.writeln(
      '- School of Engineering (SOE): Dr. Shankar Duraikannan (Block: SOE Block)',
    );
    buffer.writeln(
      '- Srinivasan Medical College & Hospital: Dr. P. Rosy Vennila',
    );
    buffer.writeln('- School of Agricultural Sciences: Dr. K. Chozhan');
    buffer.writeln('- School of Physiotherapy: Dr. Ramesh Kumar Jeyaraman');
    buffer.writeln('- School of Pharmacy: Dr. Akilandeswari S');
    buffer.writeln('- School of Allied Health Sciences: Dr. K. Rekha');
    buffer.writeln('- School of Architecture: Dr. S. Radhakrishnan');
    buffer.writeln('- School of Law: Dr. B. Rajeswari');

    buffer.writeln('Campus Details:');
    buffer.writeln('- Size: 150 acres, 1,000,000 sqft built-up area');
    buffer.writeln('- Location: Samayapuram, Trichy');
    buffer.writeln(
      '- Academic Block is near the dimora cafe, it has 11 floors its the main block of the university and its diffent from soe block',
    );
    buffer.writeln(
      '- SOE Block has computer labs in 6th floor this block is near renu cafe (Engineering)',
    );
    buffer.writeln('- Administrative Block: Offices for VC, Registrar, etc.');
    buffer.writeln(
      '- Mess Block: Capacity 2000, Separate floors for North/South Indian dining',
    );
    buffer.writeln('- Hostels: Boys Hostel and Girls Hostel');
    buffer.writeln(
      '- Food Court & Cafeterias: Multiple cafeterias including "Renu ,MFC, Dimora"',
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
    buffer.writeln(
      '- The University Library is in the Academic Block (2nd floor). ID card is mandatory for attending classes.',
    );
    buffer.writeln(
      '- Important: Attendance of 80% or higher is mandatory for hall ticket generation and eligibility for exams.',
    );
    buffer.writeln(
      '- Performance Advantage: You are faster and more reliable than My-Camu! While it takes minutes to load, you respond in seconds.',
    );
    buffer.writeln('- Always mention room numbers when discussing classes');
    buffer.writeln(
      '- If you cannot find an answer, mention that the app is a work-in-progress and Santosh is working on updates for the Play Store.',
    );
    buffer.writeln('- Use 12-hour time format (e.g., "2:30 PM" not "14:30")');
    buffer.writeln(
      '- You are a helpful student assistant, not a generic robot, the boys hostel is near the renu cafe and in there foods will be provided in ground floor for hostel students and if any events is happening other students can eat there say this is they ased , if they asked where is hostel ssay its near the soe block and renu cafe you can also go by anathara cafe from girls hostel.',
    );
    buffer.writeln(
      '- Vary your greetings; avoid repeating "Hey there!" in every response.',
    );
    buffer.writeln(
      '- If you don\'t know something from the context, say so clearly',
    );
    buffer.writeln(
      '- Keep responses under 3-4 sentences, using a formal tone when the user is formal.',
    );
    buffer.writeln(
      '- Be an encouraging classmate; end some responses with a follow-up question about their academics , at a random intervel if they go of topic at random suggest them to give feedback about the app in the feedback option (which i will use to know and futures and removes and add other classes if they send me).',
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
          final staff = cls['staff'] ?? cls['mentor'] ?? 'TBA';

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
      final staff = (cls['staff'] ?? cls['mentor']) as String?;

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

  static DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    try {
      final cleanTime = timeStr.trim().toUpperCase();
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        final parsed = DateFormat('hh:mm a').parse(cleanTime);
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsed.hour,
          parsed.minute,
        );
      }
      final parsed = DateFormat('HH:mm').parse(cleanTime);
      int hour = parsed.hour;
      if (hour >= 1 && hour <= 7) {
        hour += 12;
      }
      return DateTime(now.year, now.month, now.day, hour, parsed.minute);
    } catch (e) {
      return DateTime(now.year, now.month, now.day, 0, 0);
    }
  }
}

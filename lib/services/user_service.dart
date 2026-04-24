import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserData {
  final String name;
  final String rollNumber;
  final String branch;
  final String? year;
  final String? section;
  final int? dayStreak;
  final double? gpa;

  UserData({
    required this.name,
    required this.rollNumber,
    required this.branch,
    this.year,
    this.section,
    this.dayStreak,
    this.gpa,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  UserData copyWith({
    String? name,
    String? rollNumber,
    String? branch,
    String? year,
    String? section,
    int? dayStreak,
    double? gpa,
  }) => UserData(
    name: name ?? this.name,
    rollNumber: rollNumber ?? this.rollNumber,
    branch: branch ?? this.branch,
    year: year ?? this.year,
    section: section ?? this.section,
    dayStreak: dayStreak ?? this.dayStreak,
    gpa: gpa ?? this.gpa,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'rollNumber': rollNumber,
    'branch': branch,
    'year': year,
    'section': section,
    'dayStreak': dayStreak,
    'gpa': gpa,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    name: json['name'] as String? ?? 'Guest Student',
    rollNumber: json['rollNumber'] as String? ?? 'N/A',
    branch: json['branch'] as String? ?? 'CSE',
    year: json['year'] as String?,
    section: json['section'] as String?,
    dayStreak: json['dayStreak'] as int?,
    gpa: (json['gpa'] as num?)?.toDouble(),
  );
}

class UserService {
  static const String _userDataKey = 'mycamu_user_data';
  static const String _loginStatusKey = 'mycamu_logged_in';
  static const String _lastSyncKey = 'mycamu_user_last_sync';

  static Future<void> saveUserData(UserData userData) async {
    // SECURITY: Never save "Password" as a name
    if (userData.name.toLowerCase() == 'password' || userData.name.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    await prefs.setBool(_loginStatusKey, true);
  }

  static Future<UserData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userDataKey);
    if (jsonStr == null) return null;
    try {
      final data = jsonDecode(jsonStr);
      final user = UserData.fromJson(data);
      
      // Proactive cleanup of bad data from previous sessions
      if (user.name.toLowerCase() == 'password') {
        print("🧹 RobotEye: Purging 'Password' name from storage.");
        await logout();
        return null;
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.setBool(_loginStatusKey, false);
    await prefs.remove(_lastSyncKey);
  }

  // ── Streak tracking ───────────────────────────────────────────────────────
  static const String _streakCountKey = 'streak_count';
  static const String _streakLastDateKey = 'streak_last_date';

  /// Call once per app launch (e.g. from splash/dashboard). Increments streak
  /// if this is the first open of a new consecutive day; resets on missed days.
  static Future<int> updateAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = prefs.getString(_streakLastDateKey);
    int streak = prefs.getInt(_streakCountKey) ?? 0;

    if (lastDate == today) return streak; // already counted today

    if (lastDate != null) {
      final last = DateTime.parse(lastDate);
      final now = DateTime.now();
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      streak = diffDays == 1 ? streak + 1 : 1;
    } else {
      streak = 1;
    }

    await prefs.setInt(_streakCountKey, streak);
    await prefs.setString(_streakLastDateKey, today);
    return streak;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  static Future<UserData?> fetchFromRoboEye(String rollNumber) async {
    try {
      // RoboEye API endpoint - adjust based on your actual API
      final response = await http
          .get(
            Uri.parse('https://roboeye.api/student/$rollNumber'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserData(
          name: data['name'] ?? 'Student',
          rollNumber: data['rollNumber'] ?? rollNumber,
          branch: data['branch'] ?? 'CSE',
          year: data['year'],
          section: data['section'],
          gpa: (data['gpa'] as num?)?.toDouble(),
        );
      }
    } catch (e) {
      print('RoboEye fetch error: $e');
    }
    return null;
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? _userData;
  String? _attendancePercent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = await UserService.getUserData();
    final attendance = prefs.getString('mycamu_attendance_percent');

    if (mounted) {
      setState(() {
        _userData = userData;
        _attendancePercent = attendance;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            const AuroraBackground(),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            const AuroraBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('No Profile Data', style: AppTextStyles.interTitle),
                  const SizedBox(height: 8),
                  Text('Please sync with MyCAMU first', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final dayStreak = _userData!.dayStreak ?? 0;
    final attendance = double.tryParse(_attendancePercent ?? '0') ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.interTitle.copyWith(fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AuroraBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Hero Card
                GlassCard(
                  blur: 20,
                  opacity: 0.15,
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar with initials
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark 
                                    ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                                    : [AppTheme.paperAccent, AppTheme.paperAccent.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _userData!.initials,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData!.name,
                                  style: AppTextStyles.interTitle.copyWith(
                                    fontSize: 22,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_userData!.rollNumber} • ${_userData!.branch}',
                                  style: AppTextStyles.monoLabel.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            context,
                            icon: Icons.local_fire_department_rounded,
                            label: 'Day Streak',
                            value: '$dayStreak',
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            context,
                            icon: Icons.check_circle_rounded,
                            label: 'Attendance',
                            value: '${attendance.toInt()}%',
                            color: attendance >= 75 ? Colors.green : Colors.red,
                          ),
                          if (_userData!.gpa != null)
                            _buildStatCard(
                              context,
                              icon: Icons.grade_rounded,
                              label: 'GPA',
                              value: _userData!.gpa!.toStringAsFixed(2),
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Academic Info Section
                _buildSectionTitle(context, 'Academic Information'),
                const SizedBox(height: 12),
                GlassCard(
                  blur: 15,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.badge_rounded,
                        label: 'Roll Number',
                        value: _userData!.rollNumber,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.school_rounded,
                        label: 'Branch',
                        value: _userData!.branch,
                      ),
                      if (_userData!.year != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_today_rounded,
                          label: 'Year',
                          value: _userData!.year!,
                        ),
                      ],
                      if (_userData!.section != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          icon: Icons.group_rounded,
                          label: 'Section',
                          value: _userData!.section!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Attendance Details Button
                if (_attendancePercent != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAttendanceDetails(context),
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('View Detailed Breakdown'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                // Last Sync Info
                FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final lastSync = snapshot.data!.getString('mycamu_last_sync');
                    if (lastSync == null) return const SizedBox.shrink();

                    final syncTime = DateTime.parse(lastSync);
                    final now = DateTime.now();
                    final diff = now.difference(syncTime);

                    String timeAgo;
                    if (diff.inMinutes < 1) {
                      timeAgo = 'just now';
                    } else if (diff.inMinutes < 60) {
                      timeAgo = '${diff.inMinutes}m ago';
                    } else if (diff.inHours < 24) {
                      timeAgo = '${diff.inHours}h ago';
                    } else {
                      timeAgo = '${diff.inDays}d ago';
                    }

                    return Center(
                      child: Text(
                        'Last synced: $timeAgo',
                        style: AppTextStyles.interSmall.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAttendanceDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed attendance breakdown'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content: const Text('You will need to login with MyCAMU again to view your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await UserService.logout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

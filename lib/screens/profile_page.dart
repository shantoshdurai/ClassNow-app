import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/screens/mycamu_sync_screen.dart';
import 'package:flutter_firebase_test/notifiers.dart';

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
    attendanceUpdateNotifier.addListener(_onAttendanceUpdated);
  }

  @override
  void dispose() {
    attendanceUpdateNotifier.removeListener(_onAttendanceUpdated);
    super.dispose();
  }

  void _onAttendanceUpdated() {
    if (mounted) {
      _loadData();
    }
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
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyCamuSyncScreen()),
                    ),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sign in Camu'),
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(context, 'Academic Information'),
                    IconButton(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit_note_rounded),
                      color: theme.primaryColor,
                      tooltip: 'Edit Information',
                    ),
                  ],
                ),
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
                          value: 'Year ${_userData!.year}',
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
                // Attendance Sync Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyCamuSyncScreen()),
                    ),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Update Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Privacy Note
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Text(
                          'Your data is stored locally & kept private.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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

  void _showEditProfileDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: _userData?.name);
    final rollController = TextEditingController(text: _userData?.rollNumber == 'N/A' ? '' : _userData?.rollNumber);
    final branchController = TextEditingController(text: _userData?.branch);
    final yearController = TextEditingController(text: _userData?.year);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1A1D24) : theme.scaffoldBackgroundColor,
        title: Text('Edit Profile', style: AppTextStyles.interTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(nameController, 'Full Name', Icons.person_rounded, isDark),
              const SizedBox(height: 16),
              _buildEditField(rollController, 'Roll Number', Icons.badge_rounded, isDark),
              const SizedBox(height: 16),
              _buildEditField(branchController, 'Branch', Icons.school_rounded, isDark),
              const SizedBox(height: 16),
              _buildEditField(yearController, 'Year (e.g. 1, 2, 3, 4)', Icons.calendar_today_rounded, isDark, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = _userData!.copyWith(
                name: nameController.text.trim(),
                rollNumber: rollController.text.trim().isEmpty ? 'N/A' : rollController.text.trim(),
                branch: branchController.text.trim(),
                year: yearController.text.trim(),
              );
              await UserService.saveUserData(updatedUser);
              if (context.mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon, bool isDark, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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

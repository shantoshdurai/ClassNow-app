import 'package:flutter/material.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 45, 16, 0),
          child: GlassCard(
            blur: 40,
            opacity: isDark ? 0.05 : 0.7,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'PRIVACY POLICY',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy for\nClass Now',
                    style: AppTextStyles.interTitle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Last updated: February 2026',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 32),

                  GlassCard(
                    blur: 40,
                    opacity: isDark ? 0.05 : 0.7,
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          context,
                          'Introduction',
                          'Class Now ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Information We Collect',
                          '''We collect the following types of information:

• Account Information: Department, year, section selection
• Device Information: Device ID for notifications, widget preferences
• Usage Data: App interactions, feature usage (anonymized)
• Schedule Data: Your class timetable and preferences

We DO NOT collect:
• Personal identification (name, email, phone)
• Location data
• Photos or media files
• Contact list or other personal data''',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'How We Use Your Information',
                          '''We use the collected information to:

• Provide accurate class schedules and notifications
• Sync your timetable across devices
• Improve app functionality and user experience
• Provide AI-powered assistant features
• Display widgets on your home screen
• Send class reminders and updates''',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Data Storage & Security',
                          '''• Your data is stored securely using Firebase services
• All connections use encryption (HTTPS/TLS)
• Schedule data is stored in cloud databases with restricted access
• Device data stays on your device (SharedPreferences)
• We implement industry-standard security measures''',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Third-Party Services',
                          '''We use the following third-party services:

• Firebase (Google): Backend, authentication, database
• Google AI: Chatbot functionality
• Android NotificationService: Class reminders

These services have their own privacy policies. We recommend reviewing them.''',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Permissions We Request',
                          '''• Notifications: To send class reminders
• Internet: To sync schedule data
• Alarms: For exact timing of notifications
• Boot: To reschedule notifications after device restart

We only request permissions necessary for core functionality.''',
                          isDark,
                        ),

                        _buildSection(context, 'Your Rights', '''You have the right to:

• Change your department/section selection anytime
• Clear app data and start fresh
• Disable notifications
• Request data deletion by contacting us
• Opt-out of AI assistant usage''', isDark),

                        _buildSection(
                          context,
                          'Data Retention',
                          '''• Schedule data: Kept for current academic year
• User preferences: Until you clear app data or uninstall
• Analytics: Anonymized, retained for 1 year''',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Children\'s Privacy',
                          'Class Now is designed for college students (18+). We do not knowingly collect information from minors under 18.',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Changes to This Policy',
                          'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or this document.',
                          isDark,
                        ),

                        _buildSection(
                          context,
                          'Contact Us',
                          '''If you have questions about this Privacy Policy or your data, please contact us:

📧 Email: support@classnow.app
🏫 Institution: Dayananda Sagar University
📍 Location: Bangalore, Karnataka, India''',
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 24,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Your privacy and data security are our top priorities. We are committed to transparency and responsible data handling.',
                            style: AppTextStyles.interSmall.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.monoLabel.copyWith(
              color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.interSmall.copyWith(
              color: isDark ? AppTheme.glassInk2 : AppTheme.paperInk2,
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

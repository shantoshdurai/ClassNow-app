import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Class Now',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: February 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context,
              'Introduction',
              'Class Now ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
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
            ),

            _buildSection(
              context,
              'Data Storage & Security',
              '''• Your data is stored securely using Firebase services
• All connections use encryption (HTTPS/TLS)
• Schedule data is stored in cloud databases with restricted access
• Device data stays on your device (SharedPreferences)
• We implement industry-standard security measures''',
            ),

            _buildSection(
              context,
              'Third-Party Services',
              '''We use the following third-party services:

• Firebase (Google): Backend, authentication, database
• Google AI: Chatbot functionality
• Android NotificationService: Class reminders

These services have their own privacy policies. We recommend reviewing them.''',
            ),

            _buildSection(
              context,
              'Permissions We Request',
              '''• Notifications: To send class reminders
• Internet: To sync schedule data
• Alarms: For exact timing of notifications
• Boot: To reschedule notifications after device restart

We only request permissions necessary for core functionality.''',
            ),

            _buildSection(context, 'Your Rights', '''You have the right to:

• Change your department/section selection anytime
• Clear app data and start fresh
• Disable notifications
• Request data deletion by contacting us
• Opt-out of AI assistant usage'''),

            _buildSection(
              context,
              'Data Retention',
              '''• Schedule data: Kept for current academic year
• User preferences: Until you clear app data or uninstall
• Analytics: Anonymized, retained for 1 year''',
            ),

            _buildSection(
              context,
              'Children\'s Privacy',
              'Class Now is designed for college students (18+). We do not knowingly collect information from minors under 18.',
            ),

            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or this document.',
            ),

            _buildSection(
              context,
              'Contact Us',
              '''If you have questions about this Privacy Policy or your data, please contact us:

📧 Email: support@classnow.app
🏫 Institution: Dayananda Sagar University
📍 Location: Bangalore, Karnataka, India''',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 24,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy and data security are our top priorities. We are committed to transparency and responsible data handling.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
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
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

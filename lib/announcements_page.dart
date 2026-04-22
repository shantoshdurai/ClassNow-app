import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/widgets/chatbot_interface.dart';

class AnnouncementsPage extends StatefulWidget {
  final bool isAdmin;
  const AnnouncementsPage({super.key, required this.isAdmin});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: GlassCard(
                    blur: 40,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 72,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: theme.colorScheme.onSurface,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ANNOUNCEMENTS',
                                  style: AppTextStyles.monoLabel.copyWith(
                                    color: theme.primaryColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Latest Updates',
                                  style: AppTextStyles.interTitle.copyWith(
                                    fontSize: 18,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48), // Balances the back button
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('announcements')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 64,
                                color: theme.hintColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No announcements yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final isSystem = data['isSystemMessage'] ?? false;
                          final timestamp = data['timestamp'] as Timestamp?;

                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            blur: 20,
                            opacity: isDark ? 0.05 : 0.4,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (isSystem
                                                ? theme.primaryColor
                                                : theme.colorScheme.secondary)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isSystem
                                            ? Icons.info_outline
                                            : Icons.campaign_outlined,
                                        color: isSystem
                                            ? theme.primaryColor
                                            : theme.colorScheme.secondary,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (data['author'] ?? 'Mentor')
                                                .toUpperCase(),
                                            style: AppTextStyles.monoLabel.copyWith(
                                              color: theme.primaryColor,
                                              fontSize: 9,
                                            ),
                                          ),
                                          if (timestamp != null)
                                            Text(
                                              DateFormat('MMM dd, hh:mm a')
                                                  .format(timestamp.toDate()),
                                              style: AppTextStyles.interSmall
                                                  .copyWith(
                                                color: theme.hintColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (widget.isAdmin)
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: theme.colorScheme.error
                                              .withOpacity(0.7),
                                        ),
                                        onPressed: () =>
                                            docs[index].reference.delete(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data['message'] ?? '',
                                  style: AppTextStyles.interSmall.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (widget.isAdmin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: GlassCard(
                      blur: 30,
                      opacity: 0.1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Type announcement...',
                                hintStyle: TextStyle(
                                  color: theme.hintColor.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: theme.primaryColor,
                            ),
                            onPressed: () {
                              if (messageController.text.trim().isNotEmpty) {
                                FirebaseFirestore.instance
                                    .collection('announcements')
                                    .add({
                                  'message': messageController.text.trim(),
                                  'author': 'Mentor',
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'isSystemMessage': false,
                                });
                                messageController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

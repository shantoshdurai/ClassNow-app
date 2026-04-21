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
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 45, 16, 0),
          child: GlassCard(
            blur: 25,
            opacity: 0.1,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Announcements',
                    style: AppTextStyles.interTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      height: 1.0,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.smart_toy_outlined,
                        color: theme.primaryColor,
                      ),
                      tooltip: 'AI Assistant',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const ChatbotInterface(),
                        );
                      },
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
          if (isDark)
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
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
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final isSystem = data['isSystemMessage'] ?? false;
                          final timestamp = data['timestamp'] as Timestamp?;

                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            blur: 15,
                            opacity: 0.08,
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (isSystem
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
                                  size: 20,
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${data['author'] ?? 'Mentor'} - ',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                    ),
                                    TextSpan(
                                      text: '"${data['message'] ?? ''}"',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: timestamp != null
                                  ? Text(
                                      DateFormat(
                                        'MMM dd, hh:mm a',
                                      ).format(timestamp.toDate()),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.hintColor.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                    )
                                  : null,
                              trailing: widget.isAdmin
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: theme.colorScheme.error
                                            .withOpacity(0.7),
                                      ),
                                      onPressed: () =>
                                          docs[index].reference.delete(),
                                    )
                                  : null,
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
                      blur: 20,
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
                                      'author': 'Mentor', // Added Author
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

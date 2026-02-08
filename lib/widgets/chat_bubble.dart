import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Represents a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Chat bubble widget for displaying messages
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message copied'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI avatar (for AI messages)
            if (!message.isUser)
              Container(
                margin: const EdgeInsets.only(right: 12, top: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),

            // Message bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: message.isUser
                      ? LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.85),
                          ],
                        )
                      : null,
                  color: message.isUser
                      ? null
                      : message.isError
                      ? Colors.red.withOpacity(0.08)
                      : isDark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                  borderRadius: message.isUser
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(4),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                  boxShadow: [
                    if (message.isUser)
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: message.isUser
                    ? Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                      )
                    : MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: message.isError
                                ? Colors.red
                                : theme.textTheme.bodyLarge?.color,
                            fontSize: 15,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                          strong: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          em: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          code: TextStyle(
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

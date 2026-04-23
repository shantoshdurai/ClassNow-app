import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_firebase_test/app_theme.dart';

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

// ── Animated thinking dots (shown before first streaming chunk arrives) ────────
class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key});
  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? AppTheme.glassInk2 : AppTheme.paperInk2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final begin = i * 0.2;
        final end = begin + 0.4;
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (_, __) => Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor.withOpacity(0.3 + 0.7 * anim.value),
            ),
          ),
        );
      }),
    );
  }
}

// ── AI avatar ─────────────────────────────────────────────────────────────────
class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 10, top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.glassAccent, const Color(0xFF2979FF)]
              : [AppTheme.paperAccent, AppTheme.paperAccentInk],
        ),
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;

  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _UserBubble(message: message) : _AiBubble(message: message, isStreaming: isStreaming);
  }
}

// ── User message: subtle right-aligned pill ───────────────────────────────────
class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onLongPress: () => _copyText(context, message.text),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, 4, 16, 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(5),
              ),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AI message: full-width, no bubble, avatar on left ─────────────────────────
class _AiBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  const _AiBubble({required this.message, required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;
    final errorColor = Theme.of(context).colorScheme.error;

    return GestureDetector(
      onLongPress: () => _copyText(context, message.text),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AiAvatar(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Thinking" dots while waiting for first chunk
                  if (isStreaming && message.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: ThinkingDots(),
                    )
                  else
                    MarkdownBody(
                      data: isStreaming
                          ? '${message.text}▍' // blinking-cursor feel
                          : message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.6,
                          color: message.isError ? errorColor : textColor,
                        ),
                        strong: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: message.isError ? errorColor : textColor,
                        ),
                        em: GoogleFonts.inter(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: message.isError ? errorColor : textColor,
                        ),
                        code: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.07)
                              : Colors.black.withOpacity(0.05),
                          color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        blockquote: GoogleFonts.inter(
                          fontSize: 14,
                          color: mutedColor,
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: GoogleFonts.inter(
                          fontSize: 15,
                          color: textColor,
                        ),
                        h1: GoogleFonts.fraunces(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        h2: GoogleFonts.fraunces(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        h3: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _copyText(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Copied',
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      backgroundColor: isDark ? const Color(0xFF1E2130) : AppTheme.paperInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
  );
}

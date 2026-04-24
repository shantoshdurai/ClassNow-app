import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import '../services/gemini_service.dart';
import '../services/chatbot_context_builder.dart';
import 'chat_bubble.dart';

class ChatbotInterface extends StatefulWidget {
  const ChatbotInterface({super.key});

  @override
  State<ChatbotInterface> createState() => _ChatbotInterfaceState();
}

class _ChatbotInterfaceState extends State<ChatbotInterface> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isStreaming = false;
  String? _systemContext;
  String _streamingText = '';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initializeContext();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Context & messaging ────────────────────────────────────────────────────

  Future<void> _initializeContext() async {
    final isConfigured = await GeminiService.isConfigured();
    if (!isConfigured) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: 'API key not configured. Please set up your Gemini API key to use the AI assistant.',
          isUser: false,
          isError: true,
        ));
      });
      return;
    }
    _systemContext = await ChatbotContextBuilder.buildContext();
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _controller.clear();
    _focusNode.unfocus();

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isLoading = true;
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    try {
      if (_systemContext == null) {
        await _initializeContext();
        if (_systemContext == null) {
          if (!mounted) return;
          setState(() {
            _messages.add(ChatMessage(
              text: 'Unable to load context. Please try again later.',
              isUser: false,
              isError: true,
            ));
            _isLoading = false;
            _isStreaming = false;
          });
          return;
        }
      }

      final history = _messages
          .where((m) => !m.isError)
          .take(_messages.length - 1)
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
          .toList();

      await for (final chunk in GeminiService.chatStream(
        userMessage: trimmed,
        systemContext: _systemContext!,
        history: history,
      )) {
        if (!mounted) return;
        setState(() => _streamingText += chunk);
        _scrollToBottom();
      }

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: _streamingText, isUser: false));
        _isStreaming = false;
        _streamingText = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: 'Something went wrong. Please try again.',
          isUser: false,
          isError: true,
        ));
        _isStreaming = false;
        _streamingText = '';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _streamingText = '';
      _isStreaming = false;
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        snap: true,
        snapSizes: const [0.5, 0.92],
        builder: (context, _) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  color: isDark
                      ? const Color(0xFF0D0F16).withOpacity(0.96)
                      : const Color(0xFFFEFDFC).withOpacity(0.97),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDragHandle(isDark),
                    _buildHeader(isDark),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                    ),
                    Expanded(child: _buildBody(isDark)),
                    _buildInputBar(isDark),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildDragHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.black12,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 10),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppTheme.glassAccent, const Color(0xFF2979FF)]
                    : [AppTheme.paperAccent, AppTheme.paperAccentInk],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DSU AI',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: inkColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'GEMINI · ACADEMIC ASSISTANT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: mutedColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Clear chat button
          if (_messages.isNotEmpty)
            Tooltip(
              message: 'New chat',
              child: IconButton(
                icon: Icon(Icons.edit_note_rounded, size: 20, color: mutedColor),
                onPressed: _clearChat,
                visualDensity: VisualDensity.compact,
              ),
            ),
          // Close button
          IconButton(
            icon: Icon(Icons.close_rounded, size: 20, color: mutedColor),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  // ── Body: welcome or messages ──────────────────────────────────────────────

  Widget _buildBody(bool isDark) {
    if (_messages.isEmpty && !_isStreaming) {
      return _buildWelcome(isDark);
    }
    return _buildMessageList(isDark);
  }

  Widget _buildWelcome(bool isDark) {
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
      child: Column(
        children: [
          // Glow orb + icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppTheme.glassAccent.withOpacity(0.2), const Color(0xFF2979FF).withOpacity(0.15)]
                    : [AppTheme.paperAccent.withOpacity(0.15), AppTheme.paperAccentInk.withOpacity(0.1)],
              ),
              border: Border.all(
                color: isDark
                    ? AppTheme.glassAccent.withOpacity(0.2)
                    : AppTheme.paperAccent.withOpacity(0.15),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 30,
                color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What can I\nhelp with?',
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: inkColor,
              letterSpacing: -0.8,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask about your schedule, classes, or staff',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: mutedColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // 2×2 suggestion grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _suggestionCard("What's my next class?", Icons.schedule_rounded, isDark),
              _suggestionCard("Today's full schedule", Icons.calendar_today_rounded, isDark),
              _suggestionCard("Know about holidays", Icons.celebration_rounded, isDark),
              _suggestionCard("Any free periods today?", Icons.coffee_outlined, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard(String text, IconData icon, bool isDark) {
    final inkColor = isDark ? AppTheme.glassInk2 : AppTheme.paperInk2;
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;

    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.025),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 5),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: inkColor,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    final itemCount = _messages.length + (_isStreaming ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i < _messages.length) {
          return ChatBubble(message: _messages[i]);
        }
        // Streaming bubble
        return ChatBubble(
          message: ChatMessage(text: _streamingText, isUser: false),
          isStreaming: true,
        );
      },
    );
  }

  // ── Input bar (Claude-style pill) ──────────────────────────────────────────

  Widget _buildInputBar(bool isDark) {
    final canSend = _controller.text.trim().isNotEmpty && !_isLoading;
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;
    final hintColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.09),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? AppTheme.glassInk : AppTheme.paperInk,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: _isLoading ? 'Thinking…' : 'Ask me anything…',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color: hintColor.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                    filled: false,
                  ),
                  onSubmitted: canSend ? (_) => _sendMessage(_controller.text) : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canSend ? accent : Colors.transparent,
                    border: canSend
                        ? null
                        : Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isLoading
                          ? Icons.stop_rounded
                          : Icons.arrow_upward_rounded,
                      size: 17,
                      color: canSend
                          ? Colors.white
                          : (isDark ? Colors.white24 : Colors.black26),
                    ),
                    onPressed: canSend ? () => _sendMessage(_controller.text) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

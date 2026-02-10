import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/chatbot_context_builder.dart';
import 'chat_bubble.dart';

/// Main chatbot interface
class ChatbotInterface extends StatefulWidget {
  const ChatbotInterface({super.key});

  @override
  State<ChatbotInterface> createState() => _ChatbotInterfaceState();
}

class _ChatbotInterfaceState extends State<ChatbotInterface> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _systemContext;
  String _streamingText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // Rebuild to update send button state
    });
    _initializeContext();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeContext() async {
    final isConfigured = await GeminiService.isConfigured();
    if (!isConfigured) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                '⚠️ API key not configured. Please set up your Gemini API key in the app to use the chatbot.',
            isUser: false,
            isError: true,
          ),
        );
      });
      return;
    }

    _systemContext = await ChatbotContextBuilder.buildContext();
  }

  void _addWelcomeMessage() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    setState(() {
      _messages.add(
        ChatMessage(
          text:
              '$greeting! 👋 I\'m DSU AI. Ask me about your schedule, classes, or staff!',
          isUser: false,
        ),
      );
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    if (_systemContext == null) {
      await _initializeContext();
      if (_systemContext == null) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Unable to load context. Please try again later.',
              isUser: false,
              isError: true,
            ),
          );
          _isLoading = false;
        });
        return;
      }
    }

    try {
      // Use streaming for better UX
      setState(() {
        _isStreaming = true;
        _streamingText = '';
      });

      final history = _messages
          .where((m) => !m.isError)
          .take(_messages.length - 1)
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
          .toList();

      await for (var chunk in GeminiService.chatStream(
        userMessage: userMessage,
        systemContext: _systemContext!,
        history: history,
      )) {
        setState(() {
          _streamingText += chunk;
        });
        _scrollToBottom();
      }

      setState(() {
        _messages.add(ChatMessage(text: _streamingText, isUser: false));
        _isStreaming = false;
        _streamingText = '';
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            isError: true,
          ),
        );
        _isStreaming = false;
        _streamingText = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      // Pushes modal up when keyboard appears
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Minimal header - just title and close
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'DSU AI',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 24),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Messages - scrollable content
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          reverse: false,
                          itemCount: _messages.length + (_isStreaming ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _messages.length) {
                              return ChatBubble(message: _messages[index]);
                            } else {
                              // Streaming message
                              return ChatBubble(
                                message: ChatMessage(
                                  text: _streamingText.isEmpty
                                      ? 'Thinking...'
                                      : _streamingText,
                                  isUser: false,
                                ),
                              );
                            }
                          },
                        ),
                ),

                // Quick actions (only show when no messages)
                if (_messages.length <= 2 && !_isLoading) _buildQuickActions(),

                // Loading indicator
                if (_isLoading && !_isStreaming)
                  const LinearProgressIndicator(minHeight: 2),

                // Input field at BOTTOM (sticky)
                _buildInputField(theme, isDark),
              ],
            ),
          );
        },
      ), // Close Padding
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 64,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What can I help with?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about your schedule and classes',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: theme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DSU AI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online • Powered by Gemini',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 24),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _quickActionChip('What\'s my next class?', Icons.schedule),
          _quickActionChip('Show today\'s schedule', Icons.calendar_today),
          _quickActionChip('Who teaches Math?', Icons.person),
          _quickActionChip('When is my last class?', Icons.access_time),
        ],
      ),
    );
  }

  Widget _quickActionChip(String text, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendMessage(text),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200, // Prevent buttons from being too wide
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true, // Auto-pop keyboard when chatbot opens
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 22, // Increased for better alignment
                          vertical: 14,
                        ),
                        isDense: true, // Prevents extra padding
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _isLoading ? null : _sendMessage,
                    ),
                  ),
                  // Send button integrated into input field
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 6,
                    ), // Increased for symmetry
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading || _controller.text.trim().isEmpty
                            ? null
                            : () => _sendMessage(_controller.text),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            _isLoading
                                ? Icons.stop_circle_outlined
                                : Icons.arrow_upward_rounded,
                            color: _isLoading || _controller.text.trim().isEmpty
                                ? (isDark ? Colors.grey[700] : Colors.grey[400])
                                : theme.primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              '$greeting! 👋 I\'m your Class Now assistant. Ask me about your schedule, classes, or staff!',
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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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

              // Header
              _buildHeader(theme),

              const Divider(height: 1),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
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

              // Quick action buttons (only show at start)
              if (_messages.length <= 2 && !_isLoading) _buildQuickActions(),

              // Loading indicator
              if (_isLoading && !_isStreaming)
                const LinearProgressIndicator(minHeight: 2),

              // Input field
              _buildInputField(theme, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(text),
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: theme.primaryColor, fontSize: 13),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your schedule...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _isLoading
                  ? null
                  : () => _sendMessage(_controller.text),
              mini: true,
              child: Icon(
                _isLoading ? Icons.hourglass_bottom : Icons.send,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

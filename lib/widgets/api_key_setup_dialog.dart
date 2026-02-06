import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

/// Dialog for setting up Gemini API key
class ApiKeySetupDialog extends StatefulWidget {
  const ApiKeySetupDialog({super.key});

  @override
  State<ApiKeySetupDialog> createState() => _ApiKeySetupDialogState();
}

class _ApiKeySetupDialogState extends State<ApiKeySetupDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _currentKey;

  @override
  void initState() {
    super.initState();
    _loadCurrentKey();
  }

  Future<void> _loadCurrentKey() async {
    final key = await GeminiService.getApiKey();
    if (key != null && mounted) {
      setState(() {
        _currentKey = key;
        // Show masked key
        _controller.text =
            '*' * (key.length - 8) + key.substring(key.length - 8);
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _controller.text.trim();

    if (key.isEmpty) {
      _showError('Please enter an API key');
      return;
    }

    // Don't save if it's the masked version
    if (key.startsWith('*')) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GeminiService.saveApiKey(key);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to save API key: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, size: 24),
          SizedBox(width: 8),
          Text('Gemini API Key'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your Google Gemini API key to enable the AI chatbot.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'AIza...',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: _currentKey != null
                  ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await GeminiService.clearApiKey();
                        setState(() {
                          _currentKey = null;
                          _controller.clear();
                        });
                      },
                    )
                  : null,
            ),
            obscureText: _controller.text.startsWith('*'),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get your free API key from ai.google.dev',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveApiKey,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

/// Show API key setup dialog
Future<bool> showApiKeySetupDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const ApiKeySetupDialog(),
  );
  return result ?? false;
}

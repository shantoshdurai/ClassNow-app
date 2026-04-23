import 'package:flutter/material.dart';
import 'services/gemini_service.dart';
import 'widgets/api_key_setup_dialog.dart';

/// Helper class for easy API key configuration
class ChatbotHelper {
  /// Show API key setup dialog
  static Future<void> setupApiKey(BuildContext context) async {
    await showApiKeySetupDialog(context);
  }

  /// Configure API key programmatically (for development/testing)
  static Future<void> setApiKey(String apiKey) async {
    await GeminiService.saveApiKey(apiKey);
    print('✅ Gemini API key configured successfully!');
  }

  /// Check if API key is configured
  static Future<bool> isConfigured() async {
    return await GeminiService.isConfigured();
  }

  /// Get current API key (masked for security)
  static Future<String?> getMaskedApiKey() async {
    final key = await GeminiService.getApiKey();
    if (key == null || key.isEmpty) return null;

    // Show only last 8 characters
    if (key.length > 8) {
      return '*' * (key.length - 8) + key.substring(key.length - 8);
    }
    return key;
  }

  /// Clear API key
  static Future<void> clearApiKey() async {
    await GeminiService.clearApiKey();
    print('❌ Gemini API key cleared');
  }
}

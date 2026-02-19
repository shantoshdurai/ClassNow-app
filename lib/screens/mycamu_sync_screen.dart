import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/main.dart';

class MyCamuSyncScreen extends StatefulWidget {
  const MyCamuSyncScreen({super.key});

  @override
  State<MyCamuSyncScreen> createState() => _MyCamuSyncScreenState();
}

class _MyCamuSyncScreenState extends State<MyCamuSyncScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  Timer? _automationTimer;
  bool _hasUpdated = false;
  String _statusMessage = "Waiting for login...";

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
            _startAutomation();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.mycamu.co.in/'));
  }

  @override
  void dispose() {
    _automationTimer?.cancel();
    super.dispose();
  }

  void _startAutomation() {
    _automationTimer?.cancel();
    _automationTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _attemptAutoSync();
    });
  }

  Future<void> _attemptAutoSync() async {
    if (_hasUpdated) return;

    try {
      final Object result = await controller.runJavaScriptReturningResult(r"""
        (function() {
          try {
            var text = document.body.innerText;
            
            var data = { status: 'SCANNING', overall: null, attendanceCount: null };
            
            // Look for "Overall percentage: 79%"
            var percentMatch = text.match(/Overall percentage\s*[:|-]?\s*(\d{1,3})%/i);
            if (percentMatch) {
              data.overall = percentMatch[1];
            }
            
            // Look for "No. of periods present : 101/128"
            var countMatch = text.match(/No\.\s*of\s*periods\s*present\s*[:|-]?\s*(\d+)\s*\/\s*(\d+)/i);
            if (countMatch) {
              data.attendanceCount = countMatch[1] + '/' + countMatch[2]; // "101/128"
            }
            
            // If we found the data, return it
            if (data.overall || data.attendanceCount) {
              data.status = 'FOUND';
              return JSON.stringify(data);
            }
            
            // If not found, try to navigate to "Over all" tab
            var elements = document.querySelectorAll('a, li, span, div, button');
            for (var i = 0; i < elements.length; i++) {
              var txt = elements[i].innerText ? elements[i].innerText.trim().toLowerCase() : '';
              // Match "over all" or "overall"
              if (txt === 'over all' || txt === 'overall') {
                if (elements[i].offsetParent !== null) {
                  elements[i].click();
                  // Also try parent if it's a nested element
                  if (elements[i].parentElement && elements[i].parentElement.tagName === 'A') {
                    elements[i].parentElement.click();
                  }
                  return JSON.stringify({ status: 'SWITCHING_TAB' });
                }
              }
            }
            
            // Last resort: Try to find "Attendance" menu
            for (var i = 0; i < elements.length; i++) {
              var txt = elements[i].innerText ? elements[i].innerText.trim().toLowerCase() : '';
              if (txt === 'attendance') {
                if (elements[i].offsetParent !== null) {
                  elements[i].click();
                  return JSON.stringify({ status: 'NAVIGATING' });
                }
              }
            }
            
            return JSON.stringify({ status: 'SCANNING' });
          } catch (e) {
            return JSON.stringify({ error: e.toString() });
          }
        })();
      """);

      if (!mounted) return;

      String cleanResponse = result.toString();
      if (cleanResponse.startsWith('"') && cleanResponse.endsWith('"')) {
        cleanResponse = jsonDecode(cleanResponse);
      }

      final Map<String, dynamic> data = jsonDecode(cleanResponse);

      if (data['status'] == 'NAVIGATING') {
        setState(
          () => _statusMessage = "📍 Please click 'Attendance' in the menu",
        );
        return;
      }

      if (data['status'] == 'SWITCHING_TAB') {
        setState(() => _statusMessage = "📍 Please click 'Over all' tab above");
        return;
      }

      if (data['status'] == 'FOUND' &&
          (data['overall'] != null || data['attendanceCount'] != null)) {
        _hasUpdated = true;
        final String? percent = data['overall'];
        final String? count = data['attendanceCount'];

        String displayMsg = "Found: ";
        if (percent != null) displayMsg += "$percent%";
        if (count != null) displayMsg += " ($count)";

        setState(() => _statusMessage = displayMsg);
        await _saveAndNotify(percent, count);
      } else {
        setState(() => _statusMessage = "Scanning for Overall %...");
      }
    } catch (e) {
      // Ignore errors, keep scanning
    }
  }

  Future<void> _saveAndNotify(String? percent, String? count) async {
    final prefs = await SharedPreferences.getInstance();

    if (percent != null) {
      await prefs.setString('mycamu_attendance_percent', percent);
    }

    if (count != null) {
      await prefs.setString('mycamu_attendance_count', count);
    }

    await prefs.setString('mycamu_last_sync', DateTime.now().toIso8601String());

    // Clear any old subject data
    await prefs.remove('mycamu_subject_attendance');

    // Update global notifier
    attendanceUpdateNotifier.value++;

    if (!mounted) return;

    String snackMsg = "✅ Attendance Updated";
    if (percent != null) snackMsg += ": $percent%";
    if (count != null) snackMsg += " ($count)";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackMsg),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Auto-close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyCamu Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _hasUpdated = false;
                _statusMessage = "Reloading...";
              });
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading) const LinearProgressIndicator(),

          // Status Overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black87,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    if (_hasUpdated)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
                    else
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_test/notifiers.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';

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
            var url = window.location.href;

            // --- NAVIGATION HELPERS ---
            function clickElement(el) {
               if (!el) return false;
               el.scrollIntoView({block: 'center'});
               var events = ['mousedown', 'mouseup', 'click'];
               events.forEach(type => {
                  el.dispatchEvent(new MouseEvent(type, { view: window, bubbles: true, cancelable: true }));
               });
               if (typeof el.click === 'function') el.click();
               return true;
            }

            function smartClick(pattern) {
               var selectors = ['.mat-tab-label', 'a', 'button', 'mat-list-item', 'span', 'div'];
               var p = pattern.toLowerCase();
               for (var s of selectors) {
                  var elements = document.querySelectorAll(s);
                  for (var i = 0; i < elements.length; i++) {
                    var txt = elements[i].innerText ? elements[i].innerText.trim().toLowerCase() : '';
                    if (txt === p || txt.includes(p)) {
                       if (elements[i].offsetParent !== null || elements[i].getClientRects().length > 0) {
                          return clickElement(elements[i]);
                       }
                    }
                  }
               }
               return false;
            }

            // --- STATE DETECTION ---
            var isInstitutionPage = text.includes('Select your institution') || url.includes('search-institution');
            var isAttendancePage = url.includes('attendance');
            var isDashboard = url.includes('dashboard') || url.includes('home') || text.includes('Student status');
            
            // Logged In if on Attendance, Dashboard, or see Logout
            var isLoggedIn = isAttendancePage || isDashboard || !!document.querySelector('i.fa-power-off');

            if (isInstitutionPage) {
               var input = document.querySelector('input[placeholder*="institution name"]');
               if (input && input.value.length < 5) {
                 input.value = 'Dhanalakshmi Srinivasan University';
                 input.dispatchEvent(new Event('input', { bubbles: true }));
                 return JSON.stringify({ status: 'SELECTING_INSTITUTION' });
               }
               return JSON.stringify({ status: 'WAITING_FOR_INSTITUTION' });
            }

            if (!isLoggedIn && (document.querySelector('input[type="password"]') || text.includes('Password'))) {
               return JSON.stringify({ status: 'WAITING_FOR_LOGIN' });
            }

            // --- DATA EXTRACTION ---
            var data = { status: 'SCANNING', overall: null, attendanceCount: null, name: null, rollNumber: null, branch: null, year: null };

            // 1. Name & Profile (Always scrape if logged in)
            var nameMatch = text.match(/([A-Z\s]{4,30})\n\s*Student status/i);
            if (nameMatch) {
               data.name = nameMatch[1].trim();
            } else {
               var h3s = document.querySelectorAll('h3');
               for(var i=0; i<h3s.length; i++) {
                  var t = h3s[i].innerText.trim();
                  if(t.length > 3 && !/attendance|timetable|messages|home|dashboard|announcements/i.test(t)) {
                     data.name = t; break;
                  }
               }
            }

            // 2. Details
            var rollMatch = text.match(/(?:Roll|REG|Admission)\s*No?\s*[:|-]?\s*([A-Z0-9]{4,20})/i);
            if (rollMatch) data.rollNumber = rollMatch[1].trim();
            
            var branchMatch = text.match(/(?:Branch|Program|Department)\s*[:|-]?\s*([A-Za-z\s()&]{3,50}?)(?:\n|$|·|•)/i);
            if (branchMatch) data.branch = branchMatch[1].trim();

            var yearMatch = text.match(/Semester-(\d+)/i);
            if (yearMatch) data.year = yearMatch[1];

            // 3. Attendance
            var percentMatch = text.match(/Overall percentage\s*[:|-]?\s*(\d{1,3})%/i);
            if (percentMatch) data.overall = percentMatch[1];

            var countMatch = text.match(/No\.\s*of\s*periods\s*present\s*[:|-]?\s*(\d+)\s*\/\s*(\d+)/i);
            if (countMatch) data.attendanceCount = countMatch[1] + '/' + countMatch[2];

            // --- AUTOMATION STEPS ---
            if (data.overall && data.overall !== "0") {
               data.status = 'FOUND';
               return JSON.stringify(data);
            }

            if (isAttendancePage) {
               if (smartClick('Over all') || smartClick('Overall')) {
                  return JSON.stringify({ ...data, status: 'SWITCHING_TAB' });
               }
               return JSON.stringify({ ...data, status: 'SCANNING_ATTENDANCE' });
            }

            // If not on attendance page, try to go there
            if (smartClick('Attendance')) {
               return JSON.stringify({ ...data, status: 'NAVIGATING' });
            }

            // Open menu if nothing is visible
            var menuBtn = document.querySelector('button[aria-label*="menu"]') || document.querySelector('.menu-icon') || document.querySelector('.fa-bars');
            if (menuBtn && menuBtn.offsetParent !== null) {
               clickElement(menuBtn);
               return JSON.stringify({ ...data, status: 'OPENING_MENU' });
            }

            return JSON.stringify({ ...data, status: 'LOGGED_IN' });
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

      // --- LOGIC: Force Identity Sync ---
      if (data['name'] != null && !['password', 'dsu student', 'guest student'].contains(data['name'].toLowerCase())) {
         final prefs = await SharedPreferences.getInstance();
         final userData = UserData(
            name: data['name'],
            rollNumber: data['rollNumber'] ?? 'N/A',
            branch: data['branch'] ?? 'CSE',
            year: data['year'],
         );
         await UserService.saveUserData(userData);
         attendanceUpdateNotifier.value++; // Force global UI to show the real name
      }

      // --- STATUS UPDATES ---
      if (data['status'] == 'SELECTING_INSTITUTION') {
        setState(() => _statusMessage = "🏫 Selecting University...");
      } else if (data['status'] == 'WAITING_FOR_LOGIN') {
        setState(() => _statusMessage = "🔑 Login to your profile...");
      } else if (data['status'] == 'OPENING_MENU') {
        setState(() => _statusMessage = "☰ Opening menu...");
      } else if (data['status'] == 'NAVIGATING') {
        setState(() => _statusMessage = "📍 Selecting Attendance...");
      } else if (data['status'] == 'SWITCHING_TAB') {
        setState(() => _statusMessage = "📍 Switching to 'Over all' view...");
      } else if (data['status'] == 'FOUND') {
        _hasUpdated = true;
        setState(() => _statusMessage = "✅ Sync Complete!");
        await _saveAndNotify(data['overall'], data['attendanceCount'], data['name'], data['rollNumber'], data['branch'], data['year']);
      } else if (data['status'] == 'SCANNING_ATTENDANCE') {
        setState(() => _statusMessage = "🔍 Calculating attendance...");
      } else {
        setState(() => _statusMessage = "👤 Identified: ${data['name'] ?? 'Scanning...'}");
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveAndNotify(String? p, String? c, String? n, String? r, String? b, String? y) async {
    final prefs = await SharedPreferences.getInstance();
    if (p != null) await prefs.setString('mycamu_attendance_percent', p);
    if (c != null) await prefs.setString('mycamu_attendance_count', c);
    
    // Identity Save
    if (n != null && !['password', 'guest student'].contains(n.toLowerCase())) {
      await UserService.saveUserData(UserData(name: n, rollNumber: r ?? 'N/A', branch: b ?? 'CSE', year: y));
    }

    await prefs.setString('mycamu_last_sync', DateTime.now().toIso8601String());
    attendanceUpdateNotifier.value++;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Profile & Attendance Fully Synced"), backgroundColor: Colors.green));
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Sign in Camu', style: AppTextStyles.interTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AuroraBackground(),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40),
            child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), child: WebViewWidget(controller: controller)),
          ),
          if (_isLoading) Positioned(top: kToolbarHeight + 40, left: 0, right: 0, child: LinearProgressIndicator(backgroundColor: Colors.transparent, color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent)),
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: GlassCard(
              blur: 20, opacity: isDark ? 0.3 : 0.6, borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_hasUpdated) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
                  else SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_statusMessage, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), maxLines: 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

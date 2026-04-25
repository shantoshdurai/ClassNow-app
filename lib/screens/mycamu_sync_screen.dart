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
  int _stuckCount = 0;

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
               var selectors = [
                  'a', 'button', '[role="menuitem"]', '[role="option"]',
                  '[role="tab"]', '[role="link"]', '[role="button"]',
                  'li', '.MuiListItemButton-root', '.MuiMenuItem-root',
                  '.mat-tab-label', 'mat-list-item', 'span', 'div',
               ];
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

            // navClick: only targets navigation/sidebar/menu elements — avoids hitting dashboard content cards
            function navClick(pattern) {
               var navSels = [
                  'nav a', 'aside a', '[role="navigation"] a', '[role="menuitem"]',
                  '[role="menu"] a', '[role="menu"] li', '[role="listitem"] a',
                  '[class*="sidebar"] a', '[class*="Sidebar"] a',
                  '[class*="drawer"] a', '[class*="Drawer"] a',
                  '[class*="menu"] a', '[class*="Menu"] a',
                  '[class*="nav"] a', '[class*="Nav"] a',
               ];
               var p = pattern.toLowerCase();
               for (var s of navSels) {
                  try {
                     var elements = document.querySelectorAll(s);
                     for (var i = 0; i < elements.length; i++) {
                        var txt = (elements[i].innerText || '').trim().toLowerCase();
                        if ((txt === p || txt.includes(p)) &&
                            (elements[i].offsetParent !== null || elements[i].getClientRects().length > 0)) {
                           return clickElement(elements[i]);
                        }
                     }
                  } catch(e) {}
               }
               return false;
            }

            // --- STATE DETECTION ---
            var isInstitutionPage = text.includes('Select your institution') || url.includes('search-institution');

            // isAttendancePage: URL-based OR text-based (v2 URL may differ)
            var isAttendancePage = url.includes('attendance') ||
               (text.includes('Subject wise') || text.includes('No. of periods') ||
                text.includes('Periods Present') || (text.includes('Overall') && text.includes('present')));

            var isDashboard = url.includes('dashboard') || url.includes('home');
            var isProfilePage = url.includes('profile') || text.includes('Student status') || text.includes('Admission No');

            // Logged In if on Attendance, Dashboard, Profile, or Logout icon visible
            var isLoggedIn = isAttendancePage || isDashboard || isProfilePage || !!document.querySelector('i.fa-power-off');

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
            // Roll Number: Look for common labels or standalone patterns that look like roll numbers
            var rollMatch = text.match(/(?:Roll|REG|Admission|Registration)\s*No?\s*[:|-]?\s*([A-Z0-9\/-]{4,25})/i);
            if (rollMatch) {
               data.rollNumber = rollMatch[1].trim();
            } else {
               // Fallback: search for typical DSU roll number patterns if labels fail
               var potentialRolls = text.match(/[A-Z0-9]{2,5}[0-9]{4,8}/g);
               if (potentialRolls && potentialRolls.length > 0) {
                  data.rollNumber = potentialRolls[0];
               }
            }
            
            var branchMatch = text.match(/(?:Branch|Program|Department|Course)\s*[:|-]?\s*([A-Za-z\s()&]{3,60}?)(?:\n|$|·|•|Admission)/i);
            if (branchMatch) data.branch = branchMatch[1].trim();

            // Year Extraction: Look for Semester or Academic Year (e.g. 2024-2028)
            var semesterMatch = text.match(/Semester\s*[:|-]?\s*(\d+)/i);
            if (semesterMatch) {
               data.year = Math.ceil(parseInt(semesterMatch[1]) / 2).toString();
            } else {
               var academicYearMatch = text.match(/(\d{4})\s*-\s*(\d{4})/);
               if (academicYearMatch) {
                  var startYear = parseInt(academicYearMatch[1]);
                  var currentYear = new Date().getFullYear();
                  var currentMonth = new Date().getMonth();
                  var yearNum = currentYear - startYear + (currentMonth >= 5 ? 1 : 0);
                  data.year = Math.max(1, Math.min(4, yearNum)).toString();
               }
            }

            // 3. Attendance — try multiple label formats from both v1 and v2
            var percentMatch =
               text.match(/Overall\s*percentage\s*[:|-]?\s*(\d{1,3}(?:\.\d+)?)%?/i) ||
               text.match(/Total\s*(?:attendance|percentage)\s*[:|-]?\s*(\d{1,3}(?:\.\d+)?)%?/i) ||
               text.match(/Consolidated\s*(?:attendance|percentage|%)\s*[:|-]?\s*(\d{1,3}(?:\.\d+)?)%?/i) ||
               text.match(/(\d{1,3}(?:\.\d+)?)\s*%\s*(?:overall|total|attendance)/i) ||
               text.match(/Attendance\s*(?:Percentage|%)\s*[:|-]?\s*(\d{1,3}(?:\.\d+)?)/i);
            if (percentMatch) data.overall = Math.round(parseFloat(percentMatch[1])).toString();

            var countMatch = text.match(/No\.\s*of\s*periods\s*present\s*[:|-]?\s*(\d+)\s*\/\s*(\d+)/i) ||
               text.match(/Present\s*[:|-]?\s*(\d+)\s*\/\s*(\d+)/i) ||
               text.match(/(\d+)\s*\/\s*(\d+)\s*(?:days|periods|classes)/i);
            if (countMatch) data.attendanceCount = countMatch[1] + '/' + countMatch[2];

            // --- AUTOMATION STEPS ---
            if (data.overall && data.overall !== "0") {
               data.status = 'FOUND';
               return JSON.stringify(data);
            }

            if (isAttendancePage) {
               // Try named tab variations (v1: "Over all", v2: may differ)
               var tabLabels = ['Over all', 'Overall', 'Consolidated', 'Summary', 'All Subjects', 'Total', 'All'];
               for (var tl = 0; tl < tabLabels.length; tl++) {
                  if (smartClick(tabLabels[tl])) {
                     return JSON.stringify({ ...data, status: 'SWITCHING_TAB' });
                  }
               }
               // Fallback: click any visible tab/pill element on the page
               var tabEls = document.querySelectorAll('[role="tab"], .tab-item, .nav-tab, [class*="Tab"], [class*="tab-"]');
               for (var ti = 0; ti < tabEls.length; ti++) {
                  if (tabEls[ti].offsetParent !== null || tabEls[ti].getClientRects().length > 0) {
                     clickElement(tabEls[ti]);
                     return JSON.stringify({ ...data, status: 'SWITCHING_TAB' });
                  }
               }
               return JSON.stringify({ ...data, status: 'SCANNING_ATTENDANCE' });
            }

            // --- OPEN MENU HELPER ---
            function openSideMenu() {
               // STRATEGY 1: elementFromPoint — walk up DOM looking for cursor:pointer only
               // NO direct-click fallback — too dangerous on dashboard (clicks wrong elements)
               var hamCoords = [
                  [24, 40], [36, 40], [48, 40], [24, 56], [36, 56],
                  [20, 28], [40, 28], [60, 40], [24, 70], [36, 70]
               ];
               for (var i = 0; i < hamCoords.length; i++) {
                  var probe = document.elementFromPoint(hamCoords[i][0], hamCoords[i][1]);
                  var depth = 0;
                  while (probe && probe !== document.body && depth < 10) {
                     var tag = probe.tagName ? probe.tagName.toUpperCase() : '';
                     var role = probe.getAttribute ? probe.getAttribute('role') : '';
                     var cs = window.getComputedStyle ? window.getComputedStyle(probe) : null;
                     var cur = cs ? cs.cursor : '';
                     if (tag === 'BUTTON' || tag === 'A' || role === 'button' || cur === 'pointer') {
                        clickElement(probe);
                        return true;
                     }
                     probe = probe.parentElement;
                     depth++;
                  }
               }

               // STRATEGY 2: position scan — allow negative x (myCamu v2 hamburger is at x≈-334)
               var clickable = document.querySelectorAll('button, [role="button"], a[href]');
               for (var i = 0; i < clickable.length; i++) {
                  var r = clickable[i].getBoundingClientRect();
                  if (r.top >= -20 && r.top < 150 && r.left >= -500 && r.left < 150
                      && r.width > 8 && r.width < 150 && r.height > 8) {
                     clickElement(clickable[i]);
                     return true;
                  }
               }

               // STRATEGY 3: SVG in top-left (React icon buttons)
               var svgs = document.querySelectorAll('svg');
               for (var i = 0; i < svgs.length; i++) {
                  var r = svgs[i].getBoundingClientRect();
                  if (r.top >= -20 && r.top < 150 && r.left >= -500 && r.left < 150 && r.width > 8) {
                     var parent = svgs[i].closest('button, [role="button"], a') || svgs[i].parentElement;
                     if (parent) { clickElement(parent); return true; }
                  }
               }

               // STRATEGY 4: aria/class name selectors
               var fallbackSels = [
                  '[aria-label*="menu"]', '[aria-label*="navigation"]', '[aria-label*="sidebar"]',
                  '[aria-label*="drawer"]', '[aria-label*="toggle"]',
                  '.menu-icon', '.hamburger', '.navbar-toggler',
                  '[class*="MenuButton"]', '[class*="menu-btn"]', '[class*="HamburgerButton"]',
                  '[class*="burger"]', '[class*="sidebar"]', '[class*="drawer"]',
                  '[class*="toggle"]', '[class*="nav-icon"]',
               ];
               for (var s of fallbackSels) {
                  try {
                     var el = document.querySelector(s);
                     if (el && el.getBoundingClientRect().width > 0) { clickElement(el); return true; }
                  } catch(e) {}
               }

               return false;
            }

            // --- NAVIGATION FLOW ---
            // Go straight for Attendance — no need to visit dashboard first.
            // navClick targets sidebar/nav links only (avoids hitting dashboard content cards).
            // smartClick is the broader fallback.
            if (!isAttendancePage) {
               if (navClick('Attendance') || smartClick('Attendance')) {
                  return JSON.stringify({ ...data, status: 'NAVIGATING' });
               }
               // Attendance not visible — open the sidebar
               if (openSideMenu()) {
                  return JSON.stringify({ ...data, status: 'OPENING_MENU' });
               }
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
        _stuckCount = 0;
        setState(() => _statusMessage = "☰ Opening side menu...");
      } else if (data['status'] == 'NAVIGATING') {
        _stuckCount = 0;
        setState(() => _statusMessage = "📍 Selecting Attendance...");
      } else if (data['status'] == 'GOING_HOME') {
        _stuckCount = 0;
        setState(() => _statusMessage = "📍 Navigating to Dashboard...");
      } else if (data['status'] == 'SWITCHING_TAB') {
        _stuckCount = 0;
        setState(() => _statusMessage = "📍 Switching to Overall view...");
      } else if (data['status'] == 'FOUND') {
        _stuckCount = 0;
        _hasUpdated = true;
        setState(() => _statusMessage = "✅ Sync Complete!");
        await _saveAndNotify(data['overall'], data['attendanceCount'], data['name'], data['rollNumber'], data['branch'], data['year']);
      } else if (data['status'] == 'SCANNING_ATTENDANCE') {
        _stuckCount = 0;
        setState(() => _statusMessage = "🔍 Calculating attendance...");
      } else {
        _stuckCount++;
        final name = data['name'];
        final debug = data['debug'] as String?;
        if (name != null && _stuckCount >= 3 && debug != null) {
          setState(() => _statusMessage = "DBG: $debug");
        } else if (name != null && _stuckCount >= 3) {
          setState(() => _statusMessage = "👤 $name · Tapping menu...");
        } else {
          setState(() => _statusMessage = "👤 Identified: ${name ?? 'Scanning...'}");
        }
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

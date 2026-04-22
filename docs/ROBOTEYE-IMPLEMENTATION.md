# RobotEye Implementation Log

## Session: April 22, 2026 (Morning)

### 1. UI Polish & Refactoring
- **Dashboard Header:** Refactored from `Stack` to `Row/Expanded` to prevent the back button and title from overlapping.
- **Announcements Header:** Similarly refactored to remove the AI button and fix layout crampedness.
- **"Live Now" Indicator:** Fixed square glow artifacts by using `ClipOval` and circular containers for a perfect pulse effect.
- **Theme Toggle:** Moved the Dark Mode toggle to the header of the Settings page for better accessibility. Fixed the icon logic (Sun for Dark, Moon for Light).

### 2. Feature Removal
- **90s Retro Display:** Completely removed this deprecated feature.
  - Deleted `lib/retro_digital_display.dart`.
  - Cleaned all references in `dashboard_page.dart` and `settings_page.dart`.
  - Removed `retroDisplayEnabledNotifier` from `lib/notifiers.dart`.

---

## Session: April 22, 2026 (Evening Update)

### 1. RobotEye Accuracy & Automation Improvements
- **Roll Number Extraction:** Refined regex to catch multiple patterns (`Roll`, `REG`, `Admission`, `Registration`). Added a fallback scanner for typical DSU alphanumeric patterns (e.g., `24AIDSA4`).
- **Year/Semester Intelligence:** 
  - Implemented logic to map Semester numbers to Academic Years (e.g., Semester 3-4 -> Year 2).
  - Added support for parsing academic year ranges (e.g., "2024-2028") and calculating the current year based on the current date/month.
- **Aggressive Navigation:** Improved the scraper to automatically navigate away from the Profile page to the Dashboard and then Attendance. It now proactively finds and clicks the hamburger menu icon if navigation links are hidden.
- **Dynamic Status UI:** Added real-time status updates during sync: *"📍 Navigating to Dashboard..."*, *"☰ Opening menu..."*, *"📍 Selecting Attendance..."*.

### 2. Profile & Settings UX Updates
- **Manual Data Correction:** Added an **Edit Icon** in the Academic Information section. Users can now manually edit Name, Roll Number, Branch, and Year to fix any RobotEye hallucinations.
- **Update Attendance Button:** Replaced the "Detailed Breakdown" button with a functional **"Update Attendance"** button that opens the MyCamu sync screen directly.
- **Instant UI Refresh:** Integrated `attendanceUpdateNotifier` into the Profile and Settings pages. All stats (Streak, Attendance, Year) now update immediately as soon as a sync completes.
- **Privacy Assurance:** Added a lock-protected privacy note at the bottom of the Profile page: *"Your data is stored locally & kept private."*

### 3. General App Polish
- **AI Icon Standardization:** Switched all AI/Chatbot icons from `psychology_rounded` to `auto_awesome_rounded` (sparkles) for a more modern appearance.
- **Subject Icon Logic:** Updated `SubjectUtils` to automatically assign the Sparkle icon to any subjects containing "AI", "Intelligence", or "Logic".
- **Year Display Formatting:** Standardized the year display across the app to always show as **"Year X"** (e.g., Year 2).

### 4. Completed Tasks
- [x] Stabilize automatic navigation in the MyCamu WebView.
- [x] Ensure the profile name "Password" is cleared and replaced with correct name.
- [x] Verify attendance updates immediately on the profile card after sync.
- [x] Add manual edit capability for Academic Information.
- [x] Add Privacy Note for local storage reassurance.

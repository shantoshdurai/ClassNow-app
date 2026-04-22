# RobotEye Implementation Log

## Session: April 22, 2026

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

### 3. MyCamu (Sign in Camu) Integration
- **Renaming:** Changed all "Sync MyCamu" labels to **"Sign in Camu"** to be more descriptive.
- **Automation Improvements:**
  - Automated institution selection for "Dhanalakshmi Srinivasan University".
  - Improved the JavaScript scraper to avoid "Password" label hallucinations.
  - **Planned:** Enhancing automatic navigation to move from Home -> Sidebar -> Attendance -> Over all view automatically.
- **Data Persistence:** Ensured attendance data (percentage and counts) and profile data (name, branch) are extracted and saved to `SharedPreferences`.

### 4. Known Issues / To-Do
- [ ] Stabilize automatic navigation in the MyCamu WebView.
- [ ] Ensure the profile name "Password" is cleared and replaced with the correct student name during sync.
- [ ] Verify attendance updates immediately on the profile card after sync.

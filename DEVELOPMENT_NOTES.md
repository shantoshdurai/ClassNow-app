# Development Notes & Build Requirements

This document tracks critical architectural decisions and build-specific requirements for the ClassNow project to ensure stability across different environments.

## 1. Firebase Configuration (`DefaultFirebaseOptions`)

**IMPORTANT:** The class name in `lib/firebase_options.dart` must be **`DefaultFirebaseOptions`**.

- **Reason:** Using `PigeonFirebaseOptions` caused a type mismatch error (`type 'PigeonFirebaseOptions' is not a subtype of type 'List<Object?>'`) during Firebase initialization. 
- **Fix:** We renamed it back to the standard `DefaultFirebaseOptions` to ensure compatibility with the Firebase SDK.
- **Dart usage:** 
  ```dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```

## 2. Modular Architecture

The project has been refactored from a monolithic `main.dart` into a modular structure to prevent circular dependencies and improve maintainability:

- **`lib/main.dart`**: Minimal entry point. Handles Firebase initialization, environment loading, and the top-level `MaterialApp`.
- **`lib/notifiers.dart`**: Contains all global `ValueNotifier` instances (e.g., `attendanceUpdateNotifier`, `retroDisplayEnabledNotifier`).
- **`lib/dashboard_page.dart`**: Contains the primary `DashboardPage` UI and logic.
- **`lib/services/`**: Contains business logic (Gemini, Firestore, etc.).

**Guideline:** Do NOT import `main.dart` from other files. If you need a notifier, import `notifiers.dart`. If you need to navigate to the dashboard, import `dashboard_page.dart`.

## 3. Environment Variables

The app requires a `.env` file in the root directory for Gemini AI functionality.

- **File:** `.env`
- **Key:** `GEMINI_API_KEY=your_key_here`
- **Verification:** Ensure `.env` is listed in the `assets` section of `pubspec.yaml`.

## 4. Native Android Configuration

### MainApplication.kt
Native Firebase initialization (`FirebaseApp.initializeApp(this)`) is **disabled** in the Kotlin code (`android/app/src/main/kotlin/.../MainApplication.kt`). 
- **Reason:** Firebase is initialized via the Flutter layer in `main.dart`. Adding native initialization without explicit Gradle dependencies causes build failures.

### Build Issues
- If you encounter `Unresolved reference: FirebaseApp`, ensure that no native Kotlin file is trying to import `com.google.firebase.FirebaseApp`.
- The `compileSdk` is set to **35** to support the latest `home_widget` and `workmanager` plugins.

## 6. UI & Design System (Paper & Glass)

The app uses a dual-theme system that toggles between "Paper" (Light) and "Glass" (Dark).

### GlassCard Widget
The `GlassCard` widget (used heavily in Dark mode) requires a `BorderRadius` object for its `borderRadius` property.
- **Incorrect:** `borderRadius: 24`
- **Correct:** `borderRadius: BorderRadius.circular(24)`

### Theme-Aware UI
When building UI elements that change based on the theme (e.g., icons or text colors), always check `isDark` within the local builder scope:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### Assets & Styles
- **Paper Theme:** Uses `#F5F2ED` background, serif headers, and `AppTextStyles.paperH1`.
- **Glass Theme:** Uses `AuroraBackground` and `GlassCard` with neon accents.

## 7. Build Requirements

### Color Methods
- **Avoid:** `.withValues()` (not supported in the current Flutter version).
- **Use:** `.withOpacity()` for setting alpha values.

### Android SDK
- `compileSdk` is set to **35**.
- `minSdk` is set to **24**.

### Common Startup Issues
- **Splash Screen Hang:** If the app hangs on the splash screen, check the `logcat` for `FileNotFoundError` related to `.env`. 
  - **Fix:** Ensure `.env` is declared in `pubspec.yaml` assets and the load call in `main.dart` is wrapped in a `try-catch`.

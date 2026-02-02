# Android Widget Configuration Files

## 1. Timetable Widget Configuration
**File:** `android/app/src/main/res/xml/timetable_widget_info.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider 
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="320dp"
    android:minHeight="160dp"
    android:updatePeriodMillis="900000"
    android:previewImage="@drawable/timetable_preview"
    android:initialLayout="@layout/timetable_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/timetable_widget_description" />
```

**Notes:**
- `updatePeriodMillis="900000"` = 15 minutes (minimum allowed)
- Android will batch updates to save battery
- Actual updates are controlled by WorkManager for more precision

---

## 2. Robot Widget Configuration
**File:** `android/app/src/main/res/xml/robot_widget_info.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider 
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="160dp"
    android:minHeight="160dp"
    android:updatePeriodMillis="900000"
    android:previewImage="@drawable/robot_preview"
    android:initialLayout="@layout/robot_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/robot_widget_description" />
```

---

## 3. Strings Resource
**File:** `android/app/src/main/res/values/strings.xml`

Add these entries:

```xml
<resources>
    <string name="app_name">Your App Name</string>
    <string name="timetable_widget_description">Shows your current and upcoming classes</string>
    <string name="robot_widget_description">Cute robot showing your class status</string>
</resources>
```

---

## 4. Build.gradle Configuration
**File:** `android/app/build.gradle`

Add these dependencies in the `dependencies` block:

```gradle
dependencies {
    // Existing dependencies...
    
    // WorkManager for background updates
    implementation 'androidx.work:work-runtime:2.8.1'
    
    // Optional: For better debugging
    debugImplementation 'androidx.work:work-testing:2.8.1'
}
```

---

## 5. AndroidManifest.xml Configuration
**File:** `android/app/src/main/AndroidManifest.xml`

Add these inside the `<application>` tag:

```xml
<application>
    <!-- Your existing code... -->
    
    <!-- Timetable Widget Provider -->
    <receiver 
        android:name="com.example.flutter_firebase_test.TimetableWidgetProvider"
        android:exported="true">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        </intent-filter>
        <meta-data
            android:name="android.appwidget.provider"
            android:resource="@xml/timetable_widget_info" />
    </receiver>
    
    <!-- Robot Widget Provider -->
    <receiver 
        android:name="com.example.flutter_firebase_test.RobotWidgetProvider"
        android:exported="true">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        </intent-filter>
        <meta-data
            android:name="android.appwidget.provider"
            android:resource="@xml/robot_widget_info" />
    </receiver>
    
    <!-- WorkManager -->
    <provider
        android:name="androidx.startup.InitializationProvider"
        android:authorities="${applicationId}.androidx-startup"
        android:exported="false"
        tools:node="merge">
        <meta-data
            android:name="androidx.work.WorkManagerInitializer"
            android:value="androidx.startup"
            tools:node="remove" />
    </provider>
    
</application>
```

---

## 6. Permissions (if needed)
**File:** `android/app/src/main/AndroidManifest.xml`

Add these permissions if you need wake locks or foreground services:

```xml
<manifest>
    <!-- For background work -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <!-- Your existing permissions... -->
</manifest>
```

---

## Testing the Configuration

### 1. Verify Widget is Registered
```bash
adb shell dumpsys appwidget | grep "com.example.flutter_firebase_test"
```

### 2. Check WorkManager Tasks
```bash
adb shell dumpsys jobscheduler | grep "WorkManagerService"
```

### 3. Force Widget Update (for testing)
```bash
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE
```

### 4. Monitor Logs
```bash
flutter logs | grep -E "\[WorkManager\]|\[Timer\]|\[Update\]"
```

---

## Common Issues

### Widget not appearing in widget picker
- Clean and rebuild: `flutter clean && flutter build apk`
- Check AndroidManifest.xml has correct receiver entries
- Verify XML files are in correct location

### Widget not updating
- Check battery optimization is disabled for your app
- Verify WorkManager task is registered (check logs)
- Ensure updatePeriodMillis is valid (>= 1800000 ms on Android 12+)

### Background updates not working
- Check Doze mode settings
- Verify app has necessary permissions
- Test on different Android versions (behavior varies)

# Crash Fix: ClassCastException in NotificationSchedulerService

## Issue
The app was crashing on startup with the following error:
```
java.lang.ClassCastException: java.lang.Long cannot be cast to java.lang.Integer
at com.example.flutter_firebase_test.NotificationSchedulerService.scheduleAllNotifications(NotificationSchedulerService.kt:47)
```

## Root Cause
Flutter's `SharedPreferences` implementation sometimes stores integer values as `Long` type in native Android storage, but the Kotlin code was trying to read it as `Int` type, causing a `ClassCastException`.

**Specific line that caused the crash:**
```kotlin
val leadTimeMinutes = prefs.getInt(LEAD_TIME_KEY, 15)  // ❌ Crashes if stored as Long
```

## Solution
Added a try-catch block to safely handle both `Int` and `Long` types:

```kotlin
// Safely get lead time - Flutter might store as Long instead of Int
val leadTimeMinutes = try {
    prefs.getInt(LEAD_TIME_KEY, 15)
} catch (e: ClassCastException) {
    // If stored as Long, convert to Int
    prefs.getLong(LEAD_TIME_KEY, 15L).toInt()
}
```

## How It Works
1. **First attempt**: Try to read as `Int` (normal case)
2. **If ClassCastException**: Catch the exception and read as `Long`, then convert to `Int`
3. **Default value**: If key doesn't exist, defaults to 15 minutes

## Why This Happens
This is a known issue with Flutter's SharedPreferences plugin:
- Flutter's Dart `int` type is 64-bit
- When saved to Android's SharedPreferences, it may be stored as `Long` (64-bit)
- Reading it back as `Int` (32-bit) causes a ClassCastException

## File Modified
- `android/app/src/main/kotlin/com/example/flutter_firebase_test/NotificationSchedulerService.kt`

## Impact
✅ **App no longer crashes on startup**  
✅ **Notifications work correctly**  
✅ **Backwards compatible** - handles both Int and Long storage  
✅ **No data loss** - preserves existing user preferences

## Note
This crash was **NOT caused by** the swipe navigation or AI chatbot features that were just added. This was a pre-existing bug in the notification scheduling system that was triggered during app initialization.

## Future Prevention
Consider using this safe read pattern for all integer SharedPreferences reads in Kotlin code:
```kotlin
private fun getSafeInt(key: String, defaultValue: Int): Int {
    return try {
        prefs.getInt(key, defaultValue)
    } catch (e: ClassCastException) {
        prefs.getLong(key, defaultValue.toLong()).toInt()
    }
}
```

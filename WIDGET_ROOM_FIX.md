# Widget Room Number Fix

## Issue
The room number text "• Room 704" was wrapping and getting cut off in the widget, showing:
```
• R
oom
704
```

## Root Cause
The `room_number` TextView had `layout_width="wrap_content"` which didn't prevent text wrapping when space was limited.

## Solution
Changed the layout to:
1. **Give room TextView flexible width**: `layout_width="0dp"` with `layout_weight="1"`
2. **Prevent wrapping**: Added `android:singleLine="true"`
3. **Ellipsize if too long**: Added `android:ellipsize="end"`

This ensures:
- Time takes only what it needs
- Room number gets remaining space
- If still too long, it shows "• Room 7..." instead of wrapping

## Changes Made
File: `android/app/src/main/res/layout/timetable_widget_layout.xml`

```xml
<TextView
    android:id="@+id/room_number"
    android:layout_width="0dp"           ← Changed from wrap_content
    android:layout_weight="1"            ← NEW: Take remaining space
    android:layout_height="wrap_content"
    android:layout_marginStart="12dp"
    android:text="• Room 101"
    android:textSize="11sp"
    android:textColor="#FFFFFF"
    android:alpha="0.7"
    android:singleLine="true"            ← NEW: No wrapping
    android:ellipsize="end" />           ← NEW: Show ... if too long
```

## Testing
1. Build APK: `flutter build apk --release`
2. Install on device
3. Remove old widget from home screen
4. Re-add widget
5. Verify room number shows on one line: "• Room 704"

Building APK now...

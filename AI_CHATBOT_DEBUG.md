# AI Chatbot Global Database Access - Debugging Guide

## Issue
The AI chatbot is not able to answer questions about staff members who are not teaching the current student's classes.

## Expected Behavior
- AI should be able to answer: "What are Karthikeyan's classes today?"
- Should show real-time location and schedule for ANY staff member

## Current Behavior
- AI responds: "I don't have any classes listed for a staff member named Karthikeyan in my current data"

## Debug Steps

### 1. Check if Global Schedules are Being Fetched

When you open the chatbot, look for these console logs:

```
📚 Fetching global schedules from database...
✅ Fetched X sections successfully
```

If you see:
- `⚠️ WARNING: No global schedules fetched!` → Database fetch failed
- `🔍 Global schedules count: 0` → No data was retrieved

### 2. Check Staff Directory Building

Look for:
```
✅ Found X staff members in global directory
📝 Staff names: Name1, Name2, Name3...
```

If you see:
- `⚠️ WARNING: Staff directory is empty!` → No staff found in schedules

### 3. Check Global Staff Info Generation

Look for:
```
📊 Global staff info length: XXXX characters
```

If length is < 100 characters, the global info isn't being generated properly.

## Possible Causes

### 1. **Cache Issue**
The 30-minute cache might be serving old/empty data.

**Fix:** Clear the cache
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('global_schedules_cache');
await prefs.remove('global_schedules_cache_time');
```

### 2. **Database Structure**
Staff names might not be populated in the schedule documents.

**Check Firebase:**
- Go to: `departments/{dept}/years/{year}/sections/{section}/schedule/{class}`
- Verify each class document has a `staff` field  with the teacher's name

### 3. **Permission Issues**
Firestore security rules might be blocking reads.

**Check Firestore Rules:**
```javascript
allow read: if request.auth != null; // Should allow authenticated users
```

### 4. **Name Mismatch**
Staff names in the database might not match the query exactly.

**Example:**
- Database has: "Dr. Karthikeyan" or "Karthikeyan Kumar" 
- User asks: "Karthikeyan"
- AI can't find exact match

**Note:** The current implementation requires EXACT name matching.

## Testing Commands

### Test in Flutter App

1. **Clear Cache and Reopen Chatbot:**
   ```dart
   // In widget_service.dart or any startup file
   final prefs = await SharedPreferences.getInstance();
   await prefs.remove('global_schedules_cache');
   ```

2. **Check Console Logs:**
   Run `flutter run` and watch for debug output when opening chatbot

3. **Test Query:**
   - Open AI chatbot
   - Ask: "What classes does [StaffName] have today?"
   - Check console for debug logs

### Test Database Query

Run this in Firebase console to see all staff names:

```javascript
// This won't work in console, but shows the concept
db.collectionGroup('schedule').get().then(snap => {
  const staff = new Set();
  snap.docs.forEach(doc => {
    if (doc.data().staff) staff.add(doc.data().staff);
  });
  console.log('All staff:', Array.from(staff));
});
```

## Quick Fixes

### Fix 1: Force Cache Refresh

Add a "Refresh" button in chatbot that clears cache:

```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('global_schedules_cache');
    await prefs.remove('global_schedules_cache_time');
    // Rebuild chatbot
  },
)
```

### Fix 2: Add Case-Insensitive Search

Modify `_buildGlobalStaffInfo` to support partial name matching:

```dart
// Instead of exact match in AI instructions, add fuzzy search
final staffName = classItem['staff'] as String?;
if (staffName != null && staff Name.toLowerCase().contains('karthikeyan')) {
  // Found a match
}
```

### Fix 3: Increase AI Context Window

The global staff info might be getting cut off. Verify in `gemini_service.dart`:

```dart
'maxOutputTokens': 1000, // ✓ Already increased
```

## Next Steps

1. **Install debug build**
2. **Open chatbot** and check console logs
3. **Try asking** about a staff member you KNOW is in the database
4. **Report back** with the console debug output

If you see "⚠️ WARNING: No global schedules fetched!", the issue is with the database query, not the AI.

# Profile Integration & MyCAMU Login Guide

## Overview
This guide explains the new Profile system integration with MyCAMU login that allows students to view their real profile data fetched from the MyCAMU portal.

## What's New

### 1. **User Service** (`lib/services/user_service.dart`)
A new service that handles all user data management:
- **UserData Model**: Stores student information (name, roll number, branch, year, section, streak, GPA)
- **Local Storage**: Saves user data to SharedPreferences with encryption support
- **RoboEye Integration**: Fetches additional student details from the RoboEye API
- **Login Status**: Tracks if user is authenticated via MyCAMU

**Key Methods:**
```dart
// Save user data after MyCAMU sync
await UserService.saveUserData(userData);

// Check if user is logged in
bool isLoggedIn = await UserService.isLoggedIn();

// Get stored user profile
UserData? userData = await UserService.getUserData();

// Logout user
await UserService.logout();

// Fetch from RoboEye API
UserData? data = await UserService.fetchFromRoboEye(rollNumber);
```

### 2. **Profile Page** (`lib/screens/profile_page.dart`)
A beautiful profile screen showing:
- **Profile Hero Card**: Avatar with initials on gradient, name, roll number, branch
- **Statistics**: Day streak, attendance percentage, GPA
- **Academic Info**: Roll number, branch, year, section
- **Last Sync Info**: When profile was last synced
- **Logout Button**: Sign out from MyCAMU account

Only accessible when user is logged in via MyCAMU.

### 3. **Enhanced MyCAMU Sync** (`lib/screens/mycamu_sync_screen.dart`)
Updated to extract and save user data:
- **JavaScript Extraction**: Pulls student name, roll number, branch from MyCAMU portal
- **Data Parsing**: Uses regex to extract structured data from unformatted text
- **Automatic Save**: Saves user profile after successful sync
- **RoboEye Fallback**: Can query RoboEye API for missing data

**Extracted Data Pattern:**
```javascript
// Extracts from MyCAMU portal:
- Student Name: [name]
- Roll Number: 22CSA117
- Branch: CSE / AI
- Attendance: 79%
- Periods: 101/128
```

### 4. **Dashboard Updates** (`lib/dashboard_page.dart`)
- **Profile Button**: Shows in app bar when user is logged in via MyCAMU
- **Improved Typography**: Better text hierarchy and spacing
- **Enhanced Day Selector**: Now shows calendar dates (Mon 20, Tue 21, etc.)
- **MyCamu Login Detection**: Automatically detects login status on startup

### 5. **Improved Calendar Dates**
Day selector now displays:
```
MON        TUE        WED
20         21         22
```

Each day shows both the day name and date for better visual context.

## Implementation Details

### Data Flow Diagram
```
MyCAMU Portal
     ↓
JavaScript Extraction (HTML parsing)
     ↓
Student Data Captured (name, roll, branch, attendance)
     ↓
Save to SharedPreferences via UserService
     ↓
RoboEye API (optional - for additional data like GPA)
     ↓
Profile Page Display
```

### JavaScript Extraction Patterns
The MyCAMU sync screen uses these regex patterns to extract data:

```javascript
// Student name
/(?:Student Name|Name)\s*[:|-]?\s*([A-Za-z\s]+?)(?:\n|$)/i

// Roll number
/(?:Roll|REG|Registration)\s*[:|-]?\s*([A-Z0-9]+)/i

// Branch
/(?:Branch|Program)\s*[:|-]?\s*([A-Za-z\s()]+?)(?:\n|$|·|•)/i

// Attendance percentage
/Overall percentage\s*[:|-]?\s*(\d{1,3})%/i

// Periods attended
/No\.\s*of\s*periods\s*present\s*[:|-]?\s*(\d+)\s*\/\s*(\d+)/i
```

## Setup Instructions

### 1. Enable RoboEye API Integration (Optional)
If using RoboEye for additional student data:

```dart
// In lib/services/user_service.dart, update the endpoint:
final response = await http.get(
  Uri.parse('https://your-roboeye-api/student/$rollNumber'),
  headers: {'Accept': 'application/json'},
);
```

Replace with your actual RoboEye API endpoint.

### 2. Data Storage Structure
User data is stored in SharedPreferences as JSON:

```json
{
  "name": "John Doe",
  "rollNumber": "22CSA117",
  "branch": "CSE (AI)",
  "year": "3rd",
  "section": "B",
  "dayStreak": 18,
  "gpa": 8.5
}
```

**Storage Keys:**
- `mycamu_user_data`: Complete user profile JSON
- `mycamu_logged_in`: Boolean login status
- `mycamu_last_sync`: ISO timestamp of last sync
- `mycamu_attendance_percent`: Attendance percentage
- `mycamu_attendance_count`: Periods attended (e.g., "101/128")

### 3. Test the Integration

**Step 1: Login via MyCAMU**
1. Open Settings → Sync MyCamu
2. Log in to your MyCAMU account
3. Navigate to Attendance section
4. App automatically extracts and saves data

**Step 2: View Profile**
1. Look for new person icon (👤) in dashboard header
2. Click to open Profile page
3. See your name, roll number, branch, stats

**Step 3: Sync Again**
- Repeat Step 1 to update profile data
- Stats refresh automatically

## UI/Typography Improvements

### Text Hierarchy
```
Hero Title (Display)
├── Name: 28px, bold, -0.4 letter-spacing
├── Roll/Branch: 12px, mono, 0.4 letter-spacing
└── Stats: 16px, bold

Section Titles
├── 18px, bold, 0.5 letter-spacing
└── Medium gray (60% opacity)

Body Text
├── 14px, normal weight
└── Dark ink

Metadata
├── 12px, light weight  
└── Muted (50% opacity)
```

### Calendar Dates Formatting
Enhanced day selector shows:
- **Day abbreviation**: MON, TUE, WED (uppercase, monospace)
- **Date number**: 20, 21, 22 (bold, secondary)
- **Visual hierarchy**: Day first, date secondary
- **Responsive spacing**: Adjusts to content width

## Error Handling

### Failed MyCAMU Sync
If sync fails:
```
❌ Could not extract profile data
→ App shows: "Please navigate to Attendance section"
→ Retry automatically every 2 seconds
→ Max timeout: 30 seconds
```

### Missing Data
If fields are incomplete:
```
Name: Shows "Student" (default)
Roll: Shows "N/A"
Branch: Shows "CSE" (default)
```

### RoboEye API Failure
If RoboEye is unavailable:
```
→ Falls back to MyCAMU extracted data
→ Skips GPA and additional fields
→ No error shown to user
```

## Customization

### Change Avatar Colors
In `lib/screens/profile_page.dart`:
```dart
gradient: LinearGradient(
  colors: [AppTheme.primaryBlue, AppTheme.accentPurple],  // Change colors here
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
```

### Modify Statistics Display
In Profile Page, adjust these stat cards:
```dart
_buildStatCard(
  context,
  icon: Icons.local_fire_department_rounded,
  label: 'Day Streak',      // Change label
  value: '$dayStreak',       // Change value
  color: Colors.orange,      // Change color
),
```

### Update RoboEye Fields
In `lib/services/user_service.dart`, modify the `fetchFromRoboEye` method to parse additional fields:
```dart
gpa: (data['gpa'] as num?)?.toDouble(),  // Add custom fields
department: data['department'],
```

## Known Limitations

1. **MyCAMU Parsing**: Depends on MyCAMU portal HTML structure
   - If portal changes, JavaScript regex may need updating
   - Tested on current MyCAMU interface (as of 2026)

2. **RoboEye API**: Endpoint must be configured
   - Default endpoint is placeholder
   - Update with actual RoboEye API URL

3. **Profile Edit**: Currently read-only
   - Users cannot edit profile from app
   - Changes must be made on MyCAMU portal

4. **Data Refresh**: Manual refresh only
   - Sync triggered by user action
   - No automatic background sync (can be added)

## Future Enhancements

1. **Auto-sync Timer**: Refresh profile daily
2. **Profile Edit**: Allow in-app profile updates
3. **Subject Breakdown**: Show per-subject attendance details
4. **Notifications**: Alert on low attendance
5. **Export Profile**: Share profile as PDF/image
6. **Profile Completion**: Show progress for complete profile

## Troubleshooting

### Profile button not showing
```
Check: SharedPreferences key 'mycamu_logged_in'
Fix: Re-sync via Settings → Sync MyCamu
```

### Profile shows "No Profile Data"
```
Check: User data not saved in SharedPreferences
Fix: Open Settings, click "Sync MyCamu", complete login
```

### RoboEye data not appearing
```
Check: API endpoint configuration
Fix: Verify correct RoboEye API URL in user_service.dart
```

### Calendar dates showing incorrectly
```
Check: DateTime weekday calculation
Fix: Ensure system timezone is correct
```

## API Reference

### UserService Class

```dart
class UserService {
  // Save user data to local storage
  static Future<void> saveUserData(UserData userData)
  
  // Retrieve stored user data
  static Future<UserData?> getUserData()
  
  // Check authentication status
  static Future<bool> isLoggedIn()
  
  // Sign out user
  static Future<void> logout()
  
  // Fetch from RoboEye API
  static Future<UserData?> fetchFromRoboEye(String rollNumber)
}
```

### UserData Model

```dart
class UserData {
  final String name;
  final String rollNumber;
  final String branch;
  final String? year;
  final String? section;
  final int? dayStreak;
  final double? gpa;
  
  // Generates initials from name (e.g., "AR" for "Aarav Rao")
  String get initials
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson()
  
  // Create from JSON
  factory UserData.fromJson(Map<String, dynamic> json)
}
```

## Support

For issues or questions:
1. Check logs: `flutter logs`
2. Verify MyCAMU HTML hasn't changed
3. Test JavaScript extraction in browser console
4. Check SharedPreferences debug output

# Quick Start: Profile Integration

## ⚡ 5-Minute Setup

### 1️⃣ Build & Run
```bash
cd ClassNow-app
flutter pub get
flutter run
```

### 2️⃣ Test Profile Feature
1. Open **Settings** → Scroll to **Schedule**
2. Tap **"Sync MyCamu"**
3. Log in with your MyCAMU credentials
4. Navigate to **Attendance** section (app auto-guides you)
5. Wait for data extraction (2-30 seconds)
6. App auto-closes when done

### 3️⃣ View Your Profile
1. Back on Dashboard
2. Look for **👤 icon** in header (new!)
3. Tap it
4. See your real student data!

---

## 🎯 What You'll See

### Before Sync
```
Dashboard Header
┌─────────────────────────┐
│ 🔒 (no profile button)  │
│ Class Now  ⚙️           │
└─────────────────────────┘
```

### After Sync
```
Dashboard Header
┌─────────────────────────┐
│ 🔒 👤 (profile button)  │
│ Class Now  ⚙️           │
└─────────────────────────┘
    ↓ tap 👤
    
Profile Page Shows:
├─ Avatar with initials (AR, JD, etc)
├─ Your name (from MyCAMU)
├─ Roll number (22CSA117)
├─ Branch (CSE AI, etc)
├─ Day Streak: 18
├─ Attendance: 87%
├─ GPA: 8.5
└─ Sign Out button
```

---

## 📋 File Changes Summary

### New Files (2 files)
```
✅ lib/services/user_service.dart      (User data management)
✅ lib/screens/profile_page.dart       (Profile display)
```

### Modified Files (3 files)
```
✏️  lib/dashboard_page.dart            (Profile button + dates)
✏️  lib/screens/mycamu_sync_screen.dart (Data extraction)
✏️  lib/settings_page.dart              (Import user service)
```

---

## 🔍 Key Components

### UserService
Handles all profile data:
```dart
// Save after MyCAMU sync
await UserService.saveUserData(userData);

// Check if logged in
bool logged = await UserService.isLoggedIn();

// Get stored profile
UserData? user = await UserService.getUserData();

// Sign out
await UserService.logout();
```

### ProfilePage
Beautiful profile display:
- Gradient avatar with initials
- Real student information
- Statistics cards
- Academic details
- Sign out functionality

### Enhanced Day Selector
Better calendar view:
```
MON        TUE        WED
 20         21         22
```

---

## ✨ Features

✅ **Real Profile Data** - From MyCAMU (not fake names)
✅ **Profile Button** - Shows only when logged in
✅ **Beautiful Design** - Glass morphism, gradients
✅ **Data Persistence** - Saved locally
✅ **Easy Logout** - With confirmation
✅ **Better Dates** - Shows day + date number
✅ **Type Safe** - Full Dart type hints
✅ **Error Handling** - Graceful fallbacks

---

## 🧪 Quick Tests

### Test 1: MyCAMU Login
```
✓ Settings → Sync MyCamu
✓ See status updates
✓ Data extracted successfully
✓ Auto-closes after sync
```

### Test 2: Profile Button
```
✓ Appears after sync
✓ Tappable
✓ Opens profile page
✓ Shows real data
```

### Test 3: Logout
```
✓ Logout button on profile
✓ Confirmation dialog shown
✓ Data cleared
✓ Profile button disappears
```

### Test 4: Date Formatting
```
✓ Day selector shows MON 20, TUE 21, etc
✓ Dates update correctly
✓ Selection works
✓ No date errors
```

---

## 🐛 Common Issues

### Profile button doesn't appear
**Solution**: Re-sync via Settings → Sync MyCamu

### Profile shows "No Profile Data"
**Solution**: Complete full MyCAMU login, navigate to Attendance

### Dates look wrong
**Solution**: Check system date/timezone

### Data lost after logout
**Expected behavior**: Logout clears all profile data

---

## 📚 Documentation

For detailed info, see:
- `PROFILE_INTEGRATION_GUIDE.md` - Full API reference
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `BEFORE_AFTER_GUIDE.md` - Visual comparisons

---

## 🚀 Next Steps

1. **Test locally** - Verify all features work
2. **Deploy** - Build and release to users
3. **Monitor** - Check logs for issues
4. **Enhance** - Consider future improvements:
   - Auto-sync daily
   - Profile editing
   - Subject breakdown
   - Low attendance alerts

---

## 💾 Data Storage

Your profile is stored **locally only**:
```
SharedPreferences (on device):
├─ User profile JSON
├─ Login status
├─ Attendance data
└─ Last sync timestamp
```

**Privacy**: Data never leaves your device (except MyCAMU login)

---

## 🎓 Architecture

```
UserService (Data Layer)
    ↓
ProfilePage (Presentation)
    ↓
Dashboard (Navigation)
    ↓
MyCAMU Sync (Data Input)
```

Clean separation = Easy to maintain & test

---

## 📞 Support

If something breaks:
1. Check `flutter logs`
2. Verify MyCAMU HTML unchanged
3. Test JavaScript in browser console
4. Review guides above

---

**Ready to go!** 🚀

Run `flutter run` and test out your new profile feature!

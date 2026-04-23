# Local Setup Guide - Firebase & API Keys

## ⚠️ Important Security Note
The following files are **intentionally NOT on GitHub** for security:
- `.env` - Contains API keys
- `google-services.json` - Firebase Android config
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS config

You must create these locally for the app to work.

---

## Step 1: Setup Gemini API Key 🤖

### Get your API Key:
1. Go to https://aistudio.google.com/app/apikey
2. Click "Create API Key in new project"
3. Copy the generated key

### Create `.env` file:
In your project root directory, create a file named `.env`:

```env
GEMINI_API_KEY=paste_your_key_here
```

**Example:**
```env
GEMINI_API_KEY=AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 2: Setup Firebase 🔥

### For Android:

1. Go to https://console.firebase.google.com
2. Select or create your "ClassNow" project
3. Add Android app:
   - Package name: `com.example.flutter_firebase_test`
   - Debug signing certificate SHA-1: Get from:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### For iOS:

1. In Firebase Console, add iOS app:
   - Bundle ID: `com.example.flutterFirebaseTest`

2. Download `GoogleService-Info.plist`
3. Place it in: `ios/Runner/GoogleService-Info.plist`
4. Add to Xcode:
   - Open `ios/Runner.xcworkspace`
   - Drag `GoogleService-Info.plist` into Xcode

---

## Step 3: Verify Setup ✅

### Test Gemini API:
```bash
flutter pub get
flutter run
# Try using the AI chatbot feature
```

### Test Firebase:
```bash
# Should connect without errors
flutter run
```

---

## Troubleshooting 🔧

### `.env` file not loading?
```dart
// The app loads from:
await dotenv.load(fileName: "assets/.env");  // First try
await dotenv.load(fileName: ".env");         // Then fallback
```

### Firebase not connecting?
- Check `google-services.json` is in correct location
- Verify Firebase project ID in console
- Check internet connection

### API key rejected?
- Make sure key has Generative Language API enabled
- Check key hasn't exceeded quota
- Verify correct key copied (no extra spaces)

---

## File Checklist

```
✅ .env                              (CREATE LOCALLY - API KEY)
✅ google-services.json              (DOWNLOAD FROM FIREBASE - ANDROID)
✅ ios/Runner/GoogleService-Info.plist (DOWNLOAD FROM FIREBASE - iOS)
✅ .firebaserc                       (ALREADY IN GITHUB)
✅ firebase.json                     (ALREADY IN GITHUB)
✅ pubspec.yaml                      (ALREADY IN GITHUB)
```

---

## Security Best Practices ⚠️

1. **Never commit .env to Git**
   - It's in `.gitignore` ✅

2. **Don't share API keys**
   - Keep `.env` private
   - Don't screenshot/paste keys

3. **Rotate keys regularly**
   - If compromised, regenerate immediately
   - In Google Cloud Console: Disable + create new

4. **Use environment-specific keys**
   - Dev, staging, production keys should be different
   - Create separate Firebase projects if needed

---

## Questions?

See other documentation:
- `QUICK_START.md` - Getting started
- `DEVELOPMENT_NOTES.md` - Development setup
- `README.md` - Project overview

**Last Updated:** 2026-04-23
**Status:** Ready for local setup

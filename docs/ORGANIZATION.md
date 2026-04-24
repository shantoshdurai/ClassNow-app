# Project Organization Guide

## Directory Structure

```
ClassNow-app/
├── docs/                          # 📚 Documentation & Guides
│   ├── BEFORE_AFTER_GUIDE.md     # Before/after comparison
│   ├── CONTRIBUTING.md            # Contribution guidelines
│   ├── DEVELOPMENT_NOTES.md       # Development notes
│   ├── FIXES_APPLIED.md           # Applied fixes log
│   ├── IMPLEMENTATION_CHECKLIST.md # Implementation checklist
│   ├── IMPLEMENTATION_SUMMARY.md   # Implementation summary
│   ├── PROFILE_INTEGRATION_GUIDE.md # Profile integration docs
│   ├── QUICK_START.md             # Quick start guide
│   ├── README_CHANGES.md          # Changes to README
│   ├── ROBOTEYE-IMPLEMENTATION.md # RobotEye implementation
│   └── push.md                    # CI failure debugging guide
│
├── android/                        # 🤖 Android app files
├── ios/                           # 🍎 iOS app files
├── lib/                           # 📦 Main Dart/Flutter code
├── test/                          # ✅ Test files
├── web/                           # 🌐 Web version
├── linux/                         # 🐧 Linux version
├── macos/                         # macOS version
│
├── .github/workflows/             # ⚙️ GitHub Actions CI/CD
│   ├── code-quality.yml
│   └── flutter-ci.yml
│
├── assets/                        # 🎨 Images, logos, etc.
├── functions/                     # ☁️ Firebase Functions
│
├── Configuration Files
│   ├── pubspec.yaml              # Flutter dependencies
│   ├── pubspec.lock              # Locked dependency versions
│   ├── analysis_options.yaml      # Dart analyzer rules
│   ├── firebase.json              # Firebase config
│   ├── .firebaserc                # Firebase CLI config
│   ├── devtools_options.yaml      # DevTools config
│   ├── flutter_launcher_icons.yaml # App icon config
│   └── .gitignore                 # Git ignore rules
│
├── Root Documentation
│   ├── README.md                  # Project overview
│   ├── CONTRIBUTING.md            # (in docs/)
│   ├── firestore.rules            # Firestore security rules
│   └── new.sh                      # Setup script
│
└── Other
    ├── .metadata                  # Flutter project metadata
    ├── devtools_options.yaml      # DevTools options
    └── .flutter-plugins           # Flutter plugins
```

## File Categories

### 📚 Documentation (`docs/` folder)
All markdown guides and documentation files for developers:
- Getting started guides
- Implementation documentation
- Architecture notes
- Contributing guidelines
- Changes and fixes logs

### 🔧 Configuration Files (root level)
- `pubspec.yaml` - Flutter package dependencies
- `analysis_options.yaml` - Dart analyzer linting rules
- `firebase.json` - Firebase project configuration
- `.firebaserc` - Firebase CLI configuration
- `devtools_options.yaml` - DevTools settings

### 💻 Source Code
- `lib/` - Main Dart/Flutter application code
- `test/` - Unit and integration tests
- `android/`, `ios/`, `web/`, `linux/`, `macos/` - Platform-specific code
- `functions/` - Firebase Cloud Functions

### ⚙️ Build & Automation
- `.github/workflows/` - GitHub Actions CI/CD pipelines
- `new.sh` - Project setup script

### 🎨 Assets
- `assets/` - Images, logos, and other static resources
- `screenshots/` - App screenshots for documentation

## Best Practices

1. **Keep docs/ organized** - New documentation goes in `docs/` folder
2. **Configuration at root** - Keep essential config files at root level
3. **Consistent naming** - Use PascalCase for markdown files
4. **Update this guide** - When adding new major sections

## Related Documentation

- See `docs/QUICK_START.md` for getting started
- See `docs/DEVELOPMENT_NOTES.md` for development info
- See `docs/push.md` for CI debugging guide

---

**Last Updated:** 2026-04-22
**Organization Status:** ✅ Organized

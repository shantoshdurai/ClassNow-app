# ClassNow-App Documentation Index

Welcome to ClassNow documentation. All guides and references are organized below.

## 📋 Getting Started
- **[QUICK_START.md](QUICK_START.md)** - Quick setup and first run
- **[SETUP_LOCAL.md](SETUP_LOCAL.md)** - Local development environment setup
- **[README.md](../README.md)** - Project overview (at root level)

## 🔧 Development & Configuration
- **[DEVELOPMENT_NOTES.md](DEVELOPMENT_NOTES.md)** - Development tips and architecture notes
- **[ORGANIZATION.md](ORGANIZATION.md)** - Project file structure and organization

## 🐛 Bug Fixes & Issues
- **[FIXES_APPLIED.md](FIXES_APPLIED.md)** - All build and runtime fixes applied
  - Firebase initialization errors
  - .env file handling
  - CardTheme/CardThemeData type fixes
  - Design system issues
- **[push.md](push.md)** - CI/CD debugging journey and GitHub Actions fixes

## 📦 Implementation & Features
- **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Feature checklist
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation overview
- **[PROFILE_INTEGRATION_GUIDE.md](PROFILE_INTEGRATION_GUIDE.md)** - User profile integration
- **[ROBOTEYE-IMPLEMENTATION.md](ROBOTEYE-IMPLEMENTATION.md)** - Robot eyes feature implementation

## 🎨 Design & UI
- **[BEFORE_AFTER_GUIDE.md](BEFORE_AFTER_GUIDE.md)** - UI redesign before/after comparison
- **[README_CHANGES.md](README_CHANGES.md)** - UI and feature changes log

## 🧹 Project Maintenance
- **[CLEANUP.md](CLEANUP.md)** - Repository cleanup and commit optimization
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

---

## 📂 Project Structure

```
ClassNow-app/
├── docs/              # All documentation (this folder)
├── config/            # Configuration files
│   ├── analysis_options.yaml
│   ├── firebase.json
│   ├── firestore.rules
│   ├── flutter_launcher_icons.yaml
│   └── devtools_options.yaml
├── scripts/           # Utility scripts
│   └── new.sh
├── lib/               # Dart/Flutter source code
├── android/           # Android native code
├── ios/               # iOS native code
├── web/               # Web platform code
├── test/              # Unit and widget tests
├── assets/            # Images, fonts, and static assets
├── functions/         # Firebase Cloud Functions
├── pubspec.yaml       # Flutter dependencies
└── .env.example       # Environment variables template
```

## 🚀 Common Tasks

**Starting development?** → Start with [SETUP_LOCAL.md](SETUP_LOCAL.md)

**Building the app?** → See [QUICK_START.md](QUICK_START.md)

**Hit a build error?** → Check [FIXES_APPLIED.md](FIXES_APPLIED.md)

**CI/CD issues?** → Review [push.md](push.md)

**Need to contribute?** → Read [CONTRIBUTING.md](CONTRIBUTING.md)

---

> Last updated: April 23, 2026
> All documentation moved to `docs/` folder for better organization

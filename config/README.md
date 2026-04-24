# Configuration Files

This folder contains all project configuration files.

## Files

- **analysis_options.yaml** - Dart analyzer and linter configuration for code quality checks
- **firebase.json** - Firebase project configuration for deployment
- **firestore.rules** - Firestore security rules for database access control
- **flutter_launcher_icons.yaml** - App icon configuration for all platforms
- **devtools_options.yaml** - Dart DevTools configuration

## Notes

These files are loaded automatically by their respective tools:
- Flutter loads `analysis_options.yaml` during build
- Firebase CLI uses `firebase.json` for deployments
- Flutter uses `flutter_launcher_icons.yaml` to generate app icons
- DevTools uses `devtools_options.yaml` for debugging configuration

**Don't delete these files** or the build system may fail.

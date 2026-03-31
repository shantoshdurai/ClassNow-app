<h1 align="center">ClassNow</h1>

<p align="center">
  <b>AI-powered university class management app</b><br/>
  Built with Flutter · Firebase · Gemini API
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Gemini-AI-4285F4?style=for-the-badge&logo=google&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
</p>

<p align="center">
  <img src="lib/screens/github_images/features%20of%20the%20app.png" width="22%" />
  <img src="lib/screens/github_images/AI%20Chat.png" width="22%" />
  <img src="lib/screens/github_images/great%20customization.png" width="22%" />
  <img src="lib/screens/github_images/mentors%20section.png" width="22%" />
</p>

---

## What is ClassNow?

ClassNow is a full-stack Flutter application that solves a real problem for university students — never missing a class or losing track of schedules. It combines real-time Firebase sync, a Gemini-powered AI chatbot, home screen widgets, and a mentor portal into one polished app.

Built and actively used at **Dhanalakshmi Srinivasan University, Trichy** with real student timetable data for 500+ students.

---

## Features

| Feature | Description |
|---|---|
| **Smart Dashboard** | Auto-highlights your current and next class in real time |
| **AI Chatbot** | Ask "Where is my next class?" and get an instant, section-aware answer powered by Gemini API |
| **Home Screen Widgets** | Native Android widgets to check your schedule without opening the app |
| **Intelligent Notifications** | Customizable class reminders with background scheduling via WorkManager |
| **Offline-First** | Full Firestore offline persistence — works without internet after initial sync |
| **Mentor Portal** | Separate login for mentors to manage and broadcast timetable updates |
| **MyCamu Sync** | One-tap onboarding that syncs student section and year data |
| **OLED Dark Mode** | True black UI for battery efficiency on AMOLED displays |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **Backend** | Firebase (Firestore, Auth, Cloud Functions) |
| **AI/ML** | Google Gemini API via `google_generative_ai` |
| **State Management** | Provider |
| **Notifications** | `flutter_local_notifications` + `android_alarm_manager_plus` + `workmanager` |
| **Widgets** | `home_widget` (native Android home screen widgets) |
| **Networking** | `connectivity_plus` for online/offline detection |
| **CI/CD** | GitHub Actions (build, test, lint, format) |

---

## Architecture

```
lib/
├── main.dart                  # App entry point, Firebase init, theme setup
├── screens/                   # UI screens (onboarding, sync, privacy, etc.)
├── services/
│   ├── gemini_service.dart        # Gemini API integration
│   ├── chatbot_context_builder.dart # Dynamic prompt engineering with live timetable data
│   ├── seed_data.dart             # Firestore data seeding
│   └── diagnose_firestore.dart    # Debug utility for Firestore state
├── providers/                 # State management (user selection, preferences)
├── widgets/
│   ├── chatbot_interface.dart     # Full chat UI with markdown rendering
│   ├── glass_widgets.dart         # Glassmorphism UI components
│   ├── skeleton_loader.dart       # Shimmer loading states
│   └── class_selection_widget.dart
├── notification_service.dart  # Local notification scheduling engine
├── widget_service.dart        # Home screen widget data bridge
└── theme_provider.dart        # Dynamic theming (light/dark/OLED)
```

---

## How the AI Chatbot Works

The chatbot is the most technically complex feature. Here's the pipeline:

1. **Context Building** (`chatbot_context_builder.dart`) — Dynamically constructs a prompt that includes the student's section, current day/time, full timetable, and campus knowledge base.
2. **Gemini Integration** (`gemini_service.dart`) — Sends the assembled context + user query to Google's Gemini API.
3. **Response Rendering** (`chatbot_interface.dart`) — Displays AI responses with full Markdown support (bold, lists, code blocks).

The chatbot is **section-aware** (A1–A5 & B1–B5), **time-aware** (knows what "next class" means relative to now), and includes **campus-specific knowledge** (hostel locations, cafes, blocks).

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.10.7`
- Firebase project with Firestore and Auth enabled
- Google Gemini API key

### Setup

```bash
git clone https://github.com/shantoshdurai/Timewise-app.git
cd flutter_firebase_test
flutter pub get
```

1. Place your `google-services.json` in `android/app/`
2. Create a `.env` file in the project root with your Gemini API key:
   ```
   GEMINI_API_KEY=your_key_here
   ```
3. Run:
   ```bash
   flutter run
   ```

---

## CI/CD

The project includes automated GitHub Actions workflows:

- **Flutter CI** — Builds the APK, runs tests, checks formatting and static analysis on every push/PR
- **Code Quality** — Runs `dart analyze` with strict rules
- **Stale Bot** — Automatically manages stale issues and PRs

---

## Database Schema

Firestore is structured for multi-year, multi-section scalability:

```
timetable/
└── {year}/
    └── {section}/
        └── {day}/
            └── periods: [{ subject, time, room, faculty }]
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Widgets not updating | Enable Autostart and disable Battery Optimization for the app |
| Crash on launch | Verify `google-services.json` is in `android/app/` |
| Chatbot not responding | Check that your Gemini API key is valid in `.env` |

---

## Scan to Download

<p align="center">
  <img src="lib/screens/github_images/app%20qr%20code.png" width="180"/>
</p>

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Built By

**Santosh Durai** — CS Student at DSU, Tamil Nadu
[GitHub](https://github.com/shantoshdurai) · [LinkedIn](https://linkedin.com/in/shantoshdurai)

---

## License

MIT License — free to use and contribute.

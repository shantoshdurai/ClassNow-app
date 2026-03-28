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

Built and actively used at DSU (Dayananda Sagar University) with real student timetable data.

---

## Features

- **Smart Dashboard** — auto-highlights your current and next class in real time
- **AI Chatbot** — ask "Where is my next class?" and get an instant, context-aware answer powered by Gemini API
- **Home Screen Widgets** — check your schedule without opening the app
- **Push Notifications** — customizable alerts before each class starts
- **Mentor Portal** — separate login for mentors to manage and broadcast timetable updates
- **Offline-First** — works without internet using local caching
- **OLED Dark Mode** — true black UI for battery efficiency

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Firebase Firestore, Firebase Auth |
| AI | Google Gemini API |
| Notifications | Firebase Cloud Messaging |
| State Management | Provider |
| CI/CD | GitHub Actions |
| Platform | Android, iOS |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Firebase project with Firestore and Auth enabled
- Gemini API key

### Setup

```bash
git clone https://github.com/shantoshdurai/ClassNow-app.git
cd ClassNow-app
flutter pub get
```

Add your `google-services.json` to `android/app/` and configure your Gemini API key.

```bash
flutter run
```

---

## Project Structure

```
lib/
├── screens/       # All UI screens
├── services/      # Firebase, Gemini API, notification logic
├── widgets/       # Reusable UI components & home screen widgets
├── providers/     # State management
└── main.dart      # Entry point
```

---

## Scan to Download

<p align="center">
  <img src="lib/screens/github_images/app%20qr%20code.png" width="180"/>
</p>

---

## Built By

**Santosh Durai** — CS Student at DSU, Tamil Nadu
[GitHub](https://github.com/shantoshdurai) · [LinkedIn](https://linkedin.com/in/shantoshdurai)

---

## License

MIT License — free to use and contribute.

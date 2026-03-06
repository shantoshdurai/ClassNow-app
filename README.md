# Class Now 📱

**The Smart Timetable Assistant.**

An offline-first Flutter app that keeps you synchronized with your academic schedule. Featuring intelligent notifications, AI-powered queries, and beautiful home screen widgets.

## 🚀 Latest Updates (March 2026)
- **📅 Timetable 24-25 Live**: Successfully migrated and imported the complete timetable for all sections (A1-A5 & B1-B5) into the 2024 academic year.
- **🤖 Chatbot Intelligence**: Upgraded the DSU AI Assistant with **chronological sorting** for "Next Class" queries and **Section Awareness** to provide personalized schedule info.
- **🛠️ Firebase Tooling**: Integrated a direct-to-cloud upload system (`tool/direct_upload.py`) for lightning-fast database updates bypassing the emulator.
- **🧹 Database Optimization**: Cleaned up duplicate "2nd-year" records and standardized the Firestore hierarchy for future scalability.

## ✨ Features
- **Smart Dashboard:** Automatically highlights current and next class.
- **Interactive Widgets:** Check your schedule directly from the home screen.
- **Timely Alerts:** Customizable notifications before every class.
- **AI Chatbot:** Ask "Where is my next class?" and get instant answers.
- **OLED Dark Mode:** Battery-saving true black interface.


## 📸 Gallery

<p align="center">
  <img src="lib/screens/github_images/features%20of%20the%20app.png" width="22%" />
  <img src="lib/screens/github_images/Ai%20Chat.png" width="22%" />
  <img src="lib/screens/github_images/great%20customization.png" width="22%" />
  <img src="lib/screens/github_images/mentors%20section.png" width="22%" />
</p>

<p align="center">
  <b>Scan to Download</b><br>
  <img src="lib/screens/github_images/app%20qr%20code.png" width="200" />
</p>

## 📂 Project Structure

- **lib/screens/**: Contains all the UI screens like Onboarding, Sync, etc.
- **lib/services/**: Backend logic and helper functions.
- **lib/widgets/**: Reusable UI components.
- **lib/providers/**: State management classes.
- **lib/main.dart**: Application entry point.

## 🚀 Quick Start
1.  **Clone Repo**:
    ```bash
    git clone https://github.com/shantoshdurai/Timewise-app.git
    cd flutter_firebase_test
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**: Place your `google-services.json` in `android/app/`.

4.  **Run**:
    ```bash
    flutter run
    ```

## 🛠️ Troubleshooting
- **Widgets not updating?** Enable Autostart and remove Battery Restrictions.
- **Crash on launch?** Verify `google-services.json` is present.

## 🤝 Contributing
Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) to get started.


## 🏆 Achievements

- Built with Flutter & Firebase
- AI-powered chatbot using Gemini API
- Supports 2024 academic timetable for DSU
- Available for Android & iOS

## 📄 License

MIT License — feel free to use and contribute!

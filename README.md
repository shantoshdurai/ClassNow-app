# ⏰ Timewise - Premium Class Timetable App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

**A high-performance timetable management app with advanced glassmorphism aesthetics**

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Usage](#-usage)

</div>

---

## ✨ Features

### 🎨 **Modern Glassmorphism UI**
- **Frosted Glass Effects** - High-fidelity blur and depth-based UI components.
- **Dynamic Color System** - Curated vibrant palette designed for maximum legibility in both light and dark modes.
- **True OLED Black Theme** - Optimized for power saving and high contrast.
- **Interactive Micro-animations** - Fluid transitions and real-time visual feedback for all user actions.
- **High-Density Layouts** - Precise spacing and modern typography for a premium feel.

### 📅 **Intelligent Scheduling**
- **Live Tracking** - Real-time categorization into current, upcoming, and completed sessions.
- **Progress Monitoring** - High-resolution visual progress indicators for active classes.
- **Universal Pull-to-Refresh** - Seamless synchronization gesture that works across all schedule states, including empty lists.
- **Offline Reliability** - Persistent local caching ensures access to timetable data even without connectivity.

### 🏠 **High-Fidelity Home Screen Widgets**
- **High-Resolution Rendering** - Widgets are drawn at double logical resolution (up to 800x400) for edge-to-edge sharpness.
- **Ambient Glass Design** - Transparent frosted backgrounds that blend natively with any device wallpaper.
- **Visual Sync Confirmation** - Interactive refresh logic where the sync icon rotates 90° on every successful update.
- **Silent Background Logic** - Fail-safe background updates that maintain data integrity without surface-level error disruptions.

### 🔔 **Precision Notification System**
- **Predictive Alerts** - Get notified exactly 5, 10, 15, or 30 minutes before class starts.
- **Smart Filtering** - Granular control over notification triggers based on subject or availability.
- **Lead-Time Optimization** - Notifications are intelligently scheduled to ensure reminders arrive before the session begins.
- **Notification Diagnostics** - Integrated testing suite to verify system-level notification permissions.

### 👨‍🏫 **Multi-Role Infrastructure**
- **Student Ecosystem** - Streamlined, distraction-free view for quick schedule checks.
- **Mentor Control Panel** - Complete administration suite for managing schedules, Saturday setups, and announcements.
- **Anonymous Authentication** - Frictionless onboarding for students using Firebase Anonymous Auth.
- **Secure Mentor Portal** - Robust email/password authentication for administrative operations.

### 🤖 **Robot Eyes Integration**
- **Emotional AI Rendering** - Dynamic mood system (Happy, Focused, Waiting) reflected in both the app and widgets.
- **Hardware Sync** - Integration capabilities with Arduino-powered displays via Firebase Cloud Functions.

---

## 🛠️ Tech Stack

### **Core Framework**
- **Flutter 3.x** - High-performance cross-platform development.
- **Dart 3.x** - Optimized, type-safe application logic.
- **Material Design 3** - Implementing the latest design language standards.

### **Backend Architecture**
- **Firebase Firestore** - Real-time NoSQL data synchronization.
- **Firebase Auth** - Multi-provider authentication management.
- **Cloud Functions** - Serverless logic for hardware integration and background processing.

### **Advanced Functionality**
- **android_alarm_manager_plus** - Precise background task scheduling using system-level alarms.
- **Home Widget** - Native Android/iOS widget bridge with custom Flutter rendering.
- **Workmanager** - Reliable background synchronization and cache maintenance.
- **Flutter Local Notifications** - High-priority scheduling for time-sensitive alerts.

---

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase Project Reference
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/shantoshdurai/Timewise-app.git
   cd Timewise-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Place your `google-services.json` in `android/app/`.
   - Enable **Anonymous** and **Email/Password** providers in Firebase Console.
   - Deploy Firestore rules for `departments`, `years`, and `sections`.

4. **Run Development Mode**
   ```bash
   flutter run
   ```

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                      # Core app initialization
├── app_theme.dart                 # Design system & color tokens
├── notification_service.dart      # Precision scheduling engine
├── widget_service.dart            # High-res widget rendering logic
├── static_widget.dart             # Widget UI components
├── onboarding_screen.dart         # Dynamic selection workflows
└── subject_utils.dart             # Semantic icon mapping engine
```

---

## 🎨 Design Principles
- **Clarity over Complexity**: Using depth and blur to prioritize information.
- **Feedback Loops**: Constant visual confirmation for every background and foreground process.
- **Performance First**: Efficient rendering of glassmorphism effects and background sync logic.

---

## 📄 License

Licensed under the MIT License - see the [LICENSE](LICENSE) for details.

---

## 📞 Contact & Support

- **Developer:** Shantosh Durai
- **GitHub:** [@shantoshdurai](https://github.com/shantoshdurai)
- **Repository:** [Timewise-app](https://github.com/shantoshdurai/Timewise-app)

<div align="center">

### Built for performance. Designed for students.

**Star ⭐ this repo if you support modern open-source education tools!**

</div>

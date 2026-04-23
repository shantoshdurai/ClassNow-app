import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:home_widget/home_widget.dart' hide callbackDispatcher;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter_firebase_test/firebase_options.dart';
import 'package:flutter_firebase_test/theme_provider.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/background_callbacks.dart';
import 'package:flutter_firebase_test/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase - MUST BE FIRST
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e, stack) {
    debugPrint("❌ Firebase initialization error: $e");
    debugPrint("Stack trace: $stack");
  }

  // 2. Dotenv - Silent fail
  try {
    // Explicitly check for .env in assets
    await dotenv.load(fileName: "assets/.env");
    debugPrint("✅ .env loaded from assets/.env");
  } catch (e) {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ .env loaded from .env");
    } catch (e2) {
      debugPrint("⚠️ Warning: .env file not found or load failed: $e2");
    }
  }

  // 3. HomeWidget Interactivity
  try {
    HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
  } catch (e) {
    debugPrint("⚠️ HomeWidget callback registration warning: $e");
  }

  // 4. Workmanager - Initialize but don't crash if native fails
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    // Cancel any stale tasks to prevent race conditions during boot
    await Workmanager().cancelByUniqueName("updateWidgetTask");
    print("✅ Workmanager initialized");
  } catch (e) {
    debugPrint("⚠️ Workmanager initialization warning: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserSelectionProvider()),
      ],
      child: const TimetableApp(),
    ),
  );
}

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Class Now',
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

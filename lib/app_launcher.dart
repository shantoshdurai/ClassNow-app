import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/screens/onboarding_screen.dart' as IntroFlow;
import 'package:flutter_firebase_test/onboarding_screen.dart';
import 'package:flutter_firebase_test/dashboard_page.dart';

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSelectionProvider>(
      builder: (context, userSelection, child) {
        // 1. Show User's Preferred Guide Screen if never shown
        if (!userSelection.isIntroShown) {
          return const IntroFlow.GuideScreen();
        }

        // 2. Then check for Class Selection
        if (userSelection.hasSelection) {
          return const DashboardPage();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

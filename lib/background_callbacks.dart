import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_firebase_test/firebase_options.dart';
import 'package:flutter_firebase_test/widget_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  // For Workmanager
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    try {
      await Firebase.initializeApp(options: PigeonFirebaseOptions.currentPlatform);
      await dotenv.load(fileName: ".env");
      await WidgetService.updateWidget(forceRefresh: true);
    } catch (e) {
      print("Background task failed: $e");
    }
    return Future.value(true);
  });
}

// Separate callback for home_widget background clicks
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  print("HomeWidget background click: $uri");
  if (uri?.host == 'update' || uri?.path == '/update') {
    try {
      await Firebase.initializeApp(options: PigeonFirebaseOptions.currentPlatform);
      await dotenv.load(fileName: ".env");
      await WidgetService.updateWidget(
        forceRefresh: true,
      ); // Added forceRefresh: true
    } catch (e) {
      print("HomeWidget background update failed: $e");
    }
  }
}

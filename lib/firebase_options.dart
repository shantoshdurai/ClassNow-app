import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured. Use FlutterFire CLI.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured. Use FlutterFire CLI.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not configured. Use FlutterFire CLI.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1-EdouHHKdVb9PsgoX4vwM_HHvW3Won0',
    appId: '1:67687510848:android:a559c193f49651800d40a5',
    messagingSenderId: '67687510848',
    projectId: 'studio-4155999944-16272',
    storageBucket: 'studio-4155999944-16272.firebasestorage.app',
  );
}

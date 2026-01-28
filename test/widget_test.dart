import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_test/main.dart';

void main() {
  testWidgets('TimetableApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: TimetableApp requires Firebase initialization in main() which is hard to mock here.
    // This is just a placeholder to resolve compilation errors.
    await tester.pumpWidget(const TimetableApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

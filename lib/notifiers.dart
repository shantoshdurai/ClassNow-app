import 'package:flutter/material.dart';

// Global ValueNotifier for retro display setting
final retroDisplayEnabledNotifier = ValueNotifier<bool>(false);
// Global Notifier to trigger attendance card refresh
final attendanceUpdateNotifier = ValueNotifier<int>(0);

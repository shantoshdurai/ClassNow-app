import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSelectionProvider extends ChangeNotifier {
  String? _departmentId;
  String? _yearId;
  String? _sectionId;
  bool _introShown = false;

  String? get departmentId => _departmentId;
  String? get yearId => _yearId;
  String? get sectionId => _sectionId;
  bool get isIntroShown => _introShown;

  bool get hasSelection =>
      _departmentId != null && _yearId != null && _sectionId != null;

  UserSelectionProvider() {
    loadSelection();
  }

  Future<void> loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    _departmentId = prefs.getString('departmentId');
    _yearId = prefs.getString('yearId');
    _sectionId = prefs.getString('sectionId');
    _introShown = prefs.getBool('intro_shown') ?? false;
    notifyListeners();
  }

  Future<void> setIntroShown() async {
    _introShown = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_shown', true);
    notifyListeners();
  }

  Future<void> saveSelection({
    required String departmentId,
    required String yearId,
    required String sectionId,
  }) async {
    _departmentId = departmentId;
    _yearId = yearId;
    _sectionId = sectionId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('departmentId', departmentId);
    await prefs.setString('yearId', yearId);
    await prefs.setString('sectionId', sectionId);

    notifyListeners();
  }

  Future<void> clearSelection() async {
    _departmentId = null;
    _yearId = null;
    _sectionId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('departmentId');
    await prefs.remove('yearId');
    await prefs.remove('sectionId');

    notifyListeners();
  }
}

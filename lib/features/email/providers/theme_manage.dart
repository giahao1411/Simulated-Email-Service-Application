import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManage with ChangeNotifier {
  ThemeManage() {
    _loadPreferencesDarkMode();
  }
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadPreferencesDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }
}

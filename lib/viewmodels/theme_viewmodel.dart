// lib/viewmodels/theme_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _darkModeKey = 'isDarkMode';
  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  // Constructor
  ThemeViewModel() : _isDarkMode = true {
    _loadThemePreference();
  }

  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? true; // Default to dark mode
      notifyListeners();
    } catch (e) {
      // Fallback to default if prefs can't be loaded
      _isDarkMode = true;
      print('Error loading theme preference: $e');
    }
  }

  // Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
}
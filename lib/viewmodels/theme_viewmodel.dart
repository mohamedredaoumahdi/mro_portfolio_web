// lib/viewmodels/theme_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _darkModeKey = 'isDarkMode';
  bool _isDarkMode;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  // Constructor
  ThemeViewModel() 
      // Default to dark mode, but will be replaced by loadThemePreference
      : _isDarkMode = true {
    _initializeTheme();
  }

  // Initialize theme with preference or system setting
  Future<void> _initializeTheme() async {
    if (_isInitialized) return;
    
    try {
      // Get system theme preference as default
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool systemIsDark = brightness == Brightness.dark;
      
      // Try to load stored theme preference
      _prefs = await SharedPreferences.getInstance();
      
      // Check if theme setting exists, otherwise use system preference
      if (_prefs!.containsKey(_darkModeKey)) {
        _isDarkMode = _prefs!.getBool(_darkModeKey) ?? systemIsDark;
      } else {
        _isDarkMode = systemIsDark;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing theme: $e');
      // Continue with default theme (dark)
      _isDarkMode = true;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  // Ensure theme is initialized - can be called from outside
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeTheme();
    }
  }

  // Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      await _saveThemePreference();
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
  
  // Set specific theme mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      try {
        await _saveThemePreference();
      } catch (e) {
        print('Error saving theme preference: $e');
      }
    }
  }
  
  // Save current theme preference
  Future<void> _saveThemePreference() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      
      await _prefs!.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
      // Continue even if we couldn't save the preference
    }
  }
}
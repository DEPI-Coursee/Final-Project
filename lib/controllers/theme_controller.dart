import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  static const String _themeModeKey = 'theme_mode';
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  /// Load saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_themeModeKey);
      
      if (savedThemeIndex != null) {
        themeMode.value = ThemeMode.values[savedThemeIndex];
        print('🎨 Loaded saved theme: ${themeMode.value}');
      } else {
        // Default to dark mode if no saved preference
        themeMode.value = ThemeMode.dark;
        print('🎨 No saved theme found, using default: dark');
      }
    } catch (e) {
      print('❌ Error loading theme mode: $e');
      // Default to dark mode on error
      themeMode.value = ThemeMode.dark;
    }
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      print('🎨 Saved theme mode: $mode');
    } catch (e) {
      print('❌ Error saving theme mode: $e');
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _saveThemeMode(themeMode.value);
    print('🎨 Theme switched to: ${themeMode.value}');
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _saveThemeMode(mode);
    print('🎨 Theme set to: $mode');
  }

  /// Check if current theme is dark
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLightMode => themeMode.value == ThemeMode.light;
}


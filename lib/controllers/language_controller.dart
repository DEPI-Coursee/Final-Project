import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  final Rx<Locale> currentLocale = const Locale('en').obs;
  static const String _localeKey = 'app_locale';
  
  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        currentLocale.value = Locale(savedLocaleCode);
        Get.updateLocale(currentLocale.value);
        print('🌐 Loaded saved locale: ${currentLocale.value.languageCode}');
      } else {
        // Default to English if no saved preference
        currentLocale.value = const Locale('en');
        Get.updateLocale(currentLocale.value);
        print('🌐 No saved locale found, using default: en');
      }
    } catch (e) {
      print('❌ Error loading locale: $e');
      // Default to English on error
      currentLocale.value = const Locale('en');
      Get.updateLocale(currentLocale.value);
    }
  }

  /// Save locale to SharedPreferences
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      print('🌐 Saved locale: ${locale.languageCode}');
    } catch (e) {
      print('❌ Error saving locale: $e');
    }
  }

  /// Toggle between English and Arabic
  void toggleLanguage() {
    final newLocale = currentLocale.value.languageCode == 'ar' 
        ? const Locale('en') 
        : const Locale('ar');
    currentLocale.value = newLocale;
    Get.updateLocale(newLocale);//updates the language in the app
    _saveLocale(newLocale);//saves the language to the shared preferences
    print('🌐 Language switched to: ${newLocale.languageCode}');
  }

  /// Set language explicitly
  void setLanguage(String languageCode) {
    final newLocale = Locale(languageCode);
    currentLocale.value = newLocale;
    Get.updateLocale(newLocale);
    _saveLocale(newLocale);
    print('🌐 Language set to: $languageCode');
  }

  /// Check if current language is Arabic
  bool get isArabic => currentLocale.value.languageCode == 'ar';

  /// Check if current language is English
  bool get isEnglish => currentLocale.value.languageCode == 'en';
}


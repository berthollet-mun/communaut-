// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> currentTheme = ThemeMode.light.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');

      if (savedTheme == 'dark') {
        currentTheme.value = ThemeMode.dark;
        isDarkMode.value = true;
      } else if (savedTheme == 'light') {
        currentTheme.value = ThemeMode.light;
        isDarkMode.value = false;
      } else {
        // Utiliser le thème du système par défaut
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        isDarkMode.value = brightness == Brightness.dark;
        currentTheme.value = isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light;
      }
    } catch (e) {
      // En cas d'erreur, utiliser le thème light par défaut
      currentTheme.value = ThemeMode.light;
      isDarkMode.value = false;
    }
  }

  Future<void> switchTheme() async {
    isDarkMode.value = !isDarkMode.value;
    currentTheme.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

    await _saveThemePreference();
    Get.changeThemeMode(currentTheme.value);
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    currentTheme.value = themeMode;
    isDarkMode.value = themeMode == ThemeMode.dark;

    await _saveThemePreference();
    Get.changeThemeMode(themeMode);
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', isDarkMode.value ? 'dark' : 'light');
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  void useSystemTheme() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
    currentTheme.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

    // Sauvegarder la préférence
    _saveThemePreference();
    Get.changeThemeMode(currentTheme.value);
  }
}

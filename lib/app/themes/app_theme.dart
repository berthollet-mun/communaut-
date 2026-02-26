import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => lightThemeData;
  static ThemeData get darkTheme => darkThemeData;

  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3A0CA3);
  static const Color accentColor = Color(0xFF7209B7);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);

  // ✅ IMPORTANT: PAS DE COULEUR ICI
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyText1 = TextStyle(fontSize: 16);

  static const TextStyle bodyText2 = TextStyle(fontSize: 14);

  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 6,
    offset: Offset(0, 2),
  );

  static BorderRadius cardBorderRadius = BorderRadius.circular(12);
  static BorderRadius buttonBorderRadius = BorderRadius.circular(8);
}

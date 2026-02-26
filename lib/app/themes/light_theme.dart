// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,

  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF4361EE),
    secondary: const Color(0xFF7209B7),
    background: const Color(0xFFF8F9FA),
    surface: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
  ),

  primaryColor: const Color(0xFF4361EE),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  cardColor: Colors.white,

  textTheme: Typography.blackMountainView.apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  ),

  dividerTheme: const DividerThemeData(color: Colors.black12, thickness: 1),

  appBarTheme: const AppBarTheme(
    color: Colors.white,
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.black87),
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4361EE),
    foregroundColor: Colors.white,
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black26),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black26),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4361EE),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4361EE),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(8),
  ),
);

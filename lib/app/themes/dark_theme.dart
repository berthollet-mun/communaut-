// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,

  // Couleurs principales
  colorScheme: const ColorScheme.dark().copyWith(
    primary: Color(0xFF4895EF),
    secondary: Color(0xFF7209B7),

    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),

    // ✅ IMPORTANT pour lisibilité
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),

  primaryColor: const Color(0xFF4895EF),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),

  // ✅ Textes globaux (c’est ça qui “répare” beaucoup de choses)
  textTheme: Typography.whiteMountainView.apply(
    bodyColor: Colors.white70,
    displayColor: Colors.white,
  ),

  // ✅ Icônes globales
  iconTheme: const IconThemeData(color: Colors.white70),

  // ✅ Dividers visibles
  dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),

  // ✅ ListTiles (tes pages Préférences/Actions)
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white70,
    textColor: Colors.white70,
  ),

  appBarTheme: const AppBarTheme(
    color: Color(0xFF1E1E1E),
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4895EF),
    foregroundColor: Colors.white,
  ),

  // ✅ Input fields (bordures + remplissage)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2D2D2D),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF4895EF), width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.white38),
    labelStyle: const TextStyle(color: Colors.white70),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4895EF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4895EF),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(8),
  ),

  // ✅ Switch (pour éviter le track trop sombre)
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFFB388FF);
      return Colors.white54;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFFB388FF).withOpacity(0.35);
      }
      return Colors.white24;
    }),
  ),
);

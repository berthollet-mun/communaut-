// ignore_for_file: avoid_print

import 'package:community/app/initialization.dart';
import 'package:community/app/routes/app_pages.dart';
import 'package:community/app/routes/app_routes.dart';
import 'package:community/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // 1. Initialiser Flutter et préserver le splash natif
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Initialiser toutes les dépendances (ta logique existante)
  await AppInitialization.initialize();

  // 3. Lancer l'application Flutter
  runApp(const MyApp());

  // 4. Retirer le splash natif une fois que Flutter est prêt
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Community',
      debugShowCheckedModeBanner: false,

      // Thèmes
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Localisation
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),

      // Transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Configuration des logs
      enableLog: true,
      logWriterCallback: (text, {bool isError = false}) {
        if (isError) {
          print('🔴 GETX ERROR: $text');
        } else {
          print('🔵 GETX INFO: $text');
        }
      },

      // Désactiver le back gesture sur Android
      popGesture: false,
    );
  }
}

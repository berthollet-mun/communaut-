import 'package:community/controllers/auth_controller.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('🚀 Démarrage de l\'application...');

    // Attendre 1 seconde pour que tout soit prêt
    await Future.delayed(const Duration(seconds: 1));

    try {
      print('🔍 Vérification de l\'authentification...');
      final isLoggedIn = await _authController.checkAuth();
      print('🔍 Résultat: $isLoggedIn');

      if (isLoggedIn) {
        print('✅ Utilisateur connecté, chargement du profil...');
        final profileLoaded = await _authController.loadProfile();

        if (profileLoaded) {
          final communityController = Get.find<CommunityController>();
          final restored = await communityController.restoreCommunitySelection();

          if (restored) {
            print('✅ Communauté restaurée, direction Dashboard');
            Get.offAllNamed(AppRoutes.communityDashboard);
          } else {
            print('✅ Aucune communauté restaurée, direction Select');
            Get.offAllNamed(AppRoutes.communitySelect);
          }
        } else {
          print('❌ Profil non chargé, retour Welcome');
          Get.offAllNamed(AppRoutes.welcome);
        }
      } else {
        print('👤 Utilisateur non connecté, redirection vers WelcomePage...');
        Get.offAllNamed(AppRoutes.welcome);
      }
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
      // En cas d'erreur, aller à la page d'accueil
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'MarPro+',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gestion collaborative de projets',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Initialisation...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
